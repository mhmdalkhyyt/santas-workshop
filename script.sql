DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;

CREATE TABLE Ren(
    Nr int  unique not null,
    KlanNamn varchar(255) not null,
    Underart varchar(255) not null,
    Namn varchar(255),
    Stank varchar(255),
    Region varchar(255),

    primary key (Nr)

)ENGINE=INNODB;

CREATE TABLE TjänstRen(
    RenNr int,
    Lön float,
    

    primary key(RenNr),
    foreign key(RenNr) REFERENCES Ren(Nr)

)ENGINE=INNODB;


CREATE TABLE PensioneradRen(
    RenNr int,
    PölsaburkNr int,
    Fabriknamn varchar(255),
    Smak varchar(255),

    primary key (RenNr),
    foreign key (RenNr) REFERENCES Ren(Nr)


)ENGINE=INNODB;


CREATE TABLE Spann(
    Namn varchar(255) unique not null,
    Kapacitet int,
    Antal int,
    Andel float,

    primary key(Namn)

)ENGINE=INNODB;


CREATE TABLE Släde(
    Nr int unique not null,
    Namn varchar(255),
    Tillvärkare varchar(255),
    Steglängd int,

    Kapacitet int,

    primary key (Nr)

)Engine=INNODB;


CREATE TABLE LastSläde(
    SlädeNr int unique not null,
    Extrakapacitet int,
    Klimattyp varchar(255),

    primary key(SlädeNr),
    foreign key(SlädeNr) REFERENCES Släde(Nr)

)ENGINE=INNODB;


CREATE TABLE ExpressSläde(
    SlädeNr int unique not null,
    Raketantal int,
    Bromsverkan int,

    primary key(SlädeNr),
    foreign key (SlädeNr) REFERENCES Släde(Nr)
)ENGINE=INNODB;


