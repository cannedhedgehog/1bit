-- Процедуры для БД DB1bit
USE DB1bit;

DELIMITER //

-- -----------------------------------------------------------------------------------------------------------
-- Процедура для вывода краткой информации о компании и их программы как шпаргалка для заполнения чек-листа *
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


-- ------------------------------------------------------------------------------------------------------
-- Процедура для генерации чек-листа для компании в соответствии с конфигурацией и видом деятельности *
-- ------------------------------------------------------------------------------------------------------
CREATE PROCEDURE generating_checklist_OV(IN companyId INT)
BEGIN
	SELECT ch.id, ch.title, ch.description, ch.priority
	FROM checklist ch 
	JOIN company c ON c.id = companyId 
	JOIN company_has_configurations chc ON (c.id = chc.company_id)
	JOIN configurations conf ON (chc.configurations_id = conf.id) 
	JOIN type_of_business_has_company tobhc ON (c.id = tobhc.company_id)
	JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id)
	WHERE ch.type_of_business_id = tob.id AND ch.configurations_id = conf.id AND ch.id NOT IN (SELECT checklist_id FROM checklist_for_company)
	ORDER BY ch.priority DESC 
	LIMIT 5;
END //

CALL generating_checklist_OV(2)// -- пример вызова

/*
INSERT INTO checklist_for_company (company_id, checklist_id, status, final_price, comment, date, employee_id ) VALUE (1,5,'отказано',3000,NULL, current_date(), 1) //
select * from checklist_for_company//
*/


-- --------------------------------------------------
-- Процедура для вывода общей информации о компании *
-- --------------------------------------------------
CREATE PROCEDURE request_company_info (companyId INT)
BEGIN
	SELECT co.name AS company_name, co.TIN, co.ITS, co.industry, g.name AS group_company, co.staff, co.database_num, co.web, e.name AS equipment, co.taxation_system, co.server_license, co.maintenance_pc, co.antivirus, co.comments, 
    tob.name, conf.name, chc.version, chc.update_by, chc.date_of_update, ca.address, cc.name AS contact_name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company co JOIN group_of_companies g ON (co.group_of_companies_id = g.id) JOIN equipment e ON (co.equipment_id = e.id) JOIN type_of_business_has_company tobhc ON (co.id = tobhc.company_id) 
    JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id) JOIN company_has_configurations chc ON (co.id = chc.company_id) JOIN configurations conf ON (chc.configurations_id = conf.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) 
    WHERE companyId = co.id; 
END
//

CALL request_company_info(4)// -- пример вызова


-- -------------------------------------------------
-- Процедура для вывода уже заполеннного чек-листа  *
-- -------------------------------------------------
CREATE PROCEDURE request_checklist_for_company (companyId INT, sstatus VARCHAR(45))
BEGIN
	SELECT * FROM checklist_for_company WHERE companyId = company_id AND sstatus = status; -- можно сделать так чтобы просматривалось все или только те которые были согласованы/отказаны/под вопросом= чтобы менеджер смог добавить в асана
END
//

CALL request_checklist_for_company(1, 'отказано')//


-- -- --------------------------------------------------
-- Запрос информации и сотруднике *
-- -----------------------------------------------------
CREATE PROCEDURE request_employee (employeeId INT)
BEGIN
	SELECT name, department, role, login, password FROM employee WHERE employeeId = id;
END
//

CALL request_employee(1)//


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
SELECT title FROM checklist ORDER BY count DESC//


-- -----------------------------------------------------
-- Запрос информации о инфоповоде *
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_info (checklistId INT)
BEGIN
	SELECT title, description, priority, price_from, price_to FROM checklist WHERE checklistId = id;
END
//

CALL request_checklist_info(1)//


-- ------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- Процедура для обновления чеклиста, если у инфоповода прошел период (удаляет запись из таблицы checklist_for_company) *
-- ---------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE cleanup_expired_checklist_for_company1()
BEGIN
    DELETE cfc FROM checklist_for_company cfc JOIN checklist c ON (cfc.checklist_id = c.id)
    WHERE (cfc.status = 'отказано' OR cfc.status = 'под вопросом' ) AND DATE_ADD(cfc.date, INTERVAL c.duration DAY) < NOW() AND c.onetime_or_periodic = 0;
END //


-- -------------------------------------------------------------------
-- Процедура для обновления чеклиста, если менеджер обнуляет статус
-- -------------------------------------------------------------------
CREATE PROCEDURE cleanup_expired_checklist_for_company2()
BEGIN
    DELETE cfc FROM checklist_for_company cfc JOIN checklist c ON (cfc.checklist_id = c.id)
    WHERE cfc.status = NULL AND cfc.date = NOW();
END //

-- ------------------------------
-- Включаем планировщик событий
-- ------------------------------
SET GLOBAL event_scheduler = ON//

-- -----------------------------------------------------
-- Создаем событие для ежедневного выполнения процедур
-- -----------------------------------------------------
CREATE EVENT IF NOT EXISTS auto_checklist_cleanup ON SCHEDULE EVERY 1 HOUR STARTS CURRENT_TIMESTAMP DO
BEGIN
	CALL cleanup_expired_checklist_for_company1();
	CALL cleanup_expired_checklist_for_company2();
END//
-- --------------------------------------------------------------------------------------------------------------------------

/*  test
INSERT INTO checklist_for_company (company_id, checklist_id, status, final_price, comment, date, employee_id ) VALUE (2,3,'согласовано',1000,NULL, current_date(), 1) //
select * from checklist//
select * from checklist_for_company//
*/
