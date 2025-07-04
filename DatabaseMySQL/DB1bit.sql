SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- DROP DATABASE DB1bit;
CREATE SCHEMA IF NOT EXISTS DB1bit  DEFAULT CHARACTER SET utf8 ;
USE  DB1bit;

-- -----------------------------------------------------
-- Table   employee 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS employee (
  id INT NOT NULL AUTO_INCREMENT KEY,
  name VARCHAR(45) NOT NULL,
  role VARCHAR(45) NOT NULL,
  position VARCHAR(45) NOT NULL,
  login VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL);


-- -----------------------------------------------------
-- Table   configurations 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS configurations (
   id INT NOT NULL AUTO_INCREMENT KEY,
   name  VARCHAR(45) NOT NULL);


-- -----------------------------------------------------
-- Table   type_of_business 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS type_of_business  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   name  VARCHAR(45) NOT NULL);


-- -----------------------------------------------------
-- Table   checklist 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS checklist  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   title  VARCHAR(45) NOT NULL,
   description  VARCHAR(200) NULL,
   priority  BOOLEAN NOT NULL,
   price_from  INT NOT NULL,
   price_to  INT NOT NULL,
   configurations_id  INT NOT NULL,
   type_of_business_id  INT NOT NULL,
   duration  INT NOT NULL,
   
   FOREIGN KEY ( configurations_id ) REFERENCES   configurations  ( id ),
   FOREIGN KEY ( type_of_business_id ) REFERENCES   type_of_business  ( id ));


-- -----------------------------------------------------
-- Table   group_of_companies 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS group_of_companies  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   name  VARCHAR(45) NOT NULL);


-- -----------------------------------------------------
-- Table   equipment 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS equipment  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   name  VARCHAR(45) NOT NULL,
   period  INT NOT NULL);


-- -----------------------------------------------------
-- Table   company 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS company  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   name  VARCHAR(45) NOT NULL,
   TIN  BIGINT NOT NULL,
   ITS  VARCHAR(45) NULL,
   industry  VARCHAR(45) NULL,
   group_of_companies_id  INT NULL,
   staff  INT NOT NULL,
   database_num  INT NOT NULL,
   web  VARCHAR(45) NULL,
   equipment_id  INT NOT NULL,
   taxation_system  VARCHAR(45) NULL,
   server_license  VARCHAR(45) NULL,
   maintenance_pc  VARCHAR(45) NULL,
   antivirus  VARCHAR(45) NULL,
   comments  VARCHAR(200) NULL,
   date  DATE NOT NULL,
   employee_id  INT NOT NULL,
   
   FOREIGN KEY ( group_of_companies_id ) REFERENCES   group_of_companies  ( id ),
   FOREIGN KEY ( employee_id ) REFERENCES   employee  ( id ),
   FOREIGN KEY ( equipment_id ) REFERENCES   equipment  ( id ));


-- -----------------------------------------------------
-- Table   company_address 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS company_address  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   company_id  INT NOT NULL,
   address  VARCHAR(200) NOT NULL,
   
   FOREIGN KEY ( company_id ) REFERENCES   company  ( id ));


-- -----------------------------------------------------
-- Table   company_contact 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS   company_contact  (
   id  INT NOT NULL AUTO_INCREMENT KEY,
   company_address_id  INT NOT NULL,
   name  VARCHAR(45) NOT NULL,
   position  VARCHAR(45) NOT NULL,
   phone_number  VARCHAR(45) NOT NULL,
   email  VARCHAR(45) NOT NULL,
   city  VARCHAR(45) NOT NULL,
   work_day_of_week  VARCHAR(45) NOT NULL,
   work_time_from  TIME NOT NULL,
   work_time_to  TIME NOT NULL,
   
   FOREIGN KEY ( company_address_id ) REFERENCES   company_address  ( id ));


