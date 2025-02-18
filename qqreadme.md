
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
