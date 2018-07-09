---
title: JPQL查询语句中表达式的使用( JPA Query Expressions )
date: 2018-07-02 08:30:00
tag: JPA
---

查询表达式是构建JPQL和条件查询的基础。

### 三、JPQL和Criteria Queries中的Numbers

数字值可能以多种形式出现在JPQL查询中：

   - 作为数字 - 例如`123`,`-12.5`。
   - 作为参数 - 将数值指定为参数时。
   - 作为路径表达式 - 指向到持久化数字字段。
   - 作为汇总表达式 - 例如`COUNT`。
   - 作为集合函数 - 当返回值为数字时，例如`INDEX`，`SIZE`。
   - 作为字符串函数 - 当返回值为数字时，例如`LOCATE`，`LENGTH`。
   - 作为使用运算符和函数将简单数值组合成更复杂表达式的复合算术表达式。
   
本页面涵盖以下主题：

   - 算术运算符
   - ABS功能
   - MOD功能
   - SQRT功能
   - 条件查询算术表达式
   
#### 算术运算符


JPA支持以下算术运算符：

- 2个一元运算符：   +（加号）和-（减号）。
- 4个二元运算符：   +（加法），-（减法），*（乘法）和/（除法）。

ObjectDB还支持Java和JDO 支持的%（模）和~（按位互补）运算符。JPA遵循Java的向上转换原则。例如，对int值和double值进行二进制算术运算的结果类型是double。

#### ABS功能

ABS函数从指定参数中删除负号并返回绝对值，绝对值始终为正数或零。

例如：

- ABS（-5）计算为5
- ABS（10.7）计算为10.7

ABS函数将任何类型的数值作为参数，并返回相同类型的值。

#### MOD功能

MOD函数求一个数字除以另一个数字的余数，类似于Java中的模运算符`%`（ObjectDB作为扩展还支持该运算符）。

例如：

- 将MOD（11,3）值为2（3进入11三次，其余为2）
- MOD（8，4）值为0（4进入8两次，余数为0）

MOD函数接受任意类型的两个整数值并返回一个整数值。如果两个操作数是完全相同的类型，则结果类型相同。如果两个操作数具有不同的类型，则使用数字向上转换与Java中的二进制算术运算（例如，对于int和long操作数，MOD函数返回一个长整型值）。

#### SQRT功能

SQRT函数返回指定参数的平方根。

例如：

- SQRT（9）评估为3
- SQRT（2）评估为1.414213562373095

SQRT函数将任何类型的数值作为参数，并返回一个double值。

#### 条件查询算术表达式

JPQL算术运算符和函数也可用作JPA条件查询表达式。CriteriaBuilder接口提供工厂方法用于构建这些表达式。

##### 二元运算符

创建二进制算术运算符需要两个操作数。至少一个操作数必须是条件数字表达式。另一个操作数可以是另一个数字表达式或简单的Java数字对象：

		// Create path and parameter expressions:
		Expression<Integer> path = country.get("population");
		Expression<Integer> param = cb.parameter(Integer.class);
		
		// 求和 Addition (+)
		Expression<Integer> sum1 = cb.sum(path, param); // expression + expression
		Expression<Integer> sum2 = cb.sum(path, 1000); // expression + number
		Expression<Integer> sum3 = cb.sum(1000, path); // number + expression
		
		// 减法 Subtraction (-)
		Expression<Integer> diff1 = cb.diff(path, param); // expression - expression
		Expression<Integer> diff2 = cb.diff(path, 1000); // expression - number
		Expression<Integer> diff3 = cb.diff(1000, path); // number - expression
		
		// 乘积 Multiplication (*)
		Expression<Integer> prod1 = cb.prod(path, param); // expression * expression
		Expression<Integer> prod2 = cb.prod(path, 1000); // expression * number
		Expression<Integer> prod3 = cb.prod(1000, path); // number * expression
		
		// 求商 Division (/)
		Expression<Integer> quot1 = cb.quot(path, param); // expression / expression
		Expression<Integer> quot2 = cb.quot(path, 1000); // expression / number
		Expression<Integer> quot3 = cb.quot(1000, path); // number / expression
		
		// 求模 Modulo (%)
		Expression<Integer> mod1 = cb.mod(path, param); // expression % expression
		Expression<Integer> mod2 = cb.mod(path, 1000); // expression % number
		Expression<Integer> mod3 = cb.mod(1000, path); // number % expression
	
以上示例仅演示整数表达式，表达式支持所有数字类型（byte，short，int，long，float，double，BigInteger，BigDecimal）。

##### 一元运算符

创建一元减号（-）运算符以及ABS和SQRT函数需要一个操作数，该操作数必须是数字表达式：

		 Expression<Integer> abs = cb.abs(param); // ABS(expression)
	  	 Expression<Integer> neg = cb.neg(path); // -expression
	  	 Expression<Integer> sqrt = cb.sqrt(cb.literal(100)); // SQRT(expression)

如上所示，通过使用`literal()`方法，始终可以将数字转换为数字表达式。