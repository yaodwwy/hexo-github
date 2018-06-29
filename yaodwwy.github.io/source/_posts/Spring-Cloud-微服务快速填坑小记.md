

本文针对 [史上最简单的 SpringCloud 教程 | 终章](https://blog.csdn.net/forezp/article/details/70148833) 进行了版本升级和测试，测试过程中发现作者故意遗留很多问题(或是因版本升级出现)，导致不能直接成功测试的问题进行了修复和填坑。

## 环境

    Java 10 (VM options: --add-modules java.xml.bind)
    Gradle 4.7
    Spring Cloud Finchley.RELEASE 
    Spring boot 2.0.3

>提前说明

    Java9 / java10 可能会遇到这个异常：
    ClassNotFoundException: javax.xml.bind.JAXBException
    配置 VM options: --add-modules java.xml.bind 即可


## Spring boot Run Dashboard 测试顺序

>第一篇： 服务的注册与发现（Eureka）

    启动 EurekaServer    访问 http://localhost:8761/
    启动 EurekaClientApp    访问 http://localhost:8762/?name=adam

>第二篇: 服务消费者（rest+ribbon  启动：服务端1个，发现端2个，负载均衡端1个）
    
    启动 EurekaServer    访问 http://localhost:8761/
    
    在Dashboard中Copy Configuration 
    Name: EurekaClientApp-0 
    VM options: --add-modules java.xml.bind -Dserver.port=8762
    启动 EurekaClientApp-0     访问 http://localhost:8762/?name=adam
    
    再Copy EurekaClientApp-1 端口改为8763
    启动 EurekaClientApp-1     访问 http://localhost:8763/?name=adam
    
    启动 RibbonBalance     访问 http://localhost:8764/?name=adam
    

    
>第三篇：服务消费者（Feign）

    启动上一篇的前三个（服务端1个，发现端2个）
    启动 RibbonBalance     访问 http://localhost:8765/?name=adam

可同时运行的项目列表：

![Running](running.png)

>第四篇:断路器（Hystrix）
    
    启动 RibbonHystrixApp     
    暂停其中一个发现端  
    访问 http://localhost:8766/?name=adam
如图：
![pause](pause.png)

>第五篇: 路由网关(zuul)

    启动 ZuulApp
    访问 http://localhost:8769/ribbon/?name=adam&token=adam_token
    访问 http://localhost:8769/feign/?name=adam&token=adam_token

>第六篇: 分布式配置中心(Spring Cloud Config)
    
    启动 ConfigServerApp    访问 http://localhost:8888/config-client-dev.properties
    启动 ConfigClientApp    访问 http://localhost:8881/
    
>第七篇: 高可用的分布式配置中心(Spring Cloud Config)
    
    启动 ConfigEurekaServer    访问 http://localhost:8889/config-eureka-client-dev.properties
    启动 ConfigEurekaClient    访问 http://localhost:8887/
在读取配置文件不再写ip地址，而是服务名，这时如果配置服务部署多份，通过负载均衡高可用。
![配置文件实例](config-instances.png)
    
>第八篇: 消息总线(Spring Cloud Bus)
    
    在上一篇基础上(ribbitMQ需要自行搭建)
    修改Git上的配置文件
    重新读取配置文件    POST http://localhost:8887/actuator/refresh

>第九篇: 服务链路追踪(Spring Cloud Sleuth)
    
    下载zipkin
    curl -sSL https://zipkin.io/quickstart.sh | bash -s
    启动 java -jar zipkin.jar
    访问 http://localhost:9411
    启动 ZipkinServiceHi
    启动 ZipkinServiceMiya 访问 http://localhost:8989/hi?name=adam
    *************************************************************
    zipkin测试一至未发现服务，此测试暂未通过！
    下一步测试 spring boot admin 用于监控
    
>第十篇: 高可用的服务注册中心

    停止 EurekaServer
    在Dashboard中对EurekaServer  Copy Configuration 
    Name: EurekaServerPeer-0
    VM options: --add-modules java.xml.bind -Dspring.profiles.active=peer0
    启动 EurekaServerPeer-0
    重复再复制一份
    Name: EurekaServerPeer-1
    VM options: --add-modules java.xml.bind -Dspring.profiles.active=peer1
    启动 EurekaServerPeer-1    
    配置host:
        127.0.0.1 peer1
        127.0.0.1 peer0
    访问 http://localhost:8761/
    访问 http://localhost:8771/
    
    
    
未完待续~


## 常见问题

### 服务的注册与发现 Eureka 
    新版的Cloud(Finchley.RELEASE)使用如下的依赖地址
    compile('org.springframework.cloud:spring-cloud-starter-netflix-eureka-client')
    
    注解 `@EnableEurekaClient` ,
    需要注意 Eureka 的 Application 实例名不可以有下划线 `_` 

### 服务消费者 rest + ribbon 
eureka-client 在IDEA中启动多个的方法：

    1、复制一个启动配置
    2、在编辑界面取消勾选 `Single instance only`
    3、VM options ： -Dserver.port=新的端口号

### 服务链路追踪(Spring Cloud Sleuth)
    
   新版的Cloud(Finchley.RELEASE)已经没有Zipkin的`@EnableZipkinServer`注解了。
   官网提供的启动方式如下：
   ``` bash
   curl -sSL https://zipkin.io/quickstart.sh | bash -s
   java -jar zipkin.jar
   ```  
   如果需要源码编译启动：
   ``` bash
   # get the latest source
   git clone https://github.com/openzipkin/zipkin
   cd zipkin
   # Build the server and also make its dependencies
   ./mvnw -DskipTests --also-make -pl zipkin-server clean install
   # Run the server
   java -jar ./zipkin-server/target/zipkin-server-*exec.jar   
   ```    
>[Zipkin 官网参考](https://zipkin.io/pages/quickstart)

### 断路器 Hystrix 

断路器 Hystrix Dashboard 出现：
hystrix dashboard Unable to connect to Command Metric Stream 异常提示

依赖:

    compile('org.springframework.boot:spring-boot-starter-actuator')
    //在ribbon使用断路器
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix')
    //在ribbon使用断路器仪表盘
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix-dashboard')
    
配置：

    @EnableHystrix
    @EnableHystrixDashboard

注册servlet（基于Cloud版本Finchley需要）：

    @Bean
    public ServletRegistrationBean getServlet() {
        HystrixMetricsStreamServlet streamServlet = new HystrixMetricsStreamServlet();
        ServletRegistrationBean registrationBean = new ServletRegistrationBean(streamServlet);
        registrationBean.setLoadOnStartup(1);
        registrationBean.addUrlMappings("/hystrix.stream");
        registrationBean.setName("HystrixMetricsStreamServlet");
        return registrationBean;
    }

### 高可用的分布式配置中心 Spring Cloud Config 

如果出现配置文件的值无法获取的异常，Injection of autowired dependencies failed
Could not resolve placeholder 'foo' in value "${foo}"

检查git配置文件中心的repo目录下，有没有对应名字的文件：

    config-eureka-client-dev.properties
    对应以下的应用名：
    spring.application.name=config-eureka-client
    
    config-client-dev.properties
    对应以下的应用名：
    spring.application.name=config-client
    
以上都是基于Finchley版本环境。

填坑完成后的测试版本：https://github.com/yaodwwy/spring-cloud-tutorials