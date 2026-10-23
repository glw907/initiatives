import json,sys,os
out,wt,file,commit=sys.argv[1:5]
last=None
for line in open(out):
    try: r=json.loads(line)
    except: continue
    m=r.get('message',{})
    if m.get('role')=='assistant':
        c=m.get('content')
        if isinstance(c,list):
            for x in c:
                if x.get('type')=='tool_use' and 'andback' in x.get('name',''):
                    inp=x.get('input',{}); last=next((v for v in inp.values() if isinstance(v,str)),json.dumps(inp))
            t=''.join(x.get('text','') for x in c if x.get('type')=='text')
            if t.strip() and last is None: last=t
s=last.strip()
i=s.index('['); arr,end=json.JSONDecoder().raw_decode(s[i:])
extra=s[i+end:].strip()
d=os.path.join(os.environ.get('XDG_STATE_HOME',os.path.expanduser('~/.local/state')),'approval-queue/findings/cairn-cms',file.replace('/','__'))
os.makedirs(d,exist_ok=True)
p=os.path.join(d,commit+'.json')
open(p,'w').write(json.dumps(arr,indent=1))
from collections import Counter
print(p, Counter(x['verdict'] for x in arr), 'TRAILING PROSE' if extra or i else '')
for x in arr:
    if x['verdict']!='holds': print(json.dumps(x))
