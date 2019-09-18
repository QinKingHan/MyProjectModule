import UIKit
var str = "Hello, playground"

/*
 VIA： https://www.cnblogs.com/strengthen/p/10299618.html swift 博客
 
*/


// 给一个数组，要求写一个函数，交换数组中的两个元素
func swaps<T>(_ nums: inout [T], _ p: Int, _ q: Int) {
//    let temp = nums[p]
//    nums[p] = nums[q]
//    nums[q] = temp
    (nums[p], nums[q]) = (nums[q], nums[p])

}
var array = [1,1,2]

swaps(&array, 0, 1)

//print(array)


var dic = NSMutableDictionary()
var n = ""
dic[n] = ""
//let isMark = dic.contains(where: {$0["name"] == "Mark"})



// ----------------------- -------------------

// 1. 两数之和
func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    
    var dic = [Int : Int]()
    
    for (idx,item) in nums.enumerated() {
        if let lastIdx = dic[target - item] {
            return [lastIdx,idx]
        }else{
            dic[item] = idx
        }
    }
    
    return [0,0]
}

twoSum([2, 7, 11, 15], 17)

//136. 只出现一次的数字
func singleNumber(_ nums: [Int]) -> Int {
    
    var result = 0
    
    for num in nums {
        result = result ^ num
    }
    
    return result
}

singleNumber([0,2,2,1,1,3,3])


//206. 反转链表

public class ListNode {
      public var val: Int
      public var next: ListNode?
      public init(_ val: Int) {
          self.val = val
          self.next = nil
      }
  }
func reverseList(_ head: ListNode?) -> ListNode? {
    
    if head == nil || head?.next == nil{
        return head
    }else{
        // 递归 获取最后的节点
        print("++++++++++")
        let newHead = reverseList(head?.next)
        print("-----------")
        
         // 依次反转每个节点 <3个指针中 head?.next 为current 指针作为 反转中间轴 >
        head?.next?.next = head
        head?.next = nil
        
        return newHead
    }
}


// 442. 数组中重复的数据
func findDuplicates(_ nums: [Int]) -> [Int] {
    guard nums.count > 1 else {
        return []
    }
    var set = Set<Int>()
    var arr = [Int]()
 
    
    for i in nums {
        if set.contains(i) {
            arr.append(i)
        } else {
            set.insert(i)
        }
    }
    return arr
}

findDuplicates([4,3,2,7,8,2,3,1])


// 658. 找到 K 个最接近的元素
/*
 给定一个排序好的数组，两个整数 k 和 x，从数组中找到最靠近 x（两数之差最小）的 k 个数。返回的结果必须要是按升序排好的。如果有两个数与 x 的差值一样，优先选择数值较小的那个数。
 二分法
 */
func findClosestElements(_ arr: [Int], _ k: Int, _ x: Int) -> [Int] {
    
    var left: Int = 0
    var right: Int = arr.count - k
    
    while(left < right){
        
        let mid: Int = left + (right - left) / 2
        
        if x - arr[mid] > arr[mid + k] - x{
            
            left = mid + 1
        }else{
            
            right = mid
        }
        
    }
    
    return Array(arr[left..<(left + k)])
}

let chapter = findClosestElements([1,2,3,4,5], 1, 3)



// 704. 二分查找
func search(_ nums: [Int], _ target: Int) -> Int {
    return binarySearch(nums: nums, target: target, left: 0, right: nums.count - 1)
}

func binarySearch(nums: [Int], target :Int, left :Int, right: Int) -> Int{
    
    guard left <= right else{
        return -1
    }
    
    let mid = (right - left) / 2 + left
    
    if nums[mid] == target{
        return mid
    }else if nums[mid] < target{
        return binarySearch(nums: nums, target: target, left: mid + 1, right: right)
    }else{
        return binarySearch(nums: nums, target: target, left: left, right: mid - 1)
    }
}

search( [-1,0,3,5,9,12], 12)

// ----------------------------------------- 字符串  -----------------------

//3. 无重复字符的最长子串 (滑动窗口)

