# SABnzbd Troubleshooting

Comprehensive guide to diagnosing and fixing common *arr stack problems.


## Download Client Issues

### Can't Connect to Download Client

**Diagnosis:**
```bash
# Test connectivity from Radarr container
docker exec -it radarr curl http://qbittorrent:8080

# Check download client credentials
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq
```

**Fix:**
- Verify host/IP is correct
- Check port accessibility
- Confirm credentials
- Test connection in Settings → Download Clients → Test

### Downloads Not Starting

**Diagnosis:**
```bash
# Check indexer health
curl -H "X-Api-Key: $PROWLARR_KEY" http://host:9696/api/v1/indexer | jq '.[] | {name, enable, priority}'

# Check download client queue limit
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq '.[] | {name, protocol, priority}'
```

**Common causes:**
- Indexers down or rate limited
- Download client queue full
- No suitable releases found

**Fix:**
- Test indexers in Prowlarr
- Adjust quality profile if no releases match
- Increase download client queue limit

### Category Mismatch

**Symptom:** Downloads complete but Radarr doesn't see them

**Diagnosis:**
```bash
# Check Radarr's expected category
curl -H "X-Api-Key: $KEY" http://host:7878/api/v3/downloadclient | jq '.[] | {name, category}'

# Check download client's actual category
# In qBittorrent web UI: Right click torrent → Category
```

**Fix:**
- Set matching category in download client settings
- Or update Radarr's download client category setting
- For qBittorrent: Tools → Options → Downloads → Default Save Path per category

---
