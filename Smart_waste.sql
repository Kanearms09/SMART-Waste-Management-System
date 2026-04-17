DROP TABLE smart_user CASCADE CONSTRAINTS; 
DROP TABLE role CASCADE CONSTRAINTS;  
DROP TABLE home_address CASCADE CONSTRAINTS; 
DROP TABLE zone CASCADE CONSTRAINTS; 
DROP TABLE bin CASCADE CONSTRAINTS; 
DROP TABLE bin_type CASCADE CONSTRAINTS;
DROP TABLE report CASCADE CONSTRAINTS; 
DROP TABLE route CASCADE CONSTRAINTS;
DROP TABLE route_stop CASCADE CONSTRAINTS;
DROP TABLE vehicle CASCADE CONSTRAINTS;
DROP TABLE notification CASCADE CONSTRAINTS;

CREATE TABLE role(
    role_id NUMBER(3) PRIMARY KEY,
    role_name VARCHAR2(15) NOT NULL,
    description VARCHAR2(50) NOT NULL);

CREATE TABLE zone(
    zone_id NUMBER(5) PRIMARY KEY,
    zone_name VARCHAR2(30) NOT NULL,
    region VARCHAR2(20) NOT NULL,
    description VARCHAR2(100) NOT NULL);

CREATE TABLE home_address(
    address_id NUMBER(4) PRIMARY KEY,
    zone_id NUMBER(5) REFERENCES zone(zone_id) NOT NULL,
    street VARCHAR2(50) NOT NULL,
    city VARCHAR2(20) NOT NULL,
    postcode VARCHAR2(10) NOT NULL,
    latitude VARCHAR2(15) NOT NULL,
    longitude VARCHAR2(15) NOT NULL);

CREATE TABLE vehicle(
    vehicle_id NUMBER(4) PRIMARY KEY,
    license_plate VARCHAR2(10) NOT NULL,
    capacity NUMBER(4),
    fuel_type VARCHAR2(10),
    status VARCHAR2(15) NOT NULL);

CREATE TABLE smart_user(
    user_id NUMBER(3) PRIMARY KEY, 
    role_id NUMBER(3) REFERENCES role(role_id) NOT NULL,
    address_id NUMBER(4) REFERENCES home_address(address_id) NOT NULL,
    forename VARCHAR2(25) NOT NULL,
    surname VARCHAR2(25) NOT NULL, 
    DOB DATE NOT NULL, 
    email VARCHAR2(30) NOT NULL,
    phone_number VARCHAR2(15) NOT NULL,
    password VARCHAR2(25) NOT NULL);

CREATE TABLE bin_type(
    bin_type_id NUMBER(3) PRIMARY KEY,
    type_name VARCHAR2(20) NOT NULL,
    description VARCHAR2(50) NOT NULL,
    colour_code VARCHAR2(10) NOT NULL);

CREATE TABLE bin(
    bin_id NUMBER(4) PRIMARY KEY,
    address_id NUMBER(4) REFERENCES home_address(address_id) NOT NULL,
    bin_type_id NUMBER(3) REFERENCES bin_type(bin_type_id) NOT NULL,
    capacity_litre NUMBER(3) NOT NULL,
    status VARCHAR2(11) NOT NULL);

CREATE TABLE report(
    report_id NUMBER(4) PRIMARY KEY,
    bin_id NUMBER(4) REFERENCES bin(bin_id) NOT NULL,
    fill_level NUMBER(3) NOT NULL,
    report_time VARCHAR2(5) NOT NULL,
    status VARCHAR2(10) NOT NULL);

CREATE TABLE route(
    route_id NUMBER(4) PRIMARY KEY,
    zone_id NUMBER(5) REFERENCES zone(zone_id) NOT NULL,
    user_id NUMBER(3) REFERENCES smart_user(user_id) NOT NULL,
    vehicle_id NUMBER(4) REFERENCES vehicle(vehicle_id) NOT NULL,
    assigned_driver_id NUMBER(4) NOT NULL,
    route_date DATE NOT NULL,
    status VARCHAR2(30) NOT NULL);

CREATE TABLE route_stop(
    route_stop_id NUMBER(4) PRIMARY KEY,
    route_id NUMBER(4) REFERENCES route(route_id) NOT NULL,
    bin_id NUMBER(4) REFERENCES bin(bin_id) NOT NULL,
    stop_order NUMBER(4),
    collection_status VARCHAR2(10),
    collection_date DATE,
    collection_time VARCHAR2(10));

CREATE TABLE notification(
    notification_id NUMBER(4) PRIMARY KEY,
    user_id NUMBER(3) REFERENCES smart_user(user_id) NOT NULL,
    type VARCHAR2(20),
    message VARCHAR2(100),
    sent_at DATE,
    read_status VARCHAR2(10) NOT NULL);


-- role data
INSERT INTO role VALUES (100, 'Admin', 'Full system access.');
INSERT INTO role VALUES (101, 'Driver', 'Collects bins and manages routes.');
INSERT INTO role VALUES (102, 'Resident', 'Reports bin issues and receives notifications.');
INSERT INTO role VALUES (103, 'Supervisor', 'Oversees routes, reports and drivers.');


-- zone data
INSERT INTO zone VALUES (10000, 'Central Leeds', 'Leeds', 'City Centre and surrounding commercial district.');
INSERT INTO zone VALUES (10001, 'North Leeds', 'Leeds', 'Residential suburbs north of City Centre.');
INSERT INTO zone VALUES (10002, 'South Leeds', 'Leeds', 'Mixed residential and industrial areas.');
INSERT INTO zone VALUES (10003, 'East Leeds', 'Leeds', 'Dense urban and suburban housing areas.');
INSERT INTO zone VALUES (10004, 'West Leeds', 'Leeds', 'Residential areas and local business districts.');


