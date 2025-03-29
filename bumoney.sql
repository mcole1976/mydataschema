-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.5.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for money
DROP DATABASE IF EXISTS `money`;
CREATE DATABASE IF NOT EXISTS `money` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `money`;

-- Dumping structure for procedure money.AddEntry
DROP PROCEDURE IF EXISTS `AddEntry`;
DELIMITER //
CREATE PROCEDURE `AddEntry`(
	IN `entryDescription` VARCHAR(255),
	IN `entryAmount` DECIMAL(10, 2),
	IN `periodAndDateId` INT
)
BEGIN
    -- Insert new entry into the entry table
    INSERT INTO entry (description, amount)
    VALUES (entryDescription, entryAmount);

    -- Get the last inserted ID for the entry table
    SET @lastEntryId = LAST_INSERT_ID();

    -- Insert into the intermediate table
    INSERT INTO period_entry_intermediatetable (period_and_date_id, entry_id)
    VALUES (periodAndDateId, @lastEntryId);
END//
DELIMITER ;

-- Dumping structure for procedure money.Amend_Cost
DROP PROCEDURE IF EXISTS `Amend_Cost`;
DELIMITER //
CREATE PROCEDURE `Amend_Cost`(
	IN `P_Id` INT,
	IN `P_Cost` DECIMAL(20,6)
)
BEGIN
UPDATE entry SET amount = P_Cost WHERE id = P_id ;
END//
DELIMITER ;

-- Dumping structure for procedure money.Amend_Income
DROP PROCEDURE IF EXISTS `Amend_Income`;
DELIMITER //
CREATE PROCEDURE `Amend_Income`(
	IN `P_Id` INT,
	IN `P_Income` DECIMAL(20,6)
)
BEGIN
UPDATE income SET income = P_Income 
WHERE id = P_Id;
END//
DELIMITER ;

-- Dumping structure for procedure money.Amend_Income_Period_Date
DROP PROCEDURE IF EXISTS `Amend_Income_Period_Date`;
DELIMITER //
CREATE PROCEDURE `Amend_Income_Period_Date`(
	IN `P_Income` DECIMAL(20,6),
	IN `P_Id` INT
)
BEGIN
UPDATE income SET income = P_Income 
WHERE period_and_date_id = P_Id;

END//
DELIMITER ;

-- Dumping structure for procedure money.DeleteIncome
DROP PROCEDURE IF EXISTS `DeleteIncome`;
DELIMITER //
CREATE PROCEDURE `DeleteIncome`(
	IN `P_ID` INT
)
BEGIN
DECLARE i INT; 
SELECT i = i.period_and_date_id FROM income i WHERE i.id = P_ID; 
DELETE FROM income WHERE Id = P_ID; 
DELETE FROM period_and_date WHERE id = i;
END//
DELIMITER ;

-- Dumping structure for procedure money.Delete_Cost
DROP PROCEDURE IF EXISTS `Delete_Cost`;
DELIMITER //
CREATE PROCEDURE `Delete_Cost`(
	IN `P_ID` INT
)
BEGIN
DELETE FROM period_entry_intermediatetable WHERE entry_id = P_Id;
delete from entry WHERE id = P_Id ;
END//
DELIMITER ;

-- Dumping structure for table money.entry
DROP TABLE IF EXISTS `entry`;
CREATE TABLE IF NOT EXISTS `entry` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Description` varchar(20) DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table money.entrydate
DROP TABLE IF EXISTS `entrydate`;
CREATE TABLE IF NOT EXISTS `entrydate` (
  `Id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure money.GetIncomeandCostDataPerMonth
DROP PROCEDURE IF EXISTS `GetIncomeandCostDataPerMonth`;
DELIMITER //
CREATE PROCEDURE `GetIncomeandCostDataPerMonth`()
BEGIN
SELECT pd.id, pd.Period, pe.Description 'time desc' ,e.Id 'Entry_ID', e.Description 'entry DESC', e.amount, i.income
FROM period_and_date pd
INNER JOIN period_entry_intermediatetable pit ON pit.period_and_date_id = pd.id
INNER JOIN entry e ON e.Id = pit.entry_id
INNER JOIN period_description pe ON pe.period = pd.Period
INNER JOIN income i ON i.period_and_date_id = pd.id
  WHERE pd.date  BETWEEN DATE_SUB(CURDATE(), INTERVAL 5 DAY) AND DATE_ADD(CURDATE(), INTERVAL 60 DAY);
END//
DELIMITER ;

-- Dumping structure for procedure money.GetIncomeDataLastMonth
DROP PROCEDURE IF EXISTS `GetIncomeDataLastMonth`;
DELIMITER //
CREATE PROCEDURE `GetIncomeDataLastMonth`()
BEGIN
SELECT pd.id, pd.Date
FROM period_and_date pd
INNER JOIN period_description des ON des.Period = pd.Period
 WHERE pd.date  BETWEEN DATE_SUB(CURDATE(), INTERVAL 5 DAY) AND DATE_ADD(CURDATE(), INTERVAL 60 DAY)
 ORDER BY pd.Date;
