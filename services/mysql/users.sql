CREATE USER 'kappa'@'localhost' IDENTIFIED WITH mysql_native_password BY 'kappa';
GRANT ALL ON *.* to kappa@localhost IDENTIFIED BY 'kappa';
GRANT ALL ON *.* to kappa@'%' IDENTIFIED BY 'kappa';
FLUSH PRIVILEGES;