--home_Address data
-- 40 home addresses inserted
INSERT INTO home_address VALUES (1000,10000,'12 Albion Street','Leeds','LS1 5ER','53.8008','-1.5491');
INSERT INTO home_address VALUES (1001,10000,'24 Boar Lane','Leeds','LS1 5DA','53.7989','-1.5436');
INSERT INTO home_address VALUES (1002,10000,'8 The Headrow','Leeds','LS1 6PU','53.8012','-1.5480');
INSERT INTO home_address VALUES (1003,10004,'17 Kirkstall Road','Leeds','LS3 1LH','53.8035','-1.5701');
INSERT INTO home_address VALUES (1004,10003,'44 Roundhay Road','Leeds','LS8 5AQ','53.8184','-1.5197');
INSERT INTO home_address VALUES (1005,10002,'61 Dewsbury Road','Leeds','LS11 5HZ','53.7873','-1.5538');
INSERT INTO home_address VALUES (1006,10001,'5 Otley Road','Leeds','LS6 2AA','53.8177','-1.5756');
INSERT INTO home_address VALUES (1007,10003,'33 Harehills Lane','Leeds','LS8 5JP','53.8149','-1.5091');
INSERT INTO home_address VALUES (1008,10003,'72 York Road','Leeds','LS9 9DN','53.7990','-1.5007');
INSERT INTO home_address VALUES (1009,10003,'88 Selby Road','Leeds','LS15 7JY','53.7925','-1.4718');
INSERT INTO home_address VALUES (1010,10001,'14 Meanwood Road','Leeds','LS6 4AW','53.8155','-1.5532');
INSERT INTO home_address VALUES (1011,10001,'27 Chapeltown Road','Leeds','LS7 4AB','53.8098','-1.5360');
INSERT INTO home_address VALUES (1012,10001,'3 Hyde Park Corner','Leeds','LS6 1AF','53.8065','-1.5600');
INSERT INTO home_address VALUES (1013,10001,'52 Cardigan Road','Leeds','LS6 3BJ','53.8121','-1.5678');
INSERT INTO home_address VALUES (1014,10004,'90 Burley Road','Leeds','LS3 1JP','53.8068','-1.5665');
INSERT INTO home_address VALUES (1015,10004,'41 Gelderd Road','Leeds','LS12 6AA','53.7962','-1.6033');
INSERT INTO home_address VALUES (1016,10004,'66 Town Street','Leeds','LS12 3AA','53.7991','-1.5902');
INSERT INTO home_address VALUES (1017,10003,'29 Cross Gates Road','Leeds','LS15 7PE','53.8060','-1.4510');
INSERT INTO home_address VALUES (1018,10003,'75 Easterly Road','Leeds','LS8 3AD','53.8201','-1.5075');
INSERT INTO home_address VALUES (1019,10001,'11 Scott Hall Road','Leeds','LS7 3JN','53.8250','-1.5402');
INSERT INTO home_address VALUES (1020,10001,'22 Potternewton Lane','Leeds','LS7 4LW','53.8170','-1.5356');
INSERT INTO home_address VALUES (1021,10001,'49 Headingley Lane','Leeds','LS6 1BL','53.8090','-1.5662');
INSERT INTO home_address VALUES (1022,10000,'60 Woodhouse Lane','Leeds','LS2 9EN','53.8062','-1.5535');
INSERT INTO home_address VALUES (1023,10000,'15 Clay Pit Lane','Leeds','LS2 8AR','53.8029','-1.5444');
INSERT INTO home_address VALUES (1024,10003,'101 Marsh Lane','Leeds','LS9 8RS','53.7964','-1.5322');
INSERT INTO home_address VALUES (1025,10003,'7 Mabgate','Leeds','LS9 7DZ','53.8020','-1.5330');
INSERT INTO home_address VALUES (1026,10000,'88 Regent Street','Leeds','LS2 7QA','53.8033','-1.5375');
INSERT INTO home_address VALUES (1027,10002,'34 Domestic Street','Leeds','LS11 9SG','53.7902','-1.5604');
INSERT INTO home_address VALUES (1028,10002,'53 Holbeck Lane','Leeds','LS11 9UL','53.7885','-1.5552');
INSERT INTO home_address VALUES (1029,10002,'21 Elland Road','Leeds','LS11 8TU','53.7778','-1.5723');
INSERT INTO home_address VALUES (1030,10002,'46 Beeston Road','Leeds','LS11 6AD','53.7824','-1.5631');
INSERT INTO home_address VALUES (1031,10002,'12 Tempest Road','Leeds','LS11 6RD','53.7839','-1.5650');
INSERT INTO home_address VALUES (1032,10002,'77 Belle Isle Road','Leeds','LS10 3ES','53.7680','-1.5321');
INSERT INTO home_address VALUES (1033,10002,'9 Middleton Park Road','Leeds','LS10 3ST','53.7602','-1.5284');
INSERT INTO home_address VALUES (1034,10004,'18 Stanningley Road','Leeds','LS13 4EN','53.8122','-1.6335');
INSERT INTO home_address VALUES (1035,10004,'50 Bradford Road','Leeds','LS28 6DD','53.8044','-1.6712');
INSERT INTO home_address VALUES (1036,10004,'6 Farsley Town Street','Leeds','LS28 5LD','53.8120','-1.6670');
INSERT INTO home_address VALUES (1037,10001,'39 New Road Side','Leeds','LS18 4QD','53.8470','-1.5965');
INSERT INTO home_address VALUES (1038,10001,'82 Harrogate Road','Leeds','LS17 6LY','53.8590','-1.5360');
INSERT INTO home_address VALUES (1039,10001,'13 King Lane','Leeds','LS17 5AX','53.8732','-1.5300');