func lengthOfLongestSubstringWD(_ s: String) -> Int {
    var right = 1
    var left = 0
    var i = 0
    var result = 0
    
    if s.count > 0 {
        result = right - left
        let chars = Array(s.utf8)
        //Interate in a incremental window
        while right < chars.count {
            i = left
            while i < right {
                //Check if a duplicate is found
                if chars[i] == chars[right] {
                    left = i + 1
                    break
                }
                i = i + 1
            }
            result = max(result,right-left+1)
            right = right + 1
        }
    }
    return result
}

lengthOfLongestSubstringWD("bbbbbacd")

// 392.判断子序列 双下标  判断 s 是否为 t 的子序列。
/*
 本文主要运用的是双指针的思想，指针si指向s字符串的首部，指针ti指向t字符串的首部。
 */
func isSubsequence(_ s: String, _ t: String) -> Bool {
    // 因为子序列没有改变顺序，不存在回溯一说
    // 1 双指针
    guard s != "" else {
        return true
    }
    
    var i = 0, j = 0
    
    let s = Array(s), t = Array(t)  // 字符串转数组
    
    while (i < s.count && j < t.count) {
        if (s[i] == t[j]) {
            i+=1
        }
        j+=1
    }
    return i == s.count
}




print(isSubsequence("acd","abcd"))


// ------------------------------------------- 动态规划 ------------------------------

// 70. 爬楼梯 备忘录 递归
func climbStairs(_ n: Int) -> Int {
    var dic = [Int:Int]()
    func rec(_ n: Int) -> Int{
        if n == 1{
            dic[n] = 1
            return 1
        }
        if n == 2{
            dic[n] = 2
            return 2
        }
        if dic[n] != nil{
            return dic[n]!
        }else{
            dic[n] = rec(n-1) + rec(n-2)
            return rec(n-1) + rec(n-2)
        }
    }
    return rec(n)
}



// 动态规划求解
func DyclimbStairs(_ n: Int) -> Int {
    
    var recArray = [1,1,2]
    
    if n >= 3{
        for j in 3 ..< n+1{
            print(recArray)
            recArray.append(recArray[j-1] + recArray[j-2])
        }
    }
    
    return recArray[n]
}


var m = 4
print(array)
for i in 3 ..< m+1 {
    array.append(array[i-1] + array[i-2])
}
print(array)





// 121. 买卖股票的最佳时机
func dynamicMaxProfit(_ prices:[Int]) -> Int{

    if prices.count <= 1 {
        return 0
    }
    
    // 最优子结构
    // -- 只要考虑当天买和之前买哪个收益更高，当天卖和之前卖哪个收益更高。
    //边界
    var buy = -prices[0], sell = 0
    
    for idx in 1 ..< prices.count{
        //状态转移方程
        buy = max(buy,-prices[idx]) // 一直取买入最低的价格
        sell = max(sell,prices[idx]+buy) //第i天卖出,或者上一个状态比较,取最大值.
    }
    return sell
}

// 遍历
func maxProfit(_ prices:[Int]) -> Int{
    
    var maxprice = 0
    var minpirce = Int.max
    
    for (idx,_) in prices.enumerated() {
        
        if minpirce > prices[idx] {
            
            minpirce = prices[idx]
        }else if(maxprice < prices[idx] - minpirce){
            
            maxprice = prices[idx] - maxprice
        }
    }
    
    return maxprice
}





// 122. 买卖股票的最佳时机 II
// 动态
func dynamicMaxProfitTwo(_ prices:[Int]) -> Int{
    
    if prices.count <= 1 {
        return 0
    }
    
    var buy = -prices[0], sell = 0
    for idx in 1 ..< prices.count {
        sell = max(sell,prices[idx]+buy)
        buy = max(buy,sell - prices[idx])
    }

    
    return sell
}


// 方法二：峰谷法


print(dynamicMaxProfit([1,2,1,5,8]))






