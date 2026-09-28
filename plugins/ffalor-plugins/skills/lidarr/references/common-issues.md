# Lidarr Common Issues

Extracted verbatim from the upstream clawarr-suite reference (checklist condensed).

## Import Issues

### "No files eligible for import"

**Symptoms:**
- Download completes successfully
- Radarr/Sonarr can't see files
- Queue shows "No files found eligible for import"

**Causes & Solutions:**

#### 1. Stale Docker Mounts
**Cause:** Container started before host volumes mounted (common after host reboot)

**Diagnosis:**
```bash
# Check container vs host uptime
docker inspect radarr | grep StartedAt
uptime  # Compare
```

**Fix:**
```bash
docker restart radarr sonarr lidarr
```

Container was holding reference to old (empty) mount point. Restart picks up current mounts.

#### 2. Path Mapping Mismatch
**Cause:** Download client reports different path than Radarr expects

**Example scenario:**
- Download client reports: `/data/torrents/complete/MovieName/`
- Radarr expects: `/downloads/complete/MovieName/`

**Diagnosis:**
```bash
# Check what download client reports
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq

# Check queue for actual path
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/queue | jq '.records[].outputPath'
```

**Fix:** Settings → Download Clients → Remote Path Mappings
- Add mapping:
  - Remote Path: `/data/torrents/`
  - Local Path: `/downloads/`

#### 3. Wrong Category/Directory
**Cause:** Download client put file in unexpected location

**Diagnosis:**
```bash
# Check download client category config
# In qBittorrent: Tools → Options → Downloads → Category

# Check what Radarr expects
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq
```

**Fix:**
- Ensure download client category matches Radarr configuration
- Or update Radarr's download client category setting

#### 4. Permissions
**Cause:** Radarr user can't read download directory

**Diagnosis:**
```bash
# Exec into container
docker exec -it radarr bash

# Try to list files
ls -la /downloads/complete/

# Check ownership
ls -lnd /downloads/complete/
```

**Fix:**
```bash
# Option 1: Fix permissions on host
sudo chown -R 1000:1000 /path/to/downloads  # Match container user

# Option 2: Add Radarr user to download group
# In docker-compose.yml:
services:
  radarr:
    user: 1000:1000  # Match download client user
```

#### 5. Incomplete Download
**Cause:** Files still extracting or incomplete

**Diagnosis:**
```bash
# Check queue status
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/queue | jq '.records[] | {title, status}'
```

**Fix:** Wait for extraction to complete, or check download client for errors

---

## Path Mapping Problems

### Understanding Remote Path Mappings

Remote path mappings translate paths between different systems or containers.

**When needed:**
- Download client on different machine
- Download client in different container with different volume mounts
- Network shares with different mount points

**Example Docker setup:**

Download client (qBittorrent):
```yaml
volumes:
  - /mnt/storage/torrents:/data
```
Reports completed downloads at: `/data/complete/MovieName/`

Radarr:
```yaml
volumes:
  - /mnt/storage/torrents:/downloads
```
Expects downloads at: `/downloads/complete/MovieName/`

**Solution:** Add remote path mapping:
- Remote Path: `/data`
- Local Path: `/downloads`

### Diagnosing Path Issues

```bash
# Get download client config
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq

# Check what paths queue shows
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/queue | jq '.records[] | {title, outputPath, downloadClient}'

# Exec into both containers and compare
docker exec -it radarr ls -la /downloads
docker exec -it qbittorrent ls -la /data
```

### Testing Path Mappings

```bash
# Trigger manual import to test
curl -X POST http://host:7878/api/v3/command \
  -H "X-Api-Key: $KEY" \
  -d '{"name":"DownloadedMoviesScan"}'

# Check logs for path resolution
docker logs radarr --tail 50 | grep -i path
```

---

## Permission Checklist

Condensed from the upstream "Permission Problems" guide:

- [ ] Run all media containers as one user (`PUID=1000`, `PGID=1000`).
- [ ] Host dirs owned by that user: `chown -R 1000:1000 /mnt/media /mnt/downloads`.
- [ ] Dirs group-writable: `chmod -R 775 /mnt/media /mnt/downloads`.
- [ ] Confirm identity: `docker exec <app> id` shows `uid=1000`.
- [ ] Confirm visibility: `docker exec <app> ls -la /downloads /<media-dir>`.
- [ ] Write test: `docker exec <app> touch /<media-dir>/test.txt`, then check on host.
- [ ] New files readable: set `UMASK=002` in compose.
