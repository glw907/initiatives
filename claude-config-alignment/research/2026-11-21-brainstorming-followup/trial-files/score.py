"""score.py <result.json>...: each case's score and each grader's passes, for the with arm."""
import json, sys
for p in sys.argv[1:]:
    d = json.load(open(p))
    s = d["suite"]
    print(f"== {p}  {d['durationSeconds']}s  ${float(d['costUsd']):.2f}  partial={d['partial']}  "
          f"model={s.get('modelOverride')}  judge={s.get('judgeModel')}  {json.dumps(d['aggregates'])}")
    low = []
    for c in d["cases"]:
        for arm, runs in c["arms"].items():
            t = {}
            for r in runs:
                for g in r["graders"]:
                    t.setdefault(g["name"], []).append(bool(g["passed"]))
            score = sum(r["score"] for r in runs) / len(runs)
            low.append(score)
            miss = "  ".join(f"{k}={sum(v)}/{len(v)}" for k, v in sorted(t.items()) if sum(v) < len(v))
            print(f"  {score:.2f} {c['name']} [{arm}] n={len(runs)} graders={len(t)}  {miss}")
    print(f"  lowest case score: {min(low):.2f}; cases under 0.9: {sum(1 for x in low if x < 0.9)}; under 0.8: {sum(1 for x in low if x < 0.8)}")