--vehicle data
INSERT INTO vehicle VALUES (7000,'YK21ABC',1000,'Diesel','Active');
INSERT INTO vehicle VALUES (7001,'LG65KWZ',1200,'Electric','Active');
INSERT INTO vehicle VALUES (7002,'YK22PQR',900,'Diesel','Maintenance');
INSERT INTO vehicle VALUES (7003,'MM59HAM',1100,'Petrol','Active');
INSERT INTO vehicle VALUES (7004,'YK18STU',1000,'Petrol','Out of service');
INSERT INTO vehicle VALUES (7005,'SH67UGC',1250,'Diesel','Active');
INSERT INTO vehicle VALUES (7006,'L99LYD',950,'Petrol','Maintenance');
INSERT INTO vehicle VALUES (7007,'VO11KYV',1150,'Electric','Active');


--smart_user data
--25 users inserted
INSERT INTO smart_user VALUES (10,100,1000,'Chris','Holmes','09/09/1975','Chris.holmes@gmail.com','07123456789','P@ssw0rd01');
INSERT INTO smart_user VALUES (11,101,1001,'Sam','Cook','06/11/1982','Sam.cook@yahoo.com','07987654321','P@ssw0rd02');
INSERT INTO smart_user VALUES (12,102,1002,'Aisha','Khan','03/22/1990','Aisha.khan@gmail.com','07811223344','P@ssw0rd03');
INSERT INTO smart_user VALUES (13,103,1003,'Keira','Turner','12/05/1988','Keira.turner@icloud.com','07766554433','P@ssw0rd04');
INSERT INTO smart_user VALUES (14,102,1004,'Emily','Stuart','07/18/1993','Emily.stuart@gmail.com','07455667788','P@ssw0rd05');
INSERT INTO smart_user VALUES (15,101,1005,'Fred','Smith','03/15/1977','Fred.smith@gmail.com','07333444555','P@ssw0rd06');
INSERT INTO smart_user VALUES (16,102,1006,'Holly','Bartram','11/22/1986','Holly.bartram@gmail.com','07898482818','P@ssw0rd07');
INSERT INTO smart_user VALUES (17,102,1007,'Scarlett','Booth','02/02/1987','Scarlett.booth@gmail.com','07332265254','P@ssw0rd08');
INSERT INTO smart_user VALUES (18,102,1008,'Sheila','Singh','12/15/1995','Sheila.singh@gmail.com','07789840542','P@ssw0rd09');
INSERT INTO smart_user VALUES (19,101,1009,'Tom','Bedford','09/30/1989','Tom.bedford@gmail.com','07123997744','P@ssw0rd10');
INSERT INTO smart_user VALUES (20,103,1010,'Harry','Dean','01/12/1972','Harry.dean@gmail.com','07465464566','P@ssw0rd11');
INSERT INTO smart_user VALUES (21,102,1011,'Olivia','Parker','04/08/1991','Olivia.parker@gmail.com','07411223344','P@ssw0rd12');
INSERT INTO smart_user VALUES (22,101,1012,'Jack','Wilson','08/19/1984','Jack.wilson@yahoo.com','07922334455','P@ssw0rd13');
INSERT INTO smart_user VALUES (23,103,1013,'Grace','Mitchell','02/27/1996','Grace.mitchell@gmail.com','07833445566','P@ssw0rd14');
INSERT INTO smart_user VALUES (24,102,1014,'Ethan','Roberts','10/14/1987','Ethan.roberts@icloud.com','07744556677','P@ssw0rd15');
INSERT INTO smart_user VALUES (25,101,1015,'Sophie','Campbell','06/03/1992','Sophie.campbell@gmail.com','07355667788','P@ssw0rd16');
INSERT INTO smart_user VALUES (26,102,1016,'Noah','Evans','12/25/1985','Noah.evans@gmail.com','07466778899','P@ssw0rd17');
INSERT INTO smart_user VALUES (27,103,1017,'Amelia','Morgan','09/11/1994','Amelia.morgan@yahoo.com','07877889900','P@ssw0rd18');
INSERT INTO smart_user VALUES (28,102,1018,'Leo','Harrison','01/07/1983','Leo.harrison@gmail.com','07788990011','P@ssw0rd19');
INSERT INTO smart_user VALUES (29,101,1019,'Mia','Bennett','05/16/1990','Mia.bennett@gmail.com','07399001122','P@ssw0rd20');
INSERT INTO smart_user VALUES (30,103,1020,'Oscar','Foster','11/29/1988','Oscar.foster@icloud.com','07400112233','P@ssw0rd21');
INSERT INTO smart_user VALUES (31,102,1021,'Ella','Price','07/13/1993','Ella.price@gmail.com','07811224455','P@ssw0rd22');
INSERT INTO smart_user VALUES (32,101,1022,'Lucas','Ward','03/21/1981','Lucas.ward@yahoo.com','07922335566','P@ssw0rd23');
INSERT INTO smart_user VALUES (33,102,1023,'Chloe','Hughes','09/09/1997','Chloe.hughes@gmail.com','07733446677','P@ssw0rd24');
INSERT INTO smart_user VALUES (34,103,1024,'Henry','Powell','04/17/1986','Henry.powell@gmail.com','07444557788','P@ssw0rd25');


--bin_type data
INSERT INTO bin_type VALUES (300,'General Waste','Non-recyclable household waste','#000000');
INSERT INTO bin_type VALUES (301,'Recycling','Paper, plastic, cans, cardboard','#0000FF');
INSERT INTO bin_type VALUES (302,'Garden Waste','Grass, leaves, garden cuttings','#008080');


