---
title: Git智能提交插件 (Git integration for jira)
date: 2019-12-05 21:15:00
tag: jira
---

智能提交就是在Git提交时，Jira系统会检索并识别关键字，对问题进行转换、更新、指派等。Git用户可以输入` issue key`和所需的操作，例如时间跟踪或解决问题。`v2.6.3 +` 默认情况下，智能提交处理处于活动状态，可以通过git配置页面 启用/禁用智能提交：

* 智能提交预检查内容：
* Jira账号 `Email` 地址和Git提交配置的 `Email` 地址必须一致。

---

### 基础使用

    <ISSUE_KEY> <ignored text> #<command> <optional command_params>

#### `#comment` 添加评论

    ISSUE_KEY #comment <your comment text>
    Example：
    GIT-264 #comment 已解决冲突.
    GIT-1720 #comment 这是一条普通的Jira备注，可以通过Git提交时自动备注到Jira
    上面的示例将针对Jira问题添加指定的注释备注信息。

> _git配置中提交者的电子邮件地址必须与相应的Jira用户的电子邮件地址匹配，才能对问题发表评论。_

#### `#time` 记录时间跟踪信息

    ISSUE_KEY #time [Jira时间语法] <您的工作日志注释文本>
    Example：
    GIT-264 #time 1w 6d 13h 52m 工作日志内容，会自动提交到Jira的工作日志中。
    GIT-1720 #time 1h 20m Merged to master. Released to marketplace.
    上面的示例将对Jira问题添加相应的时间和工作日志注释文本。

> _Jira时间跟踪功能可以记录解决问题所花费的时间。Jira管理员必须启用此功能才能使此智能提交生效。_

#### `#<transition-name>` 状态流转

    ISSUE_KEY #<transition-name> <注释文本>
    Example：
    GIT-264 #开始解决 问题注释文本内容
    GIT-1720 #重新打开 #comment 问题已重现，请重新处理！

![jira-workflow](/img/jira-workflow.png?ver=4)

> _用户必须有权限才能转换问题。图中线上的文字为**转换指令**_

#### `#assign` 分配用户

    ISSUE_KEY #assign [<Jira username> or <email>]
    Example：
    GIT-1925 #assign johnsmith
    GIT-1961 #assign jsmith@example.com
    
#### `#fixversion` 修复的版本

    ISSUE_KEY #fixversion [版本号]
    Example：
    GIT-1628 #fixversion 2.9.6
    GIT-1628 #fixversion 2.9.5 #fixversion 2.9.6

#### `#affectsversion` 影响的版本
    
    ISSUE_KEY #affectsversion [版本号]
    Example：
    GIT-1582 #affectsversion 2.9.6

#### `#label` 更新标签信息

    ISSUE_KEY(S) #label [label1] .. [labeln]
    Example：
    GITCL-443 #label 订单 发货
    GITCL-443 GITCL-247 GITCL-214 #label 新功能 解耦 #comment 评论内容

### 进阶功能

    Example：
    TEST-100 #time 2w 1d 4h 30m 这是一个时间日志评论
    工作耗时2周1天4小时30分钟工作, 工作日志"这是一个时间日志评论"

#### 多指令

    Example：
    TEST-100 #time 4h 30m 修复NPE异常 #comment 修复代码异常 #resolve 已解决可以流转
    工作耗时4小时30分钟, 工作日志 "修复NPE异常", 备注"修复代码异常" 并解决问题。

#### 多问题同一指令

    Example：
    TEST-100 TEST-101 TEST-102 #resolve

#### 多问题多指令

    TEST-100 TEST-101 TEST-102 #resolve  #time 2d 4h #comment Fixed code
    解决指定的问题,工作耗时2天4个小时，添加"修复代码异常"备注。


从Git Integration for Jira应用程序的v2.6.33版开始，已实现了对智能提交的多行提交消息的支持。以下示例显示了`智能提交`消息的正确用法：

    TST-1 implemented feature 1
    TST-1 #comment 一些评论
    评论可以
    换行
    TST-1 #resolve
    TST-2 #time 1h 30m
    
    //以下的提交信息与上面是等价的
    TST-1 implemented feature 1
    #comment 一些评论
    评论可以
    换行
    #resolve TST-2
    #time 1h 30m
    
    //这样写也是允许的
    TEST-3 设置的背景色应更浅
    TEST-3 #处理中 #time 1h TEST-4 解决
    TEST-2 #已解决
    
### 工作流程转换

如下图所示，在敏捷开发大背景下，简单的Jira工作流程已经开始流行起来，工作流程不再设计过渡转换线条。[Atlassian推荐设计]

![](https://bigbrassband.com/docimgs/jira-simple-workflow-144.png)

从`DONE`进行的有效转换是：

   `#to-do`
   `#in-progress`
   `#in-review`

* 工作流中的状态名称必须唯一。
* 没有转换线的名称，可以直接使用状态名称。
* 如果有空格，请将其替换为`-`。例如: CODE REVIEW 变为 #code-review。

>**提交人：**
对于智能提交的工作流过渡名称，只有字母和`-`有效。其他任何字符均视为无效。智能提交只能处理有效字符。
    
>**Jira管理员：**
在工作流编辑器中添加转换线时，尽可能简单易记。仅能使用字母，单词之间只能使用一个空格。

---

### 其它说明

>查看工作流程
![](https://bigbrassband.com/docimgs/jira-workflow-hover.png)

Jira工作流程转换线在鼠标悬停时可以看到名称

    //智能提交支持以下三种省略写法
    <ISSUE_KEY> #to-business-spec
    <ISSUE_KEY> #to-business
    <ISSUE_KEY> #to> 
    只要不与其它的转换线名称冲突就可以使用

---

原文参考：https://bigbrassband.com/git-integration-for-jira/documentation/smart-commits.html