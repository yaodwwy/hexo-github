---
title: JPA调优实践一：合理使用实体关系的5个Tips 避免 N+1 问题
date: 2019-02-12 08:30:00
tag: JPA
---

写在最前面的话:
    JAVA程序员少不了和SQL打交道，ORM框架带给我们非常大的便利，与此同时也带来了性能不可控的风险。
这里不评测Mybatis和JPA相关的优缺点，仅对近些年的工作实践提供选型建议：

>如果团队是中级以上组成，请用JPA！如果团队参差不齐，请用Mybatis !

因为JPA可调优的点太多，一不小心就会进入性能陷阱。

---

数据库的表与表的关系对应到实体中就是引用关系，实体之间的关联很简单，但需要非常非常小心 `Lazy` 在关联时的使用。
引用的主要目标是从数据库中检索所请求的实体，并**仅在需要时**加载相关实体。
如果你只需要所请求的实体(单表查询)，JPA和Mybatis基本无差异。
但是，如果还需要一些相关联实体一并请求，它会产生额外的查询工作并且可能是产生性能问题的主要原因。

我们来看看触发实体初始化的不同方法及其各自优缺点。

### 在实体上调用另外一个实体的引用

让我们从平时最常用的，也是最低效的方法开始。在EntityManager上使用find方法并直接调用List集合列表(`@OneToMany` 引用)。

    Order order = this.em.find(Order.class, orderId);
    order.getItems().size();

好吧，此代码看起来没有什么问题，但是在实体初始化关系时就不那么理想了。
假设有一个需要查询后初始化的实体具有5个关联的实体。所以你会得到1 + 5 = 6个查询。

好的，这是另外5个查询。这仍然不是一个大问题。但我们的应用程序将由多个用户并行请求。

假设你的系统为100个并行用户提供服务。你会得到100 + 5 * 100 = 600个查询。这被称为n + 1选择问题，
显然这不是一个好方法。迟早，额外执行的查询的数量将拖跨应用程序。因此，你应该尝试避免这种方法并继续往下看。
 

### 在JPQL中使用 Join Fetch

初始化延迟关联的更好选择是使用带有提取连接的JPQL查询。

    Query q = this.em.createQuery("SELECT o FROM Order o JOIN FETCH o.items i WHERE o.id = :id");
    q.setParameter("id", orderId);
    newOrder = (Order) q.getSingleResult();

这告诉实体管理器在同一查询中加载所选实体和关系。这种方法的优点和缺点也是显而易见的：

`优点`是JPA（Hibernate）在一个查询中提取所有内容。从性能的角度来看，这比第一种方法要好得多。

`缺点`是你需要编写执行查询的SQL代码。但是如果实体具有多个关联并且你需要为不同的实例进行不同的关联，则情况会更不好控制。
在这种情况下，需要为要初始化的每个所需关联组合写JPQL查询。这可能会显的非常混乱。

在JPQL语句中使用fetch join可能需要大量的查询，这将使维护代码库变得困难。因此，在开始编写大量查询之前，你应该考虑可能需要的
获取连接查询结果的数量。如果数量很少，那么这是执行查询的最好方法。

 

### 在Criteria API中使用 Fetch Join
这种方法与之前的方法基本相同。但这次你使用的是Criteria API而不是JPQL查询。

    CriteriaBuilder cb = em.getCriteriaBuilder();
    CriteriaQuery q = cb.createQuery(Order.class);
    Root o = q.from(Order.class);
    o.fetch("items", JoinType.INNER);
    q.select(o);
    q.where(cb.equal(o.get("id"), orderId));
    
    Order order = (Order)this.em.createQuery(q).getSingleResult();
    
优点和缺点与使用获取连接的JPQL查询相同。
JPA(Hibernate)从数据库中检索实体和一个查询的关系，并且每个关联组合都需要特别声明是否需要Fetch。如果是使用Spring DATA JPA 则可以用
Specification构建查询Predicate 通用Root的如下方法可以动态关联。

        Join<Student, School> joinSchool = root.join("school");
        Fetch<Student, School> fetchSchool = root.fetch("school");

### 命名实体图

命名实体图是JPA 2.1的新功能。它可用于定义需要从数据库中查询的实体图。实体图通过注解定义，并且与查询无关。
    
    @Entity
    @NamedEntityGraph(name = "graph.Order.items", 
          attributeNodes = @NamedAttributeNode("items"))
    public class Order implements Serializable {
    ....
    
然后，命名实体图可以由EntityManager的find方法使用。

    EntityGraph graph = this.em.getEntityGraph("graph.Order.items");
      
    Map hints = new HashMap();
    hints.put("javax.persistence.fetchgraph", graph);
      
    Order order = this.em.find(Order.class, orderId, hints);

这基本上是我们第一种方法的改进版本。实体管理器将使用一个查询从数据库中检索已定义的实体图。
唯一的缺点是，你需要为每个要在一个查询中检索的关联组合注解命名实体图。
你将需要更少的额外注解，如我们的第二种方法，但它仍然可能变得非常混乱。因此，如果你只需定义有限数量的实体图并将其重用于不同的用例，
则命名实体图是一个很好的解决方案。否则，代码将难以维护。
 

### 动态实体图

动态实体图类似于命名的实体图。唯一的区别是，实体图是通过Java API定义的。

    EntityGraph graph = this.em.createEntityGraph(Order.class);
    Subgraph itemGraph = graph.addSubgraph("items");
        
    Map hints = new HashMap();
    hints.put("javax.persistence.loadgraph", graph);
      
    Order order = this.em.find(Order.class, orderId, hints);

通过API的定义可能是优点也可说是缺点。如果你需要大量特定于用例的实体图，则最好在特定Java代码中定义实体图，而不是向实体添加注解。
这避免了具有非常复杂注解的实体。另一方面，动态实体图需要通过代码定义，可重用。
因此，如果你需要创建一个不会重复使用的特定于用例的图表，我建议使用动态实体图。如果要重用实体图，则更容易注解命名实体图。

### 结论

你已经了解了5种初始化延迟关联的方法。正如你所看到的，每个都有其优点和缺点。
通过在映射关系上调用方法来初始化`Lazy`关系会导致其他查询。出于性能原因，应该避免这种情况。
在JPQL语句中获取联接会将查询数量减少到一个，但你可能需要大量不同的查询语句。
Criteria API还支持提取连接，并且你需要为要初始化的每个关联组合使用特定代码。
如果你要在代码中重用已定义的`@NamedEntityGraph`，则命名实体图是一个很好的解决方案。
如果需要在查询中根据条件动态使用实体关系，则动态实体图可以是更好的解决方案。