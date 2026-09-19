# Sunny Cove — Level Progression and Timer Contract V1

## Scope

Sunny Cove is the first 100-level campaign island.

It uses:
- the existing gameplay table;
- L1-L3 random spawn pool baseline;
- normal campaign order targets no lower than L5;
- normal targets limited to L5-L8 in Sunny Cove;
- optional VIP orders;
- timer-based completion instead of move limits.

L9 is reserved for a later island, initially Tiki Island.

## Merge cost model

Two equal levels merge into the next level.

L1-equivalent values:

| Level | Cost |
| --- | ---: |
| L1 | 1 |
| L2 | 2 |
| L3 | 4 |
| L4 | 8 |
| L5 | 16 |
| L6 | 32 |
| L7 | 64 |
| L8 | 128 |
| L9 | 256 |

For a normal objective set:

```
objective_cost = SUM(quantity * 2^(cocktail_level - 1))
```

The spawn baseline is random L1-L3. The planning-time estimate is calculated from expected production and then the final target timer is set to **2× the calculated production time**.

Do not add a fixed 30-second pad or fixed minimum timer.

## Anchor levels

### Level 1

Normal objective:
- 1×L5

Target timer:
- approximately 20 seconds.

### Level 100

Normal objectives:
- 1×L8
- 1×L7
- 1×L6
- 1×L5

L1-equivalent cost:
- 128 + 64 + 32 + 16 = 240

Target timer:
- 300 seconds / 5:00.

Optional VIP is not included in the normal timer cost calculation.

## Spatial difficulty rule

The merge-cost formula is not a complete difficulty model.

Examples with equal theoretical cost may differ materially in real play:
- 1×L8;
- 2×L7;
- 4×L6.

The board is physical 2D space. Two same-level cocktails can exist at opposite ends of the table, large pieces can block travel lanes, and board congestion can add substantial time.

Therefore:
- theoretical cost is a planning baseline;
- real difficulty must be validated using telemetry/playtests/simulation;
- timer values may be tuned from evidence;
- impossible or outlier levels must be flagged rather than papered over.

## Difficulty-wave rule

Difficulty should rise over the island but not monotonically.

Use relief levels after demanding peaks. The campaign should feel like waves, not a staircase made of nails.

Milestone levels:
10, 20, 30, 40, 50, 60, 70, 80, 90, 100.

## Approved 100-level normal objective plan