--bin data
-- 60 rows of bin data inserted
INSERT INTO bin VALUES (2000,1000,300,240,'Active');
INSERT INTO bin VALUES (2001,1001,301,120,'Active');
INSERT INTO bin VALUES (2002,1002,300,360,'Full');
INSERT INTO bin VALUES (2003,1003,301,120,'Damaged');
INSERT INTO bin VALUES (2004,1004,302,240,'Active');
INSERT INTO bin VALUES (2005,1005,300,240,'Collected');
INSERT INTO bin VALUES (2006,1006,301,240,'Full');
INSERT INTO bin VALUES (2007,1007,302,360,'Active');
INSERT INTO bin VALUES (2008,1008,300,240,'Active');
INSERT INTO bin VALUES (2009,1009,301,120,'Damaged');
INSERT INTO bin VALUES (2010,1010,300,240,'Active');
INSERT INTO bin VALUES (2011,1011,302,360,'Maintenance');
INSERT INTO bin VALUES (2012,1012,301,120,'Active');
INSERT INTO bin VALUES (2013,1013,300,240,'Full');
INSERT INTO bin VALUES (2014,1014,302,240,'Active');
INSERT INTO bin VALUES (2015,1015,301,120,'Active');
INSERT INTO bin VALUES (2016,1016,300,360,'Collected');
INSERT INTO bin VALUES (2017,1017,301,240,'Active');
INSERT INTO bin VALUES (2018,1018,302,120,'Full');
INSERT INTO bin VALUES (2019,1019,300,240,'Active');
INSERT INTO bin VALUES (2020,1020,301,240,'Active');
INSERT INTO bin VALUES (2021,1021,302,360,'Active');
INSERT INTO bin VALUES (2022,1022,300,120,'Active');
INSERT INTO bin VALUES (2023,1023,301,240,'Full');
INSERT INTO bin VALUES (2024,1024,302,240,'Active');
INSERT INTO bin VALUES (2025,1025,300,120,'Maintenance');
INSERT INTO bin VALUES (2026,1026,301,360,'Active');
INSERT INTO bin VALUES (2027,1027,302,240,'Active');
INSERT INTO bin VALUES (2028,1028,300,120,'Full');
INSERT INTO bin VALUES (2029,1029,301,240,'Active');
INSERT INTO bin VALUES (2030,1030,302,240,'Active');
INSERT INTO bin VALUES (2031,1031,300,360,'Active');
INSERT INTO bin VALUES (2032,1032,301,120,'Damaged');
INSERT INTO bin VALUES (2033,1033,302,240,'Full');
INSERT INTO bin VALUES (2034,1034,300,240,'Active');
INSERT INTO bin VALUES (2035,1035,301,120,'Active');
INSERT INTO bin VALUES (2036,1036,302,360,'Collected');
INSERT INTO bin VALUES (2037,1037,300,240,'Active');
INSERT INTO bin VALUES (2038,1038,301,120,'Active');
INSERT INTO bin VALUES (2039,1039,302,240,'Full');
INSERT INTO bin VALUES (2040,1000,300,240,'Active');
INSERT INTO bin VALUES (2041,1001,301,360,'Active');
INSERT INTO bin VALUES (2042,1002,302,120,'Active');
INSERT INTO bin VALUES (2043,1003,300,240,'Maintenance');
INSERT INTO bin VALUES (2044,1004,301,240,'Active');
INSERT INTO bin VALUES (2045,1005,302,120,'Full');
INSERT INTO bin VALUES (2046,1006,300,360,'Active');
INSERT INTO bin VALUES (2047,1007,301,240,'Active');
INSERT INTO bin VALUES (2048,1008,302,120,'Active');
INSERT INTO bin VALUES (2049,1009,300,240,'Collected');
INSERT INTO bin VALUES (2050,1010,301,240,'Active');
INSERT INTO bin VALUES (2051,1011,302,360,'Active');
INSERT INTO bin VALUES (2052,1012,300,120,'Full');
INSERT INTO bin VALUES (2053,1013,301,240,'Active');
INSERT INTO bin VALUES (2054,1014,302,240,'Active');
INSERT INTO bin VALUES (2055,1015,300,120,'Active');
INSERT INTO bin VALUES (2056,1016,301,360,'Maintenance');
INSERT INTO bin VALUES (2057,1017,302,240,'Active');
INSERT INTO bin VALUES (2058,1018,300,120,'Active');
INSERT INTO bin VALUES (2059,1019,301,240,'Full');


