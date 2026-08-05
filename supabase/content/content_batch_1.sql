-- Content batch 1: Two Pointers, Fast & Slow Pointers, BFS, DFS
-- + Load Balancer and Message Queue components.
-- Same format as supabase/seed_example.sql — run after that file.

-- ============ PATTERN: Two Pointers ============

insert into patterns (slug, name, category, description, recognition_cues) values
('two-pointers', 'Two Pointers', 'Arrays & Strings',
 'Use two indices moving through a sequence (toward each other, or at different speeds) to avoid nested loops.',
 'Look for: sorted array + "find a pair/triplet that sums to X", "reverse in place", "remove duplicates in place", or comparing elements from both ends.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'two-sum-ii-sorted', 'Two Sum II — Input Array Is Sorted',
  'https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/',
  'medium', id,
  'Given a sorted array, find two numbers that add up to a target, return their 1-indexed positions.',
  'public int[] twoSum(int[] nums, int target) {\n    int left = 0, right = nums.length - 1;\n    while (left < right) {\n        int sum = nums[left] + nums[right];\n        if (sum == target) return new int[]{left + 1, right + 1};\n        if (sum < target) left++; else right--;\n    }\n    return new int[]{-1, -1};\n}',
  'O(n)', 'O(1)',
  array['Because the array is sorted, moving left increases the sum and moving right decreases it — no need to check both directions.']
from patterns where slug = 'two-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  'Sorted array, need a pair summing to a target, O(1) extra space — which pattern?',
  '["Two Pointers", "Sliding Window", "Binary Search", "Hash Map"]'::jsonb,
  'Two Pointers',
  'A hash map also solves this in O(n) but uses O(n) space; two pointers exploits the sorted order to do it in O(1) space — that trade-off is the tell.'
from questions where slug = 'two-sum-ii-sorted';

-- ============ PATTERN: Fast & Slow Pointers ============

insert into patterns (slug, name, category, description, recognition_cues) values
('fast-slow-pointers', 'Fast & Slow Pointers', 'Linked Lists',
 'Two pointers move through a linked list at different speeds (typically 1x and 2x) to detect cycles or find midpoints without extra space.',
 'Look for: "detect a cycle", "find the middle of a linked list", or "find the start of a cycle" with a follow-up requiring O(1) space.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'linked-list-cycle', 'Linked List Cycle',
  'https://leetcode.com/problems/linked-list-cycle/',
  'easy', id,
  'Given the head of a linked list, determine if it has a cycle.',
  'public boolean hasCycle(ListNode head) {\n    ListNode slow = head, fast = head;\n    while (fast != null && fast.next != null) {\n        slow = slow.next;\n        fast = fast.next.next;\n        if (slow == fast) return true;\n    }\n    return false;\n}',
  'O(n)', 'O(1)',
  array['If there is a cycle, the fast pointer will eventually lap the slow one — think about why they must meet.']
from patterns where slug = 'fast-slow-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  'Detect a cycle in a linked list using O(1) extra space — which pattern?',
  '["Fast & Slow Pointers", "Hash Set", "Two Pointers", "DFS"]'::jsonb,
  'Fast & Slow Pointers',
  'A hash set also detects cycles but needs O(n) space to track visited nodes; fast/slow pointers (Floyd''s algorithm) does it in O(1) space.'
from questions where slug = 'linked-list-cycle';

-- ============ PATTERN: BFS ============

insert into patterns (slug, name, category, description, recognition_cues) values
('bfs', 'BFS (Breadth-First Search)', 'Trees & Graphs',
 'Explore a tree/graph level by level using a queue — guarantees the shortest path in an unweighted graph.',
 'Look for: "shortest path" or "minimum number of steps" in an unweighted graph/grid, or "level order traversal" of a tree.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'binary-tree-level-order-traversal', 'Binary Tree Level Order Traversal',
  'https://leetcode.com/problems/binary-tree-level-order-traversal/',
  'medium', id,
  'Given a binary tree, return the level order traversal of its nodes'' values (left to right, level by level).',
  'public List<List<Integer>> levelOrder(TreeNode root) {\n    List<List<Integer>> result = new ArrayList<>();\n    if (root == null) return result;\n    Queue<TreeNode> queue = new LinkedList<>();\n    queue.add(root);\n    while (!queue.isEmpty()) {\n        int size = queue.size();\n        List<Integer> level = new ArrayList<>();\n        for (int i = 0; i < size; i++) {\n            TreeNode node = queue.poll();\n            level.add(node.val);\n            if (node.left != null) queue.add(node.left);\n            if (node.right != null) queue.add(node.right);\n        }\n        result.add(level);\n    }\n    return result;\n}',
  'O(n)', 'O(n)',
  array['Capture queue.size() before the inner loop — that''s what separates one level from the next.']
from patterns where slug = 'bfs';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  '"Return the tree''s nodes grouped by level" — which pattern?',
  '["BFS", "DFS", "Backtracking", "Union-Find"]'::jsonb,
  'BFS',
  'Grouping by level is BFS''s natural output, since it visits nodes in level order using a queue; DFS would visit a full branch before returning to a sibling.'
from questions where slug = 'binary-tree-level-order-traversal';

-- ============ PATTERN: DFS ============

insert into patterns (slug, name, category, description, recognition_cues) values
('dfs', 'DFS (Depth-First Search)', 'Trees & Graphs',
 'Explore as far as possible down one branch before backtracking — implemented recursively or with an explicit stack.',
 'Look for: "path from root to leaf", "all paths", "connected components", "number of islands", or anything asking you to explore every branch fully.');

insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'number-of-islands', 'Number of Islands',
  'https://leetcode.com/problems/number-of-islands/',
  'medium', id,
  'Given a 2D grid of ''1''s (land) and ''0''s (water), count the number of islands.',
  'public int numIslands(char[][] grid) {\n    int count = 0;\n    for (int r = 0; r < grid.length; r++) {\n        for (int c = 0; c < grid[0].length; c++) {\n            if (grid[r][c] == ''1'') {\n                count++;\n                dfs(grid, r, c);\n            }\n        }\n    }\n    return count;\n}\n\nprivate void dfs(char[][] grid, int r, int c) {\n    if (r < 0 || c < 0 || r >= grid.length || c >= grid[0].length || grid[r][c] != ''1'') return;\n    grid[r][c] = ''0''; // mark visited\n    dfs(grid, r + 1, c);\n    dfs(grid, r - 1, c);\n    dfs(grid, r, c + 1);\n    dfs(grid, r, c - 1);\n}',
  'O(rows * cols)', 'O(rows * cols) worst case (recursion stack)',
  array['Sink each land cell to ''0'' once visited so you never recount it — that''s your visited-set substitute.']
from patterns where slug = 'dfs';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition',
  '"Count connected groups of land cells in a grid" — which pattern?',
  '["DFS", "BFS", "Two Pointers", "Dynamic Programming"]'::jsonb,
  'DFS',
  'Both DFS and BFS can solve this correctly — but DFS is the more natural fit here since you just need to fully mark each connected component, with no shortest-path requirement to justify BFS''s queue.'
from questions where slug = 'number-of-islands';

-- ============ COMPONENT: Load Balancer ============

insert into components (slug, name, category, description) values
('load-balancer', 'Load Balancer', 'load_balancer',
 'Distributes incoming traffic across multiple backend servers to avoid overloading any single one and to enable horizontal scaling.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'L4 (Transport layer)',
  'Need raw throughput and low latency; routing decisions don''t need to inspect HTTP content (e.g. TCP-level load balancing for a database proxy).',
  'Faster and simpler than L7, but can''t route based on URL path, headers, or cookies — it only sees IP/port.',
  'Examples: AWS NLB, basic HAProxy TCP mode.'
from components where slug = 'load-balancer'
union all
select id, 'L7 (Application layer)',
  'Need content-aware routing — e.g. route /api/* to one service and /static/* to another, or route based on cookies for session affinity.',
  'More CPU overhead per request since it parses HTTP, but far more flexible.',
  'Examples: AWS ALB, NGINX, HAProxy HTTP mode. Most interview answers default here unless the question specifically calls for raw TCP.'
from components where slug = 'load-balancer';

-- ============ COMPONENT: Message Queue ============

insert into components (slug, name, category, description) values
('message-queue', 'Message Queue', 'queue',
 'Decouples producers from consumers, buffering work so spikes in load don''t overwhelm downstream services, and enabling async processing.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'Kafka',
  'High-throughput event streaming where multiple consumers need to independently replay the same stream (e.g. analytics + notifications both reading order events).',
  'Messages persist on a log and consumers track their own offset, so replay is easy — but operationally heavier to run and reason about than a simple queue.',
  'Think "event log" more than "task queue" — great when history/replay matters.'
from components where slug = 'message-queue'
union all
select id, 'RabbitMQ',
  'Classic task-queue semantics — a job should be picked up by exactly one worker (e.g. background job processing, order fulfillment tasks).',
  'Simpler mental model than Kafka (message is gone once acknowledged), but not built for replay or multiple independent consumer groups reading the same history.',
  null
from components where slug = 'message-queue'
union all
select id, 'SQS',
  'Fully managed, "just works" queue when you''re already on AWS and don''t want to operate the infrastructure yourself.',
  'Less flexible than Kafka/RabbitMQ (fewer delivery guarantees/ordering options, though FIFO queues exist), but zero operational burden.',
  'Good default answer in an interview when asked "how would you decouple these two services" without needing to justify running your own cluster.'
from components where slug = 'message-queue';
