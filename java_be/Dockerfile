FROM eclipse-temurin:25-jdk-alpine AS builder

WORKDIR /app

# tải thư viện
COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .

# Add execution permissions to the wrapper
RUN chmod +x mvnw
# This will now work without exit code 126
RUN ./mvnw dependency:go-offline

# build
COPY . .
# Grant execution permission to the Maven wrapper
RUN chmod +x ./mvnw
# /app/target/*.jar
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

CMD [ "java", "-jar", "app.jar" ]

# docker build -t java_be_image .
# docker run --name java_be_container -d -p 8003:8080 --env-file=.env java_be_image