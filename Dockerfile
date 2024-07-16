FROM adoptopenjdk/openjdk11
    
EXPOSE 8080
 
ENV APP_HOME /usr/src/app

COPY target/*.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

ENTRYPOINT ["java", "-jar", "app.jar"]
