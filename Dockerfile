
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package


FROM tomcat:9.0-jdk11-openjdk
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
```[cite: 1]




Buka Git Bash / Terminal di folder ini, lalu jalankan:
```bash
git add Dockerfile
git commit -m "Tambah Dockerfile"
git push