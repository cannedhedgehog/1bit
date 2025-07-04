-- Триггеры для БД DB1bit
USE DB1bit;
DELIMITER //


-- ----------------------------------------------------------------------------
-- Триггер, который при удалении компании удаляет также записи из других таблиц
-- ----------------------------------------------------------------------------
CREATE TRIGGER before_company_delete BEFORE DELETE ON company
FOR EACH ROW
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
    
    DELETE FROM checklist_for_company WHERE company_id = OLD.id;
    DELETE FROM company_has_configurations WHERE company_id = OLD.id;
    DELETE FROM type_of_business_has_company WHERE company_id = OLD.id;
    DELETE FROM company_address WHERE company_id = OLD.id;
    
    SET FOREIGN_KEY_CHECKS=1;
END//


-- ------------------------------------------------------------------------
-- Триггер, который при удалении инфоповода удаляет записи из других таблиц
-- ------------------------------------------------------------------------
CREATE TRIGGER before_checklist_delete AFTER DELETE ON checklist
FOR EACH ROW
BEGIN
    DELETE FROM checklist_for_company WHERE checklist_id = OLD.id;
END//
