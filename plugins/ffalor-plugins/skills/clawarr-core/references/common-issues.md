# Common Issues & Troubleshooting

Comprehensive guide to diagnosing and fixing common *arr stack problems.


## Docker & Container Issues

### Container Won't Start

**Diagnosis:**
```bash
docker logs radarr

# Check port conflicts
docker ps | grep 7878
netstat -an | grep 7878
```

**Common causes:**
- Port already in use
- Permission denied on config directory
- Invalid volume mounts

**Fix:**
```bash
# Change port in docker-compose.yml
ports:
  - "7879:7878"  # Use different external port

# Fix config permissions
sudo chown -R 1000:1000 /path/to/appdata/radarr
```

### Container Constantly Restarting

**Diagnosis:**
```bash
docker logs radarr --tail 100

# Check restart count
docker inspect radarr | grep RestartCount
```

**Common causes:**
- Database corruption
- Out of memory
- Invalid configuration

**Fix:**
```bash
# Database repair
docker exec radarr sqlite3 /config/radarr.db "PRAGMA integrity_check;"

# If corrupted, restore from backup
cd /path/to/appdata/radarr/Backups/scheduled
# Copy most recent .zip, extract radarr.db
```

### Stale Mounts After Host Reboot

**Symptoms:**
- Services worked before reboot
- After reboot, can't see media/downloads

**Fix:**
```bash
# Restart all containers to pick up new mounts
docker restart radarr sonarr lidarr readarr prowlarr bazarr

# Or restart entire compose stack
cd /path/to/docker-compose
docker-compose restart
```


## Network & Connectivity

### Can't Access Web UI

**Diagnosis:**
```bash
# Check container is running
docker ps | grep radarr

# Check port binding
docker port radarr

# Test from host
curl http://localhost:7878/api/v3/system/status

# Test from network
curl http://192.168.1.100:7878/api/v3/system/status
```

**Fix:**
```bash
# Firewall on host
sudo ufw allow 7878

# Or use host networking
services:
  radarr:
    network_mode: host
```

### API Key Not Working

**Diagnosis:**
```bash
# Get correct API key
docker exec radarr cat /config/config.xml | grep ApiKey

# Or use /initialize.js endpoint
curl http://host:7878/initialize.js | grep apiKey
```

**Fix:**
- Copy exact key from config.xml
- Regenerate key in Settings → General → Security → API Key → Regenerate

### Connection Timeouts

**Diagnosis:**
```bash
# Check container network
docker exec -it radarr ping 8.8.8.8
docker exec -it radarr curl https://api.themoviedb.org

# Check DNS
docker exec -it radarr nslookup api.themoviedb.org
```

**Fix:**
```bash
# Set DNS in docker-compose.yml
services:
  radarr:
    dns:
      - 8.8.8.8
      - 8.8.4.4
```

## Performance Issues

### Slow Search/Import

**Diagnosis:**
```bash
# Check system resources
docker stats radarr

# Check database size
docker exec radarr ls -lh /config/*.db

# Check logs for slow queries
docker logs radarr | grep -i slow
```

**Fix:**
```bash
# Optimize database
docker exec radarr sqlite3 /config/radarr.db "VACUUM;"

# Reduce history retention
# Settings → General → History Cleanup → 30 days

# Disable unused metadata consumers
# Settings → Metadata → Disable unused
```

### High CPU/Memory Usage

**Diagnosis:**
```bash
docker stats --no-stream radarr

# Check for runaway processes
docker exec radarr ps aux
```

**Fix:**
```bash
# Set memory limits in docker-compose.yml
services:
  radarr:
    mem_limit: 1g
    memswap_limit: 1g

# Restart container
docker restart radarr
```

### Database Corruption

**Symptoms:**
- Crashes on startup
- Missing data
- Errors in logs about database

**Fix:**
```bash
# Stop container
docker stop radarr

# Backup current database
cp /path/to/appdata/radarr/radarr.db /path/to/backup/

# Try repair
docker run --rm -v /path/to/appdata/radarr:/config \
  ghcr.io/linuxserver/radarr \
  sqlite3 /config/radarr.db "PRAGMA integrity_check;"

# If failed, restore from backup
cd /path/to/appdata/radarr/Backups/scheduled
unzip radarr_backup_*.zip
cp radarr.db ../../

# Start container
docker start radarr
```

## Quick Diagnostic Checklist

When encountering issues, run through:

1. **Check container health:**
   ```bash
   docker ps | grep -E "(radarr|sonarr)"
   docker logs radarr --tail 50
   ```

2. **Check connectivity:**
   ```bash
   curl http://host:7878/api/v3/health -H "X-Api-Key: $KEY"
   ```

3. **Check paths:**
   ```bash
   docker exec -it radarr ls -la /downloads
   docker exec -it radarr ls -la /movies
   ```

4. **Check permissions:**
   ```bash
   docker exec -it radarr id
   ls -lnd /mnt/media/movies
   ```

5. **Check disk space:**
   ```bash
   df -h /mnt/media
   df -h /mnt/downloads
   ```

6. **Check queue:**
   ```bash
   curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/queue | jq
   ```

7. **Run diagnostics script:**
   ```bash
   scripts/diagnose.sh
   ```

---

## Getting Help

When asking for help, provide:

1. Container logs:
   ```bash
   docker logs radarr --tail 100 > radarr.log
   ```

2. System info:
   ```bash
   curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/system/status
   ```

3. Queue status:
   ```bash
   curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/queue
   ```

4. Docker compose configuration (redact passwords)

5. Description of exact error message and when it occurs
