/**
 * 内置题库（纯本地数据，首次启动导入 RDB）
 * 共 6 个分类：数组 / 字符串 / 链表与树 / 动态规划 / 贪心与双指针 / 其他经典
 * difficulty: 1 简单 / 2 中等 / 3 困难
 */

export interface ProblemSeed {
  id: number;
  title: string;
  category: string;
  difficulty: number;
  description: string;
  analysis: string;
  codeArkts: string;
  codePython: string;
  tags: string;
}

export const CATEGORIES: string[] = ['数组', '字符串', '链表与树', '动态规划', '贪心与双指针', '其他经典'];

export const PROBLEM_SEEDS: ProblemSeed[] = [
  // ==================== 数组 ====================
  {
    id: 1,
    title: '两数之和',
    category: '数组',
    difficulty: 1,
    description: '给定一个整数数组 nums 和一个目标值 target，请在数组中找出和为目标值的两个整数，并返回它们的下标。假设每种输入只会对应一个答案，且不能重复使用同一个元素。',
    analysis: '使用哈希表记录「值 -> 下标」。遍历数组时对每个元素查找 target - nums[i] 是否已存在，存在即找到答案，时间复杂度 O(n)。',
    codeArkts: `function twoSum(nums: number[], target: number): number[] {
  const map: Map<number, number> = new Map();
  for (let i = 0; i < nums.length; i++) {
    const need = target - nums[i];
    const idx = map.get(need);
    if (idx !== undefined) {
      return [idx, i];
    }
    map.set(nums[i], i);
  }
  return [];
}`,
    codePython: `def two_sum(nums, target):
    seen = {}
    for i, num in enumerate(nums):
        need = target - num
        if need in seen:
            return [seen[need], i]
        seen[num] = i
    return []`,
    tags: '哈希表,数组'
  },
  {
    id: 2,
    title: '移动零',
    category: '数组',
    difficulty: 1,
    description: '给定一个数组 nums，编写函数将所有 0 移动到数组末尾，同时保持非零元素的相对顺序。必须原地操作，不能复制数组。',
    analysis: '使用双指针：慢指针指向下一个非零元素应放置的位置，快指针遍历数组。遇到非零就交换到慢指针位置并前移慢指针，最终所有零自然被推到末尾。',
    codeArkts: `function moveZeroes(nums: number[]): void {
  let slow = 0;
  for (let fast = 0; fast < nums.length; fast++) {
    if (nums[fast] !== 0) {
      const tmp = nums[slow];
      nums[slow] = nums[fast];
      nums[fast] = tmp;
      slow++;
    }
  }
}`,
    codePython: `def move_zeroes(nums):
    slow = 0
    for fast in range(len(nums)):
        if nums[fast] != 0:
            nums[slow], nums[fast] = nums[fast], nums[slow]
            slow += 1`,
    tags: '双指针,数组'
  },
  {
    id: 3,
    title: '合并两个有序数组',
    category: '数组',
    difficulty: 1,
    description: '给定两个按非递减顺序排列的整数数组 nums1 和 nums2，将 nums2 合并到 nums1 中，使合并后的数组仍然有序。nums1 的初始长度为 m + n，后 n 个元素为 0 用于占位。',
    analysis: '从后向前三指针合并，避免覆盖 nums1 有效元素。比较两个数组末尾较大者放到 nums1 末尾，时间复杂度 O(m + n)，空间 O(1)。',
    codeArkts: `function merge(nums1: number[], m: number, nums2: number[], n: number): void {
  let i = m - 1;
  let j = n - 1;
  let k = m + n - 1;
  while (j >= 0) {
    if (i >= 0 && nums1[i] > nums2[j]) {
      nums1[k] = nums1[i];
      i--;
    } else {
      nums1[k] = nums2[j];
      j--;
    }
    k--;
  }
}`,
    codePython: `def merge(nums1, m, nums2, n):
    i, j, k = m - 1, n - 1, m + n - 1
    while j >= 0:
        if i >= 0 and nums1[i] > nums2[j]:
            nums1[k] = nums1[i]
            i -= 1
        else:
            nums1[k] = nums2[j]
            j -= 1
        k -= 1`,
    tags: '双指针,数组'
  },
  {
    id: 4,
    title: '最大子数组和',
    category: '数组',
    difficulty: 2,
    description: '给你一个整数数组 nums，请找出一个具有最大和的连续子数组（至少包含一个元素），返回其最大和。',
    analysis: 'Kadane 算法：维护以当前元素结尾的最大子数组和 cur，若 cur 变为负数则从当前元素重新开始。全局最大值即为答案，时间 O(n)。',
    codeArkts: `function maxSubArray(nums: number[]): number {
  let best = nums[0];
  let cur = nums[0];
  for (let i = 1; i < nums.length; i++) {
    cur = Math.max(nums[i], cur + nums[i]);
    best = Math.max(best, cur);
  }
  return best;
}`,
    codePython: `def max_sub_array(nums):
    best = cur = nums[0]
    for num in nums[1:]:
        cur = max(num, cur + num)
        best = max(best, cur)
    return best`,
    tags: '动态规划,贪心,数组'
  },
  {
    id: 5,
    title: '轮转数组',
    category: '数组',
    difficulty: 2,
    description: '给定一个整数数组 nums，将数组中的元素向右轮转 k 个位置，其中 k 是非负数。要求原地修改。',
    analysis: '三次反转法：先整体反转，再分别反转前 k 个和后 n-k 个元素，即可实现循环右移，空间 O(1)。注意 k 先对 n 取模。',
    codeArkts: `function rotate(nums: number[], k: number): void {
  const n = nums.length;
  k = k % n;
  reverse(nums, 0, n - 1);
  reverse(nums, 0, k - 1);
  reverse(nums, k, n - 1);
}

function reverse(arr: number[], left: number, right: number): void {
  while (left < right) {
    const tmp = arr[left];
    arr[left] = arr[right];
    arr[right] = tmp;
    left++;
    right--;
  }
}`,
    codePython: `def rotate(nums, k):
    n = len(nums)
    k %= n
    def reverse(l, r):
        while l < r:
            nums[l], nums[r] = nums[r], nums[l]
            l += 1
            r -= 1
    reverse(0, n - 1)
    reverse(0, k - 1)
    reverse(k, n - 1)`,
    tags: '数组,双指针'
  },
  {
    id: 6,
    title: '数组中的第K个最大元素',
    category: '数组',
    difficulty: 2,
    description: '给定整数数组 nums 和整数 k，请返回数组中第 k 个最大的元素。注意是排序后的第 k 个最大元素，而不是第 k 个不同的元素。',
    analysis: '可用快速选择（基于快排分区）在平均 O(n) 时间找到第 k 大；也可维护大小为 k 的小顶堆。这里给出快速选择的分区实现。',
    codeArkts: `function findKthLargest(nums: number[], k: number): number {
  const target = nums.length - k;
  let left = 0;
  let right = nums.length - 1;
  while (left < right) {
    const pivotIndex = partition(nums, left, right);
    if (pivotIndex === target) {
      break;
    } else if (pivotIndex < target) {
      left = pivotIndex + 1;
    } else {
      right = pivotIndex - 1;
    }
  }
  return nums[target];
}

function partition(arr: number[], left: number, right: number): number {
  const pivot = arr[right];
  let store = left;
  for (let i = left; i < right; i++) {
    if (arr[i] < pivot) {
      const t = arr[i];
      arr[i] = arr[store];
      arr[store] = t;
      store++;
    }
  }
  const t2 = arr[store];
  arr[store] = arr[right];
  arr[right] = t2;
  return store;
}`,
    codePython: `def find_kth_largest(nums, k):
    target = len(nums) - k
    def partition(left, right):
        pivot = nums[right]
        store = left
        for i in range(left, right):
            if nums[i] < pivot:
                nums[i], nums[store] = nums[store], nums[i]
                store += 1
        nums[store], nums[right] = nums[right], nums[store]
        return store
    left, right = 0, len(nums) - 1
    while left < right:
        p = partition(left, right)
        if p == target:
            break
        elif p < target:
            left = p + 1
        else:
            right = p - 1
    return nums[target]`,
    tags: '快速选择,堆,数组'
  },
  {
    id: 7,
    title: '除自身以外数组的乘积',
    category: '数组',
    difficulty: 2,
    description: '给你一个整数数组 nums，返回数组 answer，其中 answer[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积。要求不使用除法且在 O(n) 时间完成。',
    analysis: '左右乘积法：先从左到右计算前缀积存入结果，再从右到左维护后缀积并与结果相乘，空间 O(1)（不计输出数组）。',
    codeArkts: `function productExceptSelf(nums: number[]): number[] {
  const n = nums.length;
  const res: number[] = new Array<number>(n).fill(1);
  let prefix = 1;
  for (let i = 0; i < n; i++) {
    res[i] = prefix;
    prefix *= nums[i];
  }
  let suffix = 1;
  for (let i = n - 1; i >= 0; i--) {
    res[i] *= suffix;
    suffix *= nums[i];
  }
  return res;
}`,
    codePython: `def product_except_self(nums):
    n = len(nums)
    res = [1] * n
    prefix = 1
    for i in range(n):
        res[i] = prefix
        prefix *= nums[i]
    suffix = 1
    for i in range(n - 1, -1, -1):
        res[i] *= suffix
        suffix *= nums[i]
    return res`,
    tags: '前缀积,数组'
  },
  {
    id: 8,
    title: '螺旋矩阵',
    category: '数组',
    difficulty: 2,
    description: '给你一个 m 行 n 列的矩阵 matrix，请按照顺时针螺旋顺序，返回矩阵中的所有元素。',
    analysis: '维护上下左右四个边界，按「右→下→左→上」依次遍历并收缩边界，直到边界交错。注意在向左和向上遍历前判断边界是否仍有效。',
    codeArkts: `function spiralOrder(matrix: number[][]): number[] {
  const res: number[] = [];
  if (matrix.length === 0) {
    return res;
  }
  let top = 0;
  let bottom = matrix.length - 1;
  let left = 0;
  let right = matrix[0].length - 1;
  while (top <= bottom && left <= right) {
    for (let j = left; j <= right; j++) {
      res.push(matrix[top][j]);
    }
    top++;
    for (let i = top; i <= bottom; i++) {
      res.push(matrix[i][right]);
    }
    right--;
    if (top <= bottom) {
      for (let j = right; j >= left; j--) {
        res.push(matrix[bottom][j]);
      }
      bottom--;
    }
    if (left <= right) {
      for (let i = bottom; i >= top; i--) {
        res.push(matrix[i][left]);
      }
      left++;
    }
  }
  return res;
}`,
    codePython: `def spiral_order(matrix):
    res = []
    if not matrix:
        return res
    top, bottom = 0, len(matrix) - 1
    left, right = 0, len(matrix[0]) - 1
    while top <= bottom and left <= right:
        for j in range(left, right + 1):
            res.append(matrix[top][j])
        top += 1
        for i in range(top, bottom + 1):
            res.append(matrix[i][right])
        right -= 1
        if top <= bottom:
            for j in range(right, left - 1, -1):
                res.append(matrix[bottom][j])
            bottom -= 1
        if left <= right:
            for i in range(bottom, top - 1, -1):
                res.append(matrix[i][left])
            left += 1
    return res`,
    tags: '矩阵,模拟,数组'
  },
  {
    id: 9,
    title: '矩阵置零',
    category: '数组',
    difficulty: 2,
    description: '给定一个 m x n 的矩阵，如果一个元素为 0，则将其所在行和列的所有元素都置为 0。请使用原地算法。',
    analysis: '利用第一行和第一列作为标记位，先记录第一行/列本身是否含零，再用其余元素标记对应行列，最后根据标记清零。空间 O(1)。',
    codeArkts: `function setZeroes(matrix: number[][]): void {
  const m = matrix.length;
  const n = matrix[0].length;
  let firstRow = false;
  let firstCol = false;
  for (let j = 0; j < n; j++) {
    if (matrix[0][j] === 0) {
      firstRow = true;
    }
  }
  for (let i = 0; i < m; i++) {
    if (matrix[i][0] === 0) {
      firstCol = true;
    }
  }
  for (let i = 1; i < m; i++) {
    for (let j = 1; j < n; j++) {
      if (matrix[i][j] === 0) {
        matrix[i][0] = 0;
        matrix[0][j] = 0;
      }
    }
  }
  for (let i = 1; i < m; i++) {
    for (let j = 1; j < n; j++) {
      if (matrix[i][0] === 0 || matrix[0][j] === 0) {
        matrix[i][j] = 0;
      }
    }
  }
  if (firstRow) {
    for (let j = 0; j < n; j++) {
      matrix[0][j] = 0;
    }
  }
  if (firstCol) {
    for (let i = 0; i < m; i++) {
      matrix[i][0] = 0;
    }
  }
}`,
    codePython: `def set_zeroes(matrix):
    m, n = len(matrix), len(matrix[0])
    first_row = any(matrix[0][j] == 0 for j in range(n))
    first_col = any(matrix[i][0] == 0 for i in range(m))
    for i in range(1, m):
        for j in range(1, n):
            if matrix[i][j] == 0:
                matrix[i][0] = 0
                matrix[0][j] = 0
    for i in range(1, m):
        for j in range(1, n):
            if matrix[i][0] == 0 or matrix[0][j] == 0:
                matrix[i][j] = 0
    if first_row:
        for j in range(n):
            matrix[0][j] = 0
    if first_col:
        for i in range(m):
            matrix[i][0] = 0`,
    tags: '矩阵,数组'
  },
  {
    id: 10,
    title: '缺失的第一个正数',
    category: '数组',
    difficulty: 3,
    description: '给你一个未排序的整数数组 nums，请你找出其中没有出现的最小的正整数。要求实现时间复杂度 O(n) 且只使用常数级别额外空间的算法。',
    analysis: '原地哈希：把数值 x（1≤x≤n）放到下标 x-1 的位置。遍历后第一个位置不满足 nums[i] == i+1 的下标 i 对应的 i+1 即为答案，否则答案为 n+1。',
    codeArkts: `function firstMissingPositive(nums: number[]): number {
  const n = nums.length;
  for (let i = 0; i < n; i++) {
    while (nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] !== nums[i]) {
      const tmp = nums[nums[i] - 1];
      nums[nums[i] - 1] = nums[i];
      nums[i] = tmp;
    }
  }
  for (let i = 0; i < n; i++) {
    if (nums[i] !== i + 1) {
      return i + 1;
    }
  }
  return n + 1;
}`,
    codePython: `def first_missing_positive(nums):
    n = len(nums)
    for i in range(n):
        while 0 < nums[i] <= n and nums[nums[i] - 1] != nums[i]:
            nums[nums[i] - 1], nums[i] = nums[i], nums[nums[i] - 1]
    for i in range(n):
        if nums[i] != i + 1:
            return i + 1
    return n + 1`,
    tags: '原地哈希,数组'
  },
  {
    id: 11,
    title: '寻找两个正序数组的中位数',
    category: '数组',
    difficulty: 3,
    description: '给定两个大小分别为 m 和 n 的正序数组 nums1 和 nums2，请找出并返回这两个正序数组的中位数，要求时间复杂度为 O(log(m+n))。',
    analysis: '二分较短的数组，划分两个数组使左半部分元素个数为一半。通过比较分割线两侧的值调整划分，最终中位数由分割线两侧的最值推出。',
    codeArkts: `function findMedianSortedArrays(nums1: number[], nums2: number[]): number {
  if (nums1.length > nums2.length) {
    const t = nums1;
    nums1 = nums2;
    nums2 = t;
  }
  const m = nums1.length;
  const n = nums2.length;
  let left = 0;
  let right = m;
  while (left <= right) {
    const i = Math.floor((left + right) / 2);
    const j = Math.floor((m + n + 1) / 2) - i;
    const maxLeft1 = i === 0 ? -Infinity : nums1[i - 1];
    const minRight1 = i === m ? Infinity : nums1[i];
    const maxLeft2 = j === 0 ? -Infinity : nums2[j - 1];
    const minRight2 = j === n ? Infinity : nums2[j];
    if (maxLeft1 <= minRight2 && maxLeft2 <= minRight1) {
      if ((m + n) % 2 === 0) {
        return (Math.max(maxLeft1, maxLeft2) + Math.min(minRight1, minRight2)) / 2;
      }
      return Math.max(maxLeft1, maxLeft2);
    } else if (maxLeft1 > minRight2) {
      right = i - 1;
    } else {
      left = i + 1;
    }
  }
  return 0;
}`,
    codePython: `def find_median_sorted_arrays(nums1, nums2):
    if len(nums1) > len(nums2):
        nums1, nums2 = nums2, nums1
    m, n = len(nums1), len(nums2)
    left, right = 0, m
    while left <= right:
        i = (left + right) // 2
        j = (m + n + 1) // 2 - i
        max_l1 = -float('inf') if i == 0 else nums1[i - 1]
        min_r1 = float('inf') if i == m else nums1[i]
        max_l2 = -float('inf') if j == 0 else nums2[j - 1]
        min_r2 = float('inf') if j == n else nums2[j]
        if max_l1 <= min_r2 and max_l2 <= min_r1:
            if (m + n) % 2 == 0:
                return (max(max_l1, max_l2) + min(min_r1, min_r2)) / 2
            return max(max_l1, max_l2)
        elif max_l1 > min_r2:
            right = i - 1
        else:
            left = i + 1
    return 0.0`,
    tags: '二分查找,数组'
  },
  {
    id: 12,
    title: '多数元素',
    category: '数组',
    difficulty: 1,
    description: '给定一个大小为 n 的数组 nums，返回其中的多数元素。多数元素是指在数组中出现次数大于 n/2 的元素。假设数组非空且多数元素总是存在。',
    analysis: 'Boyer-Moore 投票算法：维护候选者和计数，相同则加一、不同则减一，计数为 0 时更换候选者。多数元素最终一定会留下。',
    codeArkts: `function majorityElement(nums: number[]): number {
  let candidate = 0;
  let count = 0;
  for (let i = 0; i < nums.length; i++) {
    if (count === 0) {
      candidate = nums[i];
    }
    if (nums[i] === candidate) {
      count++;
    } else {
      count--;
    }
  }
  return candidate;
}`,
    codePython: `def majority_element(nums):
    candidate, count = 0, 0
    for num in nums:
        if count == 0:
            candidate = num
        count += 1 if num == candidate else -1
    return candidate`,
    tags: '投票算法,数组'
  },
  {
    id: 13,
    title: '找到所有数组中消失的数字',
    category: '数组',
    difficulty: 2,
    description: '给你一个含 n 个整数的数组 nums，其中 nums[i] 在区间 [1, n] 内。请你找出所有在 [1, n] 范围内但没有出现在 nums 中的数字，并以数组形式返回。要求不使用额外空间且时间复杂度为 O(n)。',
    analysis: '利用下标做标记：把出现过的数字 x 对应的下标 x-1 处的值取负。最后仍为正数的位置 i 表示 i+1 没有出现过。若允许额外空间则用哈希集合更直观。',
    codeArkts: `function findDisappearedNumbers(nums: number[]): number[] {
  for (let i = 0; i < nums.length; i++) {
    const idx = Math.abs(nums[i]) - 1;
    if (nums[idx] > 0) {
      nums[idx] = -nums[idx];
    }
  }
  const res: number[] = [];
  for (let i = 0; i < nums.length; i++) {
    if (nums[i] > 0) {
      res.push(i + 1);
    }
  }
  return res;
}`,
    codePython: `def find_disappeared_numbers(nums):
    for i in range(len(nums)):
        idx = abs(nums[i]) - 1
        if nums[idx] > 0:
            nums[idx] = -nums[idx]
    return [i + 1 for i, v in enumerate(nums) if v > 0]`,
    tags: '原地标记,数组'
  },
  {
    id: 14,
    title: '最长连续序列',
    category: '数组',
    difficulty: 2,
    description: '给定一个未排序的整数数组 nums，找出数字连续的最长序列（不要求序列元素在原数组中连续）的长度。要求算法时间复杂度为 O(n)。',
    analysis: '用哈希集合去重，只从「序列起点」（即 x-1 不在集合中）开始向后枚举连续长度，避免重复计算，整体 O(n)。',
    codeArkts: `function longestConsecutive(nums: number[]): number {
  const set: Set<number> = new Set(nums);
  let best = 0;
  set.forEach((num: number) => {
    if (!set.has(num - 1)) {
      let current = num;
      let len = 1;
      while (set.has(current + 1)) {
        current++;
        len++;
      }
      best = Math.max(best, len);
    }
  });
  return best;
}`,
    codePython: `def longest_consecutive(nums):
    num_set = set(nums)
    best = 0
    for num in num_set:
        if num - 1 not in num_set:
            cur = num
            length = 1
            while cur + 1 in num_set:
                cur += 1
                length += 1
            best = max(best, length)
    return best`,
    tags: '哈希表,数组'
  },
  // ==================== 字符串 ====================
  {
    id: 15,
    title: '反转字符串',
    category: '字符串',
    difficulty: 1,
    description: '编写一个函数，将输入的字符数组 s 原地反转，要求使用 O(1) 的额外空间。',
    analysis: '使用左右双指针向中间靠拢并交换字符，时间 O(n)，空间 O(1)。',
    codeArkts: `function reverseString(s: string[]): void {
  let left = 0;
  let right = s.length - 1;
  while (left < right) {
    const tmp = s[left];
    s[left] = s[right];
    s[right] = tmp;
    left++;
    right--;
  }
}`,
    codePython: `def reverse_string(s):
    left, right = 0, len(s) - 1
    while left < right:
        s[left], s[right] = s[right], s[left]
        left += 1
        right -= 1`,
    tags: '双指针,字符串'
  },
  {
    id: 16,
    title: '有效的括号',
    category: '字符串',
    difficulty: 1,
    description: '给定一个只包括 (、)、{、}、[、] 的字符串 s，判断字符串是否有效。有效字符串需满足左括号必须用相同类型的右括号闭合，且以正确的顺序闭合。',
    analysis: '遇到左括号入栈，遇到右括号检查栈顶是否为对应左括号；最后栈必须为空。时间复杂度 O(n)。',
    codeArkts: `function isValid(s: string): boolean {
  const stack: string[] = [];
  const pairs: Map<string, string> = new Map();
  pairs.set(')', '(');
  pairs.set(']', '[');
  pairs.set('}', '{');
  for (let i = 0; i < s.length; i++) {
    const ch = s.charAt(i);
    if (ch === '(' || ch === '[' || ch === '{') {
      stack.push(ch);
    } else {
      if (stack.length === 0 || stack.pop() !== pairs.get(ch)) {
        return false;
      }
    }
  }
  return stack.length === 0;
}`,
    codePython: `def is_valid(s):
    stack = []
    pairs = {')': '(', ']': '[', '}': '{'}
    for ch in s:
        if ch in '([{':
            stack.append(ch)
        else:
            if not stack or stack.pop() != pairs[ch]:
                return False
    return not stack`,
    tags: '栈,字符串'
  },
  {
    id: 17,
    title: '最长公共前缀',
    category: '字符串',
    difficulty: 1,
    description: '编写一个函数来查找字符串数组中的最长公共前缀。如果不存在公共前缀，返回空字符串。',
    analysis: '以第一个字符串作为候选前缀，依次与其余字符串比较并逐字符缩短，直到成为它们的公共前缀。',
    codeArkts: `function longestCommonPrefix(strs: string[]): string {
  if (strs.length === 0) {
    return '';
  }
  let prefix = strs[0];
  for (let i = 1; i < strs.length; i++) {
    while (strs[i].indexOf(prefix) !== 0) {
      prefix = prefix.substring(0, prefix.length - 1);
      if (prefix.length === 0) {
        return '';
      }
    }
  }
  return prefix;
}`,
    codePython: `def longest_common_prefix(strs):
    if not strs:
        return ''
    prefix = strs[0]
    for s in strs[1:]:
        while not s.startswith(prefix):
            prefix = prefix[:-1]
            if not prefix:
                return ''
    return prefix`,
    tags: '字符串'
  },
  {
    id: 18,
    title: '无重复字符的最长子串',
    category: '字符串',
    difficulty: 2,
    description: '给定一个字符串 s，请你找出其中不含有重复字符的最长子串的长度。',
    analysis: '滑动窗口 + 哈希表记录字符最近出现的位置。右指针扩张窗口，遇到重复字符时把左指针跳到重复字符上次位置的下一位，维护最大窗口长度。',
    codeArkts: `function lengthOfLongestSubstring(s: string): number {
  const last: Map<string, number> = new Map();
  let left = 0;
  let best = 0;
  for (let right = 0; right < s.length; right++) {
    const ch = s.charAt(right);
    const prev = last.get(ch);
    if (prev !== undefined && prev >= left) {
      left = prev + 1;
    }
    last.set(ch, right);
    best = Math.max(best, right - left + 1);
  }
  return best;
}`,
    codePython: `def length_of_longest_substring(s):
    last = {}
    left = best = 0
    for right, ch in enumerate(s):
        if ch in last and last[ch] >= left:
            left = last[ch] + 1
        last[ch] = right
        best = max(best, right - left + 1)
    return best`,
    tags: '滑动窗口,哈希表,字符串'
  },
  {
    id: 19,
    title: '最长回文子串',
    category: '字符串',
    difficulty: 2,
    description: '给你一个字符串 s，找到 s 中最长的回文子串。',
    analysis: '中心扩展法：枚举每个可能的回文中心（奇数长度以单字符为中心，偶数长度以双字符间隙为中心），向两边扩展并记录最长回文，时间 O(n²)，空间 O(1)。',
    codeArkts: `function longestPalindrome(s: string): string {
  if (s.length < 2) {
    return s;
  }
  let start = 0;
  let end = 0;
  const expand = (l: number, r: number): void => {
    while (l >= 0 && r < s.length && s.charAt(l) === s.charAt(r)) {
      l--;
      r++;
    }
    if (r - l - 1 > end - start) {
      start = l + 1;
      end = r - 1;
    }
  };
  for (let i = 0; i < s.length; i++) {
    expand(i, i);
    expand(i, i + 1);
  }
  return s.substring(start, end + 1);
}`,
    codePython: `def longest_palindrome(s):
    if len(s) < 2:
        return s
    res = [0, 0]
    def expand(l, r):
        while l >= 0 and r < len(s) and s[l] == s[r]:
            l -= 1
            r += 1
        if r - l - 1 > res[1] - res[0] + 1:
            res[0], res[1] = l + 1, r - 1
    for i in range(len(s)):
        expand(i, i)
        expand(i, i + 1)
    return s[res[0]:res[1] + 1]`,
    tags: '中心扩展,字符串'
  },
  {
    id: 20,
    title: '字符串转换整数 (atoi)',
    category: '字符串',
    difficulty: 2,
    description: '请你实现 myAtoi 函数，将字符串转换成一个 32 位有符号整数。规则包括跳过前导空格、识别正负号、读取数字并在溢出时截断。',
    analysis: '先去除前导空格，处理可选的正负号，逐位累积数字并在每一步检查是否越过 32 位整数上下界，遇到非数字字符即停止。',
    codeArkts: `function myAtoi(s: string): number {
  const str = s.trim();
  if (str.length === 0) {
    return 0;
  }
  let sign = 1;
  let i = 0;
  if (str.charAt(0) === '-' || str.charAt(0) === '+') {
    sign = str.charAt(0) === '-' ? -1 : 1;
    i = 1;
  }
  const MAX = 2147483647;
  const MIN = -2147483648;
  let num = 0;
  while (i < str.length && str.charAt(i) >= '0' && str.charAt(i) <= '9') {
    num = num * 10 + (str.charCodeAt(i) - 48);
    if (sign * num > MAX) {
      return MAX;
    }
    if (sign * num < MIN) {
      return MIN;
    }
    i++;
  }
  return sign * num;
}`,
    codePython: `def my_atoi(s):
    s = s.lstrip()
    if not s:
        return 0
    sign = 1
    i = 0
    if s[0] in '+-':
        sign = -1 if s[0] == '-' else 1
        i = 1
    num = 0
    while i < len(s) and s[i].isdigit():
        num = num * 10 + int(s[i])
        num = min(max(sign * num, -2**31), 2**31 - 1)
        i += 1
    return sign * num if sign * num != 0 else num`,
    tags: '字符串,模拟'
  },
  {
    id: 21,
    title: '翻转字符串里的单词',
    category: '字符串',
    difficulty: 2,
    description: '给你一个字符串 s，请你反转字符串中单词的顺序。单词之间用单个空格分隔，反转后单词之间只保留单个空格，且首尾不能有空格。',
    analysis: '按空格切分后过滤空串，从后向前拼接非空单词，用单个空格连接即可。若要原地 O(1) 空间则可先整体反转再逐个单词反转。',
    codeArkts: `function reverseWords(s: string): string {
  const words = s.trim().split(' ');
  const res: string[] = [];
  for (let i = words.length - 1; i >= 0; i--) {
    if (words[i].length > 0) {
      res.push(words[i]);
    }
  }
  return res.join(' ');
}`,
    codePython: `def reverse_words(s):
    return ' '.join(s.split()[::-1])`,
    tags: '字符串,双指针'
  },
  {
    id: 22,
    title: '字母异位词分组',
    category: '字符串',
    difficulty: 2,
    description: '给你一个字符串数组 strs，请你将字母异位词组合在一起。可以按任意顺序返回结果列表。字母异位词是由重新排列源单词的所有字母得到的新单词。',
    analysis: '将每个字符串排序后的结果作为分组键存入哈希表，键相同即为字母异位词。时间复杂度 O(n·k log k)，k 为单词最大长度。',
    codeArkts: `function groupAnagrams(strs: string[]): string[][] {
  const map: Map<string, string[]> = new Map();
  for (let i = 0; i < strs.length; i++) {
    const arr = strs[i].split('');
    arr.sort();
    const key = arr.join('');
    const group = map.get(key);
    if (group === undefined) {
      map.set(key, [strs[i]]);
    } else {
      group.push(strs[i]);
    }
  }
  const res: string[][] = [];
  map.forEach((value: string[]) => {
    res.push(value);
  });
  return res;
}`,
    codePython: `def group_anagrams(strs):
    groups = {}
    for word in strs:
        key = ''.join(sorted(word))
        groups.setdefault(key, []).append(word)
    return list(groups.values())`,
    tags: '哈希表,排序,字符串'
  },
  {
    id: 23,
    title: '字符串相加',
    category: '字符串',
    difficulty: 2,
    description: '给定两个字符串形式的非负整数 num1 和 num2，计算它们的和并以字符串形式返回。不能使用任何内置的大整数库，也不能直接将字符串转换为整数。',
    analysis: '从末尾逐位相加并处理进位，类似竖式加法。注意最后可能还有进位，结果需要反转。',
    codeArkts: `function addStrings(num1: string, num2: string): string {
  let i = num1.length - 1;
  let j = num2.length - 1;
  let carry = 0;
  const res: string[] = [];
  while (i >= 0 || j >= 0 || carry > 0) {
    let sum = carry;
    if (i >= 0) {
      sum += num1.charCodeAt(i) - 48;
    }
    if (j >= 0) {
      sum += num2.charCodeAt(j) - 48;
    }
    res.push((sum % 10).toString());
    carry = Math.floor(sum / 10);
    i--;
    j--;
  }
  return res.reverse().join('');
}`,
    codePython: `def add_strings(num1, num2):
    i, j, carry = len(num1) - 1, len(num2) - 1, 0
    res = []
    while i >= 0 or j >= 0 or carry:
        total = carry
        if i >= 0:
            total += int(num1[i]); i -= 1
        if j >= 0:
            total += int(num2[j]); j -= 1
        res.append(str(total % 10))
        carry = total // 10
    return ''.join(reversed(res))`,
    tags: '字符串,模拟,数学'
  },
  {
    id: 24,
    title: '找出字符串中第一个匹配项的下标',
    category: '字符串',
    difficulty: 2,
    description: '给你两个字符串 haystack 和 needle，请你在 haystack 字符串中找出 needle 字符串的第一个匹配项的下标（下标从 0 开始）。如果不存在则返回 -1。',
    analysis: '朴素双指针逐位比较即可；进阶可用 KMP 算法，通过前缀函数在 O(n+m) 时间内完成匹配。下方给出朴素实现。',
    codeArkts: `function strStr(haystack: string, needle: string): number {
  const n = haystack.length;
  const m = needle.length;
  if (m === 0) {
    return 0;
  }
  for (let i = 0; i + m <= n; i++) {
    let j = 0;
    while (j < m && haystack.charAt(i + j) === needle.charAt(j)) {
      j++;
    }
    if (j === m) {
      return i;
    }
  }
  return -1;
}`,
    codePython: `def str_str(haystack, needle):
    if not needle:
        return 0
    for i in range(len(haystack) - len(needle) + 1):
        if haystack[i:i + len(needle)] == needle:
            return i
    return -1`,
    tags: '字符串,KMP'
  },
  {
    id: 25,
    title: 'Z 字形变换',
    category: '字符串',
    difficulty: 2,
    description: '将一个给定字符串 s 根据给定的行数 numRows，以从上往下、从左到右进行 Z 字形排列，然后逐行读取得到新字符串。',
    analysis: '按行模拟：维护当前行 curRow 与方向，逐字符放入对应行的缓冲，到达首行或末行时改变方向，最后拼接各行。',
    codeArkts: `function convert(s: string, numRows: number): string {
  if (numRows === 1) {
    return s;
  }
  const rows: string[] = [];
  for (let i = 0; i < numRows; i++) {
    rows.push('');
  }
  let cur = 0;
  let goingDown = false;
  for (let i = 0; i < s.length; i++) {
    rows[cur] += s.charAt(i);
    if (cur === 0 || cur === numRows - 1) {
      goingDown = !goingDown;
    }
    cur += goingDown ? 1 : -1;
  }
  return rows.join('');
}`,
    codePython: `def convert(s, num_rows):
    if num_rows == 1:
        return s
    rows = [''] * num_rows
    cur, going_down = 0, False
    for ch in s:
        rows[cur] += ch
        if cur == 0 or cur == num_rows - 1:
            going_down = not going_down
        cur += 1 if going_down else -1
    return ''.join(rows)`,
    tags: '字符串,模拟'
  },
  {
    id: 26,
    title: '外观数列',
    category: '字符串',
    difficulty: 2,
    description: '外观数列是一个整数序列，从数字 1 开始，序列中的每一项都是对前一项的描述。给定正整数 n，输出外观数列的第 n 项。',
    analysis: '从 "1" 开始迭代 n-1 次，每次扫描当前字符串，统计连续相同字符的个数并生成「个数 + 字符」的新串。',
    codeArkts: `function countAndSay(n: number): string {
  let res = '1';
  for (let i = 1; i < n; i++) {
    let next = '';
    let j = 0;
    while (j < res.length) {
      const ch = res.charAt(j);
      let count = 0;
      while (j < res.length && res.charAt(j) === ch) {
        count++;
        j++;
      }
      next += count.toString() + ch;
    }
    res = next;
  }
  return res;
}`,
    codePython: `def count_and_say(n):
    res = '1'
    for _ in range(n - 1):
        nxt, j = '', 0
        while j < len(res):
            ch, count = res[j], 0
            while j < len(res) and res[j] == ch:
                count += 1
                j += 1
            nxt += str(count) + ch
        res = nxt
    return res`,
    tags: '字符串,模拟'
  },
  {
    id: 27,
    title: '验证回文串',
    category: '字符串',
    difficulty: 1,
    description: '如果在将所有大写字符转换为小写字符、并移除所有非字母数字字符之后，短语正着读和反着读都一样，则可以认为该短语是一个回文串。给定字符串 s，判断是否为回文串。',
    analysis: '先过滤出字母数字并转小写，再用双指针从两端向中间比较即可。',
    codeArkts: `function isPalindrome(s: string): boolean {
  const clean = s.toLowerCase().split('').filter((c: string) => {
    return (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
  }).join('');
  let left = 0;
  let right = clean.length - 1;
  while (left < right) {
    if (clean.charAt(left) !== clean.charAt(right)) {
      return false;
    }
    left++;
    right--;
  }
  return true;
}`,
    codePython: `def is_palindrome(s):
    clean = [c.lower() for c in s if c.isalnum()]
    return clean == clean[::-1]`,
    tags: '双指针,字符串'
  },
  {
    id: 28,
    title: '最小覆盖子串',
    category: '字符串',
    difficulty: 3,
    description: '给你一个字符串 s 和一个字符串 t，返回 s 中涵盖 t 所有字符的最小子串。如果不存在涵盖 t 所有字符的子串，则返回空字符串。',
    analysis: '滑动窗口：用哈希表统计 t 中各字符的需求量，右指针扩张直到窗口涵盖 t，再收缩左指针求最短，边收缩边记录最优区间。',
    codeArkts: `function minWindow(s: string, t: string): string {
  const need: Map<string, number> = new Map();
  for (let i = 0; i < t.length; i++) {
    const c = t.charAt(i);
    need.set(c, (need.get(c) ?? 0) + 1);
  }
  const window: Map<string, number> = new Map();
  let left = 0;
  let valid = 0;
  let start = 0;
  let minLen = Infinity;
  for (let right = 0; right < s.length; right++) {
    const c = s.charAt(right);
    if (need.has(c)) {
      window.set(c, (window.get(c) ?? 0) + 1);
      if (window.get(c) === need.get(c)) {
        valid++;
      }
    }
    while (valid === need.size) {
      if (right - left + 1 < minLen) {
        start = left;
        minLen = right - left + 1;
      }
      const d = s.charAt(left);
      if (need.has(d)) {
        if (window.get(d) === need.get(d)) {
          valid--;
        }
        window.set(d, (window.get(d) ?? 0) - 1);
      }
      left++;
    }
  }
  return minLen === Infinity ? '' : s.substring(start, start + minLen);
}`,
    codePython: `def min_window(s, t):
    from collections import Counter
    need = Counter(t)
    window = Counter()
    left = valid = start = 0
    min_len = float('inf')
    for right, ch in enumerate(s):
        if ch in need:
            window[ch] += 1
            if window[ch] == need[ch]:
                valid += 1
        while valid == len(need):
            if right - left + 1 < min_len:
                start, min_len = left, right - left + 1
            d = s[left]
            if d in need:
                if window[d] == need[d]:
                    valid -= 1
                window[d] -= 1
            left += 1
    return '' if min_len == float('inf') else s[start:start + min_len]`,
    tags: '滑动窗口,哈希表,字符串'
  },
  // ==================== 链表与树 ====================
  {
    id: 29,
    title: '反转链表',
    category: '链表与树',
    difficulty: 1,
    description: '给你单链表的头节点 head，请你反转链表，并返回反转后的链表头节点。',
    analysis: '迭代法：用 prev 指向已反转部分的头，遍历时先把当前节点的 next 暂存，再把当前节点指回 prev，最后 prev 前移。时间 O(n)，空间 O(1)。',
    codeArkts: `class ListNode {
  val: number;
  next: ListNode | null = null;
  constructor(v: number) {
    this.val = v;
  }
}

function reverseList(head: ListNode | null): ListNode | null {
  let prev: ListNode | null = null;
  let cur: ListNode | null = head;
  while (cur !== null) {
    const next = cur.next;
    cur.next = prev;
    prev = cur;
    cur = next;
  }
  return prev;
}`,
    codePython: `class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def reverse_list(head):
    prev, cur = None, head
    while cur:
        cur.next, prev, cur = prev, cur, cur.next
    return prev`,
    tags: '链表,迭代'
  },
  {
    id: 30,
    title: '合并两个有序链表',
    category: '链表与树',
    difficulty: 1,
    description: '将两个升序链表合并为一个新的升序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。',
    analysis: '使用哨兵头节点，双指针比较两个链表当前节点，较小者接入结果并前移，最后把未遍历完的链表整体接到尾部。',
    codeArkts: `function mergeTwoLists(l1: ListNode | null, l2: ListNode | null): ListNode | null {
  const dummy = new ListNode(0);
  let cur = dummy;
  while (l1 !== null && l2 !== null) {
    if (l1.val <= l2.val) {
      cur.next = l1;
      l1 = l1.next;
    } else {
      cur.next = l2;
      l2 = l2.next;
    }
    cur = cur.next;
  }
  cur.next = l1 !== null ? l1 : l2;
  return dummy.next;
}`,
    codePython: `def merge_two_lists(l1, l2):
    dummy = ListNode(0)
    cur = dummy
    while l1 and l2:
        if l1.val <= l2.val:
            cur.next, l1 = l1, l1.next
        else:
            cur.next, l2 = l2, l2.next
        cur = cur.next
    cur.next = l1 or l2
    return dummy.next`,
    tags: '链表,双指针'
  },
  {
    id: 31,
    title: '环形链表',
    category: '链表与树',
    difficulty: 1,
    description: '给你一个链表的头节点 head，判断链表中是否有环。如果链表中有某个节点可以通过连续跟踪 next 指针再次到达，则链表中存在环。',
    analysis: '快慢指针：慢指针每次走一步，快指针每次走两步。若存在环，快指针最终会追上慢指针；若无环，快指针先到达末尾。',
    codeArkts: `function hasCycle(head: ListNode | null): boolean {
  let slow: ListNode | null = head;
  let fast: ListNode | null = head;
  while (fast !== null && fast.next !== null) {
    slow = slow === null ? null : slow.next;
    fast = fast.next.next;
    if (slow === fast) {
      return true;
    }
  }
  return false;
}`,
    codePython: `def has_cycle(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow is fast:
            return True
    return False`,
    tags: '链表,快慢指针'
  },
  {
    id: 32,
    title: '相交链表',
    category: '链表与树',
    difficulty: 1,
    description: '给你两个单链表的头节点 headA 和 headB，请找出并返回两个单链表相交的起始节点。如果两个链表不存在相交节点，返回 null。',
    analysis: '双指针交错遍历：指针 a 走完 A 链表后转到 B，指针 b 走完 B 后转到 A。两者走过的总长度相同，最终会在相交点相遇或同时到达 null。',
    codeArkts: `function getIntersectionNode(headA: ListNode | null, headB: ListNode | null): ListNode | null {
  let a: ListNode | null = headA;
  let b: ListNode | null = headB;
  while (a !== b) {
    a = a === null ? headB : a.next;
    b = b === null ? headA : b.next;
  }
  return a;
}`,
    codePython: `def get_intersection_node(headA, headB):
    a, b = headA, headB
    while a is not b:
        a = a.next if a else headB
        b = b.next if b else headA
    return a`,
    tags: '链表,双指针'
  },
  {
    id: 33,
    title: '删除链表的倒数第 N 个节点',
    category: '链表与树',
    difficulty: 2,
    description: '给你一个链表，删除链表的倒数第 n 个节点，并且返回链表的头节点。',
    analysis: '使用哨兵节点 + 快慢指针：快指针先走 n+1 步，然后快慢指针同步前进，当快指针到达末尾时，慢指针正好指向待删除节点的前驱。',
    codeArkts: `function removeNthFromEnd(head: ListNode | null, n: number): ListNode | null {
  const dummy = new ListNode(0);
  dummy.next = head;
  let fast: ListNode | null = dummy;
  let slow: ListNode | null = dummy;
  for (let i = 0; i <= n; i++) {
    if (fast !== null) {
      fast = fast.next;
    }
  }
  while (fast !== null) {
    fast = fast.next;
    if (slow !== null) {
      slow = slow.next;
    }
  }
  if (slow !== null && slow.next !== null) {
    slow.next = slow.next.next;
  }
  return dummy.next;
}`,
    codePython: `def remove_nth_from_end(head, n):
    dummy = ListNode(0, head)
    fast = slow = dummy
    for _ in range(n + 1):
        fast = fast.next
    while fast:
        fast = fast.next
        slow = slow.next
    slow.next = slow.next.next
    return dummy.next`,
    tags: '链表,快慢指针'
  },
  {
    id: 34,
    title: '两两交换链表中的节点',
    category: '链表与树',
    difficulty: 2,
    description: '给你一个链表，两两交换其中相邻的节点，并返回交换后链表的头节点。你必须在不修改节点内部值的情况下完成，只能进行节点交换。',
    analysis: '使用哨兵节点，维护 prev 指向每对节点的前驱。每轮取出 first、second，调整 three 处指针完成交换后把 prev 移到 first。',
    codeArkts: `function swapPairs(head: ListNode | null): ListNode | null {
  const dummy = new ListNode(0);
  dummy.next = head;
  let prev: ListNode = dummy;
  while (prev.next !== null && prev.next.next !== null) {
    const first = prev.next;
    const second = first.next as ListNode;
    first.next = second.next;
    second.next = first;
    prev.next = second;
    prev = first;
  }
  return dummy.next;
}`,
    codePython: `def swap_pairs(head):
    dummy = ListNode(0, head)
    prev = dummy
    while prev.next and prev.next.next:
        first = prev.next
        second = first.next
        first.next = second.next
        second.next = first
        prev.next = second
        prev = first
    return dummy.next`,
    tags: '链表,迭代'
  },
  {
    id: 35,
    title: '回文链表',
    category: '链表与树',
    difficulty: 2,
    description: '给你一个单链表的头节点 head，请你判断该链表是否为回文链表。如果是返回 true，否则返回 false。',
    analysis: '快慢指针找到中点，反转后半部分链表，再与前半部分逐节点比较。这样时间复杂度 O(n)、空间 O(1)。',
    codeArkts: `function isPalindromeList(head: ListNode | null): boolean {
  if (head === null || head.next === null) {
    return true;
  }
  let slow: ListNode = head;
  let fast: ListNode = head;
  while (fast.next !== null && fast.next.next !== null) {
    slow = slow.next as ListNode;
    fast = fast.next.next;
  }
  let prev: ListNode | null = null;
  let cur: ListNode | null = slow.next;
  while (cur !== null) {
    const next = cur.next;
    cur.next = prev;
    prev = cur;
    cur = next;
  }
  let p1: ListNode | null = head;
  let p2: ListNode | null = prev;
  while (p2 !== null) {
    if (p1 === null || p1.val !== p2.val) {
      return false;
    }
    p1 = p1.next;
    p2 = p2.next;
  }
  return true;
}`,
    codePython: `def is_palindrome_list(head):
    vals = []
    node = head
    while node:
        vals.append(node.val)
        node = node.next
    return vals == vals[::-1]`,
    tags: '链表,双指针'
  },
  {
    id: 36,
    title: '二叉树的中序遍历',
    category: '链表与树',
    difficulty: 1,
    description: '给定一个二叉树的根节点 root，返回它的中序遍历结果（左-根-右）。',
    analysis: '递归最直观；迭代时用栈模拟：一路向左压栈，弹出即访问并转向右子树。下方给出迭代实现。',
    codeArkts: `function inorderTraversal(root: TreeNode | null): number[] {
  const res: number[] = [];
  const stack: TreeNode[] = [];
  let cur: TreeNode | null = root;
  while (cur !== null || stack.length > 0) {
    while (cur !== null) {
      stack.push(cur);
      cur = cur.left;
    }
    const node = stack.pop() as TreeNode;
    res.push(node.val);
    cur = node.right;
  }
  return res;
}`,
    codePython: `def inorder_traversal(root):
    res, stack, cur = [], [], root
    while cur or stack:
        while cur:
            stack.append(cur)
            cur = cur.left
        node = stack.pop()
        res.append(node.val)
        cur = node.right
    return res`,
    tags: '二叉树,栈,遍历'
  },
  {
    id: 37,
    title: '二叉树的最大深度',
    category: '链表与树',
    difficulty: 1,
    description: '给定一个二叉树 root，返回其最大深度。最大深度是指从根节点到最远叶子节点的最长路径上的节点数。',
    analysis: '递归：树的深度等于左右子树深度的较大值加一，空树深度为 0。',
    codeArkts: `function maxDepth(root: TreeNode | null): number {
  if (root === null) {
    return 0;
  }
  return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));
}`,
    codePython: `def max_depth(root):
    if not root:
        return 0
    return 1 + max(max_depth(root.left), max_depth(root.right))`,
    tags: '二叉树,递归'
  },
  {
    id: 38,
    title: '对称二叉树',
    category: '链表与树',
    difficulty: 1,
    description: '给你一个二叉树的根节点 root，检查它是否轴对称。',
    analysis: '递归比较左右子树：两棵子树需根值相同，且左子树的左与右子树的右对称、左子树的右与右子树的左对称。',
    codeArkts: `function isSymmetric(root: TreeNode | null): boolean {
  const check = (a: TreeNode | null, b: TreeNode | null): boolean => {
    if (a === null && b === null) {
      return true;
    }
    if (a === null || b === null) {
      return false;
    }
    return a.val === b.val && check(a.left, b.right) && check(a.right, b.left);
  };
  return root === null ? true : check(root.left, root.right);
}`,
    codePython: `def is_symmetric(root):
    def check(a, b):
        if not a and not b:
            return True
        if not a or not b:
            return False
        return a.val == b.val and check(a.left, b.right) and check(a.right, b.left)
    return check(root, root) if root else True`,
    tags: '二叉树,递归'
  },
  {
    id: 39,
    title: '二叉树的层序遍历',
    category: '链表与树',
    difficulty: 2,
    description: '给你二叉树的根节点 root，返回其节点值的层序遍历结果（即逐层地从左到右访问所有节点）。',
    analysis: '使用队列进行广度优先搜索，每轮先记录当前队列长度，处理该层所有节点并把子节点入队，从而按层收集结果。',
    codeArkts: `function levelOrder(root: TreeNode | null): number[][] {
  const res: number[][] = [];
  if (root === null) {
    return res;
  }
  const queue: TreeNode[] = [root];
  while (queue.length > 0) {
    const size = queue.length;
    const level: number[] = [];
    for (let i = 0; i < size; i++) {
      const node = queue.shift() as TreeNode;
      level.push(node.val);
      if (node.left !== null) {
        queue.push(node.left);
      }
      if (node.right !== null) {
        queue.push(node.right);
      }
    }
    res.push(level);
  }
  return res;
}`,
    codePython: `def level_order(root):
    from collections import deque
    if not root:
        return []
    res, queue = [], deque([root])
    while queue:
        level = []
        for _ in range(len(queue)):
            node = queue.popleft()
            level.append(node.val)
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        res.append(level)
    return res`,
    tags: '二叉树,广度优先,队列'
  },
  {
    id: 40,
    title: '验证二叉搜索树',
    category: '链表与树',
    difficulty: 2,
    description: '给你一个二叉树的根节点 root，判断其是否是一个有效的二叉搜索树。有效 BST 需满足：左子树所有节点小于根，右子树所有节点大于根，且左右子树均为 BST。',
    analysis: '递归时携带每个节点允许的取值范围 (low, high)，根的值必须落在区间内，递归时更新左右子树的边界。',
    codeArkts: `function isValidBST(root: TreeNode | null): boolean {
  const helper = (node: TreeNode | null, low: number, high: number): boolean => {
    if (node === null) {
      return true;
    }
    if (node.val <= low || node.val >= high) {
      return false;
    }
    return helper(node.left, low, node.val) && helper(node.right, node.val, high);
  };
  return helper(root, -Infinity, Infinity);
}`,
    codePython: `def is_valid_bst(root):
    def helper(node, low, high):
        if not node:
            return True
        if not (low < node.val < high):
            return False
        return helper(node.left, low, node.val) and helper(node.right, node.val, high)
    return helper(root, float('-inf'), float('inf'))`,
    tags: '二叉搜索树,递归'
  },
  {
    id: 41,
    title: '二叉树的最近公共祖先',
    category: '链表与树',
    difficulty: 2,
    description: '给定一个二叉树，找到该树中两个指定节点 p、q 的最近公共祖先。一个节点也可以是它自己的祖先。',
    analysis: '后序遍历：若当前节点为空或是 p/q 则返回当前节点；分别递归左右子树，若左右都找到则当前节点即为最近公共祖先，否则返回非空的一侧。',
    codeArkts: `function lowestCommonAncestor(root: TreeNode | null, p: TreeNode, q: TreeNode): TreeNode | null {
  if (root === null || root === p || root === q) {
    return root;
  }
  const left = lowestCommonAncestor(root.left, p, q);
  const right = lowestCommonAncestor(root.right, p, q);
  if (left !== null && right !== null) {
    return root;
  }
  return left !== null ? left : right;
}`,
    codePython: `def lowest_common_ancestor(root, p, q):
    if not root or root is p or root is q:
        return root
    left = lowest_common_ancestor(root.left, p, q)
    right = lowest_common_ancestor(root.right, p, q)
    if left and right:
        return root
    return left or right`,
    tags: '二叉树,递归'
  },
  {
    id: 42,
    title: '二叉树中的最大路径和',
    category: '链表与树',
    difficulty: 3,
    description: '路径被定义为一条从树中任意节点出发，沿父节点-子节点连接，达到任意节点的序列。同一个节点在一条路径中至多出现一次。给定二叉树根节点，返回其最大路径和。',
    analysis: '后序遍历计算每个节点「向下的最大贡献」，负贡献取 0。以当前节点为路径拐点时，用左右贡献之和更新全局最大值；返回给父节点的只能是单侧最大贡献。',
    codeArkts: `function maxPathSum(root: TreeNode | null): number {
  let max = -Infinity;
  const gain = (node: TreeNode | null): number => {
    if (node === null) {
      return 0;
    }
    const left = Math.max(gain(node.left), 0);
    const right = Math.max(gain(node.right), 0);
    max = Math.max(max, node.val + left + right);
    return node.val + Math.max(left, right);
  };
  gain(root);
  return max;
}`,
    codePython: `def max_path_sum(root):
    best = float('-inf')
    def gain(node):
        nonlocal best
        if not node:
            return 0
        left = max(gain(node.left), 0)
        right = max(gain(node.right), 0)
        best = max(best, node.val + left + right)
        return node.val + max(left, right)
    gain(root)
    return best`,
    tags: '二叉树,深度优先,动态规划'
  },
  // ==================== 动态规划 ====================
  {
    id: 43,
    title: '爬楼梯',
    category: '动态规划',
    difficulty: 1,
    description: '假设你正在爬楼梯，需要 n 阶才能到达楼顶。每次你可以爬 1 或 2 个台阶，问有多少种不同的方法可以爬到楼顶。',
    analysis: '设 dp[i] 为到达第 i 阶的方法数，则 dp[i] = dp[i-1] + dp[i-2]，即斐波那契数列。可用两个变量滚动优化空间至 O(1)。',
    codeArkts: `function climbStairs(n: number): number {
  if (n <= 2) {
    return n;
  }
  let a = 1;
  let b = 2;
  for (let i = 3; i <= n; i++) {
    const c = a + b;
    a = b;
    b = c;
  }
  return b;
}`,
    codePython: `def climb_stairs(n):
    if n <= 2:
        return n
    a, b = 1, 2
    for _ in range(3, n + 1):
        a, b = b, a + b
    return b`,
    tags: '动态规划,斐波那契'
  },
  {
    id: 44,
    title: '斐波那契数列',
    category: '动态规划',
    difficulty: 1,
    description: '求斐波那契数列的第 n 项。斐波那契数列由 0 和 1 开始，之后的每一项都是前两项之和：F(0)=0，F(1)=1，F(n)=F(n-1)+F(n-2)。',
    analysis: '自底向上迭代，仅保留前两个状态，时间复杂度 O(n)，空间 O(1)。',
    codeArkts: `function fib(n: number): number {
  if (n < 2) {
    return n;
  }
  let a = 0;
  let b = 1;
  for (let i = 2; i <= n; i++) {
    const c = a + b;
    a = b;
    b = c;
  }
  return b;
}`,
    codePython: `def fib(n):
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b`,
    tags: '动态规划,数学'
  },
  {
    id: 45,
    title: '打家劫舍',
    category: '动态规划',
    difficulty: 2,
    description: '你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，但相邻的房屋装有相互连通的防盗系统。给定每个房屋存放金额的数组，求在不触发警报的情况下能偷窃到的最高金额。',
    analysis: 'dp[i] = max(dp[i-1], dp[i-2] + nums[i])，即对于每间房选择「不偷」或「偷」。用两个变量滚动表示前两间房的最高金额。',
    codeArkts: `function rob(nums: number[]): number {
  let prev = 0;
  let cur = 0;
  for (let i = 0; i < nums.length; i++) {
    const next = Math.max(cur, prev + nums[i]);
    prev = cur;
    cur = next;
  }
  return cur;
}`,
    codePython: `def rob(nums):
    prev = cur = 0
    for num in nums:
        prev, cur = cur, max(cur, prev + num)
    return cur`,
    tags: '动态规划'
  },
  {
    id: 46,
    title: '零钱兑换',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个整数数组 coins 表示不同面额的硬币，以及一个整数 amount 表示总金额。计算并返回可以凑成总金额所需的最少的硬币个数。如果没有任何一种组合能组成总金额，返回 -1。',
    analysis: '完全背包：dp[i] 表示凑成金额 i 的最少硬币数，转移为 dp[i] = min(dp[i - coin] + 1)，初始化为一个大于 amount 的哨兵值。',
    codeArkts: `function coinChange(coins: number[], amount: number): number {
  const dp: number[] = new Array<number>(amount + 1).fill(amount + 1);
  dp[0] = 0;
  for (let i = 1; i <= amount; i++) {
    for (let j = 0; j < coins.length; j++) {
      if (coins[j] <= i) {
        dp[i] = Math.min(dp[i], dp[i - coins[j]] + 1);
      }
    }
  }
  return dp[amount] > amount ? -1 : dp[amount];
}`,
    codePython: `def coin_change(coins, amount):
    dp = [amount + 1] * (amount + 1)
    dp[0] = 0
    for i in range(1, amount + 1):
        for coin in coins:
            if coin <= i:
                dp[i] = min(dp[i], dp[i - coin] + 1)
    return -1 if dp[amount] > amount else dp[amount]`,
    tags: '动态规划,完全背包'
  },
  {
    id: 47,
    title: '最长递增子序列',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个整数数组 nums，找到其中最长严格递增子序列的长度。子序列是由数组派生而来的序列，删除（或不删除）数组中的元素而不改变其余元素的顺序。',
    analysis: 'dp[i] 表示以 nums[i] 结尾的最长递增子序列长度，转移时枚举 j < i 且 nums[j] < nums[i]。时间 O(n²)，可用二分+贪心优化到 O(n log n)。',
    codeArkts: `function lengthOfLIS(nums: number[]): number {
  const dp: number[] = new Array<number>(nums.length).fill(1);
  let best = 0;
  for (let i = 0; i < nums.length; i++) {
    for (let j = 0; j < i; j++) {
      if (nums[j] < nums[i]) {
        dp[i] = Math.max(dp[i], dp[j] + 1);
      }
    }
    best = Math.max(best, dp[i]);
  }
  return best;
}`,
    codePython: `def length_of_lis(nums):
    import bisect
    tails = []
    for num in nums:
        pos = bisect.bisect_left(tails, num)
        if pos == len(tails):
            tails.append(num)
        else:
            tails[pos] = num
    return len(tails)`,
    tags: '动态规划,二分查找'
  },
  {
    id: 48,
    title: '最长回文子序列',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个字符串 s，找出其中最长的回文子序列，并返回该序列的长度。子序列定义为不改变剩余字符顺序的情况下删除某些字符后得到的序列。',
    analysis: '区间 DP：dp[i][j] 表示 s[i..j] 的最长回文子序列长度。若两端字符相等则 dp[i][j] = dp[i+1][j-1] + 2，否则取去掉任一端点的较大值。',
    codeArkts: `function longestPalindromeSubseq(s: string): number {
  const n = s.length;
  const dp: number[][] = [];
  for (let i = 0; i < n; i++) {
    dp.push(new Array<number>(n).fill(0));
  }
  for (let i = n - 1; i >= 0; i--) {
    dp[i][i] = 1;
    for (let j = i + 1; j < n; j++) {
      if (s.charAt(i) === s.charAt(j)) {
        dp[i][j] = dp[i + 1][j - 1] + 2;
      } else {
        dp[i][j] = Math.max(dp[i + 1][j], dp[i][j - 1]);
      }
    }
  }
  return dp[0][n - 1];
}`,
    codePython: `def longest_palindrome_subseq(s):
    n = len(s)
    dp = [[0] * n for _ in range(n)]
    for i in range(n - 1, -1, -1):
        dp[i][i] = 1
        for j in range(i + 1, n):
            if s[i] == s[j]:
                dp[i][j] = dp[i + 1][j - 1] + 2
            else:
                dp[i][j] = max(dp[i + 1][j], dp[i][j - 1])
    return dp[0][n - 1]`,
    tags: '动态规划,区间DP,字符串'
  },
  {
    id: 49,
    title: '编辑距离',
    category: '动态规划',
    difficulty: 3,
    description: '给你两个单词 word1 和 word2，请返回将 word1 转换成 word2 所使用的最少操作数。你可以对一个单词进行插入、删除、替换三种操作。',
    analysis: 'dp[i][j] 表示 word1 前 i 个字符转成 word2 前 j 个字符的最少操作数。字符相同则沿用左上角，否则在插入、删除、替换三者中取最小再加一。',
    codeArkts: `function minDistance(word1: string, word2: string): number {
  const m = word1.length;
  const n = word2.length;
  const dp: number[][] = [];
  for (let i = 0; i <= m; i++) {
    dp.push(new Array<number>(n + 1).fill(0));
  }
  for (let i = 0; i <= m; i++) {
    dp[i][0] = i;
  }
  for (let j = 0; j <= n; j++) {
    dp[0][j] = j;
  }
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (word1.charAt(i - 1) === word2.charAt(j - 1)) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = Math.min(dp[i - 1][j - 1], dp[i - 1][j], dp[i][j - 1]) + 1;
      }
    }
  }
  return dp[m][n];
}`,
    codePython: `def min_distance(word1, word2):
    m, n = len(word1), len(word2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    for i in range(m + 1):
        dp[i][0] = i
    for j in range(n + 1):
        dp[0][j] = j
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if word1[i - 1] == word2[j - 1]:
                dp[i][j] = dp[i - 1][j - 1]
            else:
                dp[i][j] = min(dp[i - 1][j - 1], dp[i - 1][j], dp[i][j - 1]) + 1
    return dp[m][n]`,
    tags: '动态规划,字符串'
  },
  {
    id: 50,
    title: '不同路径',
    category: '动态规划',
    difficulty: 2,
    description: '一个机器人位于 m x n 网格的左上角，每次只能向下或向右移动一步。机器人试图达到网格的右下角，问总共有多少条不同的路径。',
    analysis: 'dp[i][j] = dp[i-1][j] + dp[i][j-1]。可用一维数组滚动，dp[j] 在遍历中原地累加左、上两个方向的值。',
    codeArkts: `function uniquePaths(m: number, n: number): number {
  const dp: number[] = new Array<number>(n).fill(1);
  for (let i = 1; i < m; i++) {
    for (let j = 1; j < n; j++) {
      dp[j] += dp[j - 1];
    }
  }
  return dp[n - 1];
}`,
    codePython: `def unique_paths(m, n):
    dp = [1] * n
    for _ in range(1, m):
        for j in range(1, n):
            dp[j] += dp[j - 1]
    return dp[n - 1]`,
    tags: '动态规划,组合数学'
  },
  {
    id: 51,
    title: '最小路径和',
    category: '动态规划',
    difficulty: 2,
    description: '给定一个包含非负整数的 m x n 网格 grid，请找出一条从左上角到右下角的路径，使得路径上的数字总和为最小。每次只能向下或向右移动一步。',
    analysis: 'dp[i][j] = grid[i][j] + min(dp[i-1][j], dp[i][j-1])。边界行只能从左侧来、边界列只能从上方来，先分别初始化。',
    codeArkts: `function minPathSum(grid: number[][]): number {
  const m = grid.length;
  const n = grid[0].length;
  const dp: number[][] = [];
  for (let i = 0; i < m; i++) {
    dp.push(new Array<number>(n).fill(0));
  }
  dp[0][0] = grid[0][0];
  for (let i = 1; i < m; i++) {
    dp[i][0] = dp[i - 1][0] + grid[i][0];
  }
  for (let j = 1; j < n; j++) {
    dp[0][j] = dp[0][j - 1] + grid[0][j];
  }
  for (let i = 1; i < m; i++) {
    for (let j = 1; j < n; j++) {
      dp[i][j] = Math.min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j];
    }
  }
  return dp[m - 1][n - 1];
}`,
    codePython: `def min_path_sum(grid):
    m, n = len(grid), len(grid[0])
    dp = [[0] * n for _ in range(m)]
    dp[0][0] = grid[0][0]
    for i in range(1, m):
        dp[i][0] = dp[i - 1][0] + grid[i][0]
    for j in range(1, n):
        dp[0][j] = dp[0][j - 1] + grid[0][j]
    for i in range(1, m):
        for j in range(1, n):
            dp[i][j] = min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j]
    return dp[m - 1][n - 1]`,
    tags: '动态规划,矩阵'
  },
  {
    id: 52,
    title: '单词拆分',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个字符串 s 和一个字符串列表 wordDict 作为字典。请判断 s 是否可以利用字典中出现的单词拼接出来。拆分时可以重复使用字典中的单词。',
    analysis: 'dp[i] 表示 s 前 i 个字符能否被拆分。枚举分割点 j，若 dp[j] 为真且 s[j..i) 在字典中，则 dp[i] 为真。',
    codeArkts: `function wordBreak(s: string, wordDict: string[]): boolean {
  const set: Set<string> = new Set(wordDict);
  const dp: boolean[] = new Array<boolean>(s.length + 1).fill(false);
  dp[0] = true;
  for (let i = 1; i <= s.length; i++) {
    for (let j = 0; j < i; j++) {
      if (dp[j] && set.has(s.substring(j, i))) {
        dp[i] = true;
        break;
      }
    }
  }
  return dp[s.length];
}`,
    codePython: `def word_break(s, word_dict):
    words = set(word_dict)
    dp = [False] * (len(s) + 1)
    dp[0] = True
    for i in range(1, len(s) + 1):
        for j in range(i):
            if dp[j] and s[j:i] in words:
                dp[i] = True
                break
    return dp[len(s)]`,
    tags: '动态规划,字符串'
  },
  {
    id: 53,
    title: '分割等和子集',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个只包含正整数的非空数组 nums，请判断是否可以将这个数组分割成两个子集，使得两个子集的元素和相等。',
    analysis: '0/1 背包：若总和为奇数直接返回 false，否则转化为能否从 nums 中选出和为 sum/2 的子集。一维 dp 逆序遍历避免重复使用元素。',
    codeArkts: `function canPartition(nums: number[]): boolean {
  let sum = 0;
  for (let i = 0; i < nums.length; i++) {
    sum += nums[i];
  }
  if (sum % 2 !== 0) {
    return false;
  }
  const target = sum / 2;
  const dp: boolean[] = new Array<boolean>(target + 1).fill(false);
  dp[0] = true;
  for (let i = 0; i < nums.length; i++) {
    for (let j = target; j >= nums[i]; j--) {
      dp[j] = dp[j] || dp[j - nums[i]];
    }
  }
  return dp[target];
}`,
    codePython: `def can_partition(nums):
    total = sum(nums)
    if total % 2:
        return False
    target = total // 2
    dp = [False] * (target + 1)
    dp[0] = True
    for num in nums:
        for j in range(target, num - 1, -1):
            dp[j] = dp[j] or dp[j - num]
    return dp[target]`,
    tags: '动态规划,背包'
  },
  {
    id: 54,
    title: '最长公共子序列',
    category: '动态规划',
    difficulty: 2,
    description: '给定两个字符串 text1 和 text2，返回它们的最长公共子序列的长度。如果不存在公共子序列，返回 0。',
    analysis: 'dp[i][j] 表示 text1 前 i 个与 text2 前 j 个字符的最长公共子序列长度。字符相等则 dp[i-1][j-1]+1，否则取上方或左侧较大值。',
    codeArkts: `function longestCommonSubsequence(text1: string, text2: string): number {
  const m = text1.length;
  const n = text2.length;
  const dp: number[][] = [];
  for (let i = 0; i <= m; i++) {
    dp.push(new Array<number>(n + 1).fill(0));
  }
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (text1.charAt(i - 1) === text2.charAt(j - 1)) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
  }
  return dp[m][n];
}`,
    codePython: `def longest_common_subsequence(text1, text2):
    m, n = len(text1), len(text2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if text1[i - 1] == text2[j - 1]:
                dp[i][j] = dp[i - 1][j - 1] + 1
            else:
                dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
    return dp[m][n]`,
    tags: '动态规划,字符串'
  },
  {
    id: 55,
    title: '完全平方数',
    category: '动态规划',
    difficulty: 2,
    description: '给你一个整数 n，返回和为 n 的完全平方数的最少数量。完全平方数是一个整数，其值等于另一个整数的平方。',
    analysis: '类似零钱兑换：dp[i] = min(dp[i - j*j] + 1)，其中 j*j ≤ i。也可用数学的拉格朗日四平方和定理优化。',
    codeArkts: `function numSquares(n: number): number {
  const dp: number[] = new Array<number>(n + 1).fill(n + 1);
  dp[0] = 0;
  for (let i = 1; i <= n; i++) {
    for (let j = 1; j * j <= i; j++) {
      dp[i] = Math.min(dp[i], dp[i - j * j] + 1);
    }
  }
  return dp[n];
}`,
    codePython: `def num_squares(n):
    dp = [n + 1] * (n + 1)
    dp[0] = 0
    for i in range(1, n + 1):
        j = 1
        while j * j <= i:
            dp[i] = min(dp[i], dp[i - j * j] + 1)
            j += 1
    return dp[n]`,
    tags: '动态规划,数学'
  },
  {
    id: 56,
    title: '正则表达式匹配',
    category: '动态规划',
    difficulty: 3,
    description: '给你一个字符串 s 和一个字符规律 p，请你实现一个支持 . 和 * 的正则表达式匹配。. 匹配任意单个字符，* 匹配零个或多个前面的那一个元素。匹配应覆盖整个字符串 s。',
    analysis: 'dp[i][j] 表示 s 前 i 个字符与 p 前 j 个字符是否匹配。遇到 * 时考虑「匹配零次」和「匹配多次」两种转移；普通字符或 . 则比较后沿用左上角。',
    codeArkts: `function isMatch(s: string, p: string): boolean {
  const m = s.length;
  const n = p.length;
  const dp: boolean[][] = [];
  for (let i = 0; i <= m; i++) {
    dp.push(new Array<boolean>(n + 1).fill(false));
  }
  dp[0][0] = true;
  for (let j = 1; j <= n; j++) {
    if (p.charAt(j - 1) === '*') {
      dp[0][j] = dp[0][j - 2];
    }
  }
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      const pc = p.charAt(j - 1);
      const sc = s.charAt(i - 1);
      if (pc === '*') {
        const prev = p.charAt(j - 2);
        if (prev === '.' || prev === sc) {
          dp[i][j] = dp[i - 1][j] || dp[i][j - 2];
        } else {
          dp[i][j] = dp[i][j - 2];
        }
      } else if (pc === '.' || pc === sc) {
        dp[i][j] = dp[i - 1][j - 1];
      }
    }
  }
  return dp[m][n];
}`,
    codePython: `def is_match(s, p):
    m, n = len(s), len(p)
    dp = [[False] * (n + 1) for _ in range(m + 1)]
    dp[0][0] = True
    for j in range(1, n + 1):
        if p[j - 1] == '*':
            dp[0][j] = dp[0][j - 2]
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if p[j - 1] == '*':
                prev = p[j - 2]
                if prev == '.' or prev == s[i - 1]:
                    dp[i][j] = dp[i - 1][j] or dp[i][j - 2]
                else:
                    dp[i][j] = dp[i][j - 2]
            elif p[j - 1] == '.' or p[j - 1] == s[i - 1]:
                dp[i][j] = dp[i - 1][j - 1]
    return dp[m][n]`,
    tags: '动态规划,字符串,正则'
  },
  // ==================== 贪心与双指针 ====================
  {
    id: 57,
    title: '买卖股票的最佳时机',
    category: '贪心与双指针',
    difficulty: 1,
    description: '给定一个数组 prices，它的第 i 个元素 prices[i] 表示一支给定股票第 i 天的价格。你只能选择某一天买入并在未来某一天卖出，求能获取的最大利润。',
    analysis: '一次遍历维护历史最低价，每天计算「今天卖出」的利润并更新最大值，时间复杂度 O(n)。',
    codeArkts: `function maxProfit(prices: number[]): number {
  let minPrice = Infinity;
  let profit = 0;
  for (let i = 0; i < prices.length; i++) {
    minPrice = Math.min(minPrice, prices[i]);
    profit = Math.max(profit, prices[i] - minPrice);
  }
  return profit;
}`,
    codePython: `def max_profit(prices):
    min_price = float('inf')
    profit = 0
    for price in prices:
        min_price = min(min_price, price)
        profit = max(profit, price - min_price)
    return profit`,
    tags: '贪心,数组'
  },
  {
    id: 58,
    title: '跳跃游戏',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给定一个非负整数数组 nums，你最初位于数组的第一个下标。数组中的每个元素代表你在该位置可以跳跃的最大长度。判断你是否能够到达最后一个下标。',
    analysis: '贪心维护当前能到达的最远下标 reach。遍历过程中若当前下标超过 reach 则无法到达，否则不断更新 reach。',
    codeArkts: `function canJump(nums: number[]): boolean {
  let reach = 0;
  for (let i = 0; i < nums.length; i++) {
    if (i > reach) {
      return false;
    }
    reach = Math.max(reach, i + nums[i]);
  }
  return true;
}`,
    codePython: `def can_jump(nums):
    reach = 0
    for i, num in enumerate(nums):
        if i > reach:
            return False
        reach = max(reach, i + num)
    return True`,
    tags: '贪心,数组'
  },
  {
    id: 59,
    title: '跳跃游戏 II',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给定一个长度为 n 的非负整数数组 nums，你最初位于下标 0。每个元素代表你在该位置可以跳跃的最大长度。求到达最后一个下标的最少跳跃次数（假设总能到达）。',
    analysis: '贪心地按「层」跳跃：用 end 标记当前跳跃次数能到达的边界，farthest 记录下一步能到的最远处。遍历到边界时跳数加一，并把边界推进到 farthest。',
    codeArkts: `function jump(nums: number[]): number {
  let steps = 0;
  let end = 0;
  let farthest = 0;
  for (let i = 0; i < nums.length - 1; i++) {
    farthest = Math.max(farthest, i + nums[i]);
    if (i === end) {
      steps++;
      end = farthest;
    }
  }
  return steps;
}`,
    codePython: `def jump(nums):
    steps = end = farthest = 0
    for i in range(len(nums) - 1):
        farthest = max(farthest, i + nums[i])
        if i == end:
            steps += 1
            end = farthest
    return steps`,
    tags: '贪心,数组'
  },
  {
    id: 60,
    title: '分发饼干',
    category: '贪心与双指针',
    difficulty: 1,
    description: '假设你是一位家长，想要给你的孩子们分发饼干。每个孩子最多只能给一块饼干。孩子 i 的胃口为 g[i]，饼干 j 的尺寸为 s[j]。如果 s[j] >= g[i]，可以满足该孩子。求最多能满足多少个孩子。',
    analysis: '将胃口和饼干都排序，双指针从小到大匹配：饼干够大就喂给当前最小胃口的孩子，否则换更大饼干。',
    codeArkts: `function findContentChildren(g: number[], s: number[]): number {
  g.sort((a, b) => a - b);
  s.sort((a, b) => a - b);
  let i = 0;
  let j = 0;
  while (i < g.length && j < s.length) {
    if (s[j] >= g[i]) {
      i++;
    }
    j++;
  }
  return i;
}`,
    codePython: `def find_content_children(g, s):
    g.sort()
    s.sort()
    i = j = 0
    while i < len(g) and j < len(s):
        if s[j] >= g[i]:
            i += 1
        j += 1
    return i`,
    tags: '贪心,排序,双指针'
  },
  {
    id: 61,
    title: '无重叠区间',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给定一个区间的集合 intervals，其中 intervals[i] = [start_i, end_i]。返回需要移除区间的最小数量，使剩余区间互不重叠。',
    analysis: '按区间右端点升序排序，贪心地保留结束最早的区间。遍历时若当前区间起点小于已保留区间的终点则重叠，需要移除。',
    codeArkts: `function eraseOverlapIntervals(intervals: number[][]): number {
  if (intervals.length === 0) {
    return 0;
  }
  intervals.sort((a, b) => a[1] - b[1]);
  let removed = 0;
  let end = intervals[0][1];
  for (let i = 1; i < intervals.length; i++) {
    if (intervals[i][0] < end) {
      removed++;
    } else {
      end = intervals[i][1];
    }
  }
  return removed;
}`,
    codePython: `def erase_overlap_intervals(intervals):
    if not intervals:
        return 0
    intervals.sort(key=lambda x: x[1])
    removed = 0
    end = intervals[0][1]
    for start, finish in intervals[1:]:
        if start < end:
            removed += 1
        else:
            end = finish
    return removed`,
    tags: '贪心,排序,区间'
  },
  {
    id: 62,
    title: '加油站',
    category: '贪心与双指针',
    difficulty: 2,
    description: '在一条环路上有 n 个加油站，其中第 i 个加油站有汽油 gas[i] 升。你有一辆油箱容量无限的汽车，从第 i 个加油站开往第 i+1 个需要消耗 cost[i] 升。给定两个整数数组 gas 和 cost，如果你能绕环路行驶一周，返回出发时加油站的编号，否则返回 -1。',
    analysis: '若总油量小于总消耗则无解。否则从某站出发累计剩余油量，一旦为负说明从出发点到该点都无法作为起点，令起点为下一站并清零累计。',
    codeArkts: `function canCompleteCircuit(gas: number[], cost: number[]): number {
  let total = 0;
  let tank = 0;
  let start = 0;
  for (let i = 0; i < gas.length; i++) {
    const diff = gas[i] - cost[i];
    total += diff;
    tank += diff;
    if (tank < 0) {
      start = i + 1;
      tank = 0;
    }
  }
  return total >= 0 ? start : -1;
}`,
    codePython: `def can_complete_circuit(gas, cost):
    total = tank = start = 0
    for i in range(len(gas)):
        diff = gas[i] - cost[i]
        total += diff
        tank += diff
        if tank < 0:
            start = i + 1
            tank = 0
    return start if total >= 0 else -1`,
    tags: '贪心,数组'
  },
  {
    id: 63,
    title: '三数之和',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给你一个整数数组 nums，判断是否存在三元组 [nums[i], nums[j], nums[k]] 满足 i、j、k 互不相同且 nums[i] + nums[j] + nums[k] == 0。请返回所有和为 0 且不重复的三元组。',
    analysis: '先排序，固定第一个数，用左右双指针在右侧寻找两数之和为其相反数。注意跳过重复元素以避免重复三元组。',
    codeArkts: `function threeSum(nums: number[]): number[][] {
  const res: number[][] = [];
  nums.sort((a, b) => a - b);
  for (let i = 0; i < nums.length - 2; i++) {
    if (i > 0 && nums[i] === nums[i - 1]) {
      continue;
    }
    let left = i + 1;
    let right = nums.length - 1;
    while (left < right) {
      const sum = nums[i] + nums[left] + nums[right];
      if (sum === 0) {
        res.push([nums[i], nums[left], nums[right]]);
        while (left < right && nums[left] === nums[left + 1]) {
          left++;
        }
        while (left < right && nums[right] === nums[right - 1]) {
          right--;
        }
        left++;
        right--;
      } else if (sum < 0) {
        left++;
      } else {
        right--;
      }
    }
  }
  return res;
}`,
    codePython: `def three_sum(nums):
    nums.sort()
    res = []
    for i in range(len(nums) - 2):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        left, right = i + 1, len(nums) - 1
        while left < right:
            total = nums[i] + nums[left] + nums[right]
            if total == 0:
                res.append([nums[i], nums[left], nums[right]])
                while left < right and nums[left] == nums[left + 1]:
                    left += 1
                while left < right and nums[right] == nums[right - 1]:
                    right -= 1
                left += 1
                right -= 1
            elif total < 0:
                left += 1
            else:
                right -= 1
    return res`,
    tags: '双指针,排序,数组'
  },
  {
    id: 64,
    title: '盛最多水的容器',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给定一个长度为 n 的整数数组 height。有 n 条垂线，第 i 条线的两个端点是 (i, 0) 和 (i, height[i])。找出其中两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。',
    analysis: '左右双指针从两端向中间移动，每次计算当前面积并更新最大值；移动较短的那条边才有可能获得更大的面积，较长边移动不会更优。',
    codeArkts: `function maxArea(height: number[]): number {
  let left = 0;
  let right = height.length - 1;
  let best = 0;
  while (left < right) {
    const area = Math.min(height[left], height[right]) * (right - left);
    best = Math.max(best, area);
    if (height[left] < height[right]) {
      left++;
    } else {
      right--;
    }
  }
  return best;
}`,
    codePython: `def max_area(height):
    left, right = 0, len(height) - 1
    best = 0
    while left < right:
        best = max(best, min(height[left], height[right]) * (right - left))
        if height[left] < height[right]:
            left += 1
        else:
            right -= 1
    return best`,
    tags: '双指针,贪心,数组'
  },
  {
    id: 65,
    title: '接雨水',
    category: '贪心与双指针',
    difficulty: 3,
    description: '给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。',
    analysis: '双指针法：维护左右两侧的历史最高柱高。较矮一侧能接的水由该侧最高柱决定，累加 leftMax - height[left]（或右侧对应值）后向中间收缩。',
    codeArkts: `function trap(height: number[]): number {
  let left = 0;
  let right = height.length - 1;
  let leftMax = 0;
  let rightMax = 0;
  let water = 0;
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
}`,
    codePython: `def trap(height):
    left, right = 0, len(height) - 1
    left_max = right_max = water = 0
    while left < right:
        if height[left] < height[right]:
            left_max = max(left_max, height[left])
            water += left_max - height[left]
            left += 1
        else:
            right_max = max(right_max, height[right])
            water += right_max - height[right]
            right -= 1
    return water`,
    tags: '双指针,单调栈,数组'
  },
  {
    id: 66,
    title: '颜色分类',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给定一个包含红色、白色和蓝色、共 n 个元素的数组 nums，原地对它们进行排序，使得相同颜色的元素相邻，并按照红色、白色、蓝色顺序排列。使用整数 0、1、2 分别表示红色、白色和蓝色。',
    analysis: '荷兰国旗问题：用三个指针 low、mid、high 分区。遇到 0 与 low 交换并同时右移，遇到 1 直接右移 mid，遇到 2 与 high 交换并左移 high。',
    codeArkts: `function sortColors(nums: number[]): void {
  let low = 0;
  let mid = 0;
  let high = nums.length - 1;
  while (mid <= high) {
    if (nums[mid] === 0) {
      const t = nums[low];
      nums[low] = nums[mid];
      nums[mid] = t;
      low++;
      mid++;
    } else if (nums[mid] === 1) {
      mid++;
    } else {
      const t = nums[mid];
      nums[mid] = nums[high];
      nums[high] = t;
      high--;
    }
  }
}`,
    codePython: `def sort_colors(nums):
    low = mid = 0
    high = len(nums) - 1
    while mid <= high:
        if nums[mid] == 0:
            nums[low], nums[mid] = nums[mid], nums[low]
            low += 1
            mid += 1
        elif nums[mid] == 1:
            mid += 1
        else:
            nums[mid], nums[high] = nums[high], nums[mid]
            high -= 1`,
    tags: '双指针,排序,数组'
  },
  {
    id: 67,
    title: '合并区间',
    category: '贪心与双指针',
    difficulty: 2,
    description: '以数组 intervals 表示若干区间的集合，其中 intervals[i] = [start_i, end_i]。请合并所有重叠的区间，并返回一个不重叠的区间数组，该数组需恰好覆盖输入中的所有区间。',
    analysis: '按区间起点排序，顺序遍历并维护结果列表。若当前区间起点不大于结果末尾区间的终点则合并（更新终点为两者较大值），否则追加新区间。',
    codeArkts: `function mergeIntervals(intervals: number[][]): number[][] {
  if (intervals.length === 0) {
    return [];
  }
  intervals.sort((a, b) => a[0] - b[0]);
  const res: number[][] = [intervals[0]];
  for (let i = 1; i < intervals.length; i++) {
    const last = res[res.length - 1];
    if (intervals[i][0] <= last[1]) {
      last[1] = Math.max(last[1], intervals[i][1]);
    } else {
      res.push(intervals[i]);
    }
  }
  return res;
}`,
    codePython: `def merge_intervals(intervals):
    if not intervals:
        return []
    intervals.sort(key=lambda x: x[0])
    res = [intervals[0]]
    for start, end in intervals[1:]:
        if start <= res[-1][1]:
            res[-1][1] = max(res[-1][1], end)
        else:
            res.append([start, end])
    return res`,
    tags: '排序,贪心,区间'
  },
  {
    id: 68,
    title: '划分字母区间',
    category: '贪心与双指针',
    difficulty: 2,
    description: '给你一个字符串 s。我们要把这个字符串划分为尽可能多的片段，同一字母最多出现在一个片段中。返回一个表示每个字符串片段的长度的列表。',
    analysis: '先记录每个字符最后出现的下标。再次遍历时维护当前片段的结束边界 end，遇到字符就扩展 end 到其最后出现位置，当遍历到 end 时即切分一段。',
    codeArkts: `function partitionLabels(s: string): number[] {
  const last: number[] = new Array<number>(26).fill(0);
  for (let i = 0; i < s.length; i++) {
    last[s.charCodeAt(i) - 97] = i;
  }
  const res: number[] = [];
  let start = 0;
  let end = 0;
  for (let i = 0; i < s.length; i++) {
    end = Math.max(end, last[s.charCodeAt(i) - 97]);
    if (i === end) {
      res.push(end - start + 1);
      start = end + 1;
    }
  }
  return res;
}`,
    codePython: `def partition_labels(s):
    last = {c: i for i, c in enumerate(s)}
    res = []
    start = end = 0
    for i, c in enumerate(s):
        end = max(end, last[c])
        if i == end:
            res.append(end - start + 1)
            start = end + 1
    return res`,
    tags: '贪心,哈希表,字符串'
  },
  {
    id: 69,
    title: '移除元素',
    category: '贪心与双指针',
    difficulty: 1,
    description: '给你一个数组 nums 和一个值 val，你需要原地移除所有数值等于 val 的元素，并返回移除后数组的新长度。不要使用额外的数组空间。',
    analysis: '快慢指针：快指针遍历数组，只要不等于 val 就写到慢指针位置并前移慢指针。慢指针最终即为新长度。',
    codeArkts: `function removeElement(nums: number[], val: number): number {
  let k = 0;
  for (let i = 0; i < nums.length; i++) {
    if (nums[i] !== val) {
      nums[k] = nums[i];
      k++;
    }
  }
  return k;
}`,
    codePython: `def remove_element(nums, val):
    k = 0
    for num in nums:
        if num != val:
            nums[k] = num
            k += 1
    return k`,
    tags: '双指针,数组'
  },
  {
    id: 70,
    title: '判断子序列',
    category: '贪心与双指针',
    difficulty: 1,
    description: '给定字符串 s 和 t，判断 s 是否为 t 的子序列。字符串的一个子序列是原始字符串删除一些字符而不改变剩余字符相对位置形成的新字符串。',
    analysis: '双指针分别在 s 和 t 上移动，若字符相等则 s 指针前移，t 指针每次都前移。最终 s 指针走完即说明 s 是 t 的子序列。',
    codeArkts: `function isSubsequence(s: string, t: string): boolean {
  let i = 0;
  let j = 0;
  while (i < s.length && j < t.length) {
    if (s.charAt(i) === t.charAt(j)) {
      i++;
    }
    j++;
  }
  return i === s.length;
}`,
    codePython: `def is_subsequence(s, t):
    it = iter(t)
    return all(c in it for c in s)`,
    tags: '双指针,字符串,贪心'
  },
  // ==================== 其他经典 ====================
  {
    id: 71,
    title: '二分查找',
    category: '其他经典',
    difficulty: 1,
    description: '给定一个 n 个元素有序的（升序）整型数组 nums 和一个目标值 target，写一个函数搜索 nums 中的 target，如果目标值存在返回下标，否则返回 -1。',
    analysis: '标准二分：每次取区间中点比较，等于则返回，小于目标去右半区，大于去左半区。时间复杂度 O(log n)。',
    codeArkts: `function search(nums: number[], target: number): number {
  let left = 0;
  let right = nums.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (nums[mid] === target) {
      return mid;
    } else if (nums[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }
  return -1;
}`,
    codePython: `def search(nums, target):
    left, right = 0, len(nums) - 1
    while left <= right:
        mid = (left + right) // 2
        if nums[mid] == target:
            return mid
        elif nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1`,
    tags: '二分查找,数组'
  },
  {
    id: 72,
    title: '搜索旋转排序数组',
    category: '其他经典',
    difficulty: 2,
    description: '整数数组 nums 按升序排列，但在某个下标处经过了旋转。给你旋转后的数组和一个目标值 target，如果数组中存在目标值则返回下标，否则返回 -1。要求 O(log n) 时间。',
    analysis: '二分时判断哪一半有序：若左半有序且 target 落在该区间则收缩到左半，否则收缩到右半；右半有序时同理。',
    codeArkts: `function searchRotated(nums: number[], target: number): number {
  let left = 0;
  let right = nums.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (nums[mid] === target) {
      return mid;
    }
    if (nums[left] <= nums[mid]) {
      if (nums[left] <= target && target < nums[mid]) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    } else {
      if (nums[mid] < target && target <= nums[right]) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
  }
  return -1;
}`,
    codePython: `def search_rotated(nums, target):
    left, right = 0, len(nums) - 1
    while left <= right:
        mid = (left + right) // 2
        if nums[mid] == target:
            return mid
        if nums[left] <= nums[mid]:
            if nums[left] <= target < nums[mid]:
                right = mid - 1
            else:
                left = mid + 1
        else:
            if nums[mid] < target <= nums[right]:
                left = mid + 1
            else:
                right = mid - 1
    return -1`,
    tags: '二分查找,数组'
  },
  {
    id: 73,
    title: '在排序数组中查找元素的第一个和最后一个位置',
    category: '其他经典',
    difficulty: 2,
    description: '给你一个按照非递减顺序排列的整数数组 nums 和一个目标值 target，找出目标值在数组中的开始位置和结束位置。如果数组中不存在目标值则返回 [-1, -1]。要求 O(log n)。',
    analysis: '分别用二分查找目标的左边界和右边界：命中时左边界继续往左收缩，右边界继续往右收缩，两次二分即可得到区间。',
    codeArkts: `function searchRange(nums: number[], target: number): number[] {
  const findBound = (isLeft: boolean): number => {
    let left = 0;
    let right = nums.length - 1;
    let bound = -1;
    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      if (nums[mid] === target) {
        bound = mid;
        if (isLeft) {
          right = mid - 1;
        } else {
          left = mid + 1;
        }
      } else if (nums[mid] < target) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return bound;
  };
  return [findBound(true), findBound(false)];
}`,
    codePython: `def search_range(nums, target):
    def find_bound(is_left):
        left, right, bound = 0, len(nums) - 1, -1
        while left <= right:
            mid = (left + right) // 2
            if nums[mid] == target:
                bound = mid
                if is_left:
                    right = mid - 1
                else:
                    left = mid + 1
            elif nums[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        return bound
    return [find_bound(True), find_bound(False)]`,
    tags: '二分查找,数组'
  },
  {
    id: 74,
    title: '快速排序',
    category: '其他经典',
    difficulty: 2,
    description: '实现快速排序算法对数组进行升序排序。快速排序是一种分治算法，平均时间复杂度 O(n log n)。',
    analysis: '选取基准（pivot），通过分区把小于基准的元素放到左侧、大于的放到右侧，再递归排序左右两部分。下方采用 Lomuto 分区方案。',
    codeArkts: `function quickSort(nums: number[], left: number, right: number): void {
  if (left >= right) {
    return;
  }
  const pivot = nums[right];
  let store = left;
  for (let i = left; i < right; i++) {
    if (nums[i] < pivot) {
      const t = nums[i];
      nums[i] = nums[store];
      nums[store] = t;
      store++;
    }
  }
  const t2 = nums[store];
  nums[store] = nums[right];
  nums[right] = t2;
  quickSort(nums, left, store - 1);
  quickSort(nums, store + 1, right);
}`,
    codePython: `def quick_sort(nums, left, right):
    if left >= right:
        return
    pivot = nums[right]
    store = left
    for i in range(left, right):
        if nums[i] < pivot:
            nums[i], nums[store] = nums[store], nums[i]
            store += 1
    nums[store], nums[right] = nums[right], nums[store]
    quick_sort(nums, left, store - 1)
    quick_sort(nums, store + 1, right)`,
    tags: '排序,分治,快速排序'
  },
  {
    id: 75,
    title: '归并排序',
    category: '其他经典',
    difficulty: 2,
    description: '实现归并排序算法对数组进行升序排序。归并排序是稳定的分治排序算法，时间复杂度恒为 O(n log n)。',
    analysis: '将数组不断二分直到只剩一个元素，再两两合并有序子数组。合并时双指针比较取较小者，保证整体有序。',
    codeArkts: `function mergeSort(nums: number[]): number[] {
  if (nums.length <= 1) {
    return nums;
  }
  const mid = Math.floor(nums.length / 2);
  const left = mergeSort(nums.slice(0, mid));
  const right = mergeSort(nums.slice(mid));
  return mergeSorted(left, right);
}

function mergeSorted(a: number[], b: number[]): number[] {
  const res: number[] = [];
  let i = 0;
  let j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] <= b[j]) {
      res.push(a[i++]);
    } else {
      res.push(b[j++]);
    }
  }
  while (i < a.length) {
    res.push(a[i++]);
  }
  while (j < b.length) {
    res.push(b[j++]);
  }
  return res;
}`,
    codePython: `def merge_sort(nums):
    if len(nums) <= 1:
        return nums
    mid = len(nums) // 2
    left, right = merge_sort(nums[:mid]), merge_sort(nums[mid:])
    res, i, j = [], 0, 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            res.append(left[i]); i += 1
        else:
            res.append(right[j]); j += 1
    res.extend(left[i:])
    res.extend(right[j:])
    return res`,
    tags: '排序,分治,归并排序'
  },
  {
    id: 76,
    title: '用栈实现队列',
    category: '其他经典',
    difficulty: 1,
    description: '请你仅使用两个栈实现先入先出队列。队列应当支持一般队列支持的所有操作：push、pop、peek、empty。',
    analysis: '使用输入栈和输出栈：入队压入输入栈；出队或取队首时若输出栈为空，就把输入栈全部倒入输出栈，再操作输出栈顶。摊还复杂度 O(1)。',
    codeArkts: `class MyQueue {
  private inbox: number[] = [];
  private outbox: number[] = [];

  push(x: number): void {
    this.inbox.push(x);
  }

  pop(): number {
    this.transfer();
    return this.outbox.pop() as number;
  }

  peek(): number {
    this.transfer();
    return this.outbox[this.outbox.length - 1];
  }

  empty(): boolean {
    return this.inbox.length === 0 && this.outbox.length === 0;
  }

  private transfer(): void {
    if (this.outbox.length === 0) {
      while (this.inbox.length > 0) {
        this.outbox.push(this.inbox.pop() as number);
      }
    }
  }
}`,
    codePython: `class MyQueue:
    def __init__(self):
        self.inbox = []
        self.outbox = []

    def push(self, x):
        self.inbox.append(x)

    def pop(self):
        self._transfer()
        return self.outbox.pop()

    def peek(self):
        self._transfer()
        return self.outbox[-1]

    def empty(self):
        return not self.inbox and not self.outbox

    def _transfer(self):
        if not self.outbox:
            while self.inbox:
                self.outbox.append(self.inbox.pop())`,
    tags: '栈,队列,设计'
  },
  {
    id: 77,
    title: '每日温度',
    category: '其他经典',
    difficulty: 2,
    description: '给定一个整数数组 temperatures，表示每天的温度。返回一个数组 answer，其中 answer[i] 是指对于第 i 天，下一个更高温度出现在几天后。如果之后都不更高，则该位置为 0。',
    analysis: '单调递减栈存放下标。遍历每天温度，当当前温度高于栈顶下标对应温度时，弹出并记录差值；最后把当前下标入栈。',
    codeArkts: `function dailyTemperatures(temperatures: number[]): number[] {
  const n = temperatures.length;
  const res: number[] = new Array<number>(n).fill(0);
  const stack: number[] = [];
  for (let i = 0; i < n; i++) {
    while (stack.length > 0 && temperatures[i] > temperatures[stack[stack.length - 1]]) {
      const idx = stack.pop() as number;
      res[idx] = i - idx;
    }
    stack.push(i);
  }
  return res;
}`,
    codePython: `def daily_temperatures(temperatures):
    res = [0] * len(temperatures)
    stack = []
    for i, temp in enumerate(temperatures):
        while stack and temp > temperatures[stack[-1]]:
            idx = stack.pop()
            res[idx] = i - idx
        stack.append(i)
    return res`,
    tags: '单调栈,数组'
  },
  {
    id: 78,
    title: '前 K 个高频元素',
    category: '其他经典',
    difficulty: 2,
    description: '给你一个整数数组 nums 和一个整数 k，请你返回其中出现频率前 k 高的元素。可以按任意顺序返回答案。',
    analysis: '先用哈希表统计频率，再对元素按频率排序取前 k 个。更优的是维护大小为 k 的小顶堆，时间复杂度 O(n log k)。',
    codeArkts: `function topKFrequent(nums: number[], k: number): number[] {
  const freq: Map<number, number> = new Map();
  for (let i = 0; i < nums.length; i++) {
    freq.set(nums[i], (freq.get(nums[i]) ?? 0) + 1);
  }
  const arr: number[] = [];
  freq.forEach((value: number, key: number) => {
    arr.push(key);
  });
  arr.sort((a, b) => (freq.get(b) as number) - (freq.get(a) as number));
  return arr.slice(0, k);
}`,
    codePython: `def top_k_frequent(nums, k):
    from collections import Counter
    freq = Counter(nums)
    return [num for num, _ in freq.most_common(k)]`,
    tags: '哈希表,堆,排序'
  },
  {
    id: 79,
    title: '岛屿数量',
    category: '其他经典',
    difficulty: 2,
    description: '给你一个由字符 1（陆地）和 0（水）组成的二维网格 grid。岛屿由水平或垂直方向相邻的陆地连接而成。请你计算网格中岛屿的数量。',
    analysis: '遍历网格，遇到陆地就将岛屿计数加一，并通过 DFS/BFS 把与之相连的所有陆地标记为已访问（改为水），避免重复计数。',
    codeArkts: `function numIslands(grid: string[][]): number {
  if (grid.length === 0) {
    return 0;
  }
  const m = grid.length;
  const n = grid[0].length;
  const dfs = (i: number, j: number): void => {
    if (i < 0 || i >= m || j < 0 || j >= n || grid[i][j] !== '1') {
      return;
    }
    grid[i][j] = '0';
    dfs(i + 1, j);
    dfs(i - 1, j);
    dfs(i, j + 1);
    dfs(i, j - 1);
  };
  let count = 0;
  for (let i = 0; i < m; i++) {
    for (let j = 0; j < n; j++) {
      if (grid[i][j] === '1') {
        count++;
        dfs(i, j);
      }
    }
  }
  return count;
}`,
    codePython: `def num_islands(grid):
    if not grid:
        return 0
    m, n = len(grid), len(grid[0])
    def dfs(i, j):
        if i < 0 or i >= m or j < 0 or j >= n or grid[i][j] != '1':
            return
        grid[i][j] = '0'
        dfs(i + 1, j); dfs(i - 1, j); dfs(i, j + 1); dfs(i, j - 1)
    count = 0
    for i in range(m):
        for j in range(n):
            if grid[i][j] == '1':
                count += 1
                dfs(i, j)
    return count`,
    tags: '深度优先搜索,广度优先搜索,图'
  },
  {
    id: 80,
    title: '全排列',
    category: '其他经典',
    difficulty: 2,
    description: '给定一个不含重复数字的数组 nums，返回其所有可能的全排列。你可以按任意顺序返回答案。',
    analysis: '回溯法：用一个 used 数组标记已选元素，递归地把未选元素加入路径，路径长度等于数组长度时收集结果，回溯时撤销选择。',
    codeArkts: `function permute(nums: number[]): number[][] {
  const res: number[][] = [];
  const path: number[] = [];
  const used: boolean[] = new Array<boolean>(nums.length).fill(false);
  const backtrack = (): void => {
    if (path.length === nums.length) {
      res.push(path.slice());
      return;
    }
    for (let i = 0; i < nums.length; i++) {
      if (used[i]) {
        continue;
      }
      used[i] = true;
      path.push(nums[i]);
      backtrack();
      path.pop();
      used[i] = false;
    }
  };
  backtrack();
  return res;
}`,
    codePython: `def permute(nums):
    res, path, used = [], [], [False] * len(nums)
    def backtrack():
        if len(path) == len(nums):
            res.append(path[:])
            return
        for i in range(len(nums)):
            if used[i]:
                continue
            used[i] = True
            path.append(nums[i])
            backtrack()
            path.pop()
            used[i] = False
    backtrack()
    return res`,
    tags: '回溯,数组'
  },
  {
    id: 81,
    title: '子集',
    category: '其他经典',
    difficulty: 2,
    description: '给你一个整数数组 nums，数组中的元素互不相同。返回该数组所有可能的子集（幂集），解集不能包含重复的子集。',
    analysis: '回溯法：从 start 开始枚举后续元素加入路径，每进入一次递归就把当前路径作为一个子集收集，从而覆盖所有组合。',
    codeArkts: `function subsets(nums: number[]): number[][] {
  const res: number[][] = [];
  const path: number[] = [];
  const backtrack = (start: number): void => {
    res.push(path.slice());
    for (let i = start; i < nums.length; i++) {
      path.push(nums[i]);
      backtrack(i + 1);
      path.pop();
    }
  };
  backtrack(0);
  return res;
}`,
    codePython: `def subsets(nums):
    res, path = [], []
    def backtrack(start):
        res.append(path[:])
        for i in range(start, len(nums)):
            path.append(nums[i])
            backtrack(i + 1)
            path.pop()
    backtrack(0)
    return res`,
    tags: '回溯,数组'
  },
  {
    id: 82,
    title: '电话号码的字母组合',
    category: '其他经典',
    difficulty: 2,
    description: '给定一个仅包含数字 2-9 的字符串，返回所有它能表示的字母组合。数字到字母的映射与电话按键相同（2->abc，3->def ... 9->wxyz）。',
    analysis: '回溯法：逐位处理数字，对当前数字对应的每个字母分别选择并递归下一位，处理完所有数字即得到一个组合。',
    codeArkts: `function letterCombinations(digits: string): string[] {
  const res: string[] = [];
  if (digits.length === 0) {
    return res;
  }
  const map: string[] = ['', '', 'abc', 'def', 'ghi', 'jkl', 'mno', 'pqrs', 'tuv', 'wxyz'];
  const backtrack = (index: number, path: string): void => {
    if (index === digits.length) {
      res.push(path);
      return;
    }
    const letters = map[digits.charCodeAt(index) - 48];
    for (let i = 0; i < letters.length; i++) {
      backtrack(index + 1, path + letters.charAt(i));
    }
  };
  backtrack(0, '');
  return res;
}`,
    codePython: `def letter_combinations(digits):
    if not digits:
        return []
    mapping = {'2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
               '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'}
    res = []
    def backtrack(i, path):
        if i == len(digits):
            res.append(path)
            return
        for ch in mapping[digits[i]]:
            backtrack(i + 1, path + ch)
    backtrack(0, '')
    return res`,
    tags: '回溯,字符串,哈希表'
  },
  {
    id: 83,
    title: '括号生成',
    category: '其他经典',
    difficulty: 2,
    description: '数字 n 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且有效的括号组合。',
    analysis: '回溯时维护已使用的左括号数与右括号数：左括号数量小于 n 时可继续加左括号，右括号数量小于左括号数量时可加右括号，长度达到 2n 即收集。',
    codeArkts: `function generateParenthesis(n: number): string[] {
  const res: string[] = [];
  const backtrack = (open: number, close: number, path: string): void => {
    if (path.length === n * 2) {
      res.push(path);
      return;
    }
    if (open < n) {
      backtrack(open + 1, close, path + '(');
    }
    if (close < open) {
      backtrack(open, close + 1, path + ')');
    }
  };
  backtrack(0, 0, '');
  return res;
}`,
    codePython: `def generate_parenthesis(n):
    res = []
    def backtrack(open_cnt, close_cnt, path):
        if len(path) == n * 2:
            res.append(path)
            return
        if open_cnt < n:
            backtrack(open_cnt + 1, close_cnt, path + '(')
        if close_cnt < open_cnt:
            backtrack(open_cnt, close_cnt + 1, path + ')')
    backtrack(0, 0, '')
    return res`,
    tags: '回溯,字符串'
  },
  {
    id: 84,
    title: 'N 皇后',
    category: '其他经典',
    difficulty: 3,
    description: '按照国际象棋的规则，皇后可以攻击与之处在同一行、同一列或同一斜线上的棋子。n 皇后问题研究的是如何将 n 个皇后放置在 n×n 的棋盘上，并且使皇后彼此之间不能相互攻击。返回所有不同的解法。',
    analysis: '逐行放置皇后，用集合记录已占用的列、主对角线（row-col）和副对角线（row+col）。若三个集合都不冲突则放置并递归下一行，回溯时撤销。',
    codeArkts: `function solveNQueens(n: number): string[][] {
  const res: string[][] = [];
  const cols: Set<number> = new Set();
  const diag1: Set<number> = new Set();
  const diag2: Set<number> = new Set();
  const board: string[][] = [];
  for (let i = 0; i < n; i++) {
    board.push(new Array<string>(n).fill('.'));
  }
  const backtrack = (row: number): void => {
    if (row === n) {
      const snapshot: string[] = [];
      for (let i = 0; i < n; i++) {
        snapshot.push(board[i].join(''));
      }
      res.push(snapshot);
      return;
    }
    for (let col = 0; col < n; col++) {
      if (cols.has(col) || diag1.has(row - col) || diag2.has(row + col)) {
        continue;
      }
      cols.add(col);
      diag1.add(row - col);
      diag2.add(row + col);
      board[row][col] = 'Q';
      backtrack(row + 1);
      board[row][col] = '.';
      cols.delete(col);
      diag1.delete(row - col);
      diag2.delete(row + col);
    }
  };
  backtrack(0);
  return res;
}`,
    codePython: `def solve_n_queens(n):
    res = []
    cols, diag1, diag2 = set(), set(), set()
    board = [['.'] * n for _ in range(n)]
    def backtrack(row):
        if row == n:
            res.append([''.join(r) for r in board])
            return
        for col in range(n):
            if col in cols or (row - col) in diag1 or (row + col) in diag2:
                continue
            cols.add(col); diag1.add(row - col); diag2.add(row + col)
            board[row][col] = 'Q'
            backtrack(row + 1)
            board[row][col] = '.'
            cols.discard(col); diag1.discard(row - col); diag2.discard(row + col)
    backtrack(0)
    return res`,
    tags: '回溯,剪枝'
  },
];
