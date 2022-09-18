DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;

CREATE TABLE Ren(
    Nr int  unique not null,
    Namn varchar(255),
    Stank varchar(255),
    Region varchar(255),

    primary key (Nr)

)ENGINE=INNODB;

CREATE TABLE TjänstRen(
    Lön float,
    RenNr int,

    primary key(RenNr),
    foreign key(RenNr) REFERENCES Ren(Nr)

)ENGINE=INNODB;