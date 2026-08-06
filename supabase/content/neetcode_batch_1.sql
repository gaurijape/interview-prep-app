-- NeetCode 150 — Batch 1: Arrays & Hashing (9/9), completes Two Pointers (5/5)
-- and Sliding Window (6/6). Uses dollar-quoting with REAL embedded newlines
-- (not backslash-n text) so Java code renders correctly — see the earlier
-- fix_java_formatting.sql for why that matters.
-- Run in Supabase SQL Editor, plain "Run" button.

-- ============ NEW PATTERN: Arrays & Hashing ============

insert into patterns (slug, name, category, description, recognition_cues) values
('arrays-hashing', 'Arrays & Hashing', 'Arrays & Strings',
 'Use a hash map or hash set to trade space for time — turning an O(n) or O(n^2) linear search into an O(1) average lookup.',
 'Look for: "have you seen this before", counting frequencies, checking for duplicates/anagrams, or needing O(1) lookup instead of nested loops.');

-- 1. Two Sum
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'two-sum', 'Two Sum', 'https://leetcode.com/problems/two-sum/', 'easy', id,
  'Given an array of integers and a target, return indices of the two numbers that add up to the target.',
$$public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> seen = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (seen.containsKey(complement)) {
            return new int[]{seen.get(complement), i};
        }
        seen.put(nums[i], i);
    }
    return new int[]{-1, -1};
}$$,
  'O(n)', 'O(n)',
  array['Store each number''s index as you go — then for each new number, check if its complement was already seen.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', 'Find two numbers in an array that sum to a target, in one pass — which pattern?',
  '["Arrays & Hashing", "Two Pointers", "Sliding Window", "Binary Search"]'::jsonb,
  'Arrays & Hashing',
  'The array is unsorted, so two pointers doesn''t apply directly — a hash map gives O(1) lookup for the complement as you scan once.'
from questions where slug = 'two-sum';

-- 2. Contains Duplicate
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'contains-duplicate', 'Contains Duplicate', 'https://leetcode.com/problems/contains-duplicate/', 'easy', id,
  'Given an integer array, return true if any value appears at least twice.',
$$public boolean containsDuplicate(int[] nums) {
    Set<Integer> seen = new HashSet<>();
    for (int n : nums) {
        if (!seen.add(n)) return true;
    }
    return false;
}$$,
  'O(n)', 'O(n)',
  array['Set.add() returns false if the element was already present — no need for a separate contains() check.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Does this array contain any duplicate value?" — which pattern?',
  '["Arrays & Hashing", "Two Pointers", "Sorting only", "Dynamic Programming"]'::jsonb,
  'Arrays & Hashing',
  'A hash set gives O(n) time; sorting first would also work but costs O(n log n) — hashing is the better default unless space is the constraint.'
from questions where slug = 'contains-duplicate';

-- 3. Valid Anagram
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'valid-anagram', 'Valid Anagram', 'https://leetcode.com/problems/valid-anagram/', 'easy', id,
  'Given two strings, return true if the second is an anagram of the first.',
$$public boolean isAnagram(String s, String t) {
    if (s.length() != t.length()) return false;
    int[] counts = new int[26];
    for (char c : s.toCharArray()) counts[c - 'a']++;
    for (char c : t.toCharArray()) counts[c - 'a']--;
    for (int c : counts) if (c != 0) return false;
    return true;
}$$,
  'O(n)', 'O(1) — fixed 26-letter array',
  array['Count letter frequencies once, decrement for the second string, then check everything cancelled out to zero.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Check if two strings are anagrams of each other" — which pattern?',
  '["Arrays & Hashing", "Two Pointers", "Sliding Window", "Backtracking"]'::jsonb,
  'Arrays & Hashing',
  'A frequency count (a specialized hash map — here a fixed array since we know the alphabet) is the standard O(n) approach.'
from questions where slug = 'valid-anagram';

-- 4. Group Anagrams
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'group-anagrams', 'Group Anagrams', 'https://leetcode.com/problems/group-anagrams/', 'medium', id,
  'Given an array of strings, group the anagrams together.',
$$public List<List<String>> groupAnagrams(String[] strs) {
    Map<String, List<String>> groups = new HashMap<>();
    for (String s : strs) {
        char[] chars = s.toCharArray();
        Arrays.sort(chars);
        String key = new String(chars);
        groups.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
    }
    return new ArrayList<>(groups.values());
}$$,
  'O(n * k log k) — n strings, k = max string length', 'O(n * k)',
  array['Two strings are anagrams if and only if their sorted characters are identical — use the sorted string as a hash map key.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Group a list of strings by which ones are anagrams of each other" — which pattern?',
  '["Arrays & Hashing", "Two Pointers", "Backtracking", "Dynamic Programming"]'::jsonb,
  'Arrays & Hashing',
  'Map each string to a canonical key (its sorted form), then group by that key in a hash map — classic hashing-for-grouping.'
from questions where slug = 'group-anagrams';

-- 5. Top K Frequent Elements
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'top-k-frequent-elements', 'Top K Frequent Elements', 'https://leetcode.com/problems/top-k-frequent-elements/', 'medium', id,
  'Given an integer array and an integer k, return the k most frequent elements.',
$$public int[] topKFrequent(int[] nums, int k) {
    Map<Integer, Integer> counts = new HashMap<>();
    for (int n : nums) counts.merge(n, 1, Integer::sum);

    PriorityQueue<Integer> heap = new PriorityQueue<>((a, b) -> counts.get(a) - counts.get(b));
    for (int num : counts.keySet()) {
        heap.offer(num);
        if (heap.size() > k) heap.poll();
    }
    int[] result = new int[k];
    for (int i = k - 1; i >= 0; i--) result[i] = heap.poll();
    return result;
}$$,
  'O(n log k)', 'O(n)',
  array['Count frequencies with a hash map first, then use a min-heap of size k to keep only the k most frequent seen so far.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Return the k most frequent elements" — which pattern?',
  '["Arrays & Hashing + Heap", "Two Pointers", "Sliding Window", "Binary Search"]'::jsonb,
  'Arrays & Hashing + Heap',
  'This is a two-step combo: hash map to count frequencies, then a heap (or bucket sort) to extract the top k — very common combination in interviews.'
from questions where slug = 'top-k-frequent-elements';

-- 6. Product of Array Except Self
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'product-of-array-except-self', 'Product of Array Except Self', 'https://leetcode.com/problems/product-of-array-except-self/', 'medium', id,
  'Given an array, return an array where each element is the product of all other elements — without using division.',
$$public int[] productExceptSelf(int[] nums) {
    int n = nums.length;
    int[] result = new int[n];
    result[0] = 1;
    for (int i = 1; i < n; i++) {
        result[i] = result[i - 1] * nums[i - 1];
    }
    int rightProduct = 1;
    for (int i = n - 1; i >= 0; i--) {
        result[i] *= rightProduct;
        rightProduct *= nums[i];
    }
    return result;
}$$,
  'O(n)', 'O(1) extra space (output array doesn''t count)',
  array['Build prefix products left-to-right into the result array first, then multiply in suffix products right-to-left in a second pass.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Product of array except self, no division, O(1) extra space" — which technique?',
  '["Prefix/Suffix products", "Sliding Window", "Two Pointers", "Hash Map"]'::jsonb,
  'Prefix/Suffix products',
  'This is really a prefix-sum-style technique applied to products instead of sums — compute running products from both directions.'
from questions where slug = 'product-of-array-except-self';

-- 7. Valid Sudoku
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'valid-sudoku', 'Valid Sudoku', 'https://leetcode.com/problems/valid-sudoku/', 'medium', id,
  'Determine if a 9x9 Sudoku board is valid — each row, column, and 3x3 sub-box must contain digits 1-9 without repetition.',
$$public boolean isValidSudoku(char[][] board) {
    Set<String> seen = new HashSet<>();
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            char val = board[r][c];
            if (val == '.') continue;
            String rowKey = "row" + r + val;
            String colKey = "col" + c + val;
            String boxKey = "box" + (r / 3) + (c / 3) + val;
            if (!seen.add(rowKey) || !seen.add(colKey) || !seen.add(boxKey)) {
                return false;
            }
        }
    }
    return true;
}$$,
  'O(1) — fixed 81 cells', 'O(1) — fixed board size',
  array['Encode "row 3 has a 5" and "box (1,2) has a 5" as distinct string keys in one hash set — a collision on any key means a conflict.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Check row/column/box uniqueness constraints on a grid" — which pattern?',
  '["Arrays & Hashing", "Backtracking", "DFS", "Two Pointers"]'::jsonb,
  'Arrays & Hashing',
  'Validating existing constraints is a hashing/set-membership problem; backtracking would be for actually *solving* a Sudoku, not just validating one.'
from questions where slug = 'valid-sudoku';

-- 8. Encode and Decode Strings
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'encode-decode-strings', 'Encode and Decode Strings', 'https://leetcode.com/problems/encode-and-decode-strings/', 'medium', id,
  'Design an algorithm to encode a list of strings into one string, and decode it back to the original list.',
$$public String encode(List<String> strs) {
    StringBuilder sb = new StringBuilder();
    for (String s : strs) {
        sb.append(s.length()).append('#').append(s);
    }
    return sb.toString();
}

public List<String> decode(String s) {
    List<String> result = new ArrayList<>();
    int i = 0;
    while (i < s.length()) {
        int j = i;
        while (s.charAt(j) != '#') j++;
        int len = Integer.parseInt(s.substring(i, j));
        result.add(s.substring(j + 1, j + 1 + len));
        i = j + 1 + len;
    }
    return result;
}$$,
  'O(n) total characters', 'O(n)',
  array['Prefix each string with its length and a delimiter (like "5#hello") — this handles strings that contain the delimiter character themselves, unlike a naive join/split.']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', 'Why not just join strings with a comma and split on decode?',
  '["Strings may contain the delimiter itself", "It would be too slow", "Java doesn''t support split()", "It uses too much memory"]'::jsonb,
  'Strings may contain the delimiter itself',
  'If any input string contains a comma, a naive join/split breaks — length-prefixing sidesteps that entirely, which is the actual point of this question.'
from questions where slug = 'encode-decode-strings';

-- 9. Longest Consecutive Sequence
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'longest-consecutive-sequence', 'Longest Consecutive Sequence', 'https://leetcode.com/problems/longest-consecutive-sequence/', 'medium', id,
  'Given an unsorted array of integers, return the length of the longest consecutive elements sequence, in O(n) time.',
$$public int longestConsecutive(int[] nums) {
    Set<Integer> numSet = new HashSet<>();
    for (int n : nums) numSet.add(n);

    int longest = 0;
    for (int n : numSet) {
        if (!numSet.contains(n - 1)) { // only start counting from a sequence's beginning
            int length = 1;
            while (numSet.contains(n + length)) length++;
            longest = Math.max(longest, length);
        }
    }
    return longest;
}$$,
  'O(n)', 'O(n)',
  array['The key trick: only start counting a sequence from a number whose predecessor (n-1) is NOT in the set — that guarantees each sequence is only counted once, keeping it O(n) instead of O(n^2).']
from patterns where slug = 'arrays-hashing';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Longest run of consecutive integers, unsorted input, must be O(n)" — which pattern?',
  '["Arrays & Hashing", "Sorting", "Sliding Window", "Two Pointers"]'::jsonb,
  'Arrays & Hashing',
  'Sorting would work but costs O(n log n); putting everything in a hash set and only expanding from sequence-starts achieves true O(n).'
from questions where slug = 'longest-consecutive-sequence';


-- ============ TWO POINTERS: 4 more (completes 5/5) ============

-- 1. Valid Palindrome
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'valid-palindrome', 'Valid Palindrome', 'https://leetcode.com/problems/valid-palindrome/', 'easy', id,
  'Given a string, return true if it is a palindrome after converting to lowercase and removing non-alphanumeric characters.',
$$public boolean isPalindrome(String s) {
    int left = 0, right = s.length() - 1;
    while (left < right) {
        while (left < right && !Character.isLetterOrDigit(s.charAt(left))) left++;
        while (left < right && !Character.isLetterOrDigit(s.charAt(right))) right--;
        if (Character.toLowerCase(s.charAt(left)) != Character.toLowerCase(s.charAt(right))) {
            return false;
        }
        left++;
        right--;
    }
    return true;
}$$,
  'O(n)', 'O(1)',
  array['Skip non-alphanumeric characters from both ends as you go, instead of building a cleaned copy of the string first.']
from patterns where slug = 'two-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Check if a string reads the same forwards and backwards" (ignoring punctuation/case) — which pattern?',
  '["Two Pointers", "Sliding Window", "Stack", "Dynamic Programming"]'::jsonb,
  'Two Pointers',
  'Comparing characters from both ends inward, moving toward the middle, is the defining shape of two pointers.'
from questions where slug = 'valid-palindrome';

-- 2. 3Sum
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select '3sum', '3Sum', 'https://leetcode.com/problems/3sum/', 'medium', id,
  'Given an integer array, return all unique triplets that sum to zero.',
$$public List<List<Integer>> threeSum(int[] nums) {
    Arrays.sort(nums);
    List<List<Integer>> result = new ArrayList<>();
    for (int i = 0; i < nums.length - 2; i++) {
        if (i > 0 && nums[i] == nums[i - 1]) continue; // skip duplicate anchors
        int left = i + 1, right = nums.length - 1;
        while (left < right) {
            int sum = nums[i] + nums[left] + nums[right];
            if (sum == 0) {
                result.add(Arrays.asList(nums[i], nums[left], nums[right]));
                left++;
                right--;
                while (left < right && nums[left] == nums[left - 1]) left++;
                while (left < right && nums[right] == nums[right + 1]) right--;
            } else if (sum < 0) {
                left++;
            } else {
                right--;
            }
        }
    }
    return result;
}$$,
  'O(n^2)', 'O(1) extra (excluding output / sort space)',
  array['Fix one number, then run the classic two-pointer "two sum on a sorted array" for the other two — sorting first is what makes the pointer logic and duplicate-skipping possible.']
from patterns where slug = 'two-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Find all unique triplets that sum to zero" — which pattern?',
  '["Two Pointers (with sorting)", "Backtracking", "Sliding Window", "Hash Map only"]'::jsonb,
  'Two Pointers (with sorting)',
  'Sort first, then for each fixed first element, use two pointers on the remainder — reduces what would be O(n^3) brute force to O(n^2).'
from questions where slug = '3sum';

-- 3. Container With Most Water
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'container-with-most-water', 'Container With Most Water', 'https://leetcode.com/problems/container-with-most-water/', 'medium', id,
  'Given an array of heights, find two lines that together with the x-axis form a container holding the most water.',
$$public int maxArea(int[] height) {
    int left = 0, right = height.length - 1, maxArea = 0;
    while (left < right) {
        int area = Math.min(height[left], height[right]) * (right - left);
        maxArea = Math.max(maxArea, area);
        if (height[left] < height[right]) left++; else right--;
    }
    return maxArea;
}$$,
  'O(n)', 'O(1)',
  array['Always move the pointer at the SHORTER line — moving the taller one can only ever decrease or keep the same width while the limiting height stays the same or worsens, so it can never help.']
from patterns where slug = 'two-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Maximize area between two lines, choosing which pointer to move" — which pattern?',
  '["Two Pointers", "Sliding Window", "Dynamic Programming", "Greedy only"]'::jsonb,
  'Two Pointers',
  'Two pointers start at both ends and move inward based on a comparison — here, always advancing the shorter line — narrowing the search space each step.'
from questions where slug = 'container-with-most-water';

-- 4. Trapping Rain Water
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'trapping-rain-water', 'Trapping Rain Water', 'https://leetcode.com/problems/trapping-rain-water/', 'hard', id,
  'Given an elevation map, compute how much rainwater it can trap after raining.',
$$public int trap(int[] height) {
    int left = 0, right = height.length - 1;
    int leftMax = 0, rightMax = 0, water = 0;
    while (left < right) {
        if (height[left] < height[right]) {
            leftMax = Math.max(leftMax, height[left]);
            water += leftMax - height[left];
            left++;
        } else {
            rightMax = Math.max(rightMax, height[right]);
            water += rightMax - height[right];
            right--;
        }
    }
    return water;
}$$,
  'O(n)', 'O(1)',
  array['Water trapped at any position is limited by the SHORTER of the tallest wall to its left and its right — track running max from both ends as the pointers close in.']
from patterns where slug = 'two-pointers';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"How much water can this elevation map trap?" — which pattern?',
  '["Two Pointers", "Stack", "Dynamic Programming (precompute both directions)", "All of these can solve it — pick by space trade-off"]'::jsonb,
  'All of these can solve it — pick by space trade-off',
  'This is a great trade-off question: DP with prefix/suffix max arrays is O(n) time and O(n) space and easiest to reason about; two pointers gets the same O(n) time in O(1) space but is trickier to get right; a monotonic stack also works. In an interview, mention more than one.'
from questions where slug = 'trapping-rain-water';


-- ============ SLIDING WINDOW: 5 more (completes 6/6) ============

-- 1. Best Time to Buy and Sell Stock
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'best-time-buy-sell-stock', 'Best Time to Buy and Sell Stock', 'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/', 'easy', id,
  'Given an array of prices where prices[i] is the price on day i, find the maximum profit from one buy and one sell.',
$$public int maxProfit(int[] prices) {
    int minPrice = Integer.MAX_VALUE, maxProfit = 0;
    for (int price : prices) {
        minPrice = Math.min(minPrice, price);
        maxProfit = Math.max(maxProfit, price - minPrice);
    }
    return maxProfit;
}$$,
  'O(n)', 'O(1)',
  array['Think of it as a sliding window where the left edge (buy day) only ever moves forward to a new minimum — you never need to look backward once past it.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Max profit from one buy and one sell, prices given in order" — which pattern?',
  '["Sliding Window", "Two Pointers", "Dynamic Programming (full)", "Binary Search"]'::jsonb,
  'Sliding Window',
  'Tracking a running minimum while scanning once is a degenerate/simple case of the sliding window idea — the "window" is implicitly [minPrice so far, current day].'
from questions where slug = 'best-time-buy-sell-stock';

-- 2. Longest Repeating Character Replacement
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'longest-repeating-character-replacement', 'Longest Repeating Character Replacement', 'https://leetcode.com/problems/longest-repeating-character-replacement/', 'medium', id,
  'Given a string and an integer k, find the length of the longest substring containing the same letter after replacing at most k characters.',
$$public int characterReplacement(String s, int k) {
    int[] counts = new int[26];
    int left = 0, maxCount = 0, maxLength = 0;
    for (int right = 0; right < s.length(); right++) {
        counts[s.charAt(right) - 'A']++;
        maxCount = Math.max(maxCount, counts[s.charAt(right) - 'A']);
        while ((right - left + 1) - maxCount > k) {
            counts[s.charAt(left) - 'A']--;
            left++;
        }
        maxLength = Math.max(maxLength, right - left + 1);
    }
    return maxLength;
}$$,
  'O(n)', 'O(1) — fixed 26-letter array',
  array['The window is valid as long as (window size - count of its most frequent letter) <= k, since that''s exactly how many characters you''d need to replace.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Longest substring of one repeated letter after at most k replacements" — which pattern?',
  '["Sliding Window", "Two Pointers", "Dynamic Programming", "Backtracking"]'::jsonb,
  'Sliding Window',
  'The window grows and shrinks based on a validity condition (replacements needed <= k) — textbook sliding window.'
from questions where slug = 'longest-repeating-character-replacement';

-- 3. Permutation in String
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'permutation-in-string', 'Permutation in String', 'https://leetcode.com/problems/permutation-in-string/', 'medium', id,
  'Given two strings s1 and s2, return true if s2 contains a permutation of s1 (i.e. one of s1''s permutations is a substring of s2).',
$$public boolean checkInclusion(String s1, String s2) {
    if (s1.length() > s2.length()) return false;
    int[] need = new int[26], window = new int[26];
    for (char c : s1.toCharArray()) need[c - 'a']++;

    int windowSize = s1.length();
    for (int i = 0; i < s2.length(); i++) {
        window[s2.charAt(i) - 'a']++;
        if (i >= windowSize) {
            window[s2.charAt(i - windowSize) - 'a']--;
        }
        if (i >= windowSize - 1 && Arrays.equals(need, window)) {
            return true;
        }
    }
    return false;
}$$,
  'O(n) — n = length of s2 (26 is a constant factor)', 'O(1) — fixed 26-letter arrays',
  array['A fixed-size window of length s1.length() slides across s2 — a permutation match means the window''s letter counts exactly equal s1''s letter counts.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Does s2 contain any permutation (anagram) of s1 as a substring?" — which pattern?',
  '["Sliding Window (fixed size)", "Backtracking", "Two Pointers", "Dynamic Programming"]'::jsonb,
  'Sliding Window (fixed size)',
  'The window size is fixed at s1.length() and slides across s2 one character at a time — the fixed-size variant of sliding window, versus the growable window in problems like Longest Substring Without Repeating Characters.'
from questions where slug = 'permutation-in-string';

-- 4. Minimum Window Substring
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'minimum-window-substring', 'Minimum Window Substring', 'https://leetcode.com/problems/minimum-window-substring/', 'hard', id,
  'Given strings s and t, return the minimum window substring of s such that every character in t (including duplicates) is included.',
$$public String minWindow(String s, String t) {
    if (s.isEmpty() || t.isEmpty()) return "";
    Map<Character, Integer> need = new HashMap<>();
    for (char c : t.toCharArray()) need.merge(c, 1, Integer::sum);

    Map<Character, Integer> window = new HashMap<>();
    int have = 0, needCount = need.size();
    int[] result = {-1, 0, 0}; // length, left, right
    int left = 0;

    for (int right = 0; right < s.length(); right++) {
        char c = s.charAt(right);
        window.merge(c, 1, Integer::sum);
        if (need.containsKey(c) && window.get(c).intValue() == need.get(c).intValue()) {
            have++;
        }
        while (have == needCount) {
            if (result[0] == -1 || (right - left + 1) < result[0]) {
                result[0] = right - left + 1;
                result[1] = left;
                result[2] = right;
            }
            char leftChar = s.charAt(left);
            window.put(leftChar, window.get(leftChar) - 1);
            if (need.containsKey(leftChar) && window.get(leftChar) < need.get(leftChar)) {
                have--;
            }
            left++;
        }
    }
    return result[0] == -1 ? "" : s.substring(result[1], result[2] + 1);
}$$,
  'O(n + m) — n = s.length(), m = t.length()', 'O(m)',
  array['Grow the window until it satisfies all of t''s character counts, then shrink from the left as far as possible while still valid — recording the smallest valid window seen.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Smallest substring containing all characters of another string" — which pattern?',
  '["Sliding Window (variable size)", "Two Pointers", "Backtracking", "Dynamic Programming"]'::jsonb,
  'Sliding Window (variable size)',
  'Grow-then-shrink based on a validity condition (does the window contain everything needed) is the classic variable-size sliding window shape.'
from questions where slug = 'minimum-window-substring';

-- 5. Sliding Window Maximum
insert into questions (slug, title, leetcode_url, difficulty, primary_pattern_id, description, java_solution, complexity_time, complexity_space, hints)
select 'sliding-window-maximum', 'Sliding Window Maximum', 'https://leetcode.com/problems/sliding-window-maximum/', 'hard', id,
  'Given an array and a window size k, return the maximum value in each sliding window as it moves across the array.',
$$public int[] maxSlidingWindow(int[] nums, int k) {
    Deque<Integer> deque = new ArrayDeque<>(); // stores indices, values decreasing
    int[] result = new int[nums.length - k + 1];

    for (int i = 0; i < nums.length; i++) {
        while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
            deque.pollFirst(); // remove indices out of the window
        }
        while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
            deque.pollLast(); // remove smaller values, they can never be the max now
        }
        deque.offerLast(i);
        if (i >= k - 1) {
            result[i - k + 1] = nums[deque.peekFirst()];
        }
    }
    return result;
}$$,
  'O(n)', 'O(k)',
  array['A monotonic decreasing deque of indices keeps the current window''s maximum always at the front — each index is added and removed from the deque at most once, giving O(n) total despite the nested-looking loops.']
from patterns where slug = 'sliding-window';

insert into quizzes (question_id, type, prompt, options, correct_answer, explanation)
select id, 'recognition', '"Max of every fixed-size window as it slides across an array, in O(n)" — which technique?',
  '["Sliding Window + Monotonic Deque", "Sliding Window + Max Heap", "Two Pointers", "Dynamic Programming"]'::jsonb,
  'Sliding Window + Monotonic Deque',
  'A max-heap also works but costs O(n log k) since removing an out-of-window element from a heap isn''t O(1); a monotonic deque achieves true O(n) by discarding values that can never be the max again.'
from questions where slug = 'sliding-window-maximum';
