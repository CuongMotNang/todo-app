#stage 1 build JDK + Maven
FROM eclipse-temurin:17-jdk AS build
WORKDIR /workspace

#copy file khai bao
# thu tu copy la quan trong, cac file cau hinh it thay doi -> xep len truocs
# cac file src code thay doi nhieu -> xep phia sau
# neu phia truoc bi thay doi, thi chac chan se khong cache -> build lau hon
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B dependency:go-offline
# NHO la cai gi thay doi nhieu thi phai de copy sau 
Copy src/ src/ 
RUN --mount=type=cache,target=root/.m2 ./mvnw -B -DskipTests package && mv target/*.jar app.jar



#stage 2 runtime, giu lai file chuong trinh .jar va moi truong chay JRE, giam dung luong cho image
FROM eclipse-temurin:17-jre-alpine
RUn addgroup -S app && adduser -S app -G app
WORKDIR /app
#lay file .jar tu stage build der copy vao stage runtime
COPY --from=build /workspace/app.jar app.jar
# tu dong code nay tro di, user chay process container se la app, khong phai root nua
USER app
# cong cua container se la 8080
EXPOSE 8080
#lenh chay terminal thoi
ENTRYPOINT ["java", "-jar", "app.jar"] 
