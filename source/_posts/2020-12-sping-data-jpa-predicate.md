---
title: Spring Data JPA 查询条件工厂
date: 2020-12-24 00:44:23
tags: JPA Specification Predicate
---

使用 Spring Data JPA 时最大的问题往往不是技术难度问题，
毕竟ORM框架集成度已经可以做到懒人模式下开箱即用，同时也带来更大的性能隐患。
和当年的Hibernate一样，在中文圈一直不流行的其中一个原因，多数开发者认为
Hibernate自动化程度太高，可优化空间小，这恰恰只看到问题的一方面。
Hibernate的优化空间比 Mybatis 只多不少。
反观 `EclipseLink` `TopLink` `OpenJPA` 都没火起来，
但是到Spring Data JPA 反而又让JPA火了一把，又是为什么呢？
就像有的人喜欢自动档的汽车，有的人却喜欢手动档。各有各的原因。

#### 概述

本文讲述Spring Data JPA规范下的高效查询问题，
利用工厂方法，动态的把必须的表进行连接。

数据结构如图所示 

![](/img/data-diagram.svg)

> 说明：
> 一个组织有多个部门，一个部门有多个用户；
> 当查用户的时候，可以左连接部门的所有查询条件
> 也可以继续连接组织的查询条件，此时效率是最优的。

>例外情况：
> 当查部门的时候，如果连接用户的查询条件
> 默认是使用`root.get(dept).get(name)`的时候 会生成 cross join 语句即交叉连接
> 此时效率会大幅度降低。
> 这里表述的不一定特别清晰，总之如果是cross join 则会造成 2*2 得 4 的结果集，在结果集中进行筛选。

*怎么优化呢？*

可以参考以下伪代码 

```java

/**
 * 用户、部门、组织、查询条件工厂
 */
public class UserPredicateFactory {

    /**
     * 组织条件组合
     */
    public static Predicate getOrgPredicate(From<?, OrganizationEntity> from,
                                            Fetch<?, OrganizationEntity> fetch,
                                            CriteriaQuery<?> query,
                                            CriteriaBuilder cb,
                                            OrganizationEntity org) {
        List<Predicate> predicates = new ArrayList<>();
        
        //未删除
        predicates.add(cb.equal(from.get(del), false));
        if (org == null) {
            org = new OrganizationEntity();
        }

        //ID
        if (org.getId() != null) {
            predicates.add(cb.equal(from.get(id), org.getId()));
        }
        if (StringUtils.notNull(org.getName())) {
            predicates.add(cb.like(cb.upper(from.get(name)), pattern(org.getName())));
        }

        return cb.and(predicates.toArray(new Predicate[predicates.size()]));
    }

    /**
     * 部门条件组合
     */
    public static Predicate getDeptPredicate(From<?, DepartmentEntity> from,
                                             Fetch<?, DepartmentEntity> fetch,
                                             CriteriaQuery<?> query,
                                             CriteriaBuilder cb,
                                             DepartmentEntity dept) {

        List<Predicate> predicates = new ArrayList<>();
        Fetch<DepartmentEntity, OrganizationEntity> fetch1 = null;
        Fetch<DepartmentEntity, UserEntity> fetch2 = null;
        if (!Long.class.equals(query.getResultType())) {
            if (fetch == null) {
                // 为空时表示由当前实体作为 from 入口
                fetch1 = from.fetch(organization, JoinType.LEFT);
            } else {
                // 表示 需要组合 left join 语句
                fetch1 = fetch.fetch(organization, JoinType.LEFT);
            }
        }

        Join<DepartmentEntity, OrganizationEntity> join1 = from.join(organization, JoinType.LEFT);
        //未删除
        predicates.add(cb.equal(from.get(del), false));
        if (dept == null) {
            dept = new DepartmentEntity();
        }

        // 组织条件集合
        predicates.add(getOrgPredicate(join1, fetch1, query, cb, dept.getOrganization()));

        //ID
        if (dept.getId() != null) {
            predicates.add(cb.equal(from.get(id), dept.getId()));
        }
        //部门名
        if (StringUtils.notNull(dept.getName())) {
            predicates.add(cb.like(cb.upper(from.get(name)), pattern(dept.getName())));
        }
        return cb.and(predicates.toArray(new Predicate[predicates.size()]));
    }

    /**
     * 用户条件组合
     */
    public static Predicate getUserPredicate(From<?, UserEntity> from,
                                               Fetch<?, UserEntity> fetch,
                                               CriteriaQuery<?> query,
                                               CriteriaBuilder cb,
                                               User User) {
        List<Predicate> predicates = new ArrayList<>();
        Fetch<UserEntity, DepartmentEntity> fetch1 = null;
        if (!Long.class.equals(query.getResultType())) {
            if (fetch == null) {
                fetch1 = from.fetch(department, JoinType.LEFT);
            } else {
                fetch1 = fetch.fetch(department, JoinType.LEFT);
            }
        }
        Join<UserEntity, DepartmentEntity> join = from.join(department, JoinType.LEFT);
        //未删除
        predicates.add(cb.equal(from.get(del), false));
        if (User == null) {
            User = new UserEntity();
        }

        // 部门条件集合
        predicates.add(getDeptPredicate(join, fetch1, query, cb, User.getDepartment()));

        if (User.getId() != null) {
            predicates.add(cb.equal(from.get(id), User.getId()));
        }
        if (StringUtils.notNull(User.getName())) {
            predicates.add(cb.like(cb.upper(from.get(name)), pattern(User.getName().trim())));
        }
        return cb.and(predicates.toArray(new Predicate[predicates.size()]));
    }

    private static String pattern(String param) {
        return "%" + param.toUpperCase() + "%";
    }
}

```

最后，怎么调用呢？

```java
@Service
public class MemberService{
    
    
    @Override
    public List<UserEntity> list(User user) {
        // 第二个参数是 fetch 表示是否需要迫切加载关联的实体，可在外面传入，留空则由参数自动判断。
        Specification<UserEntity> spec = (Specification<UserEntity>) (root, query, cb)
                -> UserPredicateFactory.getUserPredicate(root, null, query, cb, user);
        return iUserRepository.findAll(spec);
    }
    
}
```

#### 总结：

在做连接查询的核心观点如下：
- 连表能少则少。动态连接，需要则连，不需要则不连。
- 不在Entity中做业务
- 不使用 `@Transient`
- `@OneToMany` 和 `@ManyToOne` 的参数尽量使用默认值。