END//
DELIMITER ;

-- Dumping structure for procedure money.GetPayPeriodIDandDesc
DROP PROCEDURE IF EXISTS `GetPayPeriodIDandDesc`;
DELIMITER //
CREATE PROCEDURE `GetPayPeriodIDandDesc`()
SELECT i.id, pdesc.Description , pd.date, i.income  FROM 
period_and_date pd
JOIN period_description pdesc ON pdesc.Period = pd.Period 
JOIN income i ON i.period_and_date_id = pd.id
WHERE pd.date between DATE_SUB(CURDATE(), INTERVAL 15 DAY) AND DATE_ADD(CURDATE(), INTERVAL 75 DAY)//
DELIMITER ;

-- Dumping structure for procedure money.GetPeriodAndDate
DROP PROCEDURE IF EXISTS `GetPeriodAndDate`;
DELIMITER //
CREATE PROCEDURE `GetPeriodAndDate`()
BEGIN 
SELECT distinct pd.id, DATE 
FROM period_and_date pd
JOIN income c ON c.period_and_date_id = pd.id
WHERE  pd.date  
BETWEEN DATE_SUB(CURDATE(), INTERVAL 10 DAY) AND DATE_ADD(CURDATE(), INTERVAL 75 DAY);

END//
DELIMITER ;

-- Dumping structure for procedure money.GetPeriodandDateIncome
DROP PROCEDURE IF EXISTS `GetPeriodandDateIncome`;
DELIMITER //
CREATE PROCEDURE `GetPeriodandDateIncome`()
BEGIN

    SELECT pd.id, DATE FROM period_and_date pd 
    Left JOIN income i ON i.period_and_date_id = pd.id
    WHERE i.id IS null;
END//
DELIMITER ;

-- Dumping structure for procedure money.GeTPeriodCostByID
DROP PROCEDURE IF EXISTS `GeTPeriodCostByID`;
DELIMITER //
CREATE PROCEDURE `GeTPeriodCostByID`(
	IN `_ID` INT
)
BEGIN
SELECT i.income AS 'Income', sum(e.Amount ) AS'SummedAmnt'
FROM period_and_date pd
JOIN period_entry_intermediatetable pdi ON pd.id = pdi.period_and_date_id
JOIN entry e ON e.Id = pdi.entry_id
JOIN income i ON i.period_and_date_id = pd.id
WHERE pd.id =  _ID;
END//
DELIMITER ;

-- Dumping structure for procedure money.GetPeriodDescriptions
DROP PROCEDURE IF EXISTS `GetPeriodDescriptions`;
DELIMITER //
CREATE PROCEDURE `GetPeriodDescriptions`()
BEGIN SELECT Period, Description FROM period_description; END//
DELIMITER ;

