-- NeetCode 150 — Batch 2: Stack (7/7), Binary Search (7/7), Linked List (6/11)
-- Uses dollar-quoting with REAL embedded newlines for Java code.
-- Run in Supabase SQL Editor, plain "Run" button.

-- ============ NEW PATTERN: Stack ============

insert into patterns (slug, name, category, description, recognition_cues) values
('stack', 'Stack', 'Stack / Queue',
 'Use a stack (last-in-first-out) to track state that needs to be "undone" or matched in reverse order — like nested brackets, or the most recent unresolved item.',
 'Look for: matching pairs (parentheses/brackets), "next greater element", undo operations, or anything where the most RECENTLY seen unresolved item needs to be checked first.');

-- 1. Valid Parentheses
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'valid-parentheses', 'Valid Parentheses', 'https://leetcode.com/problems/valid-parentheses/', 'easy', id,
  'Given a string containing just the characters ()[]{} , determine if the input string is valid (every open bracket is closed by the same type, in the correct order).',
$$public boolean isValid(String s) {
    Deque<Character> stack = new ArrayDeque<>();
    Map<Character, Character> pairs = Map.of(')', '(', ']', '[', '}', '{');
    for (char c : s.toCharArray()) {
        if (pairs.containsKey(c)) {
            if (stack.isEmpty() || stack.pop() != pairs.get(c)) return false;
        } else {
            stack.push(c);
        }
    }
    return stack.isEmpty();
}$$,
  'O(n)', 'O(n)',
  array['Push every opening bracket. When you see a closing bracket, it must match whatever is currently on TOP of the stack — that''s the most recently opened, still-unclosed bracket.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Check if brackets are validly matched and nested" — which pattern?',
  '["Stack", "Two Pointers", "Queue", "Recursion only"]'::jsonb,
  'Stack',
  'The most recently opened bracket must be the next one closed — that LIFO ordering is exactly what a stack models.'
from questions where slug = 'valid-parentheses';

-- 2. Min Stack
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'min-stack', 'Min Stack', 'https://leetcode.com/problems/min-stack/', 'medium', id,
  'Design a stack that supports push, pop, top, and retrieving the minimum element, all in O(1) time.',
$$class MinStack {
    private Deque<Integer> stack = new ArrayDeque<>();
    private Deque<Integer> minStack = new ArrayDeque<>();

    public void push(int val) {
        stack.push(val);
        int currentMin = minStack.isEmpty() ? val : Math.min(val, minStack.peek());
        minStack.push(currentMin);
    }

    public void pop() {
        stack.pop();
        minStack.pop();
    }

    public int top() {
        return stack.peek();
    }

    public int getMin() {
        return minStack.peek();
    }
}$$,
  'O(1) for all operations', 'O(n)',
  array['Keep a second stack that tracks "the minimum so far" at each corresponding position — when you pop the main stack, pop the min-tracker too, so it always reflects the current state.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Design a stack with O(1) getMin()" — which technique?',
  '["Auxiliary stack tracking running minimum", "Sort on every push", "Binary Search", "Heap"]'::jsonb,
  'Auxiliary stack tracking running minimum',
  'A heap could track the min but pop() from an arbitrary position isn''t O(1) for a heap; a parallel stack that mirrors push/pop exactly keeps everything O(1).'
from questions where slug = 'min-stack';

-- 3. Evaluate Reverse Polish Notation
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'evaluate-reverse-polish-notation', 'Evaluate Reverse Polish Notation', 'https://leetcode.com/problems/evaluate-reverse-polish-notation/', 'medium', id,
  'Evaluate an arithmetic expression given in Reverse Polish (postfix) Notation.',
$$public int evalRPN(String[] tokens) {
    Deque<Integer> stack = new ArrayDeque<>();
    for (String token : tokens) {
        switch (token) {
            case "+" -> { int b = stack.pop(), a = stack.pop(); stack.push(a + b); }
            case "-" -> { int b = stack.pop(), a = stack.pop(); stack.push(a - b); }
            case "*" -> { int b = stack.pop(), a = stack.pop(); stack.push(a * b); }
            case "/" -> { int b = stack.pop(), a = stack.pop(); stack.push(a / b); }
            default -> stack.push(Integer.parseInt(token));
        }
    }
    return stack.pop();
}$$,
  'O(n)', 'O(n)',
  array['Push numbers. When you see an operator, pop the two most recent numbers, apply the operator, push the result back — postfix notation is built for exactly this stack-based evaluation.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Evaluate a postfix arithmetic expression" — which pattern?',
  '["Stack", "Recursion (tree-based)", "Two Pointers", "Queue"]'::jsonb,
  'Stack',
  'Postfix notation is specifically designed to be evaluated with a stack — operators always apply to the two most recently pushed operands.'
from questions where slug = 'evaluate-reverse-polish-notation';

-- 4. Generate Parentheses
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'generate-parentheses', 'Generate Parentheses', 'https://leetcode.com/problems/generate-parentheses/', 'medium', id,
  'Given n pairs of parentheses, generate all combinations of well-formed parentheses.',
$$public List<String> generateParenthesis(int n) {
    List<String> result = new ArrayList<>();
    backtrack(result, new StringBuilder(), 0, 0, n);
    return result;
}

private void backtrack(List<String> result, StringBuilder current, int open, int close, int n) {
    if (current.length() == 2 * n) {
        result.add(current.toString());
        return;
    }
    if (open < n) {
        current.append('(');
        backtrack(result, current, open + 1, close, n);
        current.deleteCharAt(current.length() - 1);
    }
    if (close < open) {
        current.append(')');
        backtrack(result, current, open, close + 1, n);
        current.deleteCharAt(current.length() - 1);
    }
}$$,
  'O(4^n / sqrt(n)) — Catalan number bound', 'O(n) recursion depth',
  array['Only add a closing bracket if fewer closes than opens have been placed so far — that constraint alone guarantees every generated string is validly matched, no post-hoc checking needed.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Generate all valid combinations of n pairs of parentheses" — which pattern?',
  '["Backtracking", "Stack (iterative)", "Dynamic Programming", "BFS"]'::jsonb,
  'Backtracking',
  'Even though the *validity check* for a single string uses stack-like reasoning (track open count), *generating all combinations* is a backtracking/enumeration problem — this pattern is filed under Stack in NeetCode''s categorization since it''s adjacent to the bracket-matching family, but the technique used is backtracking.'
from questions where slug = 'generate-parentheses';

-- 5. Daily Temperatures
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'daily-temperatures', 'Daily Temperatures', 'https://leetcode.com/problems/daily-temperatures/', 'medium', id,
  'Given daily temperatures, return an array where answer[i] is the number of days until a warmer temperature. If none, use 0.',
$$public int[] dailyTemperatures(int[] temperatures) {
    int[] result = new int[temperatures.length];
    Deque<Integer> stack = new ArrayDeque<>(); // indices, decreasing temps

    for (int i = 0; i < temperatures.length; i++) {
        while (!stack.isEmpty() && temperatures[i] > temperatures[stack.peek()]) {
            int prevIndex = stack.pop();
            result[prevIndex] = i - prevIndex;
        }
        stack.push(i);
    }
    return result;
}$$,
  'O(n)', 'O(n)',
  array['A monotonic decreasing stack of indices: when a warmer day arrives, it resolves every colder day still waiting on the stack, in one pass — each index is pushed and popped at most once.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Days until a warmer temperature, for every day, in O(n)" — which technique?',
  '["Monotonic Stack", "Two Pointers", "Sliding Window", "Binary Search"]'::jsonb,
  'Monotonic Stack',
  'A brute-force nested loop is O(n^2); a monotonic stack resolves each element exactly once by keeping only "still waiting for something bigger" indices on the stack.'
from questions where slug = 'daily-temperatures';

-- 6. Car Fleet
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'car-fleet', 'Car Fleet', 'https://leetcode.com/problems/car-fleet/', 'medium', id,
  'Cars travel to the same destination on a one-lane road. Given positions and speeds, return the number of car fleets that will arrive (cars that catch up to a slower car ahead form one fleet).',
$$public int carFleet(int target, int[] position, int[] speed) {
    int n = position.length;
    double[][] cars = new double[n][2];
    for (int i = 0; i < n; i++) {
        cars[i][0] = position[i];
        cars[i][1] = (double) (target - position[i]) / speed[i]; // time to reach target
    }
    Arrays.sort(cars, (a, b) -> Double.compare(b[0], a[0])); // by position, descending (closest to target first)

    int fleets = 0;
    double lastArrival = 0;
    for (double[] car : cars) {
        if (car[1] > lastArrival) { // this car arrives later than the fleet ahead — it's its own fleet
            fleets++;
            lastArrival = car[1];
        }
        // else: it catches up to the car ahead, joins that fleet, doesn't increase count
    }
    return fleets;
}$$,
  'O(n log n) — dominated by sorting', 'O(n)',
  array['Process cars from closest-to-target backward. A car that would arrive LATER than the fleet ahead of it starts a new fleet; one that would arrive sooner gets "absorbed" (it catches up and can''t pass).']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Cars catching up to slower cars ahead form fleets" — which pattern?',
  '["Monotonic Stack (conceptually) / sort + greedy scan", "Two Pointers", "Union-Find", "BFS"]'::jsonb,
  'Monotonic Stack (conceptually) / sort + greedy scan',
  'Sorted by position and scanned from the front car backward, tracking "the arrival time of the fleet ahead" behaves like a monotonic stack of arrival times, even though the implementation here is a simple running variable.'
from questions where slug = 'car-fleet';

-- 7. Largest Rectangle in Histogram
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'largest-rectangle-in-histogram', 'Largest Rectangle in Histogram', 'https://leetcode.com/problems/largest-rectangle-in-histogram/', 'hard', id,
  'Given an array of bar heights forming a histogram, find the area of the largest rectangle that fits within it.',
$$public int largestRectangleArea(int[] heights) {
    Deque<Integer> stack = new ArrayDeque<>(); // indices, increasing heights
    int maxArea = 0;

    for (int i = 0; i <= heights.length; i++) {
        int currentHeight = (i == heights.length) ? 0 : heights[i];
        while (!stack.isEmpty() && heights[stack.peek()] > currentHeight) {
            int height = heights[stack.pop()];
            int width = stack.isEmpty() ? i : i - stack.peek() - 1;
            maxArea = Math.max(maxArea, height * width);
        }
        stack.push(i);
    }
    return maxArea;
}$$,
  'O(n)', 'O(n)',
  array['A monotonic increasing stack of indices: when a shorter bar appears, it means every taller bar still on the stack has found its right boundary — pop and compute the rectangle each one could form.']
from patterns where slug = 'stack';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Largest rectangle that fits inside a histogram, in O(n)" — which technique?',
  '["Monotonic Stack", "Dynamic Programming (2D)", "Two Pointers", "Divide and Conquer only"]'::jsonb,
  'Monotonic Stack',
  'A divide-and-conquer approach also solves this in O(n log n); the monotonic stack achieves true O(n) by resolving each bar''s maximal rectangle exactly once, when a shorter bar reveals its right boundary.'
from questions where slug = 'largest-rectangle-in-histogram';


-- ============ NEW PATTERN: Binary Search ============

insert into patterns (slug, name, category, description, recognition_cues) values
('binary-search', 'Binary Search', 'Binary Search',
 'Repeatedly halve the search space by comparing the middle element against what you''re looking for — requires the search space to be sorted, or at least monotonic in some property.',
 'Look for: a sorted (or rotated-sorted) array, or a question that asks to minimize/maximize some value where "can we achieve X?" gets easier or harder monotonically as X changes.');

-- 1. Binary Search
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'binary-search', 'Binary Search', 'https://leetcode.com/problems/binary-search/', 'easy', id,
  'Given a sorted array and a target, return the index of the target, or -1 if not found — in O(log n).',
$$public int search(int[] nums, int target) {
    int left = 0, right = nums.length - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] == target) return mid;
        else if (nums[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}$$,
  'O(log n)', 'O(1)',
  array['left + (right - left) / 2 avoids integer overflow compared to (left + right) / 2 — a good habit even though it rarely matters at LeetCode''s input sizes.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Find a target in a sorted array in O(log n)" — which pattern?',
  '["Binary Search", "Two Pointers", "Linear Scan", "Hash Map"]'::jsonb,
  'Binary Search',
  'The O(log n) requirement combined with a sorted array is the clearest possible signal for binary search.'
from questions where slug = 'binary-search';

-- 2. Search a 2D Matrix
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'search-a-2d-matrix', 'Search a 2D Matrix', 'https://leetcode.com/problems/search-a-2d-matrix/', 'medium', id,
  'Given an m x n matrix where each row is sorted and the first element of each row is greater than the last element of the previous row, search for a target value.',
$$public boolean searchMatrix(int[][] matrix, int target) {
    int rows = matrix.length, cols = matrix[0].length;
    int left = 0, right = rows * cols - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        int value = matrix[mid / cols][mid % cols];
        if (value == target) return true;
        else if (value < target) left = mid + 1;
        else right = mid - 1;
    }
    return false;
}$$,
  'O(log(m*n))', 'O(1)',
  array['Treat the 2D matrix as if it were one flattened sorted 1D array — a virtual index divided/modulo by column count converts back to row/col.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Search a matrix that''s sorted like one long row" — which pattern?',
  '["Binary Search (treat as flattened array)", "BFS", "DFS", "Two Pointers"]'::jsonb,
  'Binary Search (treat as flattened array)',
  'Since the whole matrix is effectively one sorted sequence, standard binary search applies directly with a bit of index math to convert between 1D and 2D.'
from questions where slug = 'search-a-2d-matrix';

-- 3. Koko Eating Bananas
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'koko-eating-bananas', 'Koko Eating Bananas', 'https://leetcode.com/problems/koko-eating-bananas/', 'medium', id,
  'Koko eats bananas from piles at a constant speed k per hour. Given piles and h hours, find the minimum k such that she can eat all bananas within h hours.',
$$public int minEatingSpeed(int[] piles, int h) {
    int left = 1, right = Arrays.stream(piles).max().getAsInt();

    while (left < right) {
        int mid = left + (right - left) / 2;
        if (canFinish(piles, mid, h)) {
            right = mid; // try a slower (smaller) speed
        } else {
            left = mid + 1; // need to go faster
        }
    }
    return left;
}

private boolean canFinish(int[] piles, int speed, int h) {
    long hoursNeeded = 0;
    for (int pile : piles) {
        hoursNeeded += Math.ceil((double) pile / speed);
    }
    return hoursNeeded <= h;
}$$,
  'O(n log(max(piles)))', 'O(1)',
  array['This isn''t searching a sorted ARRAY — it''s "binary search on the answer": the speed k isn''t given directly, but "can Koko finish at speed k?" gets monotonically easier as k increases, which is what makes binary search work.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Find the minimum eating speed to finish in time" — which technique?',
  '["Binary Search on the Answer", "Greedy", "Dynamic Programming", "Two Pointers"]'::jsonb,
  'Binary Search on the Answer',
  'There''s no array being searched here — the search space is the range of possible speeds, and "can we finish at speed k" is a monotonic yes/no check, the hallmark of binary-search-on-the-answer.'
from questions where slug = 'koko-eating-bananas';

-- 4. Find Minimum in Rotated Sorted Array
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'find-minimum-in-rotated-sorted-array', 'Find Minimum in Rotated Sorted Array', 'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/', 'medium', id,
  'Given a rotated sorted array with no duplicates, find the minimum element in O(log n).',
$$public int findMin(int[] nums) {
    int left = 0, right = nums.length - 1;
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] > nums[right]) {
            left = mid + 1; // minimum is to the right of mid
        } else {
            right = mid; // minimum is at mid or to the left
        }
    }
    return nums[left];
}$$,
  'O(log n)', 'O(1)',
  array['Compare nums[mid] to nums[right], not nums[left] — that comparison reliably tells you which half is "properly sorted" and which half contains the rotation point.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Find the minimum in a rotated sorted array, O(log n)" — which pattern?',
  '["Modified Binary Search", "Linear Scan", "Two Pointers", "Divide and Conquer (unrelated to binary search)"]'::jsonb,
  'Modified Binary Search',
  'The array isn''t fully sorted, but at every step one half IS properly sorted — you can still discard half the search space each iteration, just with a trickier comparison.'
from questions where slug = 'find-minimum-in-rotated-sorted-array';

-- 5. Search in Rotated Sorted Array
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'search-in-rotated-sorted-array', 'Search in Rotated Sorted Array', 'https://leetcode.com/problems/search-in-rotated-sorted-array/', 'medium', id,
  'Given a rotated sorted array with no duplicates and a target, return its index, or -1 if not found, in O(log n).',
$$public int search(int[] nums, int target) {
    int left = 0, right = nums.length - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] == target) return mid;

        if (nums[left] <= nums[mid]) { // left half is sorted
            if (nums[left] <= target && target < nums[mid]) right = mid - 1;
            else left = mid + 1;
        } else { // right half is sorted
            if (nums[mid] < target && target <= nums[right]) left = mid + 1;
            else right = mid - 1;
        }
    }
    return -1;
}$$,
  'O(log n)', 'O(1)',
  array['At each step, figure out which HALF is sorted first (compare nums[left] to nums[mid]), then check if the target falls in that sorted half''s range — if not, it must be in the other half.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Find a target in a rotated sorted array, O(log n)" — which pattern?',
  '["Modified Binary Search", "Linear Scan", "Two Pointers", "BFS"]'::jsonb,
  'Modified Binary Search',
  'Same core idea as Find Minimum in Rotated Sorted Array — one half is always properly sorted, so you can still eliminate half the space each step.'
from questions where slug = 'search-in-rotated-sorted-array';

-- 6. Time Based Key-Value Store
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'time-based-key-value-store', 'Time Based Key-Value Store', 'https://leetcode.com/problems/time-based-key-value-store/', 'medium', id,
  'Design a time-based key-value store: set(key, value, timestamp) stores a value at a timestamp; get(key, timestamp) returns the value set at the largest timestamp <= the given timestamp.',
$$class TimeMap {
    private Map<String, List<int[]>> store = new HashMap<>(); // key -> list of [timestamp, valueIndex]
    private List<String> values = new ArrayList<>();

    public void set(String key, String value, int timestamp) {
        values.add(value);
        store.computeIfAbsent(key, k -> new ArrayList<>()).add(new int[]{timestamp, values.size() - 1});
    }

    public String get(String key, int timestamp) {
        List<int[]> entries = store.get(key);
        if (entries == null) return "";

        int left = 0, right = entries.size() - 1, resultIndex = -1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (entries.get(mid)[0] <= timestamp) {
                resultIndex = entries.get(mid)[1];
                left = mid + 1; // look for a later valid timestamp
            } else {
                right = mid - 1;
            }
        }
        return resultIndex == -1 ? "" : values.get(resultIndex);
    }
}$$,
  'O(log n) per get, O(1) per set', 'O(n)',
  array['Timestamps for a given key are set in increasing order, so the list is already sorted — binary search for the largest timestamp that''s <= the query timestamp.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Get the most recent value at or before a given timestamp" — which pattern?',
  '["Binary Search", "Hash Map only", "TreeMap-style balanced tree only", "Linear Scan"]'::jsonb,
  'Binary Search',
  'Since set() calls arrive with increasing timestamps per key, the per-key list is naturally sorted, so binary search finds the answer in O(log n) without needing a separate balanced tree structure.'
from questions where slug = 'time-based-key-value-store';

-- 7. Median of Two Sorted Arrays
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'median-of-two-sorted-arrays', 'Median of Two Sorted Arrays', 'https://leetcode.com/problems/median-of-two-sorted-arrays/', 'hard', id,
  'Given two sorted arrays, find the median of the two combined, in O(log(m+n)) time.',
$$public double findMedianSortedArrays(int[] nums1, int[] nums2) {
    if (nums1.length > nums2.length) return findMedianSortedArrays(nums2, nums1); // ensure nums1 is smaller

    int m = nums1.length, n = nums2.length;
    int left = 0, right = m;
    int half = (m + n + 1) / 2;

    while (left <= right) {
        int i = left + (right - left) / 2; // partition point in nums1
        int j = half - i;                  // partition point in nums2

        int left1 = (i == 0) ? Integer.MIN_VALUE : nums1[i - 1];
        int right1 = (i == m) ? Integer.MAX_VALUE : nums1[i];
        int left2 = (j == 0) ? Integer.MIN_VALUE : nums2[j - 1];
        int right2 = (j == n) ? Integer.MAX_VALUE : nums2[j];

        if (left1 <= right2 && left2 <= right1) {
            if ((m + n) % 2 == 0) {
                return (Math.max(left1, left2) + Math.min(right1, right2)) / 2.0;
            }
            return Math.max(left1, left2);
        } else if (left1 > right2) {
            right = i - 1;
        } else {
            left = i + 1;
        }
    }
    throw new IllegalArgumentException("Input arrays are not sorted");
}$$,
  'O(log(min(m,n)))', 'O(1)',
  array['Binary search for the correct PARTITION point in the smaller array (not for a value) — the partition is correct when everything on the left side of both arrays combined is <= everything on the right side.']
from patterns where slug = 'binary-search';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Median of two sorted arrays in O(log(m+n))" — which technique?',
  '["Binary Search on a partition point", "Merge then find middle", "Two Pointers", "Heap"]'::jsonb,
  'Binary Search on a partition point',
  'Merging first is the intuitive O(m+n) approach; the O(log(min(m,n))) solution binary searches for the correct split point between the two arrays instead of merging anything.'
from questions where slug = 'median-of-two-sorted-arrays';


-- ============ LINKED LIST: first 6 of 11 (new pattern) ============

insert into patterns (slug, name, category, description, recognition_cues) values
('linked-list', 'Linked List', 'Linked Lists',
 'Manipulate node pointers directly — reversing, merging, or rewiring a linked list in place, usually in O(1) extra space by tracking a small number of pointers as you traverse.',
 'Look for: "reverse a linked list", "merge two lists", questions about node.next rewiring, or needing O(1) space when an array-based solution would be trivial with extra space.');

-- 1. Reverse Linked List
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'reverse-linked-list', 'Reverse Linked List', 'https://leetcode.com/problems/reverse-linked-list/', 'easy', id,
  'Given the head of a singly linked list, reverse the list and return the new head.',
$$public ListNode reverseList(ListNode head) {
    ListNode prev = null, current = head;
    while (current != null) {
        ListNode next = current.next;
        current.next = prev;
        prev = current;
        current = next;
    }
    return prev;
}$$,
  'O(n)', 'O(1)',
  array['Save current.next BEFORE overwriting it — otherwise you lose the rest of the list once you rewire current.next to point backward.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Reverse a singly linked list in O(1) space" — which pattern?',
  '["Linked List (pointer rewiring)", "Stack (push all, pop to rebuild)", "Two Pointers", "Recursion only"]'::jsonb,
  'Linked List (pointer rewiring)',
  'A stack could also reverse it but costs O(n) space; walking once while rewiring each node''s next pointer achieves O(1) space.'
from questions where slug = 'reverse-linked-list';

-- 2. Merge Two Sorted Lists
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'merge-two-sorted-lists', 'Merge Two Sorted Lists', 'https://leetcode.com/problems/merge-two-sorted-lists/', 'easy', id,
  'Merge two sorted linked lists into one sorted list by splicing their nodes together.',
$$public ListNode mergeTwoLists(ListNode list1, ListNode list2) {
    ListNode dummy = new ListNode(-1);
    ListNode tail = dummy;

    while (list1 != null && list2 != null) {
        if (list1.val <= list2.val) {
            tail.next = list1;
            list1 = list1.next;
        } else {
            tail.next = list2;
            list2 = list2.next;
        }
        tail = tail.next;
    }
    tail.next = (list1 != null) ? list1 : list2;
    return dummy.next;
}$$,
  'O(n + m)', 'O(1) — reuses existing nodes',
  array['A dummy head node avoids annoying special-casing for "what''s the very first node of the result" — just return dummy.next at the end.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Merge two sorted linked lists" — which pattern?',
  '["Linked List (splice in place)", "Two Pointers on arrays", "Sorting", "Heap"]'::jsonb,
  'Linked List (splice in place)',
  'Since both inputs are already sorted, you just rewire next pointers to interleave them correctly — no new nodes needed, O(1) extra space.'
from questions where slug = 'merge-two-sorted-lists';

-- 3. Reorder List
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'reorder-list', 'Reorder List', 'https://leetcode.com/problems/reorder-list/', 'medium', id,
  'Given a linked list L0 -> L1 -> ... -> Ln, reorder it to L0 -> Ln -> L1 -> Ln-1 -> L2 -> Ln-2 -> ..., in place.',
$$public void reorderList(ListNode head) {
    // Step 1: find the middle (fast/slow pointers)
    ListNode slow = head, fast = head;
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }

    // Step 2: reverse the second half
    ListNode prev = null, current = slow.next;
    slow.next = null;
    while (current != null) {
        ListNode next = current.next;
        current.next = prev;
        prev = current;
        current = next;
    }

    // Step 3: merge the two halves, alternating
    ListNode first = head, second = prev;
    while (second != null) {
        ListNode firstNext = first.next;
        ListNode secondNext = second.next;
        first.next = second;
        second.next = firstNext;
        first = firstNext;
        second = secondNext;
    }
}$$,
  'O(n)', 'O(1)',
  array['This is really three earlier patterns chained together: find the middle (fast/slow pointers), reverse the second half (reverse linked list), then merge two lists by alternating — a good example of combining patterns.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Reorder a list to alternate first-half/reversed-second-half nodes" — which combination of patterns?',
  '["Fast/Slow Pointers + Reverse + Merge", "Binary Search", "Stack only", "Two Pointers only"]'::jsonb,
  'Fast/Slow Pointers + Reverse + Merge',
  'Recognizing that a hard problem decomposes into three easier patterns you already know is itself a key interview skill — this question is a great test of that.'
from questions where slug = 'reorder-list';

-- 4. Remove Nth Node From End of List
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'remove-nth-node-from-end-of-list', 'Remove Nth Node From End of List', 'https://leetcode.com/problems/remove-nth-node-from-end-of-list/', 'medium', id,
  'Given the head of a linked list, remove the nth node from the end and return the head, in one pass.',
$$public ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0, head);
    ListNode fast = dummy, slow = dummy;

    for (int i = 0; i < n; i++) {
        fast = fast.next;
    }
    while (fast.next != null) {
        fast = fast.next;
        slow = slow.next;
    }
    slow.next = slow.next.next;
    return dummy.next;
}$$,
  'O(n) — one pass', 'O(1)',
  array['Advance a "fast" pointer n steps ahead first, then move both pointers together — when fast reaches the end, slow is exactly at the node just before the one to remove.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Remove the nth node from the end, in ONE pass" — which pattern?',
  '["Two-pointer gap technique (fast/slow with a head start)", "Two-pass (count length, then remove)", "Recursion", "Stack"]'::jsonb,
  'Two-pointer gap technique (fast/slow with a head start)',
  'A two-pass solution (count the list length, then walk to the target) also works but requires two traversals; giving one pointer an n-step head start achieves it in one pass.'
from questions where slug = 'remove-nth-node-from-end-of-list';

-- 5. Copy List with Random Pointer
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'copy-list-with-random-pointer', 'Copy List with Random Pointer', 'https://leetcode.com/problems/copy-list-with-random-pointer/', 'medium', id,
  'A linked list has each node with an extra "random" pointer that can point to any node or null. Return a deep copy of the list.',
$$public Node copyRandomList(Node head) {
    if (head == null) return null;
    Map<Node, Node> oldToNew = new HashMap<>();

    Node current = head;
    while (current != null) {
        oldToNew.put(current, new Node(current.val));
        current = current.next;
    }

    current = head;
    while (current != null) {
        oldToNew.get(current).next = oldToNew.get(current.next);
        oldToNew.get(current).random = oldToNew.get(current.random);
        current = current.next;
    }
    return oldToNew.get(head);
}$$,
  'O(n)', 'O(n)',
  array['First pass: create every new node and map old-node -> new-node. Second pass: wire up next and random on the new nodes using the map — since the map already has every node created, random pointers to ANY node (even ones ahead) resolve correctly.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Deep copy a linked list where nodes have arbitrary random pointers" — which technique?',
  '["Hash Map (old node -> new node)", "Two Pointers", "Recursion only", "Stack"]'::jsonb,
  'Hash Map (old node -> new node)',
  'Random pointers can point forward to nodes not yet copied, so a hash map lets you resolve any pointer, in any order, once all nodes exist as keys.'
from questions where slug = 'copy-list-with-random-pointer';

-- 6. Add Two Numbers
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'add-two-numbers', 'Add Two Numbers', 'https://leetcode.com/problems/add-two-numbers/', 'medium', id,
  'Two numbers are represented as linked lists in reverse order (least significant digit first). Add the two numbers and return the sum as a linked list.',
$$public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    int carry = 0;

    while (l1 != null || l2 != null || carry != 0) {
        int sum = carry;
        if (l1 != null) { sum += l1.val; l1 = l1.next; }
        if (l2 != null) { sum += l2.val; l2 = l2.next; }
        carry = sum / 10;
        current.next = new ListNode(sum % 10);
        current = current.next;
    }
    return dummy.next;
}$$,
  'O(max(n, m))', 'O(max(n, m)) for the output list',
  array['This is elementary-school addition, digit by digit, carrying the overflow — the reverse-order representation is actually convenient, since it means you naturally process least-significant digits first.']
from patterns where slug = 'linked-list';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Add two numbers represented as reverse-order linked lists" — which pattern?',
  '["Linked List traversal with carry tracking", "Recursion (tree-based)", "Stack", "Two Pointers"]'::jsonb,
  'Linked List traversal with carry tracking',
  'Walk both lists simultaneously, adding digits and a running carry — a direct simulation of manual addition using the list structure itself.'
from questions where slug = 'add-two-numbers';
