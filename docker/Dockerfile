# Build stage

FROM maven:alpine
COPY src /src
COPY pom.xml pom.xml
RUN mvn -f /spring-project/pom.xml clean instal -DskipTests
RUN addgroup -S xyzgroup
RUN adduser -S -D -h /spring-project appuser xyzgroup
RUN chown -R appuser:xyzgroup /spring-project/*
USER appuser


# Package stage

FROM openjdk:11
COPY /target/spring-project.jar spring-project.jar
RUN addgroup -S xyzgroup
RUN adduser -S -D -h /spring-project appuser xyzgroup
RUN chown -R appuser:xyzgroup /spring-project/*
USER appuser
EXPOSE 8080
ENTRYPOINT ["java","-jar","/spring-project.jar"]