// 53. 最大子序和  动态
func maxSubArray(_ nums: [Int]) -> Int {
    
    var result = Dictionary<Int, Int>()
    
    for i in 0..<nums.count {
        result[i] = nums[i]
    }
    
    var maxNum = nums[0]
    
    for i in 1 ..< nums.count {
        
        if result[i-1]! > 0 {
            result[i] = nums[i] + result[i-1]! // 最小子结构
        }
        
        if result[i]! > maxNum {
            maxNum = result[i]!
        }
    }
    return maxNum
}

maxSubArray([1,2,4,2])

func maxDSubArray(_ nums: [Int]) -> Int {
    
    var curMaxSub = nums[0]
    var sum : Int = 0
    
    for num in nums {
        if sum > 0{
            //否则累加
            sum += num
        }else{
            //如果小于0，则抛弃之前的子序列，从新的开始
            sum = num
        }
        
        //将当前子序列和现有的子序列最大进行比较
        if sum > curMaxSub {
            curMaxSub = sum
        }
    }
    
    return curMaxSub
    
}
maxDSubArray([-2,1,-3,4,-1,2,1,-5,4])




//LeetCode 198. 打家劫舍
/*
 他如果选择偷这一家，他就一定没有偷上一家，所以，他所能获得的最大金钱就是在当前家能获得的金钱加上在上上家拥有的钱数的和；
 他如果不选择这一家，那么他当前获取的最大金钱就是上一家拥有的钱； 当然，他会选择以上两种方案的最大值。<自顶向下>
 

 
 解题思路
 1、首先想一想如果是暴力如何做？
 假设从最后一家店铺开始抢，那么只会遇到2种情况，即：抢这家店和下下家店，或者不抢这家店。所以我们得到
 
 对于 n = 3，有两个选项:
 1 - 抢第三个房子，将数额与第一个房子相加。
 2 - 不抢第三个房子，保持现有最大数额。


 递归的公式: dp[i] = max(dp[i - 2] + nums[i], dp[i - 1])
dp[i] 代表到第n个房屋为止获得的最大金额
 
 2、上面的暴力算法虽然能够得到正确的结果，但是显然递归的效率是很低的，如果有n家店铺，每家店铺有2种可能，那么时间复杂度就是2的n次方。那么如何优化呢？
 
 我们分析一下：
 如果我们开始抢的是第n-1家店，那么后面可以是（n-3,n-4,n-5,n-6....）;
 如果我们开始抢的是第n-2家店，那么后面可以是（n-4,n-5,n-6,....）;
 那么这两种情况显然n-3之后的n-4,n-5,n-6,....都重复计算了。显然这里有非常大的优化空间。通常我们使用空间来换时间，即用一个数组记录每次计算的结果，这样每次情况只需要计算一次，再次遇到只需直接返回结果即可，大大优化了时间。
 
 总结
 这道题就是动态规划，其本质是在递归的思想上进行优化。
 原问题（N）-->子问题（N-1）-->原问题（N）
 
 最优子结构
 1、子问题最优决策可导出原问题的最优决策。
 2、无后效性
 
 重叠子问题
 1、去冗余
 2、空间换时间
*/

func rob(_ nums: [Int]) -> Int {
    var dp = [Int]()
    
    for i in 0 ... nums.count {
        dp.append(i)
    }
    
    print(dp)
    
    for i in 0 ..< dp.count {
        if i == 0 {
            dp[0] = 0
            continue
        }
        if i == 1 {
            dp[1] = nums[0]
            continue
        }
        
        dp[i] = max(dp[i - 2] + nums[i - 1], dp[i - 1])
    }
    
    return dp[nums.count]
}

func DProb(_ nums: [Int]) -> Int {
        
    let n = nums.count
    if n == 0 { return 0 }
    if n == 1 { return nums[0] }
    
    
    
    var dp = [nums[0], max(nums[0], nums[1])] // 递推公式
    
    for i in 2..<n {
        dp.append(max(dp[i-1], dp[i-2]+nums[i]))
    }
    return dp.last!
}

rob([2,7,9,3,1])

//213. 打家劫舍 II https://zhuanlan.zhihu.com/p/56969640


// 256. 粉刷房子


