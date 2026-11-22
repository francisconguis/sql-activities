-- 1. Create database EXER0927
CREATE DATABASE IF NOT EXISTS EXER0927;
USE EXER0927;

-- 3. Alter the tables to make data type/size as follows
ALTER TABLE Customer_T
    MODIFY Cust_ID INT PRIMARY KEY,
    MODIFY Cust_Name VARCHAR(30),
    MODIFY Order_ID INT,
    MODIFY Sman_ID INT;

ALTER TABLE Salesman_T
    MODIFY Sman_ID INT PRIMARY KEY,
    MODIFY Sman_Name VARCHAR(30);
    
-- 4. Copy Customer_T to custhist
CREATE TABLE custhist AS
SELECT * FROM Customer_T;

-- 5. Delete All Contents of custhist
TRUNCATE TABLE custhist;

-- 6. Add an Auto-Incrementing Primary Key to custhist
ALTER TABLE custhist
    ADD COLUMN Hist_ID INT AUTO_INCREMENT PRIMARY KEY;
    
-- 7. Create Delete Trigger TR_DelCust
DELIMITER |

CREATE TRIGGER TR_DelCust
AFTER DELETE ON Customer_T
FOR EACH ROW
BEGIN
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date)
    VALUES (OLD.Cust_ID, OLD.Cust_Name, OLD.Order_ID, OLD.Purchase_Amt, OLD.Sman_ID, OLD.Purch_Date);
END |

DELIMITER 

-- 8. Create Stored Procedure SP_DelCust and Execute
DELIMITER |

CREATE PROCEDURE SP_DelCust(IN p_cust_id INT)
BEGIN
    DELETE FROM Customer_T WHERE Cust_ID = p_cust_id;
END |

DELIMITER ;

-- Test execution (e.g., deleting Cust_ID = 2)
CALL SP_DelCust(2);

-- Verify tables
SELECT * FROM Customer_T;
SELECT * FROM custhist;

-- 9. Revise SP_DelCust with Explicit Transaction Control (Commit if Purch_Date < 2020, else Rollback)
DROP PROCEDURE IF EXISTS SP_DelCust;

DELIMITER |

CREATE PROCEDURE SP_DelCust(IN p_cust_id INT)
BEGIN
    DECLARE v_purch_year INT;

    SELECT YEAR(Purch_Date) INTO v_purch_year
    FROM Customer_T
    WHERE Cust_ID = p_cust_id;

    START TRANSACTION;

    DELETE FROM Customer_T WHERE Cust_ID = p_cust_id;

    IF v_purch_year < 2020 THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END |

DELIMITER ;

-- Test 1: Cust_ID = 3 (Purch_Date is 2012-01-16 -> before 2020 -> COMMITS)
CALL SP_DelCust(3);

-- Test 2: Cust_ID = 1 (Purch_Date is 2021-01-01 -> 2020 or later -> ROLLS BACK)
CALL SP_DelCust(1);

-- Verify tables (Cust_ID 3 is deleted and logged in custhist; Cust_ID 1 remains untouched)
SELECT * FROM Customer_T;
SELECT * FROM custhist;

-- 10. Create Update Trigger TR_UpdCust (Before & After Images) and Update Cust_ID = 10
DELIMITER |

CREATE TRIGGER TR_UpdCust
AFTER UPDATE ON Customer_T
FOR EACH ROW
BEGIN
    -- Before image
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date)
    VALUES (OLD.Cust_ID, OLD.Cust_Name, OLD.Order_ID, OLD.Purchase_Amt, OLD.Sman_ID, OLD.Purch_Date);

    -- After image
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date)
    VALUES (NEW.Cust_ID, NEW.Cust_Name, NEW.Order_ID, NEW.Purchase_Amt, NEW.Sman_ID, NEW.Purch_Date);
END |

DELIMITER ;

-- Execute update
UPDATE Customer_T
SET Purchase_Amt = 500000
WHERE Cust_ID = 10;

-- Verify
SELECT * FROM custhist;

-- 11. Alter custhist to Add Audit Columns (UName, Action_Date, Action)
ALTER TABLE custhist
    ADD COLUMN UName VARCHAR(20),
    ADD COLUMN `date` DATE,
    ADD COLUMN Action CHAR(15);
    
-- 12. Create Insert Trigger TR_InsCust and Insert a Record
DELIMITER |

CREATE TRIGGER TR_InsCust
AFTER INSERT ON Customer_T
FOR EACH ROW
BEGIN
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date, UName, `date`, Action)
    VALUES (NEW.Cust_ID, NEW.Cust_Name, NEW.Order_ID, NEW.Purchase_Amt, NEW.Sman_ID, NEW.Purch_Date, LEFT(USER(), 20), CURDATE(), 'insert');
END |

DELIMITER ;

-- Insert a new test record
INSERT INTO Customer_T (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date)
VALUES (31, 'Dela Pena, Juan M.', 131, 7500, 11, '2026-11-22');

-- Verify
SELECT * FROM custhist;

-- 13. Modify TR_DelCust and TR_UpdCust to Populate the 3 Audit Columns
DROP TRIGGER IF EXISTS TR_DelCust;
DROP TRIGGER IF EXISTS TR_UpdCust;

DELIMITER |

CREATE TRIGGER TR_DelCust
AFTER DELETE ON Customer_T
FOR EACH ROW
BEGIN
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date, UName, `date`, Action)
    VALUES (OLD.Cust_ID, OLD.Cust_Name, OLD.Order_ID, OLD.Purchase_Amt, OLD.Sman_ID, OLD.Purch_Date, LEFT(USER(), 20), CURDATE(), 'delete');
END |

CREATE TRIGGER TR_UpdCust
AFTER UPDATE ON Customer_T
FOR EACH ROW
BEGIN
    -- Before image
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date, UName, `date`, Action)
    VALUES (OLD.Cust_ID, OLD.Cust_Name, OLD.Order_ID, OLD.Purchase_Amt, OLD.Sman_ID, OLD.Purch_Date, LEFT(USER(), 20), CURDATE(), 'update');

    -- After image
    INSERT INTO custhist (Cust_ID, Cust_Name, Order_ID, Purchase_Amt, Sman_ID, Purch_Date, UName, `date`, Action)
    VALUES (NEW.Cust_ID, NEW.Cust_Name, NEW.Order_ID, NEW.Purchase_Amt, NEW.Sman_ID, NEW.Purch_Date, LEFT(USER(), 20), CURDATE(), 'update');
END |

DELIMITER ;

-- Test delete and update
DELETE FROM Customer_T WHERE Cust_ID = 4;

UPDATE Customer_T
SET Purchase_Amt = 15000
WHERE Cust_ID = 11;

-- Verify the 3 new fields are populated
SELECT * FROM custhist;

-- 14. Create View CustSman_V
CREATE OR REPLACE VIEW CustSman_V AS
SELECT 
    s.Sman_Name,
    c.Cust_ID,
    c.Cust_Name,
    c.Order_ID,
    c.Purchase_Amt
FROM Salesman_T s
INNER JOIN Customer_T c ON s.Sman_ID = c.Sman_ID;

-- Verify view
SELECT * FROM CustSman_V;