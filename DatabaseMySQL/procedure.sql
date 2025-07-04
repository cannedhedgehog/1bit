-- Процедуры для БД DB1bit
USE DB1bit;

DELIMITER //

-- -----------------------------------------------------------------------------------------------------------
-- Процедура для вывода краткой информации о компании и их программы как шпаргалка для заполнения чек-листа 
-- -----------------------------------------------------------------------------------------------------------
CREATE PROCEDURE request_brief (companyId INT)
BEGIN
	SELECT co.name, conf.name AS configuration_name, chc.version, chc.update_by, chc.date_of_update, e.name AS equipment, co.server_license, co.maintenance_pc, co.antivirus, 
    cc.name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company_has_configurations chc JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN company co ON (chc.company_id = co.id) JOIN equipment e ON (co.equipment_id = e.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) WHERE companyId = co.id; 
END
//

CALL request_brief(2)// -- пример вызова


-- ---------------------------------------------------------------------------------------------------
-- Процедура для генерации чек-листа для компании в соответствии с конфигурацией и видом деятельности
-- ---------------------------------------------------------------------------------------------------
CREATE PROCEDURE request_checklist(IN companyId INT)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM checklist_for_company WHERE checklist_id = (SELECT id FROM checklist)) THEN
		SELECT c.name AS company_name, ch.title, ch.price_from, ch.price_to FROM checklist ch 
		JOIN company c ON c.id = companyId JOIN company_has_configurations chc ON (c.id = chc.company_id)
		JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN type_of_business_has_company tobhc ON (c.id = tobhc.company_id)
		JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id)
		WHERE ch.type_of_business_id = tob.id AND ch.configurations_id = conf.id ORDER BY ch.priority DESC LIMIT 5;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Этот пункт уже предложен';
	END IF;
END //

CALL request_checklist(2)// -- пример вызова


-- --------------------------------------------------
-- Процедура для вывода общей информации о компании
-- --------------------------------------------------
CREATE PROCEDURE request_company_info (companyId INT)
BEGIN
	SELECT co.name AS company_name, co.TIN, co.ITS, co.industry, g.name AS group_company, co.staff, co.database_num, co.web, e.name AS equipment, co.taxation_system, co.server_license, co.maintenance_pc, co.antivirus, co.comments, 
    tob.name, conf.name, ca.address, cc.name AS contact_name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company co JOIN group_of_companies g ON (co.group_of_companies_id = g.id) JOIN equipment e ON (co.equipment_id = e.id) JOIN type_of_business_has_company tobhc ON (co.id = tobhc.company_id) 
    JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id) JOIN company_has_configurations chc ON (co.id = chc.company_id) JOIN configurations conf ON (chc.configurations_id = conf.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) 
    WHERE companyId = co.id; -- должен вывести актуальную информацию, т.е последнее сохранение/ последнюю версию
END
//

CALL request_company_info(4)// -- пример вызова


-- -------------------------------------------------
-- Процедура для вывода уже заполеннного чек-листа 
-- -------------------------------------------------
CREATE PROCEDURE request_checklist_for_company (companyId INT)
BEGIN
	SELECT * FROM checklist_for_company WHERE companyId = company_id; -- можно сделать так чтобы просматривалось все или только те которые были согласованы= чтобы менеджер смог добавить в асана
END
//

CALL request_checklist_for_company(2)//


-- -- -----------------------------------------------------
-- Запрос информации и сотруднике 
-- -----------------------------------------------------
CREATE PROCEDURE request_employee (employeeId INT)
BEGIN
	SELECT name, role, position, login, password FROM employee WHERE employeeId = id;
END
//

CALL request_employee(1)//


-- -----------------------------------------------------
-- запрос всех инфоповодов чек-листа 
-- -----------------------------------------------------
SELECT title FROM checklist//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по алфавиту 
-- -----------------------------------------------------
SELECT title FROM checklist ORDER BY title ASC//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по конфигурациям 
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_of_conf (configurationsId INT)
BEGIN
	SELECT ch.title FROM checklist ch JOIN configurations conf ON (conf.id = ch.configurations_id) WHERE configurationsId = ch.configurations_id ORDER BY ch.title ASC;
END
//

CALL request_checklist_of_conf(1)//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по частоте исполнения 
-- -----------------------------------------------------
SELECT c.title FROM checklist c LEFT JOIN checklist_for_company cfc ON c.id = cfc.checklist_id GROUP BY c.title ORDER BY COUNT(cfc.checklist_id) DESC//


-- -----------------------------------------------------
-- Запрос информации и инфоповоде 
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_info (checklistId INT)
BEGIN
	SELECT title, description, priority, price_from, price_to FROM checklist WHERE checklistId = id;
END
//

CALL request_checklist_info(1)//


-- ---------------------------------------------------------------------
-- Процедура для обновления чеклиста, если у инфоповода прошел период (удаляет запись из таблицы checklist_for_company)
-- ---------------------------------------------------------------------
CREATE PROCEDURE cleanup_expired_checklist_for_company()
BEGIN
    DELETE cfc FROM checklist_for_company cfc JOIN checklist c ON (cfc.checklist_id = c.id)
    WHERE (cfc.status = 'отказано' OR cfc.status = 'под вопросом') AND DATE_ADD(cfc.date, INTERVAL c.duration DAY) < NOW();
END //

-- ------------------------------
-- Включаем планировщик событий
-- ------------------------------
SET GLOBAL event_scheduler = ON//

-- -----------------------------------------------------
-- Создаем событие для ежедневного выполнения процедуры
-- -----------------------------------------------------
CREATE EVENT IF NOT EXISTS auto_checklist_cleanup ON SCHEDULE EVERY 1 DAY STARTS CURRENT_TIMESTAMP DO
CALL cleanup_expired_checklist_for_company()//

