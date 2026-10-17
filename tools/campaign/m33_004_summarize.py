"""Summarize BCM-M33-004 sample trials into a winnability report.

No difficulty grading: each sampled level is only reported as
WINNABLE (bot won at least once within the normal 4T move cap) or
NOT_WON_BY_BOT (every attempt lost). A bot loss is not proof that a level is
impossible for a human.

usage: python tools/campaign/m33_004_summarize.py
"""
import json
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ROOT = REPO / "coordination/sessions/BCM-M33-004-CLAUDE-V01/evidence"
SELECTION = REPO / "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/qualification/r23_random_selection_seed_20261016_v01.json"


def main() -> None:
    selection = json.loads(SELECTION.read_text(encoding="utf-8"))["selection"]
    trials = defaultdict(list)
    for path in sorted((ROOT / "trials").glob("*.json")):
        record = json.loads(path.read_text(encoding="utf-8"))
        if record.get("terminal_reason") == "MOVES_EXHAUSTED":
            # early trial script versions labelled the production move-budget LOSE as LOSS_DANGER
            record["classification"] = "LOSS_OUT_OF_MOVES"
        trials[(record["island_id"], int(record["level_id"]))].append(record)

    levels, islands = [], defaultdict(lambda: {"sampled": 0, "winnable": 0, "not_won": [], "errors": 0})
    for entry in selection:
        key = (entry["island_id"], int(entry["level_id"]))
        runs = trials.get(key, [])
        wins = [r for r in runs if r["classification"] == "WIN_OBSERVED"]
        errors = [r for r in runs if r["classification"] == "ERROR"]
        status = "WINNABLE" if wins else ("NOT_RUN" if not runs else ("ERROR" if len(errors) == len(runs) else "NOT_WON_BY_BOT"))
        levels.append({
            "island_id": key[0], "level_id": key[1], "status": status,
            "attempts": len(runs), "wins": len(wins),
            "outcomes": [r["classification"] for r in sorted(runs, key=lambda r: r.get("attempt_index", 0))],
            "move_cap_4T": runs[0].get("normal_4t_shot_cap") if runs else None,
            "fewest_moves_to_win": min((r["shots_used"] for r in wins), default=None),
        })
        isl = islands[key[0]]
        isl["sampled"] += 1
        isl["winnable"] += status == "WINNABLE"
        isl["errors"] += len(errors)
        if status != "WINNABLE":
            isl["not_won"].append(key[1])

    all_runs = [r for rs in trials.values() for r in rs]
    totals = {
        "levels_sampled": len(selection),
        "levels_winnable": sum(l["status"] == "WINNABLE" for l in levels),
        "levels_not_won_by_bot": sum(l["status"] == "NOT_WON_BY_BOT" for l in levels),
        "levels_not_run": sum(l["status"] == "NOT_RUN" for l in levels),
        "trials": len(all_runs),
        "trial_outcomes": {c: sum(r["classification"] == c for r in all_runs) for c in sorted({r["classification"] for r in all_runs})},
        "trials_over_4T_cap": sum(int(r.get("shots_used") or 0) > int(r.get("normal_4t_shot_cap") or 0) for r in all_runs),
    }
    summary = {"schema_version": 1, "work_item": "BCM-M33-004", "protocol": "UNCENSORED_FIXED_FPS_V01",
               "selection_sha256": "ef21d5a3023ae7328424da4e459b667c6d6b0dbd567e7a2106cc9b9161d66eb2",
               "totals": totals, "islands": islands, "levels": levels}
    (ROOT / "m33_004_summary.json").write_text(json.dumps(summary, indent=1) + "\n", encoding="utf-8")

    lines = ["# BCM-M33-004 winnability sample result", "",
             f"Sampled levels: {totals['levels_sampled']} (owner-frozen seed 20261016, 10 per island).",
             f"Winnable (bot won at least once within 4T): **{totals['levels_winnable']}**. "
             f"Not won by bot: {totals['levels_not_won_by_bot']}. Not run: {totals['levels_not_run']}.",
             f"Trials: {totals['trials']} — {totals['trial_outcomes']}. Trials over 4T cap: {totals['trials_over_4T_cap']}.", "",
             "| Island | Winnable / sampled | Not won by bot |", "|---|---|---|"]
    for island, data in islands.items():
        lines.append(f"| {island} | {data['winnable']}/{data['sampled']} | {', '.join(f'L{n}' for n in data['not_won']) or '-'} |")
    (ROOT / "M33_004_SUMMARY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
