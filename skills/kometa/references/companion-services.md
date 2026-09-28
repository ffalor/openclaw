# Companion Services Reference (Kometa)

_Extracted verbatim from the clawarr-suite source skill._

## Kometa (Plex Meta Manager) — Collections & Overlays

### What It Does
Automatically creates/manages Plex collections, applies poster overlays (4K badge, Dolby Atmos icon), and maintains metadata from external sources.

### Configuration (config.yml)
```yaml
libraries:
  Movies:
    collection_files:
      - default: basic      # Genre collections
      - default: imdb        # IMDb Top 250, Popular
      - default: tmdb        # TMDb trending
      - default: trakt       # Trakt lists
    overlay_files:
      - default: resolution  # 4K/1080p badges
      - default: audio_codec # Atmos/DTS-X badges
      - default: ratings     # IMDb/RT ratings
  TV Shows:
    collection_files:
      - default: basic
      - default: imdb
    overlay_files:
      - default: resolution
      - default: status      # Returning/Ended/Canceled

plex:
  url: http://host:32400
  token: your-plex-token

tmdb:
  apikey: your-tmdb-key       # Optional, for TMDb collections
  language: en
```

### Available Defaults
**Collections:**
basic, imdb, tmdb, trakt, flixpatrol, anidb, myanimelist, oscars, golden, spirit, separator

**Overlays:**
resolution, audio_codec, video_format, streaming, ratings, ribbon, status

### Running
```bash
# One-shot run
docker run --rm -v /config:/config kometateam/kometa:latest --run

# Scheduled (daily at 5 AM)
docker run -v /config:/config kometateam/kometa:latest --run-schedule "05:00"

# Specific library only
docker run --rm -v /config:/config kometateam/kometa:latest --run --run-libraries "Movies"
```

