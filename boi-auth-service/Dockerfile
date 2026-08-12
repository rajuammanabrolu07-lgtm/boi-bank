# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -e dependency:go-offline
COPY src ./src
RUN mvn -q -B clean package -DskipTests

# ---- runtime stage ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# non-root user (enterprise container hardening)
RUN addgroup -S boi && adduser -S boi -G boi
COPY --from=build /app/target/*.jar app.jar
USER boi
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
