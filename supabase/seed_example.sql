-- One worked example of each content type, so you can see the app render
-- something real before writing the full content library.

insert into patterns (slug, name, category, description, recognition_cues) values
('sliding-window', 'Sliding Window', 'Arrays & Strings',
 'Maintain a window over a contiguous range of a sequence, expanding and shrinking it to satisfy a condition.',
 'Look for: "contiguous subarray/substring", "at most/exactly K distinct", or a running sum/count that updates incrementally as you move one pointer.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'longest-substring-without-repeating-characters',
  'Longest Substring Without Repeating Characters',
  'https://leetcode.com/problems/longest-substring-without-repeating-characters/',
  'medium', id,
  'Given a string, find the length of the longest substring without repeating characters.',
  'public int lengthOfLongestSubstring(String s) {\n    Set<Character> seen = new HashSet<>();\n    int left = 0, maxLen = 0;\n    for (int right = 0; right < s.length(); right++) {\n        while (seen.contains(s.charAt(right))) {\n            seen.remove(s.charAt(left));\n            left++;\n        }\n        seen.add(s.charAt(right));\n        maxLen = Math.max(maxLen, right - left + 1);\n    }\n    return maxLen;\n}',
  'O(n)', 'O(min(n, charset size))',
  array['Think about what to do when you see a duplicate character.', 'You never need to move `left` backwards.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  'Which pattern fits: "find the longest substring with no repeating characters"?',
  '["Sliding Window", "Two Pointers (fixed)", "Binary Search", "Dynamic Programming"]'::jsonb,
  'Sliding Window',
  'The window (substring) grows and shrinks as duplicates are found — the defining shape of sliding window problems.'
from questions where slug = 'longest-substring-without-repeating-characters';

insert into components (slug, name, category, description) values
('cache', 'Cache', 'cache', 'A fast, usually in-memory store that sits in front of a slower data source to reduce latency and load.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'Redis',
  'Need data structures (sorted sets, lists, pub/sub) beyond simple key-value, or need persistence options.',
  'In-memory (fast) but single-threaded per core; clustering adds operational complexity; costs more than Memcached at the same memory footprint.',
  'Most common default choice in interviews — safe to reach for unless the question specifically wants pure simplicity.'
from components where slug = 'cache'
union all
select id, 'Memcached',
  'Pure key-value caching at very high throughput with the simplest possible operational model.',
  'No persistence, no rich data structures, no built-in replication — purely ephemeral cache.',
  null
from components where slug = 'cache';
