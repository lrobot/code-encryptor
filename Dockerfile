FROM docker.io/debian:bookworm as native_builder

LABEL author="4ra1n"
LABEL github="https://github.com/4ra1n"

ENV CODE_ENC_VER 0.4

WORKDIR /app

ENV HTTPS_PROXY=
ENV HTTP_PROXY=
ENV http_proxy=
ENV https_proxy=



RUN rm /etc/apt/sources.list.d/debian.sources
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware" | tee /etc/apt/sources.list

RUN cat /etc/apt/sources.list
RUN apt -o "Acquire::https::Verify-Peer=false" update && apt -o "Acquire::https::Verify-Peer=false" install -y ca-certificates --reinstall


RUN apt-get update && apt-get install -y cmake zip unzip wget ninja-build gcc g++ openjdk-17-jdk nasm python3
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

COPY . .

RUN cd native && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=ninja -G Ninja -S . -B build-release && \
	cmake --build build-release --target all
	
CMD ["echo", "build code-encryptor ${CODE_ENC_VER} completed - /app/build.zip"]


#################### java_builder
FROM ghcr.io/carlossg/maven:eclipse-temurin-17 as java_builder
COPY . /app
WORKDIR /app

# run mvn valiate make sure some jar in libs/*.jar installed before do other compile
COPY --from=native_builder /app/native/build-release/libencryptor.so /app/src/main/resources/
COPY --from=native_builder /app/native/build-release/libdecrypter.so /app/src/main/resources/

RUN --mount=type=cache,target=/usr/share/maven/ref/repository mvn -s m2_settings_container.xml validate
RUN --mount=type=cache,target=/usr/share/maven/ref/repository mvn -s m2_settings_container.xml package -DskipTests
RUN java -jar target/code-encryptor-plus-0.3-cli.jar
#################### runner
FROM docker.io/eclipse-temurin:17-jre-centos7 as runner
#FROM eclipse-temurin:17-jre-jammy
COPY --from=java_builder /app/target/code-encryptor-plus-0.3-cli.jar  /app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
