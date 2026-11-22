import json,sys
d=json.load(open(sys.argv[1])); want=set(sys.argv[2:])
for c in d["cases"]:
    for i,r in enumerate(c["arms"]["with"]):
        bad=[g["name"] for g in r["graders"] if not g["passed"]]
        if want and not (want & set(bad)) : continue
        ev=max((g.get("evidence") or "" for g in r["graders"]), key=len)
        print(f"--- run {i} failed={bad}\n{ev}\n")
