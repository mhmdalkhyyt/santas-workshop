DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;

-- START OF TABLES --

CREATE TABLE Ren(
    Nr int  unique not null,
    KlanNamn varchar(255) not null,
    Underart varchar(255) not null,
    Namn varchar(255),
    Stank int,
    Region varchar(255),
    TillhörSpann int not null,

    primary key (Nr)

)ENGINE=INNODB;


CREATE TABLE Priser(
    RenNr int unique not null,
    -- YYYY-MM-DD
    år DATE,
    titel varchar(255) not null,

    primary key (RenNr),
    FOREIGN KEY (RenNr) REFERENCES Ren(Nr)

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

-- END OF TABLES --


-- START OF TRIGGERS restricting jobs --

DELIMITER $$
CREATE TRIGGER tr_invokeInsert_renDupe
BEFORE INSERT ON TjänstRen
FOR EACH ROW 
    BEGIN
        if new.TjänstRen.RenNr = new.PensioneradRen.RenNr then
        SIGNAL sqlstate '45000'
        SET MESSAGE_TEXT = "Renen är pensionerad";
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_invokeUpdate_renDupe
BEFORE UPDATE ON TjänstRen
FOR EACH ROW 
    BEGIN
        if new.TjänstRen.RenNr = new.PensioneradRen.RenNr then
        SIGNAL sqlstate '45000'
        SET MESSAGE_TEXT = "Renen är pensionerad";
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_invokeInsert_renDupe2
BEFORE INSERT ON PensioneradRen
FOR EACH ROW 
    BEGIN
        if new.PensioneradRen.RenNr = new.TjänstRen.RenNr then
        SIGNAL sqlstate '45000'
        SET MESSAGE_TEXT = "Renen är i tjänst";
        END IF;
    END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER tr_invokeUpdate_renDupe2
BEFORE INSERT ON PensioneradRen
FOR EACH ROW 
    BEGIN
        if new.PensioneradRen.RenNr = new.TjänstRen.RenNr then
        SIGNAL sqlstate '45000'
        SET MESSAGE_TEXT = "Renen är i tjänst";
        END IF;
    END$$
DELIMITER ;


-- START OF TRIGGER FOR SlädeNamn --
DELIMITER $$
CREATE TRIGGER tr_invokeError_slädeNamn
BEFORE INSERT ON Släde
FOR EACH ROW
    BEGIN
        if (new.SlädeNamn = "Brynolf") OR (new.SlädeNamn = "Rudolf") then
        SIGNAL sqlstate = '46000'
        SET MESSAGE_TEXT = "Släde får inte heta Brynolf eller Rudolf!"
        END IF;
    END$$
DELIMITER ;



-- END OF TRIGGERS --


-- START OF Procedures --


-- START OF PROCEDURE for Transfering Ren to PensioneradRen --

