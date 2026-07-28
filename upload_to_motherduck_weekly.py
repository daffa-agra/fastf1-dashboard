import sys
import os
import re
import glob

MISSING = []
try:
    import duckdb
except ImportError:
    MISSING.append('duckdb')

if MISSING:
    print("Missing required packages: " + ", ".join(MISSING))
    print("Install them with: pip install " + " ".join(MISSING))
    sys.exit(1)

# --- Config ---
MOTHERDUCK_TOKEN = os.environ.get("MOTHERDUCK_TOKEN")
if not MOTHERDUCK_TOKEN:
    print("Missing MOTHERDUCK_TOKEN environment variable.")
    sys.exit(1)

DB_NAME = os.environ.get("MOTHERDUCK_DB", "f1_data")
SEASON = int(os.environ.get("SEASON", 2026))
INPUT_DIR = os.environ.get("INPUT_DIR", f"f1_{SEASON}_latest")

# Maps file suffix -> destination table name
TABLE_MAP = {
    "laps": "laps",
    "weather": "weather",
    "messages": "race_control_messages",
    "telemetry": "telemetry",
}

FILENAME_RE = re.compile(
    r"^round_(?P<round>\d+)_(?P<country>.+)_(?P<session_type>[A-Z0-9]+)_(?P<kind>laps|weather|messages|telemetry)\.csv$"
)


def connect():
    return duckdb.connect(f"md:{DB_NAME}?motherduck_token={MOTHERDUCK_TOKEN}")


def upload_file(con, filepath, round_num, country, session_type, kind):
    table = TABLE_MAP[kind]

    # Read CSV via DuckDB directly (no pandas needed) with schema auto-detection
    con.sql(f"""
        CREATE TEMP TABLE _staging AS
        SELECT
            {SEASON} AS season,
            {round_num} AS round_number,
            '{country}' AS country,
            '{session_type}' AS session_type,
            *
        FROM read_csv_auto('{filepath}', union_by_name=True, ignore_errors=True)
    """)

    # Create the destination table on first sight of this shape
    con.sql(f"""
        CREATE TABLE IF NOT EXISTS {table} AS
        SELECT * FROM _staging WHERE 1=0
    """)

    # Remove any prior load for this exact round/session (idempotent re-runs)
    con.sql(f"""
        DELETE FROM {table}
        WHERE season = {SEASON}
          AND round_number = {round_num}
          AND session_type = '{session_type}'
    """)

    # Insert by name so column order/schema drift across CSVs doesn't break things
    con.sql(f"""
        INSERT INTO {table} BY NAME
        SELECT * FROM _staging
    """)

    con.sql("DROP TABLE _staging")


def main():
    if not os.path.isdir(INPUT_DIR):
        print(f"Input directory not found: {INPUT_DIR}")
        sys.exit(1)

    con = connect()

    csv_files = sorted(glob.glob(os.path.join(INPUT_DIR, "*.csv")))
    if not csv_files:
        print(f"No CSV files found in {INPUT_DIR}")
        sys.exit(0)

    uploaded = 0
    skipped = 0

    for filepath in csv_files:
        filename = os.path.basename(filepath)
        match = FILENAME_RE.match(filename)

        if not match:
            print(f"Skipping (doesn't match naming pattern): {filename}")
            skipped += 1
            continue

        round_num = int(match.group("round"))
        country = match.group("country")
        session_type = match.group("session_type")
        kind = match.group("kind")

        print(f"Uploading {filename} -> table '{TABLE_MAP[kind]}' "
              f"(round={round_num}, session={session_type})...")

        try:
            upload_file(con, filepath, round_num, country, session_type, kind)
            uploaded += 1
        except Exception as e:
            print(f"  -> Failed to upload {filename}: {e}")
            skipped += 1

    con.close()
    print(f"\nDone. Uploaded: {uploaded}, Skipped/Failed: {skipped}")


if __name__ == "__main__":
    main()
