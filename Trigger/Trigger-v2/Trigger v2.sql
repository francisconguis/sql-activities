-- Part 1: Tables, Seed Data, and Trigger
-- 1. Create Tables and Populate Room
CREATE DATABASE IF NOT EXISTS RoomDB;
USE RoomDB;

CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    Category CHAR(10) CHECK (Category IN ('Single', 'Twin', 'Studio')),
    RoomDesc VARCHAR(45),
    RoomPrice DECIMAL(10, 2),
    RoomStatus CHAR(2) CHECK (RoomStatus IN ('AV', 'UA'))
);

CREATE TABLE `Transaction` (
    TransID INT AUTO_INCREMENT PRIMARY KEY,
    RoomID INT,
    CheckInOut CHAR(3) CHECK (CheckInOut IN ('In', 'Out')),
    CheckInOutDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

INSERT INTO Room (RoomID, Category, RoomDesc, RoomPrice, RoomStatus) VALUES
(1, 'Single', '1 bedroom, 1 bath', 500.00, 'AV'),
(2, 'Twin',   '2 beds, 1 bath',    300.00, 'AV'),
(3, 'Studio', '1 bed, 1 bath',     200.00, 'AV'),
(4, 'Studio', '1 bed, 1 bath',     200.00, 'AV');

-- 2. Trigger to Automatically Update RoomStatus on Insert
DELIMITER |

CREATE TRIGGER TR_UpdateRoomStatus
AFTER INSERT ON `Transaction`
FOR EACH ROW
BEGIN
    IF NEW.CheckInOut = 'In' THEN
        UPDATE Room
        SET RoomStatus = 'UA'
        WHERE RoomID = NEW.RoomID;
    ELSEIF NEW.CheckInOut = 'Out' THEN
        UPDATE Room
        SET RoomStatus = 'AV'
        WHERE RoomID = NEW.RoomID;
    END IF;
END|

DELIMITER ;

-- Test Part 1
-- 2.1 Check-in Room 1 (sets status to UA)
INSERT INTO `Transaction` (RoomID, CheckInOut) VALUES (1, 'In');
SELECT * FROM Room;

-- 2.2 Check-out Room 1 (sets status back to AV)
INSERT INTO `Transaction` (RoomID, CheckInOut) VALUES (1, 'Out');
SELECT * FROM Room;


-- Part 2: Stored Procedures (Autocommit & Explicit Mode)
-- Version A: Autocommit Mode (SP_InsertTrans_Auto)
DELIMITER |

CREATE PROCEDURE SP_InsertTrans_Auto(
    IN p_room_id INT,
    IN p_checkinout CHAR(3),
    IN p_date DATE
)
BEGIN
    DECLARE v_status CHAR(2);

    SELECT RoomStatus INTO v_status
    FROM Room
    WHERE RoomID = p_room_id;

    IF v_status IS NULL THEN
        SELECT CONCAT('Room id ', p_room_id, ' does not exist.') AS Message;

    ELSEIF p_checkinout = 'In' THEN
        IF v_status = 'AV' THEN
            INSERT INTO `Transaction` (RoomID, CheckInOut, CheckInOutDate)
            VALUES (p_room_id, p_checkinout, IFNULL(p_date, CURDATE()));

            SELECT CONCAT('Room id ', p_room_id, ' has been booked.') AS Message;
        ELSE
            SELECT CONCAT('Room id ', p_room_id, ' is not available. Choose another room') AS Message;
        END IF;

    ELSEIF p_checkinout = 'Out' THEN
        IF v_status = 'UA' THEN
            INSERT INTO `Transaction` (RoomID, CheckInOut, CheckInOutDate)
            VALUES (p_room_id, p_checkinout, IFNULL(p_date, CURDATE()));

            SELECT CONCAT('Room id ', p_room_id, ' is now available.') AS Message;
        ELSE
            SELECT CONCAT('Room id ', p_room_id, ' is already available. No need for a check out') AS Message;
        END IF;

    ELSE
        SELECT 'Invalid CheckInOut value. Use In or Out.' AS Message;
    END IF;
END|

DELIMITER ;

-- Version B: Explicit Transaction Mode (SP_InsertTrans_Explicit)
DELIMITER |

CREATE PROCEDURE SP_InsertTrans_Explicit(
    IN p_room_id INT,
    IN p_checkinout CHAR(3),
    IN p_date DATE
)
BEGIN
    DECLARE v_status CHAR(2);

    START TRANSACTION;

    SELECT RoomStatus INTO v_status
    FROM Room
    WHERE RoomID = p_room_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        ROLLBACK;
        SELECT CONCAT('Room id ', p_room_id, ' does not exist.') AS Message;

    ELSEIF p_checkinout = 'In' THEN
        IF v_status = 'AV' THEN
            INSERT INTO `Transaction` (RoomID, CheckInOut, CheckInOutDate)
            VALUES (p_room_id, p_checkinout, IFNULL(p_date, CURDATE()));

            COMMIT;
            SELECT CONCAT('Room id ', p_room_id, ' has been booked.') AS Message;
        ELSE
            ROLLBACK;
            SELECT CONCAT('Room id ', p_room_id, ' is not available. Choose another room') AS Message;
        END IF;

    ELSEIF p_checkinout = 'Out' THEN
        IF v_status = 'UA' THEN
            INSERT INTO `Transaction` (RoomID, CheckInOut, CheckInOutDate)
            VALUES (p_room_id, p_checkinout, IFNULL(p_date, CURDATE()));

            COMMIT;
            SELECT CONCAT('Room id ', p_room_id, ' is now available.') AS Message;
        ELSE
            ROLLBACK;
            SELECT CONCAT('Room id ', p_room_id, ' is already available. No need for a check out') AS Message;
        END IF;

    ELSE
        ROLLBACK;
        SELECT 'Invalid CheckInOut value. Use In or Out.' AS Message;
    END IF;
END|

DELIMITER ;

-- Test Calls for Part 2
-- 1. Check in Room 2 (AV -> UA, displays booked message)
CALL SP_InsertTrans_Auto(2, 'In', NULL);

-- 2. Try checking in Room 2 again while UA (displays not available message)
CALL SP_InsertTrans_Auto(2, 'In', NULL);

-- 3. Check out Room 2 (UA -> AV, displays now available message)
CALL SP_InsertTrans_Explicit(2, 'Out', CURDATE());

-- 4. Try checking out Room 2 again while already AV (displays already available message)
CALL SP_InsertTrans_Explicit(2, 'Out', CURDATE());

-- Verify final table states
SELECT * FROM Room;
SELECT * FROM `Transaction`;

