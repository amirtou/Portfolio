"""
Run the transaction pipeline end to end.

    python run_pipeline.py

Loads the three source CSVs into DuckDB, builds the star schema, runs the
data-quality audit, reconciliation and analysis scripts in sql/ (in order),
then writes every report table to outputs/ and the charts to figures/.
"""
from pathlib import Path

import duckdb

HERE = Path(__file__).parent
SQL_DIR, OUT_DIR = HERE / "sql", HERE / "outputs"


def run_sql(con: duckdb.DuckDBPyConnection) -> None:
    for script in sorted(SQL_DIR.glob("*.sql")):
        con.execute(script.read_text())
        print(f"ran {script.name}")


def export_reports(con: duckdb.DuckDBPyConnection) -> dict:
    OUT_DIR.mkdir(exist_ok=True)
    reports = {}
    tables = [r[0] for r in con.execute(
        "SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'rpt_%' ORDER BY table_name").fetchall()]
    for name in tables:
        df = con.execute(f"SELECT * FROM {name}").df()
        if name != "rpt_rfm":                       # customer-level detail stays out of the repo
            df.to_csv(OUT_DIR / f"{name.removeprefix('rpt_')}.csv", index=False)
        reports[name] = df
    return reports


def main() -> dict:
    con = duckdb.connect()
    import os
    os.chdir(HERE)                                  # SQL reads the CSVs by relative path
    run_sql(con)
    reports = export_reports(con)
    try:
        from make_figures import make_figures
        make_figures(reports, HERE / "figures")
    except ImportError:
        pass
    return reports


if __name__ == "__main__":
    import pandas as pd
    pd.set_option("display.width", 160, "display.max_columns", 20)
    for name, df in main().items():
        if name == "rpt_rfm":
            continue
        print(f"\n== {name}\n{df.to_string(index=False)}")
