# Companion Services Reference (Maintainerr)

_Extracted verbatim from the clawarr-suite source skill._

## Maintainerr — Library Cleanup

### What It Does
Automated library cleanup based on configurable rules. Identifies media that matches criteria (unwatched, old, low-rated) and manages deletion.

### Common Rules
- Delete movies unwatched for 180+ days
- Delete shows with all episodes watched 90+ days ago
- Delete movies rated below 5.0 and unwatched for 60 days
- Keep movies in specific Plex collections regardless
- Delete content not in any Trakt list

### API Endpoints
```
GET  /api/rules                   # List rules
POST /api/rules/run               # Run all rules
POST /api/rules/:id/run           # Run specific rule
GET  /api/rules/:id/media         # Media matched by rule
POST /api/rules/:id/exclusion     # Exclude media from rule
GET  /api/collections             # Managed collections
GET  /api/logs                    # Activity log
```

### Workflow
1. Create rules in web UI (http://host:6246)
2. Rules evaluate periodically
3. Matched media moves to a collection
4. After configurable grace period, media is deleted
5. Exclusions override rules for specific items
