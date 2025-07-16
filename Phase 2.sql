Phase 2:

PART A) Use DDL to create a logical model representation.
Customer (clientNumber N8, familyName S20, personalName S20, title S4, streetAddress S45, postCode S4)
Primary Key clientNumber
-- Not all customers are patients, but patients are customers

ResponsibleCustomer (clientNumber N8, contactPhoneNumbers S14, emailAddress S50)
Primary Key clientNumber
Foreign Key clientNumber references Customer(clientNumber) ON UPDATE CASCADE ON DELETE NO ACTION
/* UPDATE CASCADE was used to update clientNumber whenever the attribute changes in the Customer table. DELETE NO ACTION has been used to stop Customer being deleted without updating ResponsibleCustomer */

Patient (PatientID N8, clientNumber N8, medicareNo S12, birthdate D)
Primary Key PatientID
Foreign Key clientNumber references Customer(clientNumber) ON UPDATE CASCADE ON DELETE NO ACTION
/* UPDATE CASCADE was used to update clientNumber whenever the attribute changes in the Customer table. DELETE NO ACTION has been used to stop Customer being deleted without updating Patient */

Service (prescribedCode S4, description S20, currectServiceFee $3)
Primary Key prescribedCode

Appointment (dateAndStartingTime D)
Primary Key dateAndStartingTime

Invoice (uniqueInvoiceNumber N5, relevantDate D, clinicalComment S200, totalFee $4, status S1, uniqueIdentifierCode S2, PatientID N8, clientNumber N8)
Primary Key uniqueInvoiceNumber
Foreign Key uniqueIdentifierCode references Dentist(uniqueIdentifierCode)
Foreign Key PatientID references Patient(PatientID)
Foreign Key clientNumber references Customer(clientNumber)

Room (uniqueNumber N3)
Primary Key uniqueNumber

Dentist (uniqueIdentifierCode S2, familyName S20, personalName S20, title S4, contactPhoneNumber S14, qualifications S10)
Primary Key uniqueIdentifierCode


PART B) Translate part A into SQL in a file .txt and build the database using SQLite.
--Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Dentist;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS ResponsibleCustomer;
DROP TABLE IF EXISTS Customer;

--Create tables
CREATE TABLE Customer (
clientNumber INTEGER NOT NULL,
familyName CHAR(20),
personalName CHAR(20),
title CHAR(4),
streetAddress CHAR(45),
postCode CHAR(4),
PRIMARY KEY (clientNumber)
);

CREATE TABLE ResponsibleCustomer (
clientNumber INTEGER NOT NULL,
contactPhoneNumbers CHAR(14),
emailAddress CHAR(50),
PRIMARY (clientNumber),
FOREIGN KEY (clientNumber) REFERENCES Customer(clientNumber) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Patient (
PatientID INTEGER NOT NULL,
clientNumber INTEGER,
medicareNo CHAR(12),
birthdate DATE,
PRIMARY KEY (PatientID)
FOREIGN KEY (clientNumber) REFERENCES Customer(clientNumber) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Service (
prescribedCode CHAR(4) NOT NULL,
description CHAR(20),
currectServiceFee DECIMAL(3, 2),
PRIMARY KEY (prescribedCode)
);

CREATE TABLE Appointment (
dateAndStartingTime DATE NOT NULL,
PRIMARY KEY (dateAndStartingTime)
);

CREATE TABLE Invoice (
uniqueInvoiceNumber INTEGER NOT NULL,
relevantDate DATE,
clinicalComment CHAR(200),
totalFee DECIMAL(4, 2),
status CHAR(1),
streetAddress CHAR(45),
uniqueIdentifierCode CHAR(2), 
PatientID INTEGER,
clientNumber INTEGER,
PRIMARY KEY (uniqueInvoiceNumber),
FOREIGN KEY (uniqueIdentifierCode) REFERENCES Dentist(uniqueIdentifierCode),
FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
FOREIGN KEY (clientNumber) REFERENCES Customer(clientNumber)
);

CREATE TABLE Room (
uniqueNumber INTEGER NOT NULL,
PRIMARY KEY (uniqueNumber)
);

CREATE TABLE Dentist (
uniqueIdentifierCode CHAR(2) NOT NULL,
familyName CHAR(20),
personalName CHAR(20),
title CHAR(4),
contactPhoneNumber CHAR(14),
qualifications CHAR(10),
PRIMARY KEY (uniqueIdentifierCode)
);

--Data insertion
INSERT INTO Customer (clientNumber, familyName, personalName, title, streetAddress, postCode)
VALUES 
(10011001, ‘Smith, ‘John, ‘Mr’, ‘123 Main St’, ‘6000’);
INSERT INTO ResponsibleCustomer (clientNumber, contactPhoneNumbers, emailAddress)
VALUES 
(10011001, ‘0412123434’, ‘johnsmith@gmail.com’);
INSERT INTO Patient (PatientID, clientNumber, medicareNo, birthdate)
VALUES
(20011001, 10011001, 123456789012, ‘2001-04-12’);
INSERT INTO Service (prescribedCode, description, currectServiceFee)
VALUES
(‘S001’, ‘Tooth cleaning’, 80.00);
INSERT INTO Appointment (dateAndStartingTime)
VALUES
(2025-04-30);
INSERT INTO Invoice (uniqueInvoiceNumber, relevantDate, clinicalComment, totalFee, status, streetAddress, uniqueIdentifierCode, PatientID, clientNumber)
VALUES
(54321, 2025-04-30, ‘Routine cleaning’, 80.00, ‘B’, ‘123 Main St’, ‘D1’, 20011001, 10011001);
INSERT INTO Room (uniqueNumber)
VALUES
(101);
INSERT INTO Dentist (uniqueIdentifierCode, familyName, personalName, title, contactPhoneNumber, qualifications)
VALUES
(‘D1’, ‘Stone’, ‘Emily’, ‘Ms’, ‘0445456767’, ‘BDSc’);

--View to show invoice summary
CREATE VIEW InvoiceSummary
AS SELECT 
i.uniqueInvoiceNumber, c.clientNumber,
c.familyName || ‘, ‘|| c.personalName AS customerName,
i.totalFee, i.streetAddress, i.status, i.relevantDate
FROM Invoice i JOIN Customer c ON i.clientNumber = c.clientNumber;

--Updating the address from Customer to Invoice using TRIGGER
CREATE TRIGGER update_customer_address
UPDATE OF streetAddress ON Customer
BEGIN
UPDATE Invoice SET streetAddress = new.streetAddress
WHERE clientNumber = old.clientNumber
AND status = ‘C’;
END;

--Updating the address on InvoiceSummary using TRIGGER and INSTEAD OF
CREATE TRIGGER update_address
INSTEAD OF UPDATE OF streetAddress ON InvoiceSummary
BEGIN
UPDATE Customer SET streetAddress = new.streetAddress
WHERE clientNumber = old.clientNumber;
END;
