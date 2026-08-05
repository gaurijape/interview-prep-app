-- Content batch 2: Prefix Sum, Backtracking (Subsets), Dijkstra
-- + CDN and Rate Limiter components.
-- Same format as before — run after content_batch_1.sql, plain "Run" button.

-- ============ PATTERN: Prefix Sum ============

insert into patterns (slug, name, category, description, recognition_cues) values
('prefix-sum', 'Prefix Sum', 'Arrays & Strings',
 'Precompute cumulative sums so any range sum can be answered in O(1), instead of re-summing the range each time.',
 'Look for: many repeated "sum of subarray from i to j" queries, or "subarray sum equals K" (often combined with a hash map of prefix sums seen so far).');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'subarray-sum-equals-k', 'Subarray Sum Equals K',
  'https://leetcode.com/problems/subarray-sum-equals-k/',
  'medium', id,
  'Given an array of integers and an integer k, return the total number of subarrays whose sum equals k.',
  'public int subarraySum(int[] nums, int k) {\n    Map<Integer, Integer> prefixCount = new HashMap<>();\n    prefixCount.put(0, 1);\n    int sum = 0, count = 0;\n    for (int num : nums) {\n        sum += num;\n        count += prefixCount.getOrDefault(sum - k, 0);\n        prefixCount.merge(sum, 1, Integer::sum);\n    }\n    return count;\n}',
  'O(n)', 'O(n)',
  array['If prefixSum[j] - prefixSum[i] == k, the subarray between i and j sums to k — so you''re really just looking up (sum - k) in a running map.']
from patterns where slug = 'prefix-sum';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  '"Count subarrays that sum to exactly K" — which pattern?',
  '["Prefix Sum", "Sliding Window", "Two Pointers", "Dynamic Programming"]'::jsonb,
  'Prefix Sum',
  'Sliding window fails here because the array can contain negative numbers, so the window can''t be grown/shrunk based on a simple comparison — prefix sums plus a hash map handle negatives correctly.'
from questions where slug = 'subarray-sum-equals-k';

-- ============ PATTERN: Backtracking (Subsets) ============

