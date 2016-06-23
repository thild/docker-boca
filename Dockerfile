# VERSION 0.1

FROM ubuntu:14.04

ENV http_proxy http://alunocdt:cedeteg@proxy.cedeteg.unicentro.br:8080/
ENV https_proxy http://alunocdt:cedeteg@proxy.cedeteg.unicentro.br:8080/
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install tzdata
RUN echo "America/Sao_Paulo" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
RUN export LANGUAGE=pt_BR.UTF-8; export LANG=pt_BR.UTF-8; export LC_ALL=pt_BR.UTF-8; locale-gen pt_BR.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN apt-get -y install software-properties-common
RUN apt-get -y install python-software-properties
RUN apt-get -y install curl wget quota postgresql postgresql-contrib postgresql-client apache2 libapache2-mod-php5 php5 php5-cli php5-cgi php5-gd php5-mcrypt php5-pgsql iptables passwd makepasswd openssh-server
RUN apt-get -y install debootstrap
RUN apt-get -y install schroot
RUN apt-get -y install gcc binutils 
RUN cd /tmp
#RUN curl --proxy http://alunocdt:cedeteg@proxy.cedeteg.unicentro.br:8080/ http://www.ime.usp.br/~cassio/boca/download.php?filename=installv2.sh -o installv2.sh
COPY installv2.sh .
RUN chmod +x installv2.sh
RUN ./installv2.sh alreadydone
