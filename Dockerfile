# Pull base image 
From tomcat:8 

# Maintainer 
MAINTAINER "musongwe94@gmail.com" 
EXPOSE 8080
COPY ./webapp/target/webapp.* /usr/local/tomcat/webapps