--report data
-- 100 rows of data inserted for report 
--ERROR NEEDS RESOLVING
INSERT INTO report VALUES (4000,2000,85,'08:30','Pending');
INSERT INTO report VALUES (4001,2002,100,'09:00','Escalated');
INSERT INTO report VALUES (4002,2004,60,'10:15','Logged');
INSERT INTO report VALUES (4003,2006,95,'11:10','Pending');
INSERT INTO report VALUES (4004,2008,40,'12:20','Resolved');
INSERT INTO report VALUES (4005,2010,22,'13:00','Logged');
INSERT INTO report VALUES (4006,2013,75,'14:10','Pending');
INSERT INTO report VALUES (4007,2014,68,'15:20','Logged');
INSERT INTO report VALUES (4008,2015,55,'08:45','Logged');
INSERT INTO report VALUES (4009,2016,90,'09:10','Pending');
INSERT INTO report VALUES (4010,2017,35,'09:30','Resolved');
INSERT INTO report VALUES (4011,2018,100,'09:50','Escalated');
INSERT INTO report VALUES (4012,2019,62,'10:05','Logged');
INSERT INTO report VALUES (4013,2020,78,'10:25','Pending');
INSERT INTO report VALUES (4014,2021,44,'10:40','Resolved');
INSERT INTO report VALUES (4015,2022,58,'11:00','Logged');
INSERT INTO report VALUES (4016,2023,96,'11:15','Pending');
INSERT INTO report VALUES (4017,2024,27,'11:35','Logged');
INSERT INTO report VALUES (4018,2025,83,'11:50','Pending');
INSERT INTO report VALUES (4019,2026,71,'12:05','Logged');
INSERT INTO report VALUES (4020,2027,39,'12:20','Resolved');
INSERT INTO report VALUES (4021,2028,100,'12:35','Escalated');
INSERT INTO report VALUES (4022,2029,66,'12:50','Logged');
INSERT INTO report VALUES (4023,2030,88,'13:05','Pending');
INSERT INTO report VALUES (4024,2031,51,'13:20','Logged');
INSERT INTO report VALUES (4025,2032,97,'13:35','Escalated');
INSERT INTO report VALUES (4026,2033,73,'13:50','Pending');
INSERT INTO report VALUES (4027,2034,48,'14:05','Resolved');
INSERT INTO report VALUES (4028,2035,59,'14:20','Logged');
INSERT INTO report VALUES (4029,2036,92,'14:35','Pending');
INSERT INTO report VALUES (4030,2037,31,'14:50','Resolved');
INSERT INTO report VALUES (4031,2038,64,'15:05','Logged');
INSERT INTO report VALUES (4032,2039,99,'15:20','Escalated');
INSERT INTO report VALUES (4033,2040,76,'15:35','Pending');
INSERT INTO report VALUES (4034,2041,43,'15:50','Resolved');
INSERT INTO report VALUES (4035,2042,57,'16:05','Logged');
INSERT INTO report VALUES (4036,2043,84,'16:20','Pending');
INSERT INTO report VALUES (4037,2044,69,'16:35','Logged');
INSERT INTO report VALUES (4038,2045,100,'16:50','Escalated');
INSERT INTO report VALUES (4039,2046,53,'17:05','Logged');
INSERT INTO report VALUES (4040,2047,81,'17:20','Pending');
INSERT INTO report VALUES (4041,2048,36,'17:35','Resolved');
INSERT INTO report VALUES (4042,2049,61,'17:50','Logged');
INSERT INTO report VALUES (4043,2050,94,'08:10','Pending');
INSERT INTO report VALUES (4044,2051,47,'08:25','Resolved');
INSERT INTO report VALUES (4045,2052,100,'08:40','Escalated');
INSERT INTO report VALUES (4046,2053,74,'08:55','Logged');
INSERT INTO report VALUES (4047,2054,52,'09:15','Logged');
INSERT INTO report VALUES (4048,2055,87,'09:30','Pending');
INSERT INTO report VALUES (4049,2056,28,'09:45','Resolved');
INSERT INTO report VALUES (4050,2057,63,'10:00','Logged');
INSERT INTO report VALUES (4051,2058,91,'10:15','Pending');
INSERT INTO report VALUES (4052,2059,41,'10:30','Resolved');
INSERT INTO report VALUES (4053,2001,56,'10:45','Logged');
INSERT INTO report VALUES (4054,2003,98,'11:00','Escalated');
INSERT INTO report VALUES (4055,2005,72,'11:15','Pending');
INSERT INTO report VALUES (4056,2007,38,'11:30','Resolved');
INSERT INTO report VALUES (4057,2009,65,'11:45','Logged');
INSERT INTO report VALUES (4058,2011,89,'12:00','Pending');
INSERT INTO report VALUES (4059,2012,33,'12:15','Resolved');
INSERT INTO report VALUES (4060,2015,54,'12:30','Logged');
INSERT INTO report VALUES (4061,2017,82,'12:45','Pending');
INSERT INTO report VALUES (4062,2019,46,'13:00','Resolved');
INSERT INTO report VALUES (4063,2021,67,'13:15','Logged');
INSERT INTO report VALUES (4064,2024,95,'13:30','Escalated');
INSERT INTO report VALUES (4065,2026,58,'13:45','Logged');
INSERT INTO report VALUES (4066,2028,79,'14:00','Pending');
INSERT INTO report VALUES (4067,2030,42,'14:15','Resolved');
INSERT INTO report VALUES (4068,2032,60,'14:30','Logged');
INSERT INTO report VALUES (4069,2034,93,'14:45','Pending');
INSERT INTO report VALUES (4070,2036,37,'15:00','Resolved');
INSERT INTO report VALUES (4071,2038,71,'15:15','Logged');
INSERT INTO report VALUES (4072,2040,100,'15:30','Escalated');
INSERT INTO report VALUES (4073,2042,49,'15:45','Resolved');
INSERT INTO report VALUES (4074,2044,62,'16:00','Logged');
INSERT INTO report VALUES (4075,2046,86,'16:15','Pending');
INSERT INTO report VALUES (4076,2048,34,'16:30','Resolved');
INSERT INTO report VALUES (4077,2050,57,'16:45','Logged');
INSERT INTO report VALUES (4078,2052,97,'17:00','Escalated');
INSERT INTO report VALUES (4079,2054,73,'17:15','Pending');
INSERT INTO report VALUES (4080,2056,45,'17:30','Resolved');
INSERT INTO report VALUES (4081,2058,68,'17:45','Logged');
INSERT INTO report VALUES (4082,2000,88,'08:05','Pending');
INSERT INTO report VALUES (4083,2004,29,'08:20','Resolved');
INSERT INTO report VALUES (4084,2008,51,'08:35','Logged');
INSERT INTO report VALUES (4085,2010,92,'08:50','Pending');
INSERT INTO report VALUES (4086,2013,40,'09:05','Resolved');
INSERT INTO report VALUES (4087,2014,64,'09:20','Logged');
INSERT INTO report VALUES (4088,2020,85,'09:35','Pending');
INSERT INTO report VALUES (4089,2025,31,'09:50','Resolved');
INSERT INTO report VALUES (4090,2031,59,'10:05','Logged');
INSERT INTO report VALUES (4091,2035,96,'10:20','Escalated');
INSERT INTO report VALUES (4092,2041,70,'10:35','Pending');
INSERT INTO report VALUES (4093,2047,44,'10:50','Resolved');
INSERT INTO report VALUES (4094,2053,61,'11:05','Logged');
INSERT INTO report VALUES (4095,2059,90,'11:20','Pending');
INSERT INTO report VALUES (4096,2006,36,'11:35','Resolved');
INSERT INTO report VALUES (4097,2016,55,'11:50','Logged');
INSERT INTO report VALUES (4098,2029,83,'12:05','Pending');
INSERT INTO report VALUES (4099,2049,47,'12:20','Resolved');