-- Dumping structure for table money.income
DROP TABLE IF EXISTS `income`;
CREATE TABLE IF NOT EXISTS `income` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `income` decimal(10,2) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `period_and_date_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `period_id` (`period_id`),
  KEY `period_and_date_id` (`period_and_date_id`),
  CONSTRAINT `income_ibfk_1` FOREIGN KEY (`period_id`) REFERENCES `period_description` (`Period`),
  CONSTRAINT `income_ibfk_2` FOREIGN KEY (`period_and_date_id`) REFERENCES `period_and_date` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure money.InsertEntryWithIntermediate
DROP PROCEDURE IF EXISTS `InsertEntryWithIntermediate`;
DELIMITER //
CREATE PROCEDURE `InsertEntryWithIntermediate`(
	IN `p_Description` VARCHAR(50),
	IN `p_Amount` DECIMAL(20,6)
)
    COMMENT 'Insert'
BEGIN

-- Start transaction 
START TRANSACTION; 
-- Insert into Entry table 
INSERT INTO Entry (Description, Amount) VALUES (p_Description, p_Amount); 
-- Get the last inserted ID from Entry table 

-- Insert into LedgerEntry_Intermediate table 

-- Commit transaction 
COMMIT;
END//
DELIMITER ;

-- Dumping structure for procedure money.InsertIncome
DROP PROCEDURE IF EXISTS `InsertIncome`;
DELIMITER //
CREATE PROCEDURE `InsertIncome`(
	IN `amount` DECIMAL(10,2),
	IN `val_period_and_date_Id` INT
)
BEGIN 
DECLARE val_period_id INT; 
-- Retrieve the second FK ID using the first FK ID 
SELECT period INTO val_period_id FROM period_and_date WHERE id = val_period_and_date_Id; 
-- Insert the data into the income table 
INSERT INTO income (income, period_Id, period_and_date_Id) VALUES (amount, val_period_id, val_period_and_date_Id); END//
DELIMITER ;

-- Dumping structure for procedure money.InsertLedger
DROP PROCEDURE IF EXISTS `InsertLedger`;
DELIMITER //
CREATE PROCEDURE `InsertLedger`( IN p_Year INT, IN p_Month INT, IN p_Period INT )
BEGIN INSERT INTO Ledger (Year, Month, Period) VALUES (p_Year, p_Month, p_Period); END//
DELIMITER ;

-- Dumping structure for procedure money.InsertPeriodAndDate
DROP PROCEDURE IF EXISTS `InsertPeriodAndDate`;
DELIMITER //
CREATE PROCEDURE `InsertPeriodAndDate`( IN p_date DATETIME, IN p_period INT )
BEGIN 
INSERT INTO Period_and_Date (date, Period) VALUES (p_date, p_period); 
END//
DELIMITER ;

-- Dumping structure for procedure money.InsertPeriodAndDateWI
DROP PROCEDURE IF EXISTS `InsertPeriodAndDateWI`;
DELIMITER //
CREATE PROCEDURE `InsertPeriodAndDateWI`(
	IN `p_date` DATE,
	IN `p_period` INT,
	IN `p_income` DECIMAL(20,6)
)
BEGIN
INSERT INTO Period_and_Date (date, Period) VALUES (p_date, p_period); 

SET @last_id = LAST_INSERT_ID();

call InsertIncome(p_income,@last_id);
END//
DELIMITER ;

-- Dumping structure for table money.ledger
DROP TABLE IF EXISTS `ledger`;
CREATE TABLE IF NOT EXISTS `ledger` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Year` int(11) DEFAULT NULL,
  `Month` int(11) DEFAULT NULL,
  `Period` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table money.ledgerentry_intermediate
DROP TABLE IF EXISTS `ledgerentry_intermediate`;
CREATE TABLE IF NOT EXISTS `ledgerentry_intermediate` (
  `LedgerID` int(11) DEFAULT NULL,
  `EntryID` int(11) DEFAULT NULL,
  `TimeEntered` datetime DEFAULT NULL,
  KEY `LedgerID` (`LedgerID`),
  KEY `EntryID` (`EntryID`),
  CONSTRAINT `ledgerentry_intermediate_ibfk_1` FOREIGN KEY (`LedgerID`) REFERENCES `ledger` (`Id`),
  CONSTRAINT `ledgerentry_intermediate_ibfk_2` FOREIGN KEY (`EntryID`) REFERENCES `entry` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure money.NextMonthExpenses
DROP PROCEDURE IF EXISTS `NextMonthExpenses`;
DELIMITER //
CREATE PROCEDURE `NextMonthExpenses`()
BEGIN

SELECT p.date, e.Description AS 'Expln', e.Amount, p.Period
FROM period_entry_intermediatetable i
INNER JOIN entry e ON e.id = i.entry_id
INNER JOIN period_and_date p ON p.id = i.period_and_date_id

WHERE p.date between

DATE(DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY)) AND LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 1 MONTH));




END//
DELIMITER ;

-- Dumping structure for procedure money.NextMonthIncome
DROP PROCEDURE IF EXISTS `NextMonthIncome`;
DELIMITER //
CREATE PROCEDURE `NextMonthIncome`()
BEGIN
SELECT p.date, i.income, p.Period FROM income i
INNER JOIN period_and_date p
ON i.period_and_date_id = p.id
WHERE p.date 
BETWEEN DATE(DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY)) AND LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 1 MONTH));
END//
DELIMITER ;

-- Dumping structure for table money.period_and_date
DROP TABLE IF EXISTS `period_and_date`;
CREATE TABLE IF NOT EXISTS `period_and_date` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `Period` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Period` (`Period`),
  CONSTRAINT `period_and_date_ibfk_1` FOREIGN KEY (`Period`) REFERENCES `period_description` (`Period`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table money.period_description
DROP TABLE IF EXISTS `period_description`;
CREATE TABLE IF NOT EXISTS `period_description` (
  `Period` int(11) NOT NULL CHECK (`Period` between 1 and 3),
  `Description` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`Period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table money.period_entry_intermediatetable
DROP TABLE IF EXISTS `period_entry_intermediatetable`;
CREATE TABLE IF NOT EXISTS `period_entry_intermediatetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `period_and_date_id` int(11) DEFAULT NULL,
  `entry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `period_and_date_id` (`period_and_date_id`),
  KEY `entry_id` (`entry_id`),
  CONSTRAINT `period_entry_intermediatetable_ibfk_1` FOREIGN KEY (`period_and_date_id`) REFERENCES `period_and_date` (`id`),
  CONSTRAINT `period_entry_intermediatetable_ibfk_2` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
