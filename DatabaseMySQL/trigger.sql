-- Триггеры для БД DB1bit
USE DB1bit;
DELIMITER //


-- -------------------------------------------------------------------------------
-- Триггер, который при удалении компании удаляет также записи из других таблиц *
-- -------------------------------------------------------------------------------
CREATE TRIGGER before_company_delete BEFORE DELETE ON company
FOR EACH ROW
BEGIN
    DELETE FROM checklist_for_company WHERE company_id = OLD.id;
    DELETE FROM company_has_configurations WHERE company_id = OLD.id;
    DELETE FROM type_of_business_has_company WHERE company_id = OLD.id;
    DELETE FROM company_address WHERE company_id = OLD.id;
END//

/* test
SET SQL_SAFE_UPDATES = 0//
SET FOREIGN_KEY_CHECKS=0//
DELETE FROM company WHERE id=1//
SET SQL_SAFE_UPDATES = 1//
SET FOREIGN_KEY_CHECKS=1//

SELECT * FROM checklist_for_company//
SELECT * FROM company_has_configurations//
SELECT * FROM type_of_business_has_company//
SELECT * FROM company_address//
*/


-- ------------------------------------------------------------------------
-- Триггер, который при удалении инфоповода удаляет записи из других таблиц *
-- ------------------------------------------------------------------------
CREATE TRIGGER before_checklist_delete BEFORE DELETE ON checklist
FOR EACH ROW
BEGIN
    DELETE FROM checklist_for_company WHERE checklist_id = OLD.id;
END//

/* test
DELETE FROM checklist WHERE id=5//
SELECT * FROM checklist_for_company//
SELECT * from checklist//
*/

-- -----------------------------------------------------------------------------
-- расчет count, который хранит количество раз, когда инфоповод был согласован *
-- -----------------------------------------------------------------------------
CREATE TRIGGER after_checklist_for_company_insert AFTER INSERT ON checklist_for_company
FOR EACH ROW
BEGIN
    IF NEW.status = 'согласовано' THEN
        UPDATE checklist 
        SET count = IFNULL(count, 0) + 1
        WHERE id = NEW.checklist_id;
    END IF;
END // 