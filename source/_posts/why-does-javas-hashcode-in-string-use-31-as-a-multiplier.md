---

title: Why does javas hashcode in string use 31 as a multiplier
date: 2020-04-01 10:06:45
tags:
-----------------------------------------------------------------------------------------------

The value 31 was chosen because it is an odd prime. If it were even and the multiplication overflowed,
information would be lost, as multiplication by 2 is equivalent to shifting. The advantage of using a
prime is less clear, but it is traditional. A nice property of 31 is that the multiplication can be
replaced by a shift and a subtraction for better performance: 31 * i == (i << 5) - i. Modern VMs do
this sort of optimization automatically.

> 简单翻译一下：

选择数字 31 是因为它是一个奇质数，如果选择一个偶数会在乘法运算中产生溢出，导致数值信息丢失，因为乘二相当于移位运算。
选择质数的优势并不是特别的明显，但这是一个传统。同时，数字 31 有一个很好的特性，即乘法运算可以被移位和减法运算取代，
来获取更好的性能：31 * i == (i << 5) - i，现代的 Java 虚拟机可以自动的完成这个优化。

As Goodrich and Tamassia point out, If you take over 50,000 English words (formed as the union of the
word lists provided in two variants of Unix), using the constants 31, 33, 37, 39, and 41 will produce less than 7 collisions in each case. Knowing this, it should come as no surprise that many Java implementations choose one of these constants.

> 这段话也翻译一下：

正如 Goodrich 和 Tamassia 指出的那样，如果你对超过 50,000 个英文单词（由两个不同版本的 Unix 字典合并而成）进行
hash code 运算，并使用常数 31, 33, 37, 39 和 41 作为乘子，每个常数算出的哈希值冲突数都小于 7 个，所以在上面几个常
数中，常数 31 被 Java 实现所选用也就不足为奇了。
