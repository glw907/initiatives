import json,sys
for p in sys.argv[1:]:
    try: d=json.load(open(p))
    except Exception as e: print(p,"not ready"); continue
    print(f"== {p}  {d['durationSeconds']}s  ${float(d['costUsd']):.2f}  partial={d['partial']}")
    for c in d["cases"]:
        for arm,runs in c["arms"].items():
            n=len(runs); t={}
            for r in runs:
                for g in r["graders"]: t.setdefault(g["name"],[]).append(g["passed"])
            allp=sum(1 for r in runs if r["passed"])
            print(f"  {c['name']} [{arm}] runs={n} all-pass={allp}  "+"  ".join(f"{k}={sum(v)}/{len(v)}" for k,v in sorted(t.items())))
