# Build stage
#
FROM maven:alpine
COPY src /src
COPY pom.xml pom.xml
RUN mvn -f /spring-project/pom.xml clean instal -DskipTests

#
# Package stage
#
FROM openjdk:11
COPY /target/spring-project.jar spring-project.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/spring-project.jar"]
