FROM java:8

ADD essential-futures-1.0-SNAPSHOT.zip /opt/essential-futures-1.0-SNAPSHOT.zip

RUN unzip /opt/essential-futures-1.0-SNAPSHOT.zip -d /opt

RUN chmod 755 /opt/essential-futures-1.0-SNAPSHOT/bin/essential-futures

EXPOSE 9000

CMD nohup /opt/essential-futures-1.0-SNAPSHOT/bin/essential-futures -Dhttp.port=9000