-- -----------------------------------------------------
-- Table   checklist_for_company 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS   checklist_for_company  (
   company_id  INT NOT NULL,
   checklist_id  INT NOT NULL,
   status  VARCHAR(45),
   comment  VARCHAR(45) NULL,
   date  DATE NOT NULL,
   employee_id  INT NOT NULL,
   
   FOREIGN KEY ( employee_id ) REFERENCES   employee  ( id ));


-- -----------------------------------------------------
-- Table   company_has_configurations 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS   company_has_configurations  (
   company_id  INT NOT NULL,
   configurations_id  INT NOT NULL,
   version  FLOAT NOT NULL,
   update_by  VARCHAR(45) NOT NULL,
   date_of_update  DATE NOT NULL,
   users_col  INT NOT NULL,
   
   FOREIGN KEY ( company_id ) REFERENCES   company  ( id ),
   FOREIGN KEY ( configurations_id ) REFERENCES   configurations  ( id ));


-- -----------------------------------------------------
-- Table   type_of_business_has_company 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS   type_of_business_has_company  (
   company_id  INT NOT NULL,
   type_of_business_id  INT NOT NULL,

   FOREIGN KEY ( type_of_business_id ) REFERENCES   type_of_business  ( id ),
   FOREIGN KEY ( company_id ) REFERENCES   company  ( id ));


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table   employee 
-- -----------------------------------------------------
INSERT INTO   employee  (name ,  role ,  position ,  login ,  password ) VALUES 
('сотрудник1', 'СОВ', 'сотрудник', 'empl1', '1234'),
('сотрудник2', 'СОВ', 'сотрудник', 'empl2', '4321'),
('сотрудник3', 'МОС', 'менеджер', 'empl3', '1111');
 


-- -----------------------------------------------------
-- Data for table   configurations 
-- -----------------------------------------------------
 
INSERT INTO   configurations  ( name ) VALUES 
( 'конфигурация1'),
( 'конфигурация2'),
( 'конфигурация3');
 


-- -----------------------------------------------------
-- Data for table   type_of_business 
-- -----------------------------------------------------
 
INSERT INTO   type_of_business  (  name ) VALUES 
( 'вид_деят1'),
( 'вид_деят2'),
( 'вид_деят3');
 


-- -----------------------------------------------------
-- Data for table   checklist 
-- -----------------------------------------------------
 
INSERT INTO   checklist  (  title ,  description ,  priority ,  price_from ,  price_to ,  configurations_id ,  type_of_business_id ,  duration ) VALUES 
( 'инфоповод1', 'описание1', 1, 1500, 5000, 1, 1, 6),
( 'инфоповод2', 'описание2', 0, 3000, 5000, 1, 3, 12),
( 'инфоповод3', 'описание3', 1, 1000, 4000, 3, 3, 6),
( 'инфоповод4', 'описание4', 0, 2500, 6000, 2, 2, 24);
 
INSERT INTO   checklist  (  title ,  description ,  priority ,  price_from ,  price_to ,  configurations_id ,  type_of_business_id ,  duration ) VALUES  ( 'инфоповод5', 'описание5', 0, 2500, 6000, 1, 1, 24);

-- -----------------------------------------------------
-- Data for table   group_of_companies 
-- -----------------------------------------------------
 
INSERT INTO   group_of_companies  (  name ) VALUES 
( 'group1'),
( 'group2'),
( 'group3');
 


-- -----------------------------------------------------
-- Data for table   equipment 
-- -----------------------------------------------------
 
INSERT INTO   equipment  (  name ,  period ) VALUES 
( 'касса1', 3),
( 'касса2', 3),
( 'касса3', 6);
 


-- -----------------------------------------------------
-- Data for table   company 
-- -----------------------------------------------------
 
