extends RefCounted

var grant_calls := 0


func grant_reward(_reward_id: String, _reward: Dictionary) -> Dictionary:
    grant_calls += 1
    return {"ok": false, "granted": false, "duplicate": false, "reason": "FORCED_TEST_FAILURE"}
