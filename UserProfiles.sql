use a20muhal;

-- Users and their privileges -- 

-- Santa --
CREATE USER 'Santa'@'localhost' IDENTIFIED BY 'Northpole';

GRANT ALL PRIVILIGES ON a20muhal.* TO 'Santa'@'localhost';

-- Reindeer User -- 

GRANT SELECT ON a20muhal.VIEW TO 'a20muhalSanta'@'localhost';

GRANT SELECT ON a20muhal.PROCEDURE TO 'a20muhalSanta'@'localhost';