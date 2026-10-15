# Human-agent review: the evidence behind the approval queue

Research brief for the approval-queue design. Audience: the owner and the agents that build the queue. Date: 2026-10-14.

## How to read this

Each finding carries a strength label:

- **Replicated**: multiple independent studies, meta-analyses, or large preregistered work agree.
- **Supported**: one or more good studies or a systematic review, no serious contrary evidence, limited replication.
- **Contested**: a well-known effect with failed replications, artefact critiques, or mixed results.
- **Doctrine**: practitioner or institutional practice with little controlled evidence; useful as a template, not as proof.

Sources were checked by web search during this session against publisher pages, PubMed/PMC, arXiv, or author copies. Items marked † are cited from prior knowledge and were not re-fetched; their bibliographic details are believed correct but should be checked before being quoted in published prose.

The problem being solved: one decision maker meets about 48 review items a day, many near-duplicates, 90 to 1,600 words each, sometimes the same change twice. The proposed fix is a packet per agent hand-over, grouped by initiative and repo, each part carrying an agent-recommended verdict, approvable as a whole or overridable per part.

---

## 1. Cognitive limits relevant to review

### 1.1 Working memory holds about four chunks

- **Finding**: Adults hold roughly three to five meaningful chunks in the focus of attention at once (central estimate about four), not Miller's seven plus or minus two, which Miller himself offered loosely. Endsley later named working memory and attention as the main limits on building situation awareness.
- **Strength**: Replicated. Cowan's BBS target article drew extensive commentary and the four-chunk estimate has held up as the mainstream figure; the exact number depends on how chunks are defined.
- **Sources**: Cowan, N. (2001). The magical number 4 in short-term memory. *Behavioral and Brain Sciences* 24(1), 87-114. https://pubmed.ncbi.nlm.nih.gov/11515286/ (author PDF: https://memory.psych.missouri.edu/assets/doc/articles/2001/cowan-bbs-2001.pdf). Endsley, M. R. (1995). Toward a theory of situation awareness in dynamic systems. *Human Factors* 37(1), 32-64. https://doi.org/10.1518/001872095779049543
- **Implication**: A packet's top section should never ask the owner to hold more than about three open questions at once (leaving one slot for the context of "what is this packet"). Everything beyond that goes behind disclosure or into a separate lane. "What changes" bullets above the fold should also be capped near four; longer lists stop being held and start being skimmed.

### 1.2 Decision fatigue and ego depletion

- **Finding (lab)**: The classic "willpower is a depletable resource" effect did not survive large preregistered tests. Hagger et al.'s 23-lab replication (N = 2,141) found d = 0.04, CI spanning zero; Vohs et al.'s 36-lab test (N = 3,531), led by a proponent, found d = 0.06 confirmatory and Bayesian odds about 4:1 for the null.
- **Finding (field)**: Real-world decision quality does degrade with the number of decisions already made in a session. Primary-care clinicians prescribed antibiotics for acute respiratory infections more often as a session went on (about 26% higher odds in hour four than hour one; Linder et al. 2014). Equity analysts' forecasts grew less accurate and more heuristic (herding to consensus, reissuing their own prior forecast) with each additional forecast issued that day (Hirshleifer et al. 2019).
- **What holds up, plainly**: The *resource* mechanism is not supported. The *behavioural pattern* (later decisions in a run drift toward the easy or default option) is supported in several field datasets, but those are observational and open to confounds. The leading replacement account treats effort as an opportunity-cost signal (Kurzban et al. 2013): people disengage from effortful evaluation as it feels less worth it, which predicts the same drift toward defaults without a fuel tank.
- **Strength**: Ego depletion (resource model): contested, leaning failed. Within-session drift toward defaults in field data: supported, correlational.
- **Sources**: Hagger, M. S., Chatzisarantis, N. L. D., et al. (2016). A multilab preregistered replication of the ego-depletion effect. *Perspectives on Psychological Science* 11(4), 546-573. https://doi.org/10.1177/1745691616652873. Vohs, K. D., et al. (2021). A multisite preregistered paradigmatic test of the ego-depletion effect. *Psychological Science* 32(10), 1566-1581. https://doi.org/10.1177/0956797621989733. Linder, J. A., et al. (2014). Time of day and the decision to prescribe antibiotics. *JAMA Internal Medicine* 174(12), 2029-2031. https://pmc.ncbi.nlm.nih.gov/articles/PMC4648561. Hirshleifer, D., Levi, Y., Lourie, B., & Teoh, S. H. (2019). Decision fatigue and heuristic analyst forecasts. *Journal of Financial Economics* 133(1), 83-98. https://www.nber.org/papers/w24293. Kurzban, R., Duckworth, A., Kable, J. W., & Myers, J. (2013). An opportunity cost model of subjective effort and task performance. *Behavioral and Brain Sciences* 36(6), 661-726. https://pmc.ncbi.nlm.nih.gov/articles/PMC3856320
- **Implication**: In this queue, "drift toward the default" means drift toward approving the agent's recommendation. Put the highest-stakes asks first in any review session, keep sessions short, and never let a run of routine approvals precede a judgment call. Do not cite ego depletion as the rationale in docs; cite the field drift and the opportunity-cost account.

