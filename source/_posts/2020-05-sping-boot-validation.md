---
title: Spring Boot 验证框架
date: 2020-05-12 07:44:23
tags:
---

使用Spring Boot 验证框架简化业务代码。

#### 概念

Spring Boot 的验证框架，
一如既往没有重复造轮子，
集成的是Bean Validation 和Hibernate Validator 规范，
Bean Validation 2.0已经集成到 Jakarta EE中，
也就是以前的 JAVA EE 企业版，
Bean Validation 2.0 核心思想是，
一次约束，随处验证，
有了验证框架 就不用在控制层、服务层、数据层，
代码中重复验证Bean了，
那我们开始吧。

新建测试项目，

选择你喜欢的JDK版本，

使用Spring Initializr Spring 初始化器，
如果没有科学上网可以使用国内源，
https://start.aliyun.com/

选择Developer Tools 中的 Spring Boot DevTools & Lombok，
选择Web中的Spring Web，
选择Ops中的 Spring Boot Actuator 

选择I/O中的Validation 也是今天的主角。

下一步，给项目起名字，
完成。

等待依赖加载完成，
可以使用国内源加速。

新建模型类Bar，
添加普通字段，
使用非空验证，

这里解释一下，
foobar是计算机程序领域里的术语，
并无实际用途和参考意义。
就像我们经常说的张三、李四，
它们的确切身份并不重要，仅用于演示一个概念。
这个词最早是麻省理工学院的
一个黑客学生组织使用在计算机领域，
Foobar表示的是高低电平，是一种控制开关，
后来美国DEC公司把Foobar写到系统手册里就被慢慢传开了，
Intel也开始把foo写进文档，
Google用foobar.withgoogle.com 的网站招人，
后来DEC被康柏收购，康柏又被惠普收购，
说到惠普应该都认识了。
怎么样，涨知识吧，关注一波吧！
回到正题。

配置使用的提示语言。

	spring.mvc.locale=zh

标记参数类开启级联验证。

	@Valid 

增加参数：绑定验证结果接口，
处理验证结果。
开始测试！
全部校验成功！

Bean Validation 2.0默认支持22种约束注解，
主要包括非空、断言、数值范围、正负范围，
日期范围和邮件地址、及强大的正则表达式。
自定义注解也非常简单，
一个描述验证消息的注解类 + 约束验证器即可，
更多深入细节可以clone视频下方的。
demo示例，
包含自定义注解，
统一的参数异常处理，
服务层及数据层异常验证方法。


>参考链接: https://beanvalidation.org/2.0/spec/

    @AssertFalse = 只能为false
    @AssertTrue = 只能为true
    @DecimalMax = 必须小于或等于{value}
    @DecimalMin = 必须大于或等于{value}
    @Digits = 数字的值超出了允许范围(只允许在{integer}位整数和{fraction}位小数范围内)
    @Email = 不是一个合法的电子邮件地址
    @Future = 需要是一个将来的时间
    @FutureOrPresent = 需要是一个将来或现在的时间
    @Max = 最大不能超过{value}
    @Min = 最小不能小于{value}
    @Negative = 必须是负数
    @NegativeOrZero = 必须是负数或零
    @NotBlank = 不能为空
    @NotEmpty = 不能为空
    @NotNull = 不能为null
    @Null = 必须为null
    @Past = 需要是一个过去的时间
    @PastOrPresent = 需要是一个过去或现在的时间
    @Pattern = 需要匹配正则表达式"{regexp}"
    @Positive = 必须是正数
    @PositiveOrZero = 必须是正数或零
    @Size = 个数必须在{min}和{max}之间
    
    @CreditCardNumber = 不合法的信用卡号码
    @Currency = 不合法的货币 (必须是{value}其中之一)
    @EAN = 不合法的{type}条形码
    @Email= 不是一个合法的电子邮件地址
    @Length = 长度需要在{min}和{max}之间
    @CodePointLength = 长度需要在{min}和{max}之间
    @LuhnCheck = ${validatedValue}的校验码不合法, Luhn模10校验和不匹配
    @Mod10Check = ${validatedValue}的校验码不合法, 模10校验和不匹配
    @Mod11Check = ${validatedValue}的校验码不合法, 模11校验和不匹配
    @ModCheck = ${validatedValue}的校验码不合法, {modType}校验和不匹配
    @NotBlank = 不能为空
    @NotEmpty = 不能为空
    @ParametersScriptAssert = 执行脚本表达式"{script}"没有返回期望结果
    @Range= 需要在{min}和{max}之间
    @SafeHtml = 可能有不安全的HTML内容
    @ScriptAssert = 执行脚本表达式"{script}"没有返回期望结果
    @URL = 需要是一个合法的URL
    
    @DurationMax = 必须小于${inclusive == true ? '或等于' : ''}${days == 0 ? '' : days += '天'}${hours == 0 ? '' : hours += '小时'}${minutes == 0 ? '' : minutes += '分钟'}${seconds == 0 ? '' : seconds += '秒'}${millis == 0 ? '' : millis += '毫秒'}${nanos == 0 ? '' : nanos += '纳秒'}
    @DurationMin = 必须大于${inclusive == true ? '或等于' : ''}${days == 0 ? '' : days += '天'}${hours == 0 ? '' : hours += '小时'}${minutes == 0 ? '' : minutes += '分钟'}${seconds == 0 ? '' : seconds += '秒'}${millis == 0 ? '' : millis += '毫秒'}${nanos == 0 ? '' : nanos += '纳秒'}

[参考约束说明](https://beanvalidation.org/2.0/spec/#builtinconstraints) 