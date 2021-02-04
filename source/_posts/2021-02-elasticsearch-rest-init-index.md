---
title: ElasticSearch RestHighLevelClient 自动检测索引并创建
date: 2021-02-04 00:44:23
tags: ElasticSearch RestHighLevelClient
---

ElasticSearch在JAVA中，如果使用TCP连接方式，则可以使用`@Document`进行索引的自动创建，如果使用REST方式则非常麻烦。

RestHighLevelClient是ES提供的应用层API客户端组件，使用Http进行CRUD；原理是模拟各种es需要的请求，如GET,PUT,POST,DELETE等动作。

本文是通过schema的json文件，在项目启动时自动检查及创建新索引。
把schema文件放入到 resources 目录下就可以被检测到；实现由文件名创建索引，如果索引已经存在，则不会覆盖。

Schema：

```json
{
  "properties": {
    "id": {
      "type": "long"
    },
    "description": {
      "analyzer": "ik_max_word",
      "type": "text"
    },
    "time": {
      "format": "yyyy-MM-dd HH:mm:ss",
      "type": "date"
    },
    "createdBy": {
      "type": "keyword"
    }
  }
}


```

代码 ：

```java


import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.indices.CreateIndexRequest;
import org.elasticsearch.client.indices.GetIndexRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.io.*;
import java.util.Map;

/**
 * @author Adam
 */

@Slf4j
@Configuration
@RequiredArgsConstructor(onConstructor_ = {@Autowired})
public class ElasticsearchRestfulConfig {

    private final RestHighLevelClient client;
    private final ObjectMapper mapper;

    @PostConstruct
    public void initElasticsearchTemplate() throws Exception {

        String prefix = "BOOT-INF/classes/";
        
        // resources目录下的json文件都可以被检测到；
        String suffix = ".json";
        String jarName = "app.jar";

        //在Linux环境下使用Docker打的包名字带hash，使用统配查找
        if (!System.getProperties().getProperty("os.name").toUpperCase().startsWith("WIN")) {
            jarName = "*.jar";
        }

        //支持在Windows的IDEA环境下获取文件信息
        File[] files = new File(this.getClass().getResource("/").getPath()).listFiles();
        log.info("检查并创建新索引列表：");
        if (files != null) {
            log.info("通过文件目录获取索引资源文件列表");
            for (File file : files) {
                if (!file.getName().endsWith(suffix)) {
                    continue;
                }
                String indexName = file.getName().split(suffix)[0];
                Map map = mapper.readValue(file, Map.class);
                this.checkAndCreateIndices(indexName, map);
            }
        } else {
            log.info("通过jar文件命令获取索引资源列表");
            String[] cmd = new String[]{"jar", "-tf", jarName};
            Process ps = Runtime.getRuntime().exec(cmd);
            BufferedReader br = new BufferedReader(new InputStreamReader(ps.getInputStream()));
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith(prefix) && line.endsWith(suffix)) {
                    String fileName = line.split(prefix)[1];
                    InputStream is = this.getClass().getClassLoader().getResourceAsStream(fileName);
                    Map map = mapper.readValue(is, Map.class);
                    this.checkAndCreateIndices(fileName.split(suffix)[0], map);
                }
            }
        }
    }

    private void checkAndCreateIndices(String indexName, Map map) throws IOException {

        log.info("Checking Index: {}", indexName);

        GetIndexRequest request = new GetIndexRequest(indexName);
        boolean exists = client.indices().exists(request, RequestOptions.DEFAULT);
        if (exists) {
            return;
        }
        CreateIndexRequest createIndexRequest = new CreateIndexRequest(indexName);
        CreateIndexRequest source = createIndexRequest.source(map);
        try {
            client.indices().create(source, RequestOptions.DEFAULT);
            log.info("Index: {} Created!", indexName);

        } catch (IOException e) {
            log.error("创建新索引失败，请检查资源文件！");
        }
    }
}


```