--route data
INSERT INTO route VALUES (5000,10000,11,7000,11,'03/19/2026','Scheduled');
INSERT INTO route VALUES (5001,10001,15,7001,15,'03/19/2026','In Progress');
INSERT INTO route VALUES (5002,10002,19,7005,19,'03/19/2026','Completed');
INSERT INTO route VALUES (5003,10003,11,7003,11,'03/20/2026','Scheduled');
INSERT INTO route VALUES (5004,10004,15,7007,15,'03/20/2026','Scheduled');
INSERT INTO route VALUES (5005,10000,19,7000,19,'03/20/2026','Completed');
INSERT INTO route VALUES (5006,10001,11,7001,11,'03/21/2026','Scheduled');
INSERT INTO route VALUES (5007,10002,15,7005,15,'03/21/2026','In Progress');
INSERT INTO route VALUES (5008,10003,19,7003,19,'03/21/2026','Completed');
INSERT INTO route VALUES (5009,10004,11,7007,11,'03/22/2026','Scheduled');
INSERT INTO route VALUES (5010,10000,15,7000,15,'03/22/2026','In Progress');
INSERT INTO route VALUES (5011,10001,19,7001,19,'03/22/2026','Completed');
INSERT INTO route VALUES (5012,10002,11,7005,11,'03/23/2026','Scheduled');
INSERT INTO route VALUES (5013,10003,15,7003,15,'03/23/2026','In Progress');
INSERT INTO route VALUES (5014,10004,19,7007,19,'03/23/2026','Completed');
INSERT INTO route VALUES (5015,10000,11,7000,11,'03/24/2026','Scheduled');
INSERT INTO route VALUES (5016,10001,15,7001,15,'03/24/2026','In Progress');
INSERT INTO route VALUES (5017,10002,19,7005,19,'03/24/2026','Completed');
INSERT INTO route VALUES (5018,10003,11,7003,11,'03/25/2026','Scheduled');
INSERT INTO route VALUES (5019,10004,15,7007,15,'03/25/2026','In Progress');


