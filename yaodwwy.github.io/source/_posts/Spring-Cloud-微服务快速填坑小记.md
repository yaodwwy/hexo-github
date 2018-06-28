

本文针对 [史上最简单的 SpringCloud 教程 | 终章](https://blog.csdn.net/forezp/article/details/70148833) 进行了版本升级和测试，测试过程中发现作者故意遗留很多问题(或是因版本升级出现)，导致不能直接成功测试的问题进行了修复和填坑。

使用`Gradle4+`构建,
如果 是Java9 或 java10 可能会遇到这个异常：ClassNotFoundException: javax.xml.bind.JAXBException
在VM options 添加模块导入即可

    --add-modules java.xml.bind 

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