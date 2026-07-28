# FastF1 Data Importer

Batch downloader for official Formula 1 session data via the [fastf1](https://github.com/theOehrly/Fast-F1) library. This script pulls every available session type for a given season and exports laps, weather, race-control messages, and car telemetry to CSV.

## Features

- Fetches **all session types** for each round: `FP1`, `FP2`, `FP3`, `SQ`, `SS`, `Q`, `S`, `R`
- Loads **full telemetry**, weather, and race-control messages
- Skips rounds with unconfirmed countries (`NaN` country)
- Handles missing sessions gracefully (e.g., sprint weekends without FP2/FP3/Q)
- Built-in dependency check with install instructions
- Local cache support for faster re-runs

## Requirements

- Python 3.8+
- `fastf1`
- `pandas`

## Installation

```bash
git clone https://github.com/daffa-agra/fastf1_data.git
cd fastf1_data
pip install -r requirements.txt
```

## Usage

Edit the configuration at the top of `import_fastf1_data.py`:

```python
SEASON = 2026  # Set your desired year (e.g., 2025 or 2026)
```

Then run:

```bash
python import_fastf1_data.py
```

Output is saved to `f1_{SEASON}_all_data/` with files named like:

```
round_01_Bahrain_R_laps.csv
round_01_Bahrain_R_weather.csv
round_01_Bahrain_R_messages.csv
round_01_Bahrain_R_telemetry.csv
```

## Output

| File suffix | Description |
|-------------|-------------|
| `_laps.csv` | Lap timing and stint data per driver |
| `_weather.csv` | Session weather conditions |
| `_messages.csv` | Race control messages |
| `_telemetry.csv` | High-frequency car telemetry (speed, RPM, gear, throttle, brake) |

## Notes

- Telemetry CSVs can be very large. Consider using Parquet or skipping telemetry for practice sessions if storage is limited.
- The script uses `fastf1`'s cache (`f1_cache/`) to avoid re-downloading unchanged data.

## License

MIT