INSERT INTO   company  (  name ,  TIN ,  ITS ,  industry ,  group_of_companies_id ,  staff ,  database_num ,  web ,  equipment_id ,  taxation_system ,  server_license ,  maintenance_pc ,  antivirus ,  comments ,  version ,  date ,  employee_id ) VALUES 
( 'компания а', 2222058686, 'проф', 'категория1', 1, 40, 2, 'маркетплейс', 3, 'ОСН', 'сервер 1с', 'сисадмин', 'касперского', 'пометка1', 1, '2025-06-30', 3),
( 'компания б', 1234567890, 'бюджет', NULL, 2, 25, 1, 'маркетплейс', 2, 'ОСН', 'сервер 1с', 'сисадмин', 'касперского', 'пометка2', 1, '2025-06-30', 3),
( 'компания в', 0987654321, 'отраслевойй', NULL, 3, 50, 2, 'сайт', 1, 'УСН', 'сервер 1с', 'обслуживается в компании', 'доктор веб', NULL, 1, '2025-06-30', 3),
( 'компания г', 5138651648, 'ритейл', 'категория4', 1, 30, 1, 'сайт', 1, 'УСН', 'мини сервер', 'приходящий', NULL, 'пометка4', 1, '2025-06-30', 3);
 


-- -----------------------------------------------------
-- Data for table   company_address 
-- -----------------------------------------------------
 
INSERT INTO   company_address  (  company_id ,  address ) VALUES 
( 1, 'Владивосток Гоголя 41 оф 1312'),
( 1, 'Уссурийск Кирова 16 оф 1'),
( 2, 'Хабаровск Лермонтова 150 оф 233'),
( 3, 'Находка Чапаева 5 оф 45'),
( 4, 'Владивосток Проспект красного знамени 59 оф 23');
 


-- -----------------------------------------------------
-- Data for table   company_contact 
-- -----------------------------------------------------
 
INSERT INTO   company_contact  (  company_address_id ,  name ,  position ,  phone_number ,  email ,  city ,  work_day_of_week ,  work_time_from ,  work_time_to ) VALUES 
( 1, 'ФИО1', 'Менеджер', 79681545288, 'mail.ru', 'Владивосток', 'пн-пт', '09:00:00', '19:00:00'),
( 2, 'ФИО2', 'Руководитель отдела продаж', 79681545288, 'mail.ru', 'Уссурийск', 'пн-пт', '09:00:00', '17:00:00'),
( 3, 'ФИО3', 'Менеджер', 79681545288, 'mail.ru', 'Хабаровск', 'пн-сб', '10:00:00', '14:00:00'),
( 4, 'ФИО4', 'Сотрудник отдела продаж', 79681545288, 'mail.ru', 'Находка', 'пн-сб', '11:00:00', '17:00:00'),
( 5, 'ФИО5', 'Руководитель отдела продаж', 79681545288, 'mail.ru', 'Владивосток', 'пн-вс', '14:00:00', '18:00:00');
 


-- -----------------------------------------------------
-- Data for table   company_has_configurations 
-- -----------------------------------------------------
 
INSERT INTO   company_has_configurations  ( company_id ,  configurations_id ,  version ,  update_by ,  date_of_update ,  users_col ) VALUES 
(1, 1, 1.5, 'сисадмин', '2024-12-05', 20),
(2, 1, 2.0, 'сисадмин', '2025-01-12', 30),
(3, 3, 1.0, 'мы', '2025-02-02', 20),
(4, 2, 5.5, 'сами', '2025-06-18', 5);
 


-- -----------------------------------------------------
-- Data for table   type_of_business_has_company 
-- -----------------------------------------------------
 
INSERT INTO   type_of_business_has_company  ( company_id ,  type_of_business_id ) VALUES 
(1, 1),
(2, 3),
(3, 3),
(4, 2);
 

/*
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM company WHERE id = 1;
SELECT * FROM checklist_for_company;
SELECT * FROM company_has_configurations;

SELECT * FROM type_of_business_has_company;
SELECT * FROM company_address;
*/
