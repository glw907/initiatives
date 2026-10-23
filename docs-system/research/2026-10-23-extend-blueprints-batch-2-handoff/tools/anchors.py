import re,sys
lines=open(sys.argv[1]).read().split('\n')
slug=None;n=0;inrow=False;fence=False;blk=None
def sl(h): return re.sub(r'[^a-z0-9 -]','',h.lower()).strip().replace(' ','-')
for i,l in enumerate(lines,1):
    if l.startswith('```'): fence=not fence; continue
    if fence: continue
    if l.startswith(':::') and l.strip()!=':::': blk=l.strip()[3:].split()[0]
    if l.strip()==':::': blk=None
    m=re.match(r'^(#+) (.*)',l)
    if m: slug=sl(m.group(2)); n=0; print(f'{i}: {slug}.heading  {l[:70]}'); continue
    if l.startswith(':::row'): print(f'{i}: {slug}.p{n} ROW'); n+=1; continue
    if blk in ('row',): continue
    if re.match(r'^(- |\d+\. )',l):
        print(f'{i}: {slug}.p{n}  [{blk or ""}] {l[:80]}'); n+=1
