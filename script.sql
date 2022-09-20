-- Active: 1663679019364@@127.0.0.1@3306@a20muhal
DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;

-- START OF TABLES --

CREATE TABLE Reindeer(
    Nr int  unique not null,
    ClanName varchar(255),
    Subspecies varchar(255) not null,
    Name varchar(255),
    Stink varchar(255),
    Region varchar(255),
    GroupBellonging int not null,

    primary key (Nr)

)ENGINE=INNODB;


CREATE TABLE Trophy(
    ReindeerNr int unique not null,
    -- YYYY-MM-DD --
    year DATE,
    title varchar(255) not null,

    primary key (ReindeerNr),
    FOREIGN KEY (ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;

CREATE TABLE WorkReindeer(
    ReindeerNr int,
    Salary float,
    

    primary key(ReindeerNr),
    foreign key(ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;


CREATE TABLE PensionedReindeer(
    ReindeerNr int,
    PölsaburkNr int,
    FactoryName varchar(255),
    Taste varchar(255),

    primary key (ReindeerNr),
    foreign key (ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;


CREATE TABLE GroupOfReindeers(
    Name varchar(255) unique not null,
    Capacity int,
    Quantity int not null,
    Share float,

    primary key(Name)

)ENGINE=INNODB;


CREATE TABLE Sleigh(
    Nr int unique not null,
    Name varchar(255),
    Manifactor varchar(255),
    StepLenght int,

    Capacity int,

    primary key (Nr)

)Engine=INNODB;


CREATE TABLE LoadSleigh(
    SleighNr int unique not null,
    ExtraCapacity int,
    ClimateType varchar(255),

    primary key(SleighNr),
    foreign key(SleighNr) REFERENCES Sleigh(Nr)

)ENGINE=INNODB;


CREATE TABLE ExpressSleigh(
    SleighNr int unique not null,
    RocketQuantity int,
    BreakEfficiency int,

    primary key(SleighNr),
    foreign key (SleighNr) REFERENCES Sleigh(Nr)
)ENGINE=INNODB;


CREATE TABLE 

-- END OF TABLES --


-- START OF TRIGGERS restricting jobs --

DELIMITER $$
CREATE TRIGGER tr_invokeInsert_reindeerDupe
BEFORE INSERT ON WorkReindeer
FOR EACH ROW 
    BEGIN
        IF ((SELECT PensionedReindeer.ReindeerNr FROM PensionedReindeer) = NEW.ReindeerNr) then
            SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is pensionized';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_invokeUpdate_reindeerDupe
BEFORE UPDATE ON WorkReindeer
FOR EACH ROW 
    BEGIN
        IF ((SELECT PensionedReindeer.ReindeerNr FROM PensionedReindeer) = NEW.ReindeerNr) then
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is pensionized';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_invokeInsert_reindeerDupe2
BEFORE INSERT ON PensionedReindeer
FOR EACH ROW 
    BEGIN
        IF ((SELECT WorkReindeer.ReindeerNr FROM WorkReindeer) = NEW.ReindeerNr) then
            SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is Working';
        END IF;
    END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER tr_invokeUpdate_reindeerDupe2
BEFORE INSERT ON PensionedReindeer
FOR EACH ROW 
    BEGIN
        if ((SELECT WorkReindeer.ReindeerNr FROM WorkReindeer) = NEW.ReindeerNr) then
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is a working reindeer';
        END IF;
    END$$
DELIMITER ;


-- START OF TRIGGER FOR SlädeNamn --
DELIMITER $$
CREATE TRIGGER tr_invokeError_sleighName
BEFORE INSERT ON Sleigh
FOR EACH ROW
    BEGIN
        if (new.Sleigh.Name = "Brynolf") OR (new.Sleigh.Name = "Rudolf") then
        SIGNAL sqlstate '46000'
        SET MESSAGE_TEXT = "Sleigh name cannot be Brynolf or Rudolf!";
        END IF;
    END$$
DELIMITER ;





-- END OF TRIGGERS --


-- START OF Procedures --


-- START OF PROCEDURE for Transfering Ren to PensioneradRen --

-- START OF PROCEDURE for Selecting from Ren-table -- 




-- END OF PROCEDURES --


-- START OF INSERTS --

INSERT INTO Reindeer(Nr, ClanName, Subspecies, Name, Stink, Region, GroupBellonging)
VALUES (1, 'Huzars', 'pearyi', 'ReindeerMome', 'tolererbar', 'Norr',1);

INSERT INTO Reindeer(Nr, ClanName, Subspecies, Name, Stink, Region, GroupBellonging)
VALUES (2, '', 'pearyi', 'Gandalf', 'YUCK', 'Syd',5);

INSERT INTO PensionedReindeer(ReindeerNr,PölsaburkNr,FactoryName, Taste)
VALUES (2, 200, 'Scan', 'Kanel');

INSERT INTO WorkReindeer(ReindeerNr, Salary)
VALUES(1, 1000);

-- END OF INSERTS --
