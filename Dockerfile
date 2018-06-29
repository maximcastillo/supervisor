FROM        ubuntu:14.04
MAINTAINER  Dicotraining maximo.a.c.g@outlook.com
 

# Update the package repository
RUN apt-get update -y && apt-get upgrade -yqq


# Install PHP 5.5
RUN apt-get install -y php5-cli php5 php5-mcrypt php5-curl php-pgsql
# Install openssh
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd

# Add the student user with su permission
RUN useradd -d /home/student -m -s /bin/bash student
RUN echo student:student | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Configuration of supervisor
RUN mkdir -p /var/log/supervisor
COPY ./supervisord.conf /etc/supervisor/supervisor.conf

# Configure apache
ADD ./config/001-docker.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/


# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

EXPOSE 80
ADD ./scripts/info.php /var/www/html/info.php
ADD ./scripts/start.sh /start.sh
RUN chmod 0755 /start.sh
CMD ["bash", "start.sh"]
