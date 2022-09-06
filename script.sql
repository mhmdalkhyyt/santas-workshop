DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;

CREATE TABLE tomtenisse(
	Namn varchar(255),
    IdNr int(3),
    Lon int(3),
    Adress varchar(255),
     
    primary key (Namn)
)ENGINE=INNODB; 

CREATE TABLE verktyg(
	Namn varchar(255),
	
    primary key (Namn)
)ENGINE=INNODB; 