| Lv | Normal objective | Cost | Time |
|---:|---|---:|---:|
|1|1×L5|16|0:20|
|2|1×L5|16|0:20|
|3|2×L5|32|0:40|
|4|1×L6|32|0:40|
|5|2×L5|32|0:40|
|6|1×L6 + 1×L5|48|1:00|
|7|3×L5|48|1:00|
|8|1×L6 + 1×L5|48|1:00|
|9|2×L6|64|1:20|
|10|1×L7|64|1:20|
|11|1×L6 + 1×L5|48|1:00|
|12|2×L6|64|1:20|
|13|1×L7|64|1:20|
|14|1×L6 + 2×L5|64|1:20|
|15|1×L7 + 1×L5|80|1:40|
|16|2×L6|64|1:20|
|17|1×L7 + 1×L5|80|1:40|
|18|2×L6 + 1×L5|80|1:40|
|19|1×L7 + 1×L5|80|1:40|
|20|1×L7 + 1×L6|96|2:00|
|21|2×L6|64|1:20|
|22|1×L7 + 1×L5|80|1:40|
|23|2×L6 + 1×L5|80|1:40|
|24|1×L7 + 1×L6|96|2:00|
|25|1×L7 + 1×L5|80|1:40|
|26|3×L6|96|2:00|
|27|1×L7 + 2×L5|96|2:00|
|28|1×L7 + 1×L6|96|2:00|
|29|1×L7 + 1×L6 + 1×L5|112|2:20|
|30|1×L7 + 3×L5|112|2:20|
|31|1×L7 + 1×L5|80|1:40|
|32|1×L7 + 1×L6|96|2:00|
|33|3×L6|96|2:00|
|34|1×L7 + 1×L6 + 1×L5|112|2:20|
|35|1×L7 + 2×L5|96|2:00|
|36|1×L7 + 3×L5|112|2:20|
|37|1×L7 + 1×L6 + 1×L5|112|2:20|
|38|2×L7|128|2:40|
|39|1×L7 + 1×L6 + 1×L5|112|2:20|
|40|1×L8|128|2:40|
|41|1×L7 + 1×L6|96|2:00|
|42|1×L7 + 1×L6 + 1×L5|112|2:20|
|43|1×L8|128|2:40|
|44|1×L7 + 3×L5|112|2:20|
|45|2×L7|128|2:40|
|46|1×L7 + 2×L6|128|2:40|
|47|1×L8 + 1×L5|144|3:00|
|48|2×L7|128|2:40|
|49|2×L7 + 1×L5|144|3:00|
|50|1×L8 + 1×L5|144|3:00|
|51|1×L7 + 1×L6 + 1×L5|112|2:20|
|52|1×L8|128|2:40|
|53|1×L8 + 1×L5|144|3:00|
|54|2×L7|128|2:40|
|55|1×L8 + 1×L5|144|3:00|
|56|1×L8 + 1×L6|160|3:20|
|57|2×L7 + 1×L5|144|3:00|
|58|1×L8 + 1×L6|160|3:20|
|59|2×L7 + 1×L6|160|3:20|
|60|1×L8 + 1×L6 + 1×L5|176|3:40|
|61|1×L8|128|2:40|
|62|1×L8 + 1×L5|144|3:00|
|63|1×L8 + 1×L6|160|3:20|
|64|2×L7 + 1×L5|144|3:00|
|65|1×L8 + 1×L6|160|3:20|
|66|1×L8 + 1×L6 + 1×L5|176|3:40|
|67|2×L7 + 1×L6|160|3:20|
|68|1×L8 + 3×L5|176|3:40|
|69|1×L8 + 1×L7|192|4:00|
|70|1×L8 + 1×L6 + 1×L5|176|3:40|
|71|1×L8 + 1×L5|144|3:00|
|72|1×L8 + 1×L6|160|3:20|
|73|1×L8 + 1×L6 + 1×L5|176|3:40|
|74|2×L7 + 1×L6|160|3:20|
|75|1×L8 + 1×L6 + 1×L5|176|3:40|
|76|1×L8 + 1×L7|192|4:00|
|77|1×L8 + 3×L5|176|3:40|
|78|1×L8 + 1×L7|192|4:00|
|79|1×L8 + 1×L7 + 1×L5|208|4:20|
|80|1×L8 + 2×L6|192|4:00|
|81|1×L8 + 1×L6|160|3:20|
|82|1×L8 + 1×L6 + 1×L5|176|3:40|
|83|1×L8 + 1×L7|192|4:00|
|84|1×L8 + 3×L5|176|3:40|
|85|1×L8 + 1×L7|192|4:00|
|86|1×L8 + 1×L7 + 1×L5|208|4:20|
|87|1×L8 + 2×L6|192|4:00|
|88|1×L8 + 1×L7 + 1×L5|208|4:20|
|89|1×L8 + 1×L7 + 1×L6|224|4:40|
|90|1×L8 + 1×L7 + 1×L5|208|4:20|
|91|1×L8 + 1×L6 + 1×L5|176|3:40|
|92|1×L8 + 1×L7|192|4:00|
|93|1×L8 + 1×L7 + 1×L5|208|4:20|
|94|1×L8 + 2×L6|192|4:00|
|95|1×L8 + 1×L7 + 1×L5|208|4:20|
|96|1×L8 + 1×L7 + 1×L6|224|4:40|
|97|1×L8 + 1×L7 + 1×L5|208|4:20|
|98|1×L8 + 1×L7 + 1×L6|224|4:40|
|99|1×L8 + 1×L7 + 1×L6|224|4:40|
|100|1×L8 + 1×L7 + 1×L6 + 1×L5|240|5:00|

## VIP policy

VIP entries are a separate content pass.

Rules:
- optional;
- not included in normal timer calculation;
- clearly marked in existing To-Go UI with a VIP badge;
- completion grants a booster or configured reward;
- failure does not fail the level;
- VIP placements should create meaningful risk/reward, not make normal completion mathematically impossible.

## Acceptance anchors

The canonical Sunny Cove data must pass automated assertions that:
- level count = 100;
- ids are 1..100 with no gaps/duplicates;
- no normal objective is below L5;
- no normal Sunny Cove objective exceeds L8;
- Level 1 is 1×L5 at about 20 seconds;
- Level 100 is L8+L7+L6+L5 at exactly 300 seconds;
- VIP cost is not added to normal timer calculation;
- each level is reachable through sequential unlock state.
