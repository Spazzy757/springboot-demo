# Build stage builds the JAR
FROM openjdk AS builder

ENV MAVEN_VERSION 3.6.3

# Install Maven
RUN mkdir -p /usr/share/maven \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
  | tar -xzC /usr/share/maven --strip-components=1 \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

VOLUME /root/.m2

RUN mkdir /app

COPY . /app

WORKDIR /app

RUN mvn package

# Final Stage copies the JAR from previous builder and setups to run
FROM openjdk:16-jdk-alpine
RUN mkdir /target
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
# Copy JAR from builder
COPY --from=builder /app/target/*.jar /target/
ARG JAR_FILE=/target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
