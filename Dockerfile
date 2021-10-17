FROM ubuntu:20.04
LABEL maintainer "Jose Gomez <reg.github@derpepe.com>"

ENV VERSION 9.3.1-5492
ENV DEBIAN_FRONTEND noninteractive

## Update OS and install dependencies
RUN apt-get update -q 
RUN apt-get upgrade -q -y
RUN apt-get install -q -y sysstat lsof openssh-server wget cryptsetup supervisor locales
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /app

RUN wget -q -O kerio-connect-${VERSION}-p1-linux-amd64.deb https://cdn.kerio.com/dwn/connect/connect-${VERSION}/kerio-connect-${VERSION}-p1-linux-amd64.deb
RUN dpkg -i kerio-connect-${VERSION}-p1-linux-amd64.deb ; exit 0
RUN rm -rf kerio-connect-${VERSION}-p1-linux-amd64.deb

RUN mkdir -p /var/log/supervisord
RUN mkdir -p /var/run/sshd
RUN locale-gen en_US.utf8
RUN useradd docker -d /home/docker -g users -G sudo -m                                                                                                                    
RUN echo docker:test123 | chpasswd
ADD etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
ADD etc/init.d/kerio-connect /etc/init.d/kerio-connect 
RUN chmod +x /etc/init.d/kerio-connect

EXPOSE 4040 25 465 587 110 995 143 993 119 563 389 636 80 443 5222 5223
VOLUME /opt/kerio/mailserver/store
VOLUME /opt/kerio/mailserver/cluster.cfg
VOLUME /opt/kerio/mailserver/mailserver.cfg
VOLUME /opt/kerio/mailserver/users.cfg

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"] 


#COPY files/kerio-connect-9.3.1-5492-p1-linux-amd64.deb .
#RUN apt-get update \
#    && apt-get install -y ca-certificates lsb-release sysstat lsof cryptsetup \
#    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
#    && dpkg -i ./kerio-connect-9.3.1-5492-p1-linux-amd64.deb \
#    && apt-get install -y -f

#RUN apt update\
    #&& apt-get upgrade -y \
    #&& apt-get install -y curl \
    #&& https://cdn.kerio.com/dwn/connect/connect-9.3.1-5492/kerio-connect-9.3.1-5492-p1-linux-amd64.deb \
    #&& dpkg -i ./kerio-connect-9.3.1-5492-p1-linux-amd64.deb \
    #&& apt-get install -y -f \
    #&& rm -rf /var/lib/apt/lists/* \