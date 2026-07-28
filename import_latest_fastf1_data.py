import sys, os
from datetime import datetime, timezone

MISSING = []
try:
    import fastf1
except ImportError:
    MISSING.append('fastf1')
try:
    import pandas as pd
except ImportError:
    MISSING.append('pandas')

if MISSING:
    print("Missing required packages: " + ", ".join(MISSING))
    print("Install them with: pip install " + " ".join(MISSING))
    sys.exit(1)

cache_dir = 'f1_cache'
os.makedirs(cache_dir, exist_ok=True)
fastf1.Cache.enable_cache(cache_dir)

SEASON = int(os.environ.get("SEASON", datetime.now().year))
OUTPUT_DIR = f'f1_{SEASON}_latest'
os.makedirs(OUTPUT_DIR, exist_ok=True)

SESSION_TYPES = ['FP1', 'FP2', 'FP3', 'SQ', 'SS', 'Q', 'S', 'R']


def get_latest_completed_round():
    schedule = fastf1.get_event_schedule(SEASON)
    races = schedule[schedule['RoundNumber'] > 0].copy()
    now = pd.Timestamp.now(tz='UTC')

    # EventDate is normally the race day; keep only events that have already happened
    races['EventDate'] = pd.to_datetime(races['EventDate'], utc=True)
    completed = races[races['EventDate'] < now]

    if completed.empty:
        print("No completed races found yet this season.")
        sys.exit(0)

    return completed.sort_values('EventDate').iloc[-1]


def main():
    race = get_latest_completed_round()
    round_num = race['RoundNumber']
    event_name = race['EventName']
    country = str(race['Country']).replace(' ', '_')

    print(f"Latest completed round: {round_num} - {event_name} ({country})\n")

    for session_type in SESSION_TYPES:
        filename_base = f"round_{round_num:02d}_{country}_{session_type}"
        filepath_base = os.path.join(OUTPUT_DIR, filename_base)

        print(f"Fetching {event_name} - {session_type}...")
        try:
            session = fastf1.get_session(SEASON, round_num, session_type)
            session.load(laps=True, telemetry=True, weather=True, messages=True)

            laps = session.laps.copy()
            if laps.empty:
                print("  -> Skipped: No lap data found.\n")
                continue

            laps['Season'] = SEASON
            laps['RoundNumber'] = round_num
            laps['EventName'] = event_name
            laps['SessionType'] = session_type

            if 'LapTime' in laps.columns:
                laps['LapTimeSeconds'] = laps['LapTime'].dt.total_seconds()

            timedelta_cols = laps.select_dtypes(include=['timedelta64[ns]']).columns
            for col in timedelta_cols:
                laps[col] = laps[col].astype(str)

            laps.to_csv(f"{filepath_base}_laps.csv", index=False)

            if hasattr(session, 'weather_data') and session.weather_data is not None:
                weather = session.weather_data.copy()
                if not weather.empty:
                    weather.to_csv(f"{filepath_base}_weather.csv", index=False)

            if hasattr(session, 'race_control_messages') and session.race_control_messages is not None:
                messages = session.race_control_messages.copy()
                if not messages.empty:
                    messages.to_csv(f"{filepath_base}_messages.csv", index=False)

            if hasattr(session, 'car_data') and session.car_data:
                telemetry_frames = []
                for car, tel in session.car_data.items():
                    df = tel.to_dataframe() if hasattr(tel, 'to_dataframe') else (tel.copy() if hasattr(tel, 'copy') else pd.DataFrame(tel))
                    if df.empty:
                        continue
                    df['Car'] = car
                    telemetry_frames.append(df)

                if telemetry_frames:
                    telemetry_df = pd.concat(telemetry_frames, ignore_index=True)
                    telemetry_df['Season'] = SEASON
                    telemetry_df['RoundNumber'] = round_num
                    telemetry_df['EventName'] = event_name
                    telemetry_df['SessionType'] = session_type
                    telemetry_df.to_csv(f"{filepath_base}_telemetry.csv", index=False)

            print(f"  -> Saved to: {filepath_base}_*.csv\n")

        except Exception as e:
            print(f"  -> Failed to process {session_type}: {e}\n")

    print(f"Done. Latest race data saved in '{OUTPUT_DIR}'.")


if __name__ == "__main__":
    main()
