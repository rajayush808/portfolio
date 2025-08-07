# ---------- 1. Build stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml first to leverage Docker layer-caching for dependencies
COPY pom.xml .
RUN mvn -q dependency:go-offline

# Copy the rest of the source and build the jar
COPY . .
RUN mvn -q clean package -DskipTests

# ---------- 2. Run stage ----------
FROM eclipse-temurin:21-jdk
WORKDIR /app

# Copy only the fat jar from the previous image
COPY --from=build /app/target/*.jar app.jar

# Render will inject a PORT env var (e.g. 10000); expose 8080 for local use
EXPOSE 8080
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport"
ENTRYPOINT ["java","-jar","app.jar"]
