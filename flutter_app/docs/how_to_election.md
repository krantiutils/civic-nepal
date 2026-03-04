# Enabling Election Results Display

After elections are complete and results are available, follow these steps to show vote counts in the app without requiring users to update.

## Federal Elections (Constituencies)

### Step 1: Update the flag in constituencies.json

Edit `assets/data/election/constituencies.json` and change:

```json
"showVotes": false,
```

to:

```json
"showVotes": true,
```

This flag is in the top-level metadata of the file (around line 6).

### Step 2: Update vote counts (if not already populated)

The scraper at `scripts/scrape_constituencies.py` should populate vote counts. Run it to get updated data with results.

### Step 3: Push to GitHub

Once pushed, the app will pick up the new data on next refresh. No app store update needed.

## How It Works

- `ConstituencyData` model has a `showVotes` boolean field (default: `false`)
- `showVotesProvider` in `lib/providers/constituencies_provider.dart` exposes this flag
- UI components in `constituency_screen.dart` and `federal_map_screen.dart` check this flag before displaying vote counts
- Condition: `if (showVotes && candidate.votes > 0)`

## Files Involved

| File | Purpose |
|------|---------|
| `assets/data/election/constituencies.json` | Data file with `showVotes` flag |
| `lib/models/constituency.dart` | Model with `showVotes` field |
| `lib/providers/constituencies_provider.dart` | Provider exposing `showVotesProvider` |
| `lib/screens/map/constituency_screen.dart` | UI that checks flag before showing votes |
| `lib/screens/map/federal_map_screen.dart` | UI that checks flag before showing votes |

## Local Elections

Local elections (`local_body_screen.dart`) use separate data and currently don't have this flag mechanism. If needed, implement a similar pattern:

1. Add `showVotes` to the local elections JSON metadata
2. Create a provider for local election showVotes
3. Update `local_body_screen.dart` to check the flag

## Reverting

To hide votes again (e.g., for next election cycle), simply set `"showVotes": false` in the JSON.
