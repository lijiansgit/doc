create database confluence;
GRANT ALL PRIVILEGES ON confluence.* TO 'confluence'@'%' IDENTIFIED BY 'confluence' WITH GRANT OPTION;
flush privileges;