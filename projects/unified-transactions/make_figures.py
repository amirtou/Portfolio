"""Charts for the README and portfolio write-up, built from the pipeline's report tables."""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

INFLOW, OUTFLOW = "#2a78d6", "#eb6834"          # colourblind-safe pair (validated)
INK, MUTED, GRID = "#1c2733", "#5b6875", "#e3e7ea"
plt.rcParams.update({
    "figure.dpi": 110, "savefig.dpi": 160, "axes.spines.top": False, "axes.spines.right": False,
    "axes.edgecolor": MUTED, "axes.labelcolor": INK, "xtick.color": MUTED, "ytick.color": MUTED,
    "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.8, "axes.axisbelow": True,
    "axes.titleweight": "bold", "axes.titlesize": 12, "axes.titlelocation": "left",
    "font.size": 10, "lines.linewidth": 2, "legend.frameon": False,
})
money = FuncFormatter(lambda x, _: f"{x/1000:,.0f}k")


def make_figures(r: dict, out: Path) -> None:
    out.mkdir(exist_ok=True)

    # 1. Data-quality findings
    dq = r["rpt_data_quality"].query("rows_affected > 0").iloc[::-1]
    fig, ax = plt.subplots(figsize=(8.5, 3.2))
    ax.barh(dq["check_name"], dq["rows_affected"], color=OUTFLOW, height=0.55)
    for y, (n, pct, scope) in enumerate(zip(dq["rows_affected"], dq["pct_of_scope"], dq["scope"])):
        ax.text(n + 15, y, f"{n:,}  ({pct:.1f}% of {scope.lower()})", va="center", color=INK, fontsize=9)
    ax.set_xlim(0, dq["rows_affected"].max() * 1.6); ax.grid(axis="y", visible=False)
    ax.set_xlabel("Rows affected"); ax.set_title("Data-quality issues found in the source files")
    fig.tight_layout(); fig.savefig(out / "data_quality.png"); plt.close(fig)

    # 2. Monthly inflow vs outflow
    m = r["rpt_monthly_flow"].copy()
    m["outflow"] = m["withdrawals"].fillna(0) + m["card_spend"].fillna(0)
    fig, ax = plt.subplots(figsize=(10, 3.8))
    ax.plot(m["month_start"], m["deposits"], color=INFLOW, label="Inflow (deposits)")
    ax.plot(m["month_start"], m["outflow"], color=OUTFLOW, label="Outflow (withdrawals + card spend)")
    ax.fill_between(m["month_start"], m["deposits"], m["outflow"], where=m["outflow"] > m["deposits"],
                    color=OUTFLOW, alpha=0.08, interpolate=True)
    ax.yaxis.set_major_formatter(money); ax.set_ylabel("Amount per month")
    ax.set_title("Monthly inflow vs outflow, 2022–2024 (transfers excluded)")
    ax.legend(loc="upper left"); fig.tight_layout(); fig.savefig(out / "monthly_flow.png"); plt.close(fig)

    # 3. Card spend by category
    c = r["rpt_card_categories"].iloc[::-1]
    fig, ax = plt.subplots(figsize=(7.5, 3.4))
    ax.barh(c["spend_category"], c["spend"], color=INFLOW, height=0.55)
    for y, (s, pct, t) in enumerate(zip(c["spend"], c["share_of_spend_pct"], c["avg_ticket"])):
        ax.text(s + 900, y, f"{pct:.1f}%  · avg {t:,.0f}", va="center", color=INK, fontsize=9)
    ax.set_xlim(0, c["spend"].max() * 1.35); ax.xaxis.set_major_formatter(money); ax.grid(axis="y", visible=False)
    ax.set_title("Card spend by category (share of spend · average ticket)")
    fig.tight_layout(); fig.savefig(out / "card_categories.png"); plt.close(fig)

    # 4. RFM segments: share of card spend, labelled with customer counts
    s = r["rpt_segments"].iloc[::-1]
    fig, ax = plt.subplots(figsize=(7.5, 3.2))
    ax.barh(s["segment"], s["share_of_spend_pct"], color=INFLOW, height=0.55)
    for y, (pct, n) in enumerate(zip(s["share_of_spend_pct"], s["customers"])):
        ax.text(pct + 0.8, y, f"{pct:.0f}% of spend · {n} customers", va="center", color=INK, fontsize=9)
    ax.set_xlim(0, s["share_of_spend_pct"].max() * 1.55); ax.grid(axis="y", visible=False)
    ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _: f"{x:.0f}%"))
    ax.set_title("Card customers by RFM segment, at 31 Dec 2024")
    fig.tight_layout(); fig.savefig(out / "rfm_segments.png"); plt.close(fig)
