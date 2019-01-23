---
title: Flowable6.4 Activiti6 通过存储过程同步用户数据
date: 2018-11-02 13:57:00
tag: 
---

用户数据属于业务范畴

基于 `Activiti6` 或 `Flowable6.4` 

数据库 `Postgres` + `Spring Data JPA`

一、先实现存储过程

```sql

CREATE OR REPLACE FUNCTION sync_flowable_identify()
RETURNS NUMERIC
AS $$
BEGIN

		raise notice '业务用户数与Flowable用户数同步';
		  INSERT INTO act_id_user(id_,rev_,first_,last_,display_name_,email_,tenant_id_)
		  SELECT username,'2',fullname,'[同步]',fullname,email,null from t_member where username not in (SELECT id_ from act_id_user);
		  update act_id_user set pwd_ = '123123' where id_ = 'admin';

		raise notice '业务角色数与Flowable组同步';
		  INSERT INTO act_id_group(id_,rev_,name_,type_)
		  SELECT distinct name,1,name,'assignment' from t_role where name <> '' and name not in (SELECT id_ from act_id_group);

		raise notice '业务关系记录与Flowable关系记录同步';
		  INSERT INTO act_id_membership(user_id_,group_id_)
		  select distinct m.username,r.name from t_member_role mr left join t_member m on mr.member_id=m.id
        left join t_role r on mr.role_id = r.id where m.username is not null and m.username not in (select user_id_ from act_id_membership);

    RETURN 1;
END;
$$ LANGUAGE PLPGSQL;

SELECT sync_flowable_identify();

```

二、在用户Repo层添加调用存储过程接口

```java
public interface IMemberRepository extends JpaRepository<MemberEntity, Integer>{
    @Procedure(procedureName = "sync_flowable_identify")
    void syncFlowableIdentify();
}
```

三、在业务中新增用户或组时调用同步方法 `syncFlowableIdentify()`

四、再用同样的方式定义修改和删除时对应的数据同步业务。