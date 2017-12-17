# This is a Chef recipe file. It can be used to specify resources which will
# apply configuration to a server.

require 'mixlib/shellout'

execute "apt-get-update" do
   command "apt-get update"
end

apt_repository "docker" do
  uri "https://apt.dockerproject.org/repo"
  distribution "ubuntu-trusty"
  components ["main"]
  keyserver "p80.pool.sks-keyservers.net"
  key "58118E89F3A912897C070ADBF76221572C52609D"
end

package "docker-engine"

group "docker" do
  action :modify
  members "ubuntu"
  append true
end

script "mysql_docker" do
  interpreter "bash"
  code <<-EOH
    docker pull mysql
    docker run --name #{node["wordpress"]["name"]} -e MYSQL_ROOT_PASSWORD=#{node["wordpress"]["dbpassword"]} -d mysql:latest
    touch /home/ubuntu/mysqldocker.executed
    EOH
  not_if do ::File.exists?('/home/ubuntu/mysqldocker.executed') end
end

user 'www-data'
group 'www-data'

environment = Chef::DataBagItem.load('wordpress', 'wordpress')
node.default['wordpress']['siteurl'] = environment['siteurl']

['apache2', 'apache2-doc', 'apache2-mpm-prefork', 'apache2-utils', 'libexpat1', 'ssl-cert', 'libapache2-mod-php5', 'php5', 'php5-common', 'php5-curl', 'php5-dev', 'php5-gd', 'php5-idn', 'php-pear', 'php5-imagick', 'php5-mcrypt', 'php5-mysql', 'php5-ps', 'php5-pspell', 'php5-recode', 'php5-xsl', 'phpmyadmin', 'mysql-client-core-5.6'].each do |p|
  package p do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/wordpress-latest.tar.gz" do
  source 'https://wordpress.org/wordpress-latest.tar.gz'
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  notifies :run, "script[wordpress_install]" , :immediately
  action :create_if_missing
end

script "wordpress_install" do
  interpreter "bash"
  cwd '/opt/'
  code <<-EOH
    rm -rf wordpress
    tar zxf #{Chef::Config[:file_cache_path]}/wordpress-latest.tar.gz
    rm -rf /var/www/html/*
    cp -a /opt/wordpress/. /var/www/html
    chown -R www-data:www-data /var/www/html
    EOH
  notifies :create, "template[mysql connect.sh]", :delayed
  notifies :run, "script[mysqlscript]", :delayed
  notifies :run, "script[wordpress wp_install]", :delayed
  notifies :run, "script[wordpress site_install]", :delayed
  action :nothing
end

template 'mysql connect.sh' do
  path '/opt/mysql-connect.sh'
  source "mysql-connect.sh.erb"
  cookbook 'wordpress'
  variables lazy {{ :DB_NAME => node["wordpress"]["dbname"],
                    :DB_USER => node["wordpress"]["dbuser"],
                    :DB_PASSWORD => node["wordpress"]["dbpassword"]}}
end

script "mysqlscript" do
  interpreter "bash"
  cwd '/opt/'
  code <<-EOH
    sh /opt/mysql-connect.sh
    touch /home/ubuntu/database.executed
    EOH
   not_if do ::File.exists?('/home/ubuntu/database.executed') end
end

script "wordpress wp_install" do
  interpreter "bash"
  cwd '/opt/'
  code <<-EOH
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    php wp-cli.phar --info
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp --info --allow-root
    cd /var/www/html/
    export db_ip=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" $(docker inspect --format="{{.Id}}" wordpress))
    wp config create --dbname=#{node["wordpress"]["dbname"]} --dbuser=#{node["wordpress"]["dbuser"]} --dbhost=$db_ip --dbpass=#{node["wordpress"]["dbpassword"]} --allow-root
    chown -R www-data:www-data /var/www/html
    EOH
  action :nothing
end

script "wordpress site_install" do
  interpreter "bash"
  cwd '/var/www/html/'
  user 'www-data'
  group 'www-data'
  code <<-EOH
    wp core install --url=#{node["wordpress"]["siteurl"]}  --title=#{node["wordpress"]["sitetitle"]}  --admin_user=#{node["wordpress"]["siteuser"]} --admin_password=#{node["wordpress"]["sitepass"]} --admin_email=#{node["wordpress"]["siteemail"]}
    EOH
  action :nothing
end
      