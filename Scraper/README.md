# Scraper Backend

## Scripts

- `main.py`: fetches and parses weekly Reddit post into `data/weekly-update.json`
- `vehicle_scraper.py`: scrapes vehicle image + pricing into `data/vehicle_data.json`
- `pipeline.py`: runs both scripts, then syncs data into `expo/assets/data`

## Run

```bash
cd scraper
python3 pipeline.py
```

## Notes

- Vehicle slug matching now uses multiple fallbacks before marking a vehicle as failed.
- Failed vehicle matches are printed with attempted slugs to speed up `special_cases.py` updates.