--route_stop data
-- Inserted 100 rows of data
-- ERROR 
INSERT INTO route_stop VALUES (6000,5000,2000,1,'Completed','03/19/2026','07:45');
INSERT INTO route_stop VALUES (6001,5000,2001,2,'Completed','03/19/2026','08:02');
INSERT INTO route_stop VALUES (6002,5000,2002,3,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6003,5001,2003,1,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6004,5001,2004,2,'Completed','03/19/2026','09:30');
INSERT INTO route_stop VALUES (6005,5002,2005,1,'Completed','03/19/2026','10:00');
INSERT INTO route_stop VALUES (6006,5002,2006,2,'Delayed','03/19/2026','10:35');
INSERT INTO route_stop VALUES (6007,5002,2007,3,'Completed','03/19/2026','10:55');
INSERT INTO route_stop VALUES (6008,5003,2008,1,'Completed','03/20/2026','07:40');
INSERT INTO route_stop VALUES (6009,5003,2009,2,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6010,5003,2010,3,'Completed','03/20/2026','08:25');
INSERT INTO route_stop VALUES (6011,5004,2011,1,'Delayed','03/20/2026','09:05');
INSERT INTO route_stop VALUES (6012,5004,2012,2,'Completed','03/20/2026','09:35');
INSERT INTO route_stop VALUES (6013,5004,2013,3,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6014,5005,2014,1,'Completed','03/20/2026','10:10');
INSERT INTO route_stop VALUES (6015,5005,2015,2,'Completed','03/20/2026','10:32');
INSERT INTO route_stop VALUES (6016,5005,2016,3,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6017,5006,2017,1,'Completed','03/21/2026','07:35');
INSERT INTO route_stop VALUES (6018,5006,2018,2,'Delayed','03/21/2026','07:58');
INSERT INTO route_stop VALUES (6019,5006,2019,3,'Completed','03/21/2026','08:20');
INSERT INTO route_stop VALUES (6020,5007,2020,1,'Completed','03/21/2026','08:45');
INSERT INTO route_stop VALUES (6021,5007,2021,2,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6022,5007,2022,3,'Completed','03/21/2026','09:25');
INSERT INTO route_stop VALUES (6023,5008,2023,1,'Completed','03/21/2026','09:50');
INSERT INTO route_stop VALUES (6024,5008,2024,2,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6025,5008,2025,3,'Completed','03/21/2026','10:30');
INSERT INTO route_stop VALUES (6026,5009,2026,1,'Delayed','03/22/2026','07:50');
INSERT INTO route_stop VALUES (6027,5009,2027,2,'Completed','03/22/2026','08:15');
INSERT INTO route_stop VALUES (6028,5009,2028,3,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6029,5010,2029,1,'Completed','03/22/2026','08:40');
INSERT INTO route_stop VALUES (6030,5010,2030,2,'Completed','03/22/2026','09:05');
INSERT INTO route_stop VALUES (6031,5010,2031,3,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6032,5011,2032,1,'Completed','03/22/2026','09:35');
INSERT INTO route_stop VALUES (6033,5011,2033,2,'Delayed','03/22/2026','10:00');
INSERT INTO route_stop VALUES (6034,5011,2034,3,'Completed','03/22/2026','10:25');
INSERT INTO route_stop VALUES (6035,5012,2035,1,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6036,5012,2036,2,'Completed','03/23/2026','07:45');
INSERT INTO route_stop VALUES (6037,5012,2037,3,'Completed','03/23/2026','08:10');
INSERT INTO route_stop VALUES (6038,5013,2038,1,'Completed','03/23/2026','08:35');
INSERT INTO route_stop VALUES (6039,5013,2039,2,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6040,5013,2040,3,'Completed','03/23/2026','09:15');
INSERT INTO route_stop VALUES (6041,5014,2041,1,'Delayed','03/23/2026','09:40');
INSERT INTO route_stop VALUES (6042,5014,2042,2,'Completed','03/23/2026','10:05');
INSERT INTO route_stop VALUES (6043,5014,2043,3,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6044,5015,2044,1,'Completed','03/24/2026','07:30');
INSERT INTO route_stop VALUES (6045,5015,2045,2,'Completed','03/24/2026','07:55');
INSERT INTO route_stop VALUES (6046,5015,2046,3,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6047,5016,2047,1,'Completed','03/24/2026','08:20');
INSERT INTO route_stop VALUES (6048,5016,2048,2,'Delayed','03/24/2026','08:45');
INSERT INTO route_stop VALUES (6049,5016,2049,3,'Completed','03/24/2026','09:10');
INSERT INTO route_stop VALUES (6050,5017,2050,1,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6051,5017,2051,2,'Completed','03/24/2026','09:40');
INSERT INTO route_stop VALUES (6052,5017,2052,3,'Completed','03/24/2026','10:05');
INSERT INTO route_stop VALUES (6053,5018,2053,1,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6054,5018,2054,2,'Completed','03/25/2026','07:50');
INSERT INTO route_stop VALUES (6055,5018,2055,3,'Delayed','03/25/2026','08:15');
INSERT INTO route_stop VALUES (6056,5019,2056,1,'Completed','03/25/2026','08:40');
INSERT INTO route_stop VALUES (6057,5019,2057,2,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6058,5019,2058,3,'Completed','03/25/2026','09:20');
INSERT INTO route_stop VALUES (6059,5000,2059,4,'Completed','03/19/2026','08:40');
INSERT INTO route_stop VALUES (6060,5001,2010,3,'Completed','03/19/2026','09:55');
INSERT INTO route_stop VALUES (6061,5002,2011,4,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6062,5003,2012,4,'Completed','03/20/2026','08:50');
INSERT INTO route_stop VALUES (6063,5004,2013,4,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6064,5005,2014,4,'Completed','03/20/2026','10:55');
INSERT INTO route_stop VALUES (6065,5006,2015,4,'Delayed','03/21/2026','08:45');
INSERT INTO route_stop VALUES (6066,5007,2016,4,'Completed','03/21/2026','09:55');
INSERT INTO route_stop VALUES (6067,5008,2017,4,'Completed','03/21/2026','10:55');
INSERT INTO route_stop VALUES (6068,5009,2018,4,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6069,5010,2019,4,'Completed','03/22/2026','09:35');
INSERT INTO route_stop VALUES (6070,5011,2020,4,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6071,5012,2021,4,'Completed','03/23/2026','08:40');
INSERT INTO route_stop VALUES (6072,5013,2022,4,'Delayed','03/23/2026','09:45');
INSERT INTO route_stop VALUES (6073,5014,2023,4,'Completed','03/23/2026','10:40');
INSERT INTO route_stop VALUES (6074,5015,2024,4,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6075,5016,2025,4,'Completed','03/24/2026','09:35');
INSERT INTO route_stop VALUES (6076,5017,2026,4,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6077,5018,2027,4,'Completed','03/25/2026','08:45');
INSERT INTO route_stop VALUES (6078,5019,2028,4,'Delayed','03/25/2026','09:55');
INSERT INTO route_stop VALUES (6079,5000,2029,5,'Completed','03/19/2026','09:05');
INSERT INTO route_stop VALUES (6080,5001,2030,4,'Completed','03/19/2026','10:20');
INSERT INTO route_stop VALUES (6081,5002,2031,5,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6082,5003,2032,5,'Completed','03/20/2026','09:20');
INSERT INTO route_stop VALUES (6083,5004,2033,5,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6084,5005,2034,5,'Completed','03/20/2026','11:20');
INSERT INTO route_stop VALUES (6085,5006,2035,5,'Delayed','03/21/2026','09:15');
INSERT INTO route_stop VALUES (6086,5007,2036,5,'Completed','03/21/2026','10:20');
INSERT INTO route_stop VALUES (6087,5008,2037,5,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6088,5009,2038,5,'Completed','03/22/2026','09:10');
INSERT INTO route_stop VALUES (6089,5010,2039,5,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6090,5011,2040,5,'Completed','03/22/2026','10:55');
INSERT INTO route_stop VALUES (6091,5012,2041,5,'Delayed','03/23/2026','09:05');
INSERT INTO route_stop VALUES (6092,5013,2042,5,'Completed','03/23/2026','10:10');
INSERT INTO route_stop VALUES (6093,5014,2043,5,'Pending',NULL,NULL);
INSERT INTO route_stop VALUES (6094,5015,2044,5,'Completed','03/24/2026','08:25');
INSERT INTO route_stop VALUES (6095,5016,2045,5,'Missed',NULL,NULL);
INSERT INTO route_stop VALUES (6096,5017,2046,5,'Completed','03/24/2026','10:35');
INSERT INTO route_stop VALUES (6097,5018,2047,5,'Delayed','03/25/2026','09:15');
INSERT INTO route_stop VALUES (6098,5019,2048,5,'Completed','03/25/2026','10:20');
INSERT INTO route_stop VALUES (6099,5019,2049,6,'Pending',NULL,NULL);


