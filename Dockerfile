# Build project pake Maven
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Run di server Tomcat
FROM tomcat:9.0-jdk11-openjdk
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
```[cite: 1]

3. Tekan `Ctrl + S` untuk menyimpan, lalu tutup editornya.

---

### **Langkah 3: Push File Baru ke GitHub**
Buka Git Bash / Terminal di folder ini, lalu jalankan:
```bash
git add Dockerfile
git commit -m "Tambah Dockerfile"
git push