use a20muhal;

-- Users and their privileges -- 

-- Santa --
CREATE USER 'Santa'@'localhost' IDENTIFIED BY 'Northpole';

GRANT ALL PRIVILIGES ON a20muhal.* TO 'Santa'@'localhost';

-- Reindeer User -- 
CREATE USER 'Reindeer'@'localhost' IDENTIFIED BY 'Northpole';

GRANT EXECUTE ON a20muhal.WhosInMyGroup TO 'a20muhalReindeer'@'localhost';

