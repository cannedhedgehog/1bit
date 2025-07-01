USE DB1bit;

-- -----------------------------------------------------
-- Запрос компаний по алфавиту
-- -----------------------------------------------------
SELECT name FROM company ORDER BY name ASC;


DELIMITER //
-- -----------------------------------------------------
-- Запрос компаний по конфигурациям по алфавиту
-- -----------------------------------------------------
CREATE PROCEDURE request_company_of_conf (configurationsId INT)
BEGIN
	SELECT co.name FROM company co JOIN company_has_configurations chc ON (co.id = chc.company_id) WHERE configurationsId = chc.configurations_id ORDER BY co.name ASC;
END
//

CALL request_company_of_conf(1)//


-- -----------------------------------------------------
-- Запрос компаний по виду деят по алфавиту
-- -----------------------------------------------------
CREATE PROCEDURE request_company_of_type (typeOfBusinessId INT)
BEGIN
	SELECT co.name FROM company co JOIN type_of_business_has_company tobhc ON (co.id = tobhc.company_id) WHERE typeOfBusinessId = tobhc.type_of_business_id ORDER BY co.name ASC;
END
//

CALL request_company_of_type(3)//


-- ----------------------------------------------------------------------------------------------
-- Запрос краткой информации о компании и о их программе как шпаргалка для заполнения чек-листа
-- ----------------------------------------------------------------------------------------------
CREATE PROCEDURE request_brief (companyId INT)
BEGIN
	SELECT co.name, conf.name AS configuration_name, chc.version, chc.update_by, chc.date_of_update, e.name AS equipment, co.server_license, co.maintenance_pc, co.antivirus, 
    cc.name, cc.position, cc.phone_number, cc.email, cc.city, cc.work_day_of_week, cc.work_time_from, cc.work_time_to 
    FROM company_has_configurations chc JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN company co ON (chc.company_id = co.id) JOIN equipment e ON (co.equipment_id = e.id) 
    JOIN company_address ca ON (co.id = ca.company_id) JOIN company_contact cc ON (ca.id = cc.company_address_id) WHERE companyId = co.id;
END
//

CALL request_brief(2)//


-- ---------------------------------------------------------------------------------------------
-- Запрос чек-листа в соответствии с конфигурацией и видом деятельности компании для сотрудника
-- ---------------------------------------------------------------------------------------------
CREATE PROCEDURE request_checklist(IN companyId INT)
BEGIN
    SELECT c.name AS company_name, ch.title, ch.price_from, ch.price_to FROM checklist ch
    JOIN company c ON c.id = companyId JOIN company_has_configurations chc ON (c.id = chc.company_id)
    JOIN configurations conf ON (chc.configurations_id = conf.id) JOIN type_of_business_has_company tobhc ON (c.id = tobhc.company_id)
    JOIN type_of_business tob ON (tobhc.type_of_business_id = tob.id)
    WHERE ch.type_of_business_id = tob.id AND ch.configurations_id = conf.id;
END //

CALL request_checklist(1)//


-- -----------------------------------------------------
-- Запрос общей информации о компании
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


-- -----------------------------------------------------
-- Запрос журнала 
-- -----------------------------------------------------
CREATE PROCEDURE request_checklist_for_company (companyId INT)
BEGIN
	SELECT * FROM checklist_for_company WHERE companyId = company_id; -- надо добавить группировку по заявкам компании 
END
//

CALL request_checklist_for_company(1)//



-- надо написать триггер которые обновляет чеклист если у инфоповода прошел период

-- -----------------------------------------------------
-- запрос всех инфоповодов чек-листа
-- -----------------------------------------------------
SELECT name FROM checklist//


-- -----------------------------------------------------
-- Запрос инфоповодов чек-листа по алфавиту
-- -----------------------------------------------------
SELECT name FROM checklist ORDER BY name ASC//


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


-- -----------------------------------------------------
-- Запрос информации и инфоповоде
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Запрос всех сотрудников
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Запрос всех сотрудников по алфавиту
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Запрос информации и сотруднике
-- -----------------------------------------------------

-- статистика по group by и having 
