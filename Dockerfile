FROM ubuntu
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get  update -y
RUN apt-get install -y apache2
RUN apt-get install -y curl php-cli php-mbstring git unzip
RUN apt-get install -y apache2 php7.4 libapache2-mod-php7.4
RUN a2query -m php7.4
RUN a2enmod php7.4
RUN cd ~
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=bin --filename=composer
RUN composer global require laravel/installer
RUN cd /var/www/html/
RUN php -v
RUN apt-get -y install php7.4-xml
COPY ./ /var/www/html/
RUN  cd /var/www/html/
WORKDIR /var/www/html/
RUN mv /var/www/html/apache-conf/.htaccess /etc/apache2/sites-available/000-default.conf
RUN service apache2 restart
ADD docker-entrypoint.sh /data/
RUN cd /var/www/html \
	&& chown -R www-data:www-data /var/www/html  \
	&& chmod -R 755 /var/www/html/storage        \
    && chmod +x /data/docker-entrypoint.sh
ENTRYPOINT ["/data/docker-entrypoint.sh"]
