### 力扣之437. 路径总和 III

```java
package com.tangdi.leetcode.backtrack.prefixsum;

import java.util.HashMap;
import java.util.Map;

/**
 * @program: algorithm
 * @description: 437. 路径总和 III
 * 给定一个二叉树的根节点 root ，和一个整数 targetSum ，求该二叉树里节点值之和等于 targetSum 的 路径 的数目。
 * 路径 不需要从根节点开始，也不需要在叶子节点结束，但是路径方向必须是向下的（只能从父节点到子节点）。
 * @author: Wangwentao
 * @create: 2021-09-28 17:00
 * 深度优先遍历-回溯算法 + 前缀和
 * 递归终止条件：判断是否到了叶子节点
 * 思路：
 *    1. 前缀和：当前路径和-当前路径的所有前缀和 = 目标值
 *    2. 深度优先遍历dfs，递归遍历到叶子节点，然后回溯，前缀和的map中减去当前路径
 **/
public class BinaryTreeRouteSum437 {


    public static void main(String[] args) {
        int targetSum = 1;
//        TreeNode root = init();
        TreeNode root = init2();

        Map<Integer,Integer> map = new HashMap<Integer,Integer>();
        map.put(0,1);

        if(root == null){
            System.out.println(0);
        }

        Integer i = dfs(root,targetSum,map,0);
        System.out.println(i);
    }

    /**
     *       10
     *      /  \
     *     5   -3
     *    / \    \
     *   3   2    11
     *  / \   \
     * 3  -2   1
     * @return
     */
    public static Integer dfs(TreeNode node, int targetSum, Map<Integer,Integer> map, Integer curr){
        curr += node.val;

        int res = 0;
        res += map.getOrDefault(curr-targetSum,0);


        map.put(curr,map.getOrDefault(curr,0) + 1);

        TreeNode left =  node.left;
        TreeNode right =  node.right;

        if(left == null && right == null){
            // 删除当前路径和
            map.put(curr,map.getOrDefault(curr,0) - 1);
            return res;
        }

        if(left != null){
            res += dfs(left,targetSum,map,curr);
        }

        if(right != null){
            res += dfs(right,targetSum,map,curr);
        }

        // 删除当前路径和
        map.put(curr,map.getOrDefault(curr,0) - 1);
        return res;
    }


    /**
     *       10
     *      /  \
     *     5   -3
     *    / \    \
     *   3   2    11
     *  / \   \
     * 3  -2   1
     * @return
     */
    static TreeNode init() {
        TreeNode root = new TreeNode(10);
        TreeNode l1 = new TreeNode(5);
        TreeNode r1 = new TreeNode(-3);
        TreeNode l21 = new TreeNode(3);
        TreeNode r21 = new TreeNode(2);
        TreeNode r22 = new TreeNode(11);
        TreeNode l31 = new TreeNode(3);
        TreeNode r31 = new TreeNode(-2);
        TreeNode r32 = new TreeNode(1);

        root.left = l1;
        root.right = r1;
        l1.left = l21;
        l1.right = r21;
        l21.left = l31;
        l21.right = r31;
        r21.right = r32;
        r1.right = r22;
        return root;
    }

    /**
     *    0
     *   / \
     *  1   1
     * @return
     */
    static TreeNode init2() {
        TreeNode root = new TreeNode(0);
        TreeNode l1 = new TreeNode(1);
        TreeNode r1 = new TreeNode(1);
        root.left = l1;
        root.right = r1;

        return root;
    }

    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        TreeNode() {
        }

        TreeNode(int val) {
            this.val = val;
        }

        TreeNode(int val, TreeNode left, TreeNode right) {
            this.val = val;
            this.left = left;
            this.right = right;
        }
    }
}
```