--notification data
INSERT INTO notification VALUES (8000,12,'Alert','Bin is full at Albion Street',SYSDATE,'Unread');
INSERT INTO notification VALUES (8001,14,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8002,16,'Update','Route delayed due to traffic in Leeds',SYSDATE,'Unread');
INSERT INTO notification VALUES (8003,17,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8004,18,'Alert','Damaged bin reported',SYSDATE,'Read');
INSERT INTO notification VALUES (8005,20,'Reminder','Collection starts at 7am',SYSDATE,'Unread');
INSERT INTO notification VALUES (8006,10,'Alert','Bin is full at Boar Lane',SYSDATE,'Unread');
INSERT INTO notification VALUES (8007,11,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8008,13,'Update','Route delayed due to traffic in Leeds',SYSDATE,'Unread');
INSERT INTO notification VALUES (8009,15,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8010,19,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8011,21,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8012,22,'Update','Vehicle assigned to your route',SYSDATE,'Unread');
INSERT INTO notification VALUES (8013,23,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8014,24,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8015,25,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8016,26,'Update','Route completed successfully',SYSDATE,'Unread');
INSERT INTO notification VALUES (8017,27,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8018,28,'Alert','Bin is full at Harehills Lane',SYSDATE,'Unread');
INSERT INTO notification VALUES (8019,29,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8020,30,'Update','Traffic delays expected today',SYSDATE,'Unread');
INSERT INTO notification VALUES (8021,31,'Assignment','New collection route assigned',SYSDATE,'Read');
INSERT INTO notification VALUES (8022,32,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8023,33,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8024,34,'Update','Vehicle maintenance completed',SYSDATE,'Unread');
INSERT INTO notification VALUES (8025,12,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8026,14,'Alert','Bin is full at York Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8027,16,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8028,17,'Update','Route delayed due to weather',SYSDATE,'Unread');
INSERT INTO notification VALUES (8029,18,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8030,20,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8031,10,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8032,11,'Update','Vehicle assigned to your route',SYSDATE,'Unread');
INSERT INTO notification VALUES (8033,13,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8034,15,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8035,19,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8036,21,'Update','Route completed successfully',SYSDATE,'Unread');
INSERT INTO notification VALUES (8037,22,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8038,23,'Alert','Bin is full at Roundhay Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8039,24,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8040,25,'Update','Traffic delays expected today',SYSDATE,'Unread');
INSERT INTO notification VALUES (8041,26,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8042,27,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8043,28,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8044,29,'Update','Vehicle maintenance completed',SYSDATE,'Unread');
INSERT INTO notification VALUES (8045,30,'Assignment','New collection route assigned',SYSDATE,'Read');
INSERT INTO notification VALUES (8046,31,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8047,32,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8048,33,'Update','Route delayed due to traffic in Leeds',SYSDATE,'Unread');
INSERT INTO notification VALUES (8049,34,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8050,12,'Alert','Bin is full at Otley Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8051,14,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8052,16,'Update','Vehicle assigned to your route',SYSDATE,'Unread');
INSERT INTO notification VALUES (8053,17,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8054,18,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8055,20,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8056,10,'Update','Route completed successfully',SYSDATE,'Unread');
INSERT INTO notification VALUES (8057,11,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8058,13,'Alert','Bin is full at Meanwood Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8059,15,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8060,19,'Update','Traffic delays expected today',SYSDATE,'Unread');
INSERT INTO notification VALUES (8061,21,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8062,22,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8063,23,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8064,24,'Update','Vehicle maintenance completed',SYSDATE,'Unread');
INSERT INTO notification VALUES (8065,25,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8066,26,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8067,27,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8068,28,'Update','Route delayed due to weather',SYSDATE,'Unread');
INSERT INTO notification VALUES (8069,29,'Assignment','New collection route assigned',SYSDATE,'Read');
INSERT INTO notification VALUES (8070,30,'Alert','Bin is full at Cross Gates Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8071,31,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8072,32,'Update','Vehicle assigned to your route',SYSDATE,'Unread');
INSERT INTO notification VALUES (8073,33,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8074,34,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8075,12,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8076,14,'Update','Route completed successfully',SYSDATE,'Unread');
INSERT INTO notification VALUES (8077,16,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8078,17,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8079,18,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8080,20,'Update','Traffic delays expected today',SYSDATE,'Unread');
INSERT INTO notification VALUES (8081,10,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8082,11,'Alert','Bin is full at Dewsbury Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8083,13,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8084,15,'Update','Vehicle maintenance completed',SYSDATE,'Unread');
INSERT INTO notification VALUES (8085,19,'Assignment','New collection route assigned',SYSDATE,'Read');
INSERT INTO notification VALUES (8086,21,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8087,22,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8088,23,'Update','Route delayed due to traffic in Leeds',SYSDATE,'Unread');
INSERT INTO notification VALUES (8089,24,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8090,25,'Alert','Missed collection reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8091,26,'Reminder','Collection starts at 7am',SYSDATE,'Read');
INSERT INTO notification VALUES (8092,27,'Update','Vehicle assigned to your route',SYSDATE,'Unread');
INSERT INTO notification VALUES (8093,28,'Assignment','New route allocated for today',SYSDATE,'Read');
INSERT INTO notification VALUES (8094,29,'Alert','Bin is full at Selby Road',SYSDATE,'Unread');
INSERT INTO notification VALUES (8095,30,'Reminder','Collection scheduled for tomorrow',SYSDATE,'Read');
INSERT INTO notification VALUES (8096,31,'Update','Route completed successfully',SYSDATE,'Unread');
INSERT INTO notification VALUES (8097,32,'Assignment','Your route has been updated',SYSDATE,'Read');
INSERT INTO notification VALUES (8098,33,'Alert','Damaged bin reported',SYSDATE,'Unread');
INSERT INTO notification VALUES (8099,34,'Reminder','Collection starts at 7am',SYSDATE,'Read');