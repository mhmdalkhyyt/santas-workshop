-- Active: 1663679019364@@127.0.0.1@3306@a20muhal
DROP DATABASE IF EXISTS a20muhal;
CREATE DATABASE a20muhal;
USE a20muhal;


-- USERS -- 



-- START OF TABLES --

CREATE TABLE Reindeer(
    Nr int  unique not null,
    ClanName varchar(255),
    Subspecies varchar(255) not null,
    ReindeerName varchar(255),
    Stink varchar(255),
    Region varchar(255),
    GroupBellonging int not null,

    primary key (Nr)

)ENGINE=INNODB;


CREATE TABLE Trophy(
    ReindeerNr int unique not null,
    -- YYYY-MM-DD --
    Occation DATE not null,
    Title varchar(50) not null,

    primary key (ReindeerNr, Occation),
    FOREIGN KEY (ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;

CREATE TABLE WorkReindeer(
    ReindeerNr int,
    Salary float,
    

    primary key(ReindeerNr),
    foreign key(ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;


CREATE TABLE RetiredReindeer(
    ReindeerNr int unique not null,
    PölsaburkNr int not null,
    FactoryName varchar(255),
    Taste varchar(255),

    primary key (ReindeerNr),
    foreign key (ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;


CREATE TABLE GroupOfReindeers(
    ReindeerNr int not null,
    ReindeerName varchar(255) not null,
    GroupNr int not NULL,
    Capacity int,
    Quantity int not null,
    Share float,
    

    primary key(ReindeerNr),
    foreign key(ReindeerNr) REFERENCES Reindeer(Nr)

)ENGINE=INNODB;


CREATE TABLE Sleigh(
    Nr int unique not null,
    SleighName varchar(255),
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


-- Horizontal split of the Reindeer names --


CREATE TABLE ReindeerNames(
    RNr int unique not null,
    RName varchar(255),

    PRIMARY KEY (RNr), 
    foreign key (RNr) REFERENCES Reindeer(Nr)
 

)ENGINE=INNODB; 

-- Join of the Reindeers who has won prices--

CREATE TABLE ReindeerHasTrophy(
    TReindeerNr int unique not null,
    ReindeerName varchar(255),
    TReindeerTitle varchar(255),
    TrophyOccation DATE,

    FOREIGN KEY(TReindeerNr) REFERENCES Reindeer(Nr),
    FOREIGN KEY(TReindeerNr, TrophyOccation) REFERENCES Trophy(ReindeerNr, Occation),
    PRIMARY KEY(TReindeerNr, TReindeerTitle)
    

)ENGINE=INNODB;


CREATE TABLE data_log_ReindeerChanges(
    id int unsigned NOT NULL auto_increment,
    logData varchar(255) NOT NULL,
    Username varchar(255) NOT NULL,
    timeOccured TIMESTAMP,
    PRIMARY KEY(id) 
)ENGINE=INNODB;


-- START OF INDEXES --
CREATE INDEX TrophyList ON Trophy(Title);

-- END OF TABLES --


-- START OF TRIGGERS restricting jobs --

DELIMITER $$
CREATE TRIGGER tr_invokeInsert_reindeerDupe
BEFORE INSERT ON WorkReindeer
FOR EACH ROW 
    BEGIN
        IF ((SELECT RetiredReindeer.ReindeerNr FROM RetiredReindeer) = NEW.ReindeerNr) THEN
            SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is pensionized';
        END IF;
    END$$


CREATE TRIGGER tr_invokeUpdate_reindeerDupe
BEFORE UPDATE ON WorkReindeer
FOR EACH ROW 
    BEGIN
        IF ((SELECT RetiredReindeer.ReindeerNr FROM RetiredReindeer) = NEW.ReindeerNr) THEN
            SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Reindeer is pensionized';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$


-- START OF TRIGGER FOR SlädeNamn --


DELIMITER $$
CREATE TRIGGER tr_invokeError_sleighName
BEFORE INSERT ON Sleigh
FOR EACH ROW
    BEGIN
        IF (new.SleighName = "Brynolf") OR (new.SleighName = "Rudolf") THEN
            SIGNAL sqlstate '46000' SET MESSAGE_TEXT = 'Sleigh name cannot be Brynolf or Rudolf!';
        END IF;
    END$$


-- TRIGGERS For VG -- 

CREATE TRIGGER tr_invokeInsert_reindeerHasTrophyDupe
BEFORE INSERT ON ReindeerHasTrophy
FOR EACH ROW
    BEGIN
        IF EXISTS (SELECT TReindeerTitle FROM ReindeerHasTrophy WHERE TReindeerTitle = NEW.TReindeerTitle 
        AND TrophyOccation = NEW.TrophyOccation) THEN
        SIGNAL sqlstate '47000'
        SET MESSAGE_TEXT = 'That title has already been distributed that day!';
        END IF;
    END $$


CREATE TRIGGER tr_invokeLogging_reindeerStatusChange
AFTER DELETE ON WorkReindeer
FOR EACH ROW
    BEGIN
        INSERT INTO data_log_ReindeerChanges(logData, Username, timeOccured)
        VALUES(CONCAT(('Deleted: ', ReindeerNr, @logData)), 'Santa', CURRENT_TIMESTAMP());
    END$$

DELIMITER ;

-- END OF TRIGGERS --

-- START OF VIEWS --


-- START OF VIEW for showing Reindeers that are in a group --

CREATE VIEW ShowReindeersInGroups AS
SELECT Reindeer.Nr AS 'ReindeerNr', Reindeer.ReindeerName, GroupOfReindeers.GroupNr
FROM Reindeer INNER JOIN GroupOfReindeers
ON Reindeer.GroupBellonging = GroupOfReindeers.GroupNr 
ORDER BY GroupOfReindeers.GroupNr ASC;


-- START OF VIEW for listing WorkReindeers and their salaries --


CREATE VIEW ListSalaries AS
SELECT  ReindeerNames.RNr AS 'Nr', ReindeerNames.RName AS 'Name', WorkReindeer.Salary
FROM ReindeerNames INNER JOIN WorkReindeer
ON ReindeerNames.RNr = WorkReindeer.ReindeerNr;


CREATE VIEW ViewGroups AS
SELECT ReindeerNames.RNr AS 'Nr', ReindeerNames.RName AS 'Name', GroupOfReindeers.GroupNr
FROM ReindeerNames INNER JOIN GroupOfReindeers
ON ReindeerNames.RNr = GroupOfReindeers.ReindeerNr;

-- END OF VIEWS --


-- START OF Procedures --


-- START OF PROCEDURE for Transfering WorkReindeer to PensionedReindeer --

DELIMITER $$
CREATE PROCEDURE Retire_a_Reindeer(RNr INTEGER, PBNr INTEGER, FName VARCHAR(255), TValue VARCHAR(255))
    BEGIN
        INSERT INTO RetiredReindeer(ReindeerNr, PölsaburkNr, FactoryName, Taste)
        VALUES(RNr, PBNr, FName, TValue); 
        DELETE FROM WorkReindeer WHERE ReindeerNr = RNr;
    END$$


-- START OF PROCEDURE for Show salary of the WorkingReindeers  --

CREATE PROCEDURE ListOfSalary()
    BEGIN
        SELECT * FROM ListSalaries;
    END$$


-- START OF PROCEDURE for Show Reindeers in your own group --

CREATE PROCEDURE WhosInMyGroup(RNr INTEGER, RName VARCHAR(255))
    BEGIN
        SELECT * FROM ViewGroups 
        WHERE ViewGroups.GroupNr = (SELECT GroupNr FROM GroupOfReindeers WHERE ReindeerNr = RNr);
    END$$

DELIMITER ;





-- END OF PROCEDURES --



-- START OF INSERTS --

-- Reindeers --
INSERT INTO Reindeer(Nr, ClanName, Subspecies, ReindeerName, Stink, Region, GroupBellonging)
VALUES (1, 'Huzars', 'pearyi', 'ReindeerMome', 'tolererbar', 'Norr',1);

INSERT INTO Reindeer(Nr, ClanName, Subspecies, ReindeerName, Stink, Region, GroupBellonging)
VALUES (2, 'buskensis', 'pearyi', 'Gandalf', 'YUCK', 'Syd',5);

INSERT INTO Reindeer(Nr, ClanName, Subspecies, ReindeerName, Stink, Region, GroupBellonging)
VALUES (3, 'caboti', '100Grabb', 'Flacco', 'YUCK', 'Syd', 1);

INSERT INTO Reindeer(Nr, ClanName, Subspecies, ReindeerName, Stink, Region, GroupBellonging)
VALUES (4, 'dawsoni', 'tarandus', 'Simsalabim', 'så man svimmar', 'Öst', 7);

-- WorkReindeer --


INSERT INTO WorkReindeer(ReindeerNr, Salary)
VALUES(1, 1000);

INSERT INTO WorkReindeer(ReindeerNr, Salary)
VALUES(2, 2002);

INSERT INTO WorkReindeer(ReindeerNr, Salary)
VALUES(3, 200);


-- RetiredReindeer -- 
INSERT INTO RetiredReindeer(ReindeerNr, PölsaburkNr, FactoryName, Taste)
VALUES (2, 100, 'Scan', 'Kanel');


-- TEST IF TRIGGERS FIRE --
/*
INSERT INTO WorkReindeer(ReindeerNr, Salary)
VALUES (2, 3000);

INSERT INTO Sleigh(Nr, SleighName, Manifactor, StepLenght, Capacity)
VALUES (1, 'Rudolf', 'Mercedes', 2, 500);
*/

-- ReindeerNames --

INSERT INTO ReindeerNames(RNr, RName)
VALUES(1, 'ReindeerMome');

INSERT INTO ReindeerNames(RNr, RName)
VALUES(2, 'Gandalf');

INSERT INTO ReindeerNames(RNr, RName)
VALUES(3, 'Flacco');

INSERT INTO ReindeerNames(RNr, RName)
VALUES(4, 'Simsalabim');
/*
INSERT INTO RetiredReindeer(ReindeerNr, PölsaburkNr, FactoryName, Taste)
        VALUES(3, 200, 'Findus', 'Mild'); 
*/
-- GroupOfReindeers--

INSERT INTO GroupOfReindeers(ReindeerNr, ReindeerName, GroupNr, Capacity, Quantity, Share)
VALUES(1, 'ReindeerMome', 1, 33, 1, 1.2);

INSERT INTO GroupOfReindeers(ReindeerNr, ReindeerName, GroupNr, Capacity, Quantity, Share)
VALUES(4,'Simsalabim', 7, 14, 2, 23.1);

INSERT INTO GroupOfReindeers(ReindeerNr, ReindeerName, GroupNr, Capacity, Quantity, Share)
VALUES(3, 'Flacco', 1, 2, 11, 1.2);
-- END OF INSERTS --




-- START OF Procedure Calls --
/*
call Retire_a_Reindeer(3, 200, 'Findus', 'Mild');
*/
call ListOfSalary();


-- START OF SELECT Queries --

SELECT * FROM ReindeerNames;

SELECT * FROM ShowReindeersInGroups;

SELECT * FROM RetiredReindeer;

SHOW INDEXES FROM ReindeerNames;

SELECT * FROM data_log_ReindeerChanges;

call WhosInMyGroup(1, 'ReindeerMome'); 

-- END OF SELECT Queries --

-- END OF Procedure Calls --