### 1.3 Attention residue and task-switching costs

- **Finding**: Switching task sets costs time and accuracy immediately after the switch; preparation reduces but does not eliminate the cost (Monsell 2003). When people move from an unfinished task to a new one, thoughts about the first persist and degrade performance on the second ("attention residue"); finishing the first task under time pressure still leaves residue (Leroy 2009). Interrupted workers compensate by working faster at the same quality, paying in stress, frustration, and effort (Mark, Gudith & Klocke 2008).
- **Strength**: Switch costs: replicated (decades of task-switching work). Attention residue: supported (Leroy's two studies plus follow-ups; less replicated than switch costs). Interruption stress: supported.
- **Sources**: Monsell, S. (2003). Task switching. *Trends in Cognitive Sciences* 7(3), 134-140. https://pubmed.ncbi.nlm.nih.gov/12639695/. Leroy, S. (2009). Why is it so hard to do my work? The challenge of attention residue when switching between work tasks. *Organizational Behavior and Human Decision Processes* 109(2), 168-181. https://doi.org/10.1016/j.obhdp.2009.04.002 †(DOI). Mark, G., Gudith, D., & Klocke, U. (2008). The cost of interrupted work: more speed and stress. *CHI 2008*, 107-110. https://www.ics.uci.edu/~gmark/chi08-mark.pdf
- **Implication**: 48 items arriving through the day means 48 interruptions, each leaving residue on the owner's own work. Packets should accumulate silently and be reviewed in scheduled windows, not pushed as they land. Within a window, present one initiative at a time and one repo at a time, so the owner reloads context once per group rather than once per item. Meeting the same change twice is a pure switch cost with no information gain, so de-duplication is a cognitive fix, not just tidiness.

### 1.4 Vigilance decrement

- **Finding**: Detection sensitivity for infrequent critical signals declines over a monitoring watch, typically within the first 15 to 30 minutes, across hundreds of studies; the See et al. meta-analysis (42 experiments) pooled the sensitivity decrement. Contrary to the "boring so mindless" view, vigilance is effortful and stressful (high NASA-TLX workload), which is why it decays.
- **Strength**: Replicated.
- **Sources**: See, J. E., Howe, S. R., Warm, J. S., & Dember, W. N. (1995). Meta-analysis of the sensitivity decrement in vigilance. *Psychological Bulletin* 117(2), 230-249. https://doi.org/10.1037/0033-2909.117.2.230. Warm, J. S., Parasuraman, R., & Matthews, G. (2008). Vigilance requires hard mental work and is stressful. *Human Factors* 50(3), 433-441. https://doi.org/10.1518/001872008X312152 †(DOI)
- **Implication**: Reviewing a long queue of mostly fine agent work is a vigilance task: the rare bad PR is the "signal". Detection of that rare bad item will fall as the session lengthens. Keep review sessions to roughly 20 minutes or a fixed number of judgment calls, surface the break explicitly, and reduce the number of items that require vigilance at all (by automating or deferring the routine ones) rather than asking for more of it.

---

## 2. Automation bias and complacency

### 2.1 The core phenomenon

- **Finding**: People supervising decision aids make omission errors (missing problems the aid did not flag) and commission errors (following the aid's wrong advice). Complacency appears under multitask load, affects experts as well as novices, and is not cured by practice; Parasuraman & Manzey argue both phenomena are attentional: attention is reallocated away from checking a reliable-seeming aid. Goddard et al.'s systematic review (74 studies, mainly healthcare) found automation bias common, increased by high workload, task complexity, and higher trust/confidence in the aid, and decreased by certain designs and by accountability.
- **Strength**: Replicated.
- **Sources**: Parasuraman, R., & Manzey, D. H. (2010). Complacency and bias in human use of automation: an attentional integration. *Human Factors* 52(3), 381-410. https://doi.org/10.1177/0018720810376055. Goddard, K., Roudsari, A., & Wyatt, J. C. (2012). Automation bias: a systematic review of frequency, effect mediators, and mitigators. *JAMIA* 19(1), 121-127. https://pmc.ncbi.nlm.nih.gov/articles/PMC3240751. Skitka, L. J., Mosier, K. L., & Burdick, M. (2000). Accountability and automation bias. *International Journal of Human-Computer Studies* 52(4), 701-717 (abstract not retrieved this session; the accountability effect is consistent with Mosier and colleagues' NASA-funded pilot studies, https://ntrs.nasa.gov/citations/20020041010).
- **Implication**: Every part of a packet arrives with a recommended verdict, which is exactly the commission-error setup. The dangerous failure is not the owner rejecting good work; it is the owner approving the one bad recommendation in a stream of good ones. The queue should be designed against commission errors on high-stakes parts and omission errors on what the agent did not mention (see 2.4, the code-review anchoring result).

### 2.2 When to show the recommendation

- **Finding**: Veterinary radiologists who recorded a provisional decision before seeing the AI's output agreed with the AI less often, whether the AI was right or wrong, without spending more time (Fogliato et al. 2022). Cognitive forcing functions (decide first, wait before seeing the AI, or see the AI only on request) reduced overreliance relative to simple explainable-AI displays, but participants rated those designs least favourably, and the benefit was larger for people high in need for cognition (Buçinca et al. 2021).
- **Strength**: Supported (two well-designed studies plus follow-ups; effect direction consistent).
- **Sources**: Fogliato, R., et al. (2022). Who goes first? Influences of human-AI workflow on decision making in clinical imaging. *FAccT '22*. https://arxiv.org/abs/2205.09696. Buçinca, Z., Malaya, M. B., & Gajos, K. Z. (2021). To trust or to think: cognitive forcing functions can reduce overreliance on AI in AI-assisted decision-making. *PACM HCI* 5(CSCW1), Article 188. https://arxiv.org/abs/2102.09692
- **Implication**: For the small number of genuine judgment calls ("Decide:" blocks: design calls, product or taste choices, irreversible actions), show the question, options, and evidence first and take a one-tap provisional lean before revealing the agent's recommendation. For routine parts, show the recommendation directly: forcing on everything would be resented (Buçinca) and would raise disagreement with correct advice too (Fogliato). Note the conflict: provisional-first lowers agreement regardless of correctness, so it trades some lost value on correct advice for protection on wrong advice. That trade is worth making only where an error is costly.

### 2.3 Explanations can increase overreliance

- **Finding**: In tasks where human and AI accuracy were comparable, AI explanations did not improve team performance; they increased the chance the human accepted the AI's recommendation regardless of whether it was correct (Bansal et al. 2021). LLM users overestimate answer accuracy under default explanations, and longer explanations raise confidence without improving accuracy (Steyvers et al. 2025). AI-assisted programmers wrote less secure code and were more confident it was secure (Perry et al. 2023). However, explanations do reduce overreliance when they lower the cost of verifying the AI's answer relative to the cost of doing the task, per a five-study cost-benefit account (Vasconcelos et al. 2023).
- **Strength**: Explanations-increase-acceptance: replicated across several groups. Verification-cost moderation: supported (one multi-study paper, theoretically coherent).
- **Sources**: Bansal, G., et al. (2021). Does the whole exceed its parts? The effect of AI explanations on complementary team performance. *CHI '21*. https://arxiv.org/abs/2006.14779. Steyvers, M., et al. (2025). What large language models know and what people think they know. *Nature Machine Intelligence*. https://arxiv.org/abs/2401.13835. Perry, N., Srivastava, M., Kumar, D., & Boneh, D. (2023). Do users write more insecure code with AI assistants? *CCS '23*. https://arxiv.org/abs/2211.03622. Vasconcelos, H., et al. (2023). Explanations can reduce overreliance on AI systems during decision-making. *PACM HCI* (CSCW 2023). https://arxiv.org/abs/2212.06823. Passi, S., & Vorvoreanu, M. (2022). Overreliance on AI: literature review. Microsoft Research MSR-TR-2022-12. https://www.microsoft.com/en-us/research/?p=854967
- **Implication**: The 1,600-word briefs are a risk, not just a cost: length reads as competence. The rationale attached to a recommendation should be short and verification-shaped (the test result, the diff stat, the one risk the agent sees, the specific evidence that would change the verdict), not a persuasive narrative. Put the narrative behind disclosure where it serves the owner who chooses to dig, not the owner skimming.

### 2.4 Uncertainty display and LLM-specific evidence

- **Finding**: First-person hedges from an LLM ("I'm not sure, but...") lowered user agreement with its answers and raised user accuracy, mainly by reducing reliance on wrong answers; impersonal hedges ("It's not clear...") had weaker, non-significant effects (Kim et al. 2024, preregistered, N = 404). Aligning explanation wording with the model's internal confidence narrowed the human-model calibration gap (Steyvers et al. 2025). In LLM-assisted code review, reviewers accepted most LLM-flagged issues as valid and concentrated on the locations the LLM pointed to, finding more low-severity issues but no more high-severity ones, with no time saved (Tufano et al. 2025).
- **Strength**: Supported (recent, preregistered or controlled, not yet widely replicated).
- **Sources**: Kim, S. S. Y., Liao, Q. V., Vorvoreanu, M., Ballard, S., & Vaughan, J. W. (2024). "I'm not sure, but...": examining the impact of large language models' uncertainty expression on user reliance and trust. *FAccT '24*. https://arxiv.org/abs/2405.00623. Tufano, R., et al. (2025). Deep learning-based code reviews: a paradigm shift or a double-edged sword? *ICSE 2025*. https://arxiv.org/abs/2411.11401
- **Implication**: Each recommended verdict should carry the agent's own confidence, stated in the first person and tied to a reason ("I'm unsure this migration is reversible because..."). Low-confidence parts should be promoted into the asks, not buried. And because reviewers anchor on what the AI flagged, every PR part should state what the agent did *not* check (the omission-error surface) so the owner's attention is pointed at the blind spot rather than only at the agent's own highlights.

---

## 3. Alert fatigue and ask volume

- **Finding**: Clinicians override 49% to 96% of drug-safety alerts (van der Sijs et al. 2006 review of 17 studies); in a three-year inpatient study 73% of alerts were overridden and about 40% of overrides were inappropriate, with some categories nearly all inappropriate (Nanji et al. 2018). In ambulatory care, each additional reminder per encounter cut the odds of acceptance by about 30%, and each 5-point rise in the share of *repeated* reminders cut acceptance by about 10%; total workload had no independent effect (Ancker et al. 2017). Tiering, so that only the most severe alerts interrupt and the rest display passively, raised acceptance of the interruptive tier to 67% (Shah et al. 2006).
- **Strength**: Replicated (override rates and the volume/repeat effect are consistent across sites and decades).
- **Sources**: van der Sijs, H., Aarts, J., Vulto, A., & Berg, M. (2006). Overriding of drug safety alerts in computerized physician order entry. *JAMIA* 13(2), 138-147. https://pmc.ncbi.nlm.nih.gov/articles/PMC1447540. Nanji, K. C., et al. (2018). Medication-related clinical decision support alert overrides in inpatients. *JAMIA* 25(5), 476-481. https://academic.oup.com/jamia/article/25/5/476/4569609. Ancker, J. S., et al. (2017). Effects of workload, work complexity, and repeated alerts on alert fatigue in a clinical decision support system. *BMC Medical Informatics and Decision Making* 17:36. https://bmcmedinformdecismak.biomedcentral.com/articles/10.1186/s12911-017-0430-8. Shah, N. R., et al. (2006). Improving acceptance of computerized prescribing alerts in ambulatory care. *JAMIA* 13(1), 5-11. https://pmc.ncbi.nlm.nih.gov/articles/PMC1380196. Dixon, S. R., Wickens, C. D., & McCarley, J. S. (2007). On the independence of compliance and reliance: are automation false alarms worse than misses? *Human Factors* 49(4), 564-572. † (false-alarm-prone aids reduce compliance with true alarms: "cry wolf").
- **Implication**: The queue is a clinical decision support system with the polarity flipped (the human approves the machine), and the same law applies: per-session volume and repetition degrade every ask, including the important ones. The two biggest levers in this literature are the two the queue can pull: (a) remove repeats, so the same change is never asked twice; (b) tier, so only items that genuinely need the owner interrupt, and the rest are visible but passive. A queue that asks too often about things that turn out fine trains the owner to approve reflexively ("cry wolf" in reverse).

---

## 4. Information presentation for decision makers

### 4.1 BLUF and completed staff work

- **Finding**: US Army correspondence doctrine requires the main point or recommendation at the start (bottom line up front); the 2024 revision of AR 25-50 adds a formal decision-memorandum format. The 1942 "Completed Staff Work" doctrine holds that a staff officer presents a solution "in such form that all that remains to be done on the part of the head ... is to indicate his approval or disapproval"; the chief should never have to work out the details, and the staff officer should draft the document the chief would sign.
- **Strength**: Doctrine. Long institutional use; no controlled trials.
- **Sources**: Department of the Army (2020, admin revision 2024). AR 25-50, Preparing and Managing Correspondence. https://www.maine.gov/dvem/policies/documents/AR%2025-50%20(10%20October%202020).pdf (current copy at armypubs.army.mil). "The Doctrine of Completed Staff Work" (1942; published in *Army and Navy Journal*; authorship variously attributed). https://govleaders.org/completed-staff-work.htm and https://en.wikipedia.org/wiki/Completed_staff_work
- **Implication**: The current inverted-pyramid brief already follows BLUF. Completed staff work adds a stronger test: each packet must be approvable *as is*, with the agent having resolved everything it could, so that the owner's job is literally approve or override. A packet that contains open research ("we should investigate X") has not finished staff work and should not reach the owner as an ask; it belongs in the follow-up lane.

### 4.2 The President's Daily Brief

- **Finding**: The PDB has no fixed format; it has been re-cut for each president's reading habits (Kennedy's pocket-sized checklist, Nixon's legal-size pages, Obama's tablet). What is constant is curation: a short set of articles, each a single assessed item, chosen for the reader.
- **Strength**: Doctrine (institutional history).
- **Sources**: CIA Reading Room, President's Daily Brief collection. https://www.cia.gov/readingroom/node/1829818. CIA Museum, The President's Intelligence Checklist. https://www.cia.gov/legacy/museum/artifact/the-presidents-intelligence-checklist/. Priess, D. (2016). *The President's Book of Secrets*. PublicAffairs.
- **Implication**: The lesson is curation and fit to one reader, not a template. The queue serves one owner; it can learn and enforce that owner's preferred shape (word budgets, what goes above the fold) rather than a generic format.

### 4.3 Amazon six-pagers versus slides

- **Finding**: Amazon replaced slide decks with narrative memos read silently at the start of the meeting, on the argument that "the narrative structure of a good memo forces better thought and better understanding of what's more important than what" (Bezos, 2004 email; 2017 shareholder letter). Tufte's critique of slide formats and the Columbia accident board's finding that a key risk was buried in a bullet hierarchy point the same way: bullet fragments hide causal reasoning.
- **Strength**: Doctrine, with case evidence (CAIB) rather than experiments.
- **Sources**: CNBC (2018). What Jeff Bezos learned from requiring 6-page memos at Amazon. https://www.cnbc.com/2018/04/23/what-jeff-bezos-learned-from-requiring-6-page-memos-at-amazon.html. Bezos, J. (2018). 2017 Letter to Shareholders. https://www.aboutamazon.com/news/company-news/2017-letter-to-shareholders †. Tufte, E. (2003). *The Cognitive Style of PowerPoint*. Graphics Press †. Columbia Accident Investigation Board (2003). Report, Vol. 1, ch. 7 †.
- **Implication**: There is a real tension with BLUF. Bullets are fast for "what changes"; prose is better for "why this design call". Resolve it by layer: the top layer is BLUF and bullets (scan), the "Decide:" block's rationale and the collapsed detail are short connected prose (reason). Never let a design call's key risk live only as a nested bullet.

### 4.4 Situation awareness levels

- **Finding**: Endsley's model separates level 1 (perceiving the relevant elements), level 2 (comprehending what they mean against goals), and level 3 (projecting future states). Higher levels are what support good decisions in dynamic settings, and they are limited by working memory and attention.
- **Strength**: Replicated as a framework (widely used and measured, e.g. SAGAT); the levels are a model, not a law.
- **Sources**: Endsley (1995), above.
- **Implication**: The agent should do levels 1 and 2 (what happened, what it means) and the packet should foreground level 3: what happens if the owner approves, what happens if they don't, and what becomes hard to undo. The existing "If you approve" section is the level-3 slot; it should sit immediately under the lede, include reversibility, and name downstream effects on other repos in the initiative.

### 4.5 Recognition-primed decisions and satisficing

- **Finding**: Experienced fireground commanders usually did not compare options; they recognised the situation as a type, generated one workable course, and mentally simulated it to check for problems, moving on to another only if the simulation failed (Klein, Calderwood & Clinton-Cirocco 1988). Kahneman and Klein agree such intuition is trustworthy only in environments with valid cues and rapid feedback, and that subjective confidence is not a reliable indicator of accuracy. Simon's satisficing: under bounded rationality, decision makers accept the first option that meets an aspiration level rather than optimising.
- **Strength**: RPD: supported (replicated across several naturalistic domains, though mostly by Klein's group with interview methods). Kahneman-Klein conditions: consensus position. Satisficing: foundational, well supported descriptively.
- **Sources**: Klein, G. A., Calderwood, R., & Clinton-Cirocco, A. (1988). Rapid decision making on the fire ground. US Army Research Institute Technical Report 796. https://apps.dtic.mil/sti/pdfs/ADA199492.pdf. Kahneman, D., & Klein, G. (2009). Conditions for intuitive expertise: a failure to disagree. *American Psychologist* 64(6), 515-526. https://pubmed.ncbi.nlm.nih.gov/19739881/. Simon, H. A. (1955). A behavioral model of rational choice. *Quarterly Journal of Economics* 69(1), 99-118. https://doi.org/10.2307/1884852 †. Simon, H. A. (1956). Rational choice and the structure of the environment. *Psychological Review* 63(2), 129-138. https://doi.org/10.1037/h0042769 †
- **Implication**: An expert owner reviewing a familiar repo works in RPD mode: show one recommended course plus the single most likely way it fails, so they can run the mental simulation, rather than a balanced menu of five options. Offer alternatives only when the agent genuinely cannot choose (the "Decide:" block). Because the owner's confidence is not a reliable signal in low-feedback areas (novel architecture, a repo they rarely touch), flag those packets as outside the owner's validated-intuition zone and give them more of the evidence layer by default.

### 4.6 What each format puts first

| Format | First thing the reader sees | Assumes the reader will |
|---|---|---|
| BLUF memo (AR 25-50) | The recommendation or main point | Approve or ask questions |
| Completed staff work | A document ready to sign | Approve or disapprove only |
| PDB article | The assessed judgment, one item | Read a handful, chosen for them |
| Amazon six-pager | Narrative context and tenets | Read all of it, silently, then debate |
| SA-oriented display | Current state and projection | Act on what comes next |
| RPD-friendly brief | One course of action plus its failure mode | Simulate it mentally |

The fastest path to a good call for an executive, across these, is: the decision itself, the recommended answer, its consequences and reversibility, the one thing that would make it wrong; reasoning available on demand.

---

## 5. Batching versus interleaving

### 5.1 Grouping reduces switching, but sequences create bias

- **Finding**: Batching similar tasks reduces switch costs (section 1.3). But consecutive similar decisions are not independent: asylum judges, loan officers, and baseball umpires show negative autocorrelation (after approving several in a row, they become more likely to reject the next), strongest when cases are similar and close in time and among less experienced decision makers (Chen, Moskowitz & Shue 2016). Speed-dating evaluators were less likely to say yes after a highly attractive previous partner, a short-lived contrast effect (Bhargava & Fisman 2014).
- **Strength**: Supported (large field datasets across three domains; contrast effects found in several further settings).
- **Sources**: Chen, D. L., Moskowitz, T. J., & Shue, K. (2016). Decision making under the gambler's fallacy: evidence from asylum judges, loan officers, and baseball umpires. *Quarterly Journal of Economics* 131(3), 1181-1241. https://www.nber.org/papers/w22026. Bhargava, S., & Fisman, R. (2014). Contrast effects in sequential decisions: evidence from speed dating. *Review of Economics and Statistics* 96(3), 444-457. https://ideas.repec.org/a/tpr/restat/v96y2014i3p444-457.html
- **Implication**: Grouping by initiative and repo is right for context loading, but a long run of near-identical asks invites both reflexive approval (drift to default) and a spurious "I've said yes too often, this one must be wrong". Collapse near-identical asks into one decision rather than asking them in sequence; judge each remaining ask against a stated absolute criterion (the acceptance criteria, the risk class) rather than against its neighbours; and do not show running approve/override tallies during a session.

### 5.2 Order effects: the parole board study and its critiques

- **Finding**: Danziger et al. (2011) reported favourable Israeli parole rulings falling from about 65% to near zero within each session and resetting after food breaks. Critics showed that case order was not random (unrepresented prisoners tended to come last; Weinshall-Margel & Shapard 2011) and that a rational judge who avoids starting a long favourable hearing just before a break reproduces much of the pattern (Glöckner 2016); the effect size is implausibly large for a psychological effect.
- **Strength**: Contested. The original magnitude should not be cited as evidence of decision fatigue.
- **Sources**: Danziger, S., Levav, J., & Avnaim-Pesso, L. (2011). Extraneous factors in judicial decisions. *PNAS* 108(17), 6889-6892. https://doi.org/10.1073/pnas.1018033108 †(DOI). Weinshall-Margel, K., & Shapard, J. (2011). Overlooked factors in the analysis of parole decisions. *PNAS* 108(42), E833 †. Glöckner, A. (2016). The irrational hungry judge effect revisited: simulations reveal that the magnitude of the effect is overestimated. *Judgment and Decision Making* 11(6), 601-610. https://dlab.sauder.ubc.ca/sjdm/journal/16/16823/jdm16823.html
- **Implication**: Order effects are real enough (5.1, 1.2) to design for, but the parole study is not the evidence. The cheap, robust move is ordering by stakes: high-stakes asks first in a session, while attention is fresh, regardless of the mechanism.

### 5.3 Defaults and choice architecture

- **Finding**: Opt-out organ-donation countries showed far higher consent than opt-in countries (Johnson & Goldstein 2003). A meta-analysis of 58 default studies (N = 73,675) found a substantial average effect (d = 0.68), very heterogeneous, larger when the default is read as an endorsement or as the status quo (Jachimowicz et al. 2019); publication bias in the nudge literature is a live concern.
- **Strength**: Replicated in direction; effect size varies widely and is probably inflated by publication bias.
- **Sources**: Johnson, E. J., & Goldstein, D. (2003). Do defaults save lives? *Science* 302(5649), 1338-1339. https://doi.org/10.1126/science.1091721 †(DOI). Jachimowicz, J. M., Duncan, S., Weber, E. U., & Johnson, E. J. (2019). When and why defaults influence decisions: a meta-analysis of default effects. *Behavioural Public Policy* 3(2), 159-186. https://ideas.repec.org/a/cup/bpubpo/v3y2019i02p159-186_00.html
- **Implication**: An agent's recommended verdict is an endorsement default, the strongest kind. It will dominate. That is acceptable for routine parts (it is the point of the queue) and dangerous for judgment calls. Pre-selecting "approve" on a "Decide:" block is the same as opt-out consent; leave judgment calls unselected and pre-select only routine parts.

### 5.4 Management by exception

- **Finding**: Taylor's "exception principle" (managers should receive only condensed, comparative reports, with exceptions to the standard brought to their attention) and its later formalisation as management by exception are the managerial ancestor of tiered alerting.
- **Strength**: Doctrine. Its empirical analogue is the alert-tiering evidence in section 3 (Shah 2006), which is supported.
- **Sources**: Taylor, F. W. (1903). *Shop Management* †. Bittel, L. R. (1964). *Management by Exception*. McGraw-Hill †. Shah et al. (2006), above.
- **Implication**: The default state of an agent hand-over should be "proceeds unless the owner objects", with explicit criteria that promote a part to an exception requiring the owner. The owner sees routine parts as a count and a list, not as asks.

---

## 6. Human-agent teaming and adjustable autonomy

### 6.1 Levels and stages of automation

- **Finding**: Sheridan & Verplank (1978) defined a ladder from "human does everything" through "computer suggests", "computer executes if human approves", "computer executes and informs", to full autonomy. Parasuraman, Sheridan & Wickens (2000) split this across four stages (information acquisition, analysis, decision selection, action implementation), each automatable to a different level. Onnasch et al.'s meta-analysis (18 experiments) found higher degrees of automation improve routine performance and reduce workload but worsen performance when the automation fails and erode situation awareness: the "lumberjack" effect (the higher the tree, the harder the fall).
- **Strength**: Framework: doctrine-level consensus in human factors. Routine-versus-failure trade-off: replicated (meta-analysis).
- **Sources**: Sheridan, T. B., & Verplank, W. L. (1978). Human and computer control of undersea teleoperators. MIT Man-Machine Systems Lab, DTIC ADA057655. https://ntrl.ntis.gov/NTRL/dashboard/searchResults/titleDetail/ADA057655.xhtml. Parasuraman, R., Sheridan, T. B., & Wickens, C. D. (2000). A model for types and levels of human interaction with automation. *IEEE Transactions on Systems, Man, and Cybernetics, Part A* 30(3), 286-297. https://doi.org/10.1109/3468.844354. Onnasch, L., Wickens, C. D., Li, H., & Manzey, D. (2014). Human performance consequences of stages and levels of automation: an integrated meta-analysis. *Human Factors* 56(3), 476-488. https://depositonce.tu-berlin.de/items/7df9879f-d77b-4f2b-8760-f0e3d174ca67
- **Implication**: The queue sits at "computer executes if human approves" for everything today. It should run different decision classes at different levels: e.g. dependency patch bumps and docs-only PRs at "executes and informs" (visible in a digest), ordinary PRs at "executes if approved, recommended verdict preselected", design calls and anything irreversible at "computer suggests, human decides". The lumberjack effect means raising autonomy must come with a way to keep the owner's model of the system current: digests, spot audits, and a clear trail when something auto-approved later breaks.

### 6.2 What should escalate

- **Finding**: Parasuraman et al. (2000) recommend choosing levels by the consequences of automation error and by reliability; high-risk, irreversible decision functions warrant lower automation levels. Kahneman & Klein (2009) add that human intuition is reliable only in high-validity, high-feedback domains. Goddard et al. (2012) and Kim et al. (2024) indicate that the aid's own uncertainty is a usable signal for when human checking adds most.
- **Strength**: Supported as design guidance (derived from the above evidence; no direct trial of escalation rules for coding agents).
- **Sources**: As above.
- **Implication**: Escalate a part to an owner ask when any of these hold: it is hard to reverse (data migrations, releases, deletions, force pushes, public API or schema changes, auth behaviour); it is a product, taste, priority, scope, or budget choice (the owner's own CLAUDE.md already draws this line); it crosses repos within an initiative; the agent reports low confidence; or it contradicts an earlier owner ruling. Everything else defaults to the agent's verdict, visible but not asked.

### 6.3 Calibrating trust over time

- **Finding**: Lee & See (2004) define appropriate reliance as trust matched to the automation's actual capability (calibration) and fine-grained enough to distinguish where it is and is not capable (resolution). Trust tracks observed performance, so calibration needs feedback about outcomes; poor calibration yields either misuse (overtrust) or disuse (distrust).
- **Strength**: Replicated as a framework; the most-cited model in the field.
- **Sources**: Lee, J. D., & See, K. A. (2004). Trust in automation: designing for appropriate reliance. *Human Factors* 46(1), 50-80. https://doi.org/10.1518/hfes.46.1.50_30392 †(DOI); full text https://csel.eng.ohio-state.edu/productions/intel/research/trust/Lee%20%26%20See%20Trust%20Review.pdf
- **Implication**: The queue should keep an outcome ledger per decision class (and per repo or agent type): how often the owner overrode the recommendation, and how often an approved part was later reverted, hotfixed, or flagged in CI or close review. Show the owner that record next to the recommendation for the class ("this class: 41 approved, 0 reverted"). Use it to move classes up the autonomy ladder (to "executes and informs") or down (back to asks) with the owner's sign-off. Resolution matters: track by class, not one global "agent accuracy" number, so a strong record on docs PRs does not lend unearned trust to schema changes.

---

## 7. Where the evidence conflicts

1. **Explanations**: they increase acceptance regardless of correctness (Bansal 2021, Steyvers 2025) and reduce overreliance when they cut verification cost (Vasconcelos 2023). Reconciliation used below: explanations should be verification aids (evidence, tests, the failure mode), not persuasive narrative.
2. **Provisional-first and forcing functions**: they reduce overreliance (Buçinca 2021, Fogliato 2022) but are disliked and reduce agreement with correct advice too. Reconciliation: apply only to the small top tier.
3. **Batching**: it reduces switch costs (Monsell, Leroy) but sequential similar decisions show gambler's-fallacy and contrast effects (Chen 2016, Bhargava & Fisman 2014). Reconciliation: batch by context, collapse near-duplicates into single decisions, judge against absolute criteria.
4. **Decision fatigue**: the lab mechanism failed replication (Hagger 2016, Vohs 2021); field drift-to-default is observed (Linder 2014, Hirshleifer 2019) but is correlational, and the most famous field example (parole) is substantially an artefact. Reconciliation: design for drift because it is cheap to do so; do not claim a mechanism.
5. **BLUF versus narrative**: bullets scan fast; narrative carries reasoning (Bezos, Tufte). Reconciliation: layer by depth.
6. **Defaults**: they are the point of the queue (speed) and the main rubber-stamping risk. Reconciliation: preselect only routine parts.

---

## 8. Ranked design principles

Ranked by expected effect on decision quality per unit of build effort.

1. **One change, one ask.** Before a packet reaches the owner, de-duplicate across packets: the same PR, design call, or follow-up appearing in several hand-overs collapses into one item that links to every packet that raised it. A later packet that touches an already-decided item shows "decided on <date>: <verdict>" instead of asking again. *Rests on*: Ancker 2017 (repeats and per-encounter volume degrade acceptance), van der Sijs 2006 and Nanji 2018 (override rates under volume), Leroy 2009 and Monsell 2003 (meeting a change twice is pure switch cost).

2. **Tier every part and cap the asks at three per packet.** Each part is either an *ask* (needs the owner) or *routine* (proceeds on the agent's verdict, shown as a collapsed count). A part becomes an ask only by named rule: irreversible, public surface/schema/auth, cross-repo, product/taste/priority/scope/budget, agent low confidence, or contradicts a prior ruling. Show at most three asks above the fold; if an agent produces more, the packet is not completed staff work and goes back or splits. *Rests on*: Cowan 2001, Shah 2006 (tiering raised interruptive acceptance to 67%), Parasuraman et al. 2000 (levels by consequence of error), completed staff work doctrine.

3. **Top of packet in a fixed order: decision, recommendation, consequences, the one thing that would make it wrong.** Headline states the decision; then the asks; then "If you approve" with reversibility and cross-repo effects; then "what I did not check"; detail collapsed. Above-the-fold budget about 150 words. *Rests on*: AR 25-50 BLUF, Endsley 1995 (foreground projection), Klein 1988 (one course plus its failure mode for mental simulation), Tufano 2025 (reviewers anchor on what the AI flagged, so name the blind spot).

4. **Judgment calls get a provisional lean before the recommendation is revealed; routine parts show it immediately.** On "Decide:" blocks, show options and evidence, take a one-tap lean, then reveal the agent's pick and highlight disagreement. *Rests on*: Fogliato 2022, Buçinca 2021. *Conflict flagged*: forcing is disliked and lowers agreement with correct advice too; restricting it to the capped top tier is the compromise.

5. **Rationale is short, verification-shaped, and calibrated.** Each recommendation carries a first-person confidence statement with a reason, plus evidence the owner can check in seconds (test result, diff stat, CI link). No narrative above the fold; length is never used to persuade. Low confidence auto-promotes a part to an ask. *Rests on*: Bansal 2021, Steyvers 2025, Kim 2024, Vasconcelos 2023, Perry 2023. *Conflict flagged*: explanations can raise or lower overreliance; this resolves it toward verification aids.

6. **Preselect verdicts only on routine parts; whole-packet approve unlocks after every ask is answered.** Asks start unselected. Overriding a single part is one click. Each decision is logged with its time and whether it matched the recommendation. *Rests on*: Johnson & Goldstein 2003, Jachimowicz 2019 (endorsement defaults are the strongest), Skitka et al. 2000 and Goddard 2012 (accountability reduces automation bias).

7. **Review in scheduled windows, one initiative at a time, never by push.** Packets accumulate silently; the owner opens a window, the queue presents initiative, then repo, then packet. Only a genuinely blocking ask (an agent idle on it) may notify. *Rests on*: Mark 2008, Leroy 2009, Monsell 2003; consistent with the owner's calm-desktop rule.

8. **Order by stakes and bound the session.** Within a window, highest-stakes asks first; the queue suggests a break after about 20 minutes or ten judgment calls and never places an ask after a long run of routine approvals. *Rests on*: See 1995 and Warm 2008 (vigilance decrement), Linder 2014 and Hirshleifer 2019 (field drift to default). *Conflict flagged*: the ego-depletion mechanism failed replication (Hagger 2016, Vohs 2021) and the parole study is largely artefact (Glöckner 2016); the design rests on vigilance and field drift, not depletion.

9. **Judge against criteria, not neighbours.** Each ask shows its acceptance criteria or risk class; near-identical asks in a batch merge into one decision; no running approve/override tally is shown mid-session. *Rests on*: Chen et al. 2016, Bhargava & Fisman 2014. *Conflict flagged*: batching cuts switch costs but invites sequence bias; merging similar asks addresses both.

10. **Calibrate autonomy per decision class from an outcome ledger, with spot audits.** Track per class the override rate and the later-revert rate; show it beside each recommendation; promote clean classes to "executes and informs" (digest only) and demote classes that break, each move confirmed by the owner. Randomly sample a few auto-approved items per week for the owner to inspect. *Rests on*: Lee & See 2004, Parasuraman et al. 2000, Onnasch et al. 2014 (higher automation hurts failure detection), Parasuraman & Manzey 2010 (practice does not cure complacency).

11. **Follow-ups are a separate, passive lane.** Found-but-not-done items never interleave with PR approvals; they default to "log to backlog", de-duplicate against the existing backlog, and are triaged in a weekly batch. *Rests on*: management by exception (Taylor; Shah 2006), Ancker 2017, Cowan 2001.