insert into patterns (slug, name, category, description, recognition_cues) values
('backtracking-subsets', 'Backtracking — Subsets', 'Backtracking',
 'Build up a combination/subset incrementally, recursing forward and undoing ("backtracking") the last choice before trying the next one.',
 'Look for: "return all possible subsets/combinations/permutations", where the answer is a list of lists and brute-force enumeration is expected.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'subsets', 'Subsets',
  'https://leetcode.com/problems/subsets/',
  'medium', id,
  'Given an integer array of unique elements, return all possible subsets (the power set).',
  'public List<List<Integer>> subsets(int[] nums) {\n    List<List<Integer>> result = new ArrayList<>();\n    backtrack(nums, 0, new ArrayList<>(), result);\n    return result;\n}\n\nprivate void backtrack(int[] nums, int start, List<Integer> current, List<List<Integer>> result) {\n    result.add(new ArrayList<>(current));\n    for (int i = start; i < nums.length; i++) {\n        current.add(nums[i]);\n        backtrack(nums, i + 1, current, result);\n        current.remove(current.size() - 1);\n    }\n}',
  'O(n * 2^n)', 'O(n) recursion depth',
  array['Every recursive call itself represents a valid subset — that''s why result.add() happens at the top, not just at a "base case".', 'Removing the last element after the recursive call is the "backtrack" step — without it, current would leak between branches.']
from patterns where slug = 'backtracking-subsets';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  '"Return every possible subset of an array" — which pattern?',
  '["Backtracking", "Dynamic Programming", "BFS", "Greedy"]'::jsonb,
  'Backtracking',
  'You need every combination explicitly enumerated, not just a count or optimum — that''s the signal for backtracking over DP, which would be used if you only needed a count or best value.'
from questions where slug = 'subsets';

-- ============ PATTERN: Dijkstra ============

insert into patterns (slug, name, category, description, recognition_cues) values
('dijkstra', 'Dijkstra''s Algorithm', 'Graph Algorithms',
 'Find shortest paths from a source in a weighted graph with non-negative edge weights, using a priority queue to always expand the closest unvisited node next.',
 'Look for: "shortest path" with weighted edges (unlike plain BFS, which only works on unweighted graphs), and all weights are non-negative.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'network-delay-time', 'Network Delay Time',
  'https://leetcode.com/problems/network-delay-time/',
  'medium', id,
  'Given a network of n nodes and weighted travel times between them, find the minimum time for a signal from node k to reach all nodes.',
  'public int networkDelayTime(int[][] times, int n, int k) {\n    Map<Integer, List<int[]>> graph = new HashMap<>();\n    for (int[] t : times) {\n        graph.computeIfAbsent(t[0], x -> new ArrayList<>()).add(new int[]{t[1], t[2]});\n    }\n    PriorityQueue<int[]> pq = new PriorityQueue<>((a, b) -> a[1] - b[1]);\n    pq.offer(new int[]{k, 0});\n    Map<Integer, Integer> dist = new HashMap<>();\n    while (!pq.isEmpty()) {\n        int[] cur = pq.poll();\n        int node = cur[0], d = cur[1];\n        if (dist.containsKey(node)) continue;\n        dist.put(node, d);\n        for (int[] edge : graph.getOrDefault(node, new ArrayList<>())) {\n            if (!dist.containsKey(edge[0])) {\n                pq.offer(new int[]{edge[0], d + edge[1]});\n            }\n        }\n    }\n    if (dist.size() != n) return -1;\n    return Collections.max(dist.values());\n}',
  'O(E log V)', 'O(V + E)',
  array['The priority queue always pops the currently-closest unvisited node — once a node is popped, its distance is final and can be skipped if seen again.']
from patterns where slug = 'dijkstra';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  '"Shortest time for a signal to reach all nodes, with weighted edges" — which pattern?',
  '["Dijkstra''s Algorithm", "BFS", "DFS", "Union-Find"]'::jsonb,
  'Dijkstra''s Algorithm',
  'Plain BFS only guarantees shortest path when every edge has equal weight; here edges have different weights, so a priority queue (Dijkstra) is needed to always expand the truly-closest node next.'
from questions where slug = 'network-delay-time';

-- ============ COMPONENT: CDN ============

insert into components (slug, name, category, description) values
('cdn', 'CDN (Content Delivery Network)', 'cdn',
 'A geographically distributed network of servers that cache static (and sometimes dynamic) content close to users, reducing latency and origin server load.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'Pull CDN',
  'Default choice for most sites — content is fetched from origin the first time it''s requested at a given edge location, then cached there.',
  'First request at each edge location is slow (cache miss), but requires zero manual upload/sync work — the CDN handles population automatically.',
  'Examples: Cloudflare, CloudFront in default mode.'
from components where slug = 'cdn'
union all
select id, 'Push CDN',
  'You control exactly when and where content is distributed — e.g. pre-warming caches globally before a big launch, or serving large media files that rarely change.',
  'You (or your pipeline) must proactively upload content to the CDN — more operational overhead, but no first-request latency penalty anywhere.',
  'Less common in interview answers; mention it only if the question specifically involves predictable, infrequently-changing large assets.'
from components where slug = 'cdn';

-- ============ COMPONENT: Rate Limiter ============

insert into components (slug, name, category, description) values
('rate-limiter', 'Rate Limiter', 'rate_limiter',
 'Restricts how many requests a client can make in a given time window, protecting backend services from overload or abuse.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'Token Bucket',
  'Need to allow short bursts of traffic while still enforcing an average rate over time (e.g. API rate limiting that tolerates occasional spikes).',
  'More complex to reason about than fixed windows, but avoids the "thundering herd at window boundary" problem — tokens refill continuously rather than resetting all at once.',
  'Most commonly cited answer in interviews for "design a rate limiter" — safe default unless the question wants strict, no-burst enforcement.'
from components where slug = 'rate-limiter'
union all
select id, 'Sliding Window Log',
  'Need precise, strictly accurate rate limiting (e.g. billing-related limits) where exact request timestamps matter.',
  'Most memory-intensive option — you store a timestamp per request per user — but gives exact correctness with no boundary edge cases.',
  null
from components where slug = 'rate-limiter'
union all
select id, 'Fixed Window Counter',
  'Simplest possible implementation when approximate limiting is good enough and engineering time is tight.',
  'Vulnerable to a burst of 2x the limit right at the boundary between two windows (e.g. max requests at 11:59:59 and again at 12:00:00) — the classic weakness to mention if asked about trade-offs.',
  'Good "naive first answer" in an interview, as long as you can name its boundary-burst flaw and what fixes it (token bucket or sliding window).'
from components where slug = 'rate-limiter';
