# Roadmap — Definition of Done

Scope locked in as of this doc. No new tangents (new features, new
sections, new patterns beyond this list) until everything below is
checked off. If something new comes up, it goes on a "later" list, not
into the current sprint.

## Workstream 1: LeetCode depth (not breadth)
Target: ~75 questions total (currently 61 exist — roughly 14 more to add
LATER, after depth work is done, not before). Every question needs a
real `approach` field (the "how it works" walkthrough), not just a
one-line hint.

- [x] 9/61 questions have a written `approach` (the original foundational 8 + Two Sum)
- [ ] Batch A: 18 questions — Arrays & Hashing, remaining Two Pointers, remaining Sliding Window
- [ ] Batch B: 20 questions — Stack, Binary Search, first 6 Linked List
- [ ] Batch C: 15 questions — remaining Linked List, Trees
- [ ] Then: add ~14 more questions (to reach ~75) WITH approach included from the start — no more backfill debt going forward

## Workstream 2: System Design — finish the 18 imported topics (no new topics)
Every topic needs its `followup_answers` filled in (TinyURL already done,
proving the format).

- [x] TinyURL (4/4 answered)
- [ ] Social Media: News Feed, Messaging, Online Presence, Comments/Links
- [ ] Inventory: Amazon, TicketMaster, Instacart, Cinemark
- [ ] Video: Upload, Streaming, Feed, Recommendations
- [ ] Infra: Rate Limiter, Job Scheduler, Crawler
- [ ] Maps: Uber Matching, Heat Map, IoT

## Workstream 3: Interactive pattern lessons — 8-10 highest-value patterns only
Sliding Window is done (proves the format: concept+diagram → recognize →
reason why → time complexity → space complexity → data structure →
practice). Same 7-step shape for each of these:

- [x] Sliding Window
- [ ] Two Pointers
- [ ] Fast & Slow Pointers
- [ ] BFS
- [ ] DFS
- [ ] Binary Search
- [ ] Backtracking
- [ ] Trees (recursive traversal)
- [ ] Dynamic Programming (once it exists as a pattern — currently doesn't)

## Explicitly OUT of scope until the above is done
- More system design topics beyond the 19
- More than ~75 LeetCode questions
- Interactive lessons beyond the 8-10 listed
- Any new dashboard/UI features
- Real diagram image uploads (still available if you have them, but not something to chase proactively)

## Working process going forward
- One workstream item per turn, finished completely, before starting the next
- Batches bundled bigger (fewer separate zip/SQL round-trips) to cut down on the copy-paste cycles
- This file gets checked off as we go — if progress stalls or drifts, point back to this doc
