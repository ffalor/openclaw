# Companion Services Reference (Recyclarr)

_Extracted verbatim from the clawarr-suite source skill._

## Recyclarr — Quality Profile Sync

### What It Does
Automatically syncs quality profiles from [TRaSH Guides](https://trash-guides.info/) to Sonarr and Radarr. Keeps your quality profiles optimized without manual tuning.

### Configuration (recyclarr.yml)
```yaml
sonarr:
  main:
    base_url: http://host:8989
    api_key: sonarr-key
    delete_old_custom_formats: true
    replace_existing_custom_formats: true
    quality_definition:
      type: series
    quality_profiles:
      - name: HD-1080p
        reset_unmatched_scores:
          enabled: true

radarr:
  main:
    base_url: http://host:7878
    api_key: radarr-key
    delete_old_custom_formats: true
    replace_existing_custom_formats: true
    quality_definition:
      type: movie
    quality_profiles:
      - name: HD-1080p
        reset_unmatched_scores:
          enabled: true
```

### Commands
```bash
recyclarr sync                    # Sync all
recyclarr sync --preview          # Dry run
recyclarr sync sonarr             # Sync only Sonarr
recyclarr list custom-formats radarr  # List available profiles
recyclarr list qualities radarr   # List quality definitions
recyclarr config create           # Generate template
```
