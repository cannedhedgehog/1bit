-- Изначальный файл со всеми запросами, процедурами, триггерами

USE DB1bit;

-- -----------------------------------------------------
-- Запрос компаний по алфавиту *
-- -----------------------------------------------------
SELECT name FROM company ORDER BY name ASC;


DELIMITER //
-- -----------------------------------------------------
-- Запрос компаний по конфигурациям по алфавиту *
-- -----------------------------------------------------
CREATE PROCEDURE request_company_of_conf (configurationsId INT)
BEGIN
	SELECT co.name FROM company co JOIN company_has_configurations chc ON (co.id = chc.company_id) WHERE configurationsId = chc.configurations_id ORDER BY co.name ASC;
END
//

CALL request_company_of_conf(1)//


-- -----------------------------------------------------
-- Запрос компаний по виду деят по алфавиту *
-- -----------------------------------------------------
CREATE PROCEDURE request_company_of_type (typeOfBusinessId INT)
BEGIN
	SELECT co.name FROM company co JOIN type_of_business_has_company tobhc ON (co.id = tobhc.company_id) WHERE typeOfBusinessId = tobhc.type_of_business_id ORDER BY co.name ASC;
END
//

CALL request_company_of_type(3)//


-- -------------------------------------------------------------------------------------------------
-- Запрос краткой информации о компании и о их программе как шпаргалка для заполнения чек-листа * 
-- -------------------------------------------------------------------------------------------------
CREATE PROCEDURE request_brief (companyId INT)
BEGIN
	SELECT co.name, conf.name AS configuration_name, chc.version, chc.update_by, chc.date_of_update, e.name AS equipment, co.server_license, co.maintenance_pc, co.antivirus, 
    cc.name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company_has_configurations chc JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN company co ON (chc.company_id = co.id) JOIN equipment e ON (co.equipment_id = e.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) WHERE companyId = co.id;
END
//

CALL request_brief(2)//


-- -----------------------------------------------------
-- Запрос общей информации о компании *
-- -----------------------------------------------------
CREATE PROCEDURE request_company_info (companyId INT)
BEGIN
	SELECT co.name AS company_name, co.TIN, co.ITS, co.industry, g.name AS group_company, co.staff, co.database_num, co.web, e.name AS equipment, co.taxation_system, co.server_license, co.maintenance_pc, co.antivirus, co.comments, 
    tob.name, conf.name, ca.address, cc.name AS contact_name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company co JOIN group_of_companies g ON (co.group_of_companies_id = g.id) JOIN equipment e ON (co.equipment_id = e.id) JOIN type_of_business_has_company tobhc ON (co.id = tobhc.company_id) 
    JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id) JOIN company_has_configurations chc ON (co.id = chc.company_id) JOIN configurations conf ON (chc.configurations_id = conf.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) 
    WHERE companyId = co.id;
END
//

CALL request_company_info(4)//


-- ---------------------------------------------------------------------------------------------
-- Запрос чек-листа в соответствии с конфигурацией и видом деятельности компании *
-- ---------------------------------------------------------------------------------------------
CREATE PROCEDURE request_checklist(IN companyId INT)
BEGIN
    SELECT c.name AS company_name, ch.title, ch.price_from, ch.price_to FROM checklist ch
    JOIN company c ON c.id = companyId JOIN company_has_configurations chc ON (c.id = chc.company_id)
    JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN type_of_business_has_company tobhc ON (c.id = tobhc.company_id)
    JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id)
    WHERE ch.type_of_business_id = tob.id AND ch.configurations_id = conf.id ORDER BY ch.priority;
END //

CALL request_checklist(2)//


-- -----------------------------------------------------
-- Запрос уже заполенненого чек-листа
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_for_company (companyId INT)
BEGIN
	SELECT * FROM checklist_for_company WHERE companyId = company_id;
END
//

CALL request_checklist_for_company(2)//


-- -----------------------------------------------------
-- запрос всех инфоповодов чек-листа *
-- -----------------------------------------------------
SELECT title FROM checklist//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по алфавиту *
-- -----------------------------------------------------
SELECT title FROM checklist ORDER BY title ASC//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по конфигурациям *
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_of_conf (configurationsId INT)
BEGIN
	SELECT ch.title FROM checklist ch JOIN configurations conf ON (conf.id = ch.configurations_id) WHERE configurationsId = ch.configurations_id ORDER BY ch.title ASC;
END
//

CALL request_checklist_of_conf(1)//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по частоте исполнения *
-- -----------------------------------------------------
SELECT c.title FROM checklist c LEFT JOIN checklist_for_company cfc ON c.id = cfc.checklist_id GROUP BY c.title ORDER BY COUNT(cfc.checklist_id) DESC//


-- -----------------------------------------------------
-- Запрос информации и инфоповоде *
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_info (checklistId INT)
BEGIN
	SELECT title, description, priority, price_from, price_to FROM checklist WHERE checklistId = id;
END
//

CALL request_checklist_info(1)//


-- ------------------------------------------------------------------
-- триггер для обновления чеклиста, если у инфоповода прошел период
-- ------------------------------------------------------------------
CREATE TRIGGER update_status_after_insert AFTER INSERT ON checklist_for_company
FOR EACH ROW
BEGIN
    DECLARE checklist_duration INT;

    SELECT duration INTO checklist_duration FROM checklist WHERE id = NEW.checklist_id;

    IF (NEW.status = 'отказано' OR NEW.status = 'под вопросом') AND  date_end = DATE_ADD(NEW.date_start, INTERVAL checklist_duration MONTH) < NOW() THEN
        UPDATE checklist_for_company
        SET date_end = NEW.date_end
        WHERE checklist_id = NEW.checklist_id;
    END IF;
END
//


-- -----------------------------------------------------
-- Запрос всех сотрудников *
-- -----------------------------------------------------
SELECT name FROM employee//


-- -----------------------------------------------------
-- Запрос всех сотрудников по алфавиту *
-- -----------------------------------------------------
SELECT name FROM employee ORDER BY name ASC//


-- -----------------------------------------------------
-- Запрос информации и сотруднике *
-- -----------------------------------------------------
CREATE PROCEDURE request_employee (employeeId INT)
BEGIN
	SELECT name, role, position, login, password FROM employee WHERE employeeId = id;
END
//


CALL request_employee(1)//


-- ----------------------------------------------------------------------------
-- Триггер, который при удалении компании удаляет также записи из других таблиц
-- ----------------------------------------------------------------------------
CREATE TRIGGER before_company_delete BEFORE DELETE ON company
FOR EACH ROW
BEGIN
    DELETE FROM checklist_for_company WHERE company_id = OLD.id;
    DELETE FROM company_has_configurations WHERE company_id = OLD.id;
    DELETE FROM type_of_business_has_company WHERE company_id = OLD.id;
    DELETE FROM company_address WHERE company_id = OLD.id;
END//

-- ------------------------------------------------------------------------
-- Триггер, который при удалении инфоповода удаляет записи из других таблиц
-- ------------------------------------------------------------------------
CREATE TRIGGER before_checklist_delete AFTER DELETE ON checklist
FOR EACH ROW
BEGIN
    DELETE FROM checklist_for_company WHERE checklist_id = OLD.id;
END//



