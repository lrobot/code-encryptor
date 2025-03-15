
##  最后发现此方案和sprintboot有冲突

* spring-core会跳过java自己的class加载机制。直接读取jar包中的class文件进行class的分析。结果读取到了加密的内容。报错
* 发现 https://github.com/roseboy/classfinal 项目据说是没有class文件整体加密。而是加密class中的方法体。可以尝试一下
* 还发现*.asm汇编代码中对于 signature部分的处理也有问题。没有那个文档描述过那个字段是signature.


* java --add-opens=java.base/java.util.zip=ALL-UNNAMED -jar /code_encryptor.jar patch --jar /app.jar --package com.xxx --key 0123456789abceef

## better

* 用docker的multistage方式编译出native 和jar 然后放入jar运行环境中
* 此工程改为目标java版本是java17
* 目前只支持linux
* 用debian12 进行native build, 应该是不需要execstack了
* 直接./release.sh就可以编译好 并发布到docker.io

## 运行方式1

* 假如你的jar包在 ./spring-boot-web/target/your-app.jar

```shell
podman run --rm -it -v .:/host_dir lrobot/code-encryptor:0.4 java -jar /app.jar patch --jar /host_dir/spring-boot-web/target/your-app.jar --package com.your.pack --key 1234567890abcdef
```

## 运行方式2

 * 在自己的Dockerfile中copy jar过去运行
```
COPY --from docker.io/lrobot/code-encryptor:0.4 /app.jar /code-encryptor.jar
RUN java -jar /code-encryptor.jar --jar /app/spring-boot-web/target/your-app.jar --package com.your.pack --key your-key
```
