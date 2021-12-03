

DROP TABLE International;
DROP TABLE Tracking;
DROP TABLE Vehicle_Warehouse;
DROP TABLE Transaction;
DROP TABLE PackageDelivery;
DROP TABLE Package;
DROP TABLE Service;
DROP TABLE Customer CASCADE ;

--subTask 2(Design)--

CREATE TABLE Customer(
	CustomerID varchar(20),
	Name varchar(30) NOT NULL,
	Country varchar(30),
	State varchar(30),
	City varchar(30),
	HouseNo varchar(30),
	Street varchar(30),
	Email varchar(30),
	Phone varchar(10),
	PRIMARY KEY(CustomerID));

CREATE TABLE Service(
	ServiceID varchar(15),
	ServiceType varchar(20),
	PackageType varchar(20) NOT NULL,
	Weight int,
	Amount int,
	Speed varchar(20),
	PRIMARY KEY(ServiceID));

CREATE TABLE Package(
	PkgID varchar(15),
	IsFragile varchar(3),
	Description varchar(30),
	Weight int,
	HazardousCategory varchar(20),
	PRIMARY KEY(PkgID));

CREATE TABLE PackageDelivery(
	CustomerID varchar(20),
	PkgID varchar(20),
	RecieverName varchar(20),
	Email varchar(30),
	Phone varchar(10),
	Country varchar(30),
	State varchar(30),
	City varchar(30),
	Zipcode varchar(30),
	Street varchar(30),
	DateOfRequest timestamp,
	PRIMARY KEY(PkgID),
	CONSTRAINT FK_PkgDel FOREIGN KEY(PkgID) REFERENCES Package(PkgID));

CREATE TABLE Transaction(
	PkgID varchar(15),
	CustomerID varchar(15),
	ServiceID varchar(20),
	Time timestamp,
	Amount int,
	PaymentType varchar(20),
	Account varchar(20),
	FOREIGN KEY(PkgID) REFERENCES Package(PkgID),
	CONSTRAINT FK_Transaction1 FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID),
	CONSTRAINT FK_Transaction2 FOREIGN KEY(ServiceID) REFERENCES Service(ServiceID));

CREATE TABLE Vehicle_Warehouse(
	RegistrationNo varchar(15),
	Type varchar(30) NOT NULL,
	PRIMARY KEY(RegistrationNo));

CREATE TABLE Tracking(
	PkgID varchar(15),
	RegistrationNo varchar(15),
	CurrentCity varchar(50),
	CurrentTime timestamp,
	DeliveryTime timestamp,
	Status varchar(20),
	PRIMARY KEY(PkgID,CurrentTime),
	CONSTRAINT FK_Tracking1 FOREIGN KEY(PkgID) REFERENCES Package(PkgID),
	CONSTRAINT FK_Tracking2 FOREIGN KEY(RegistrationNo) REFERENCES Vehicle_Warehouse(RegistrationNo));

CREATE TABLE International(
	PkgID varchar(15),
	Value int,
	Contents varchar(30),
	PRIMARY KEY(PkgID),
	CONSTRAINT FK_International FOREIGN KEY(PkgID) REFERENCES Package(PkgID));

--subTask 3(Populate)--
--Customer--
DROP procedure procCustDummyData(N int);
CREATE PROCEDURE procCustDummyData(IN N int)
AS $$

	DECLARE varCustomerID varchar(15);
         varName varchar(30);
         varCountry varchar(30);
         varState varchar(30);
         varCity varchar(30);
         varHouseNo varchar(10);
         varStreet varchar(30);
         varEmail varchar(30);
         varPhone varchar(10);
         c int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            varCustomerID := concat('cust-',c);
            varName := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(20)+1)::int);
            varCountry := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(20)+1)::int);
            varCity := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(20)+1)::int);
            varState := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(20)+1)::int);
            varHouseNo := LPAD(ceil(RANDOM() * 10000000000)::text, 10, '0'::text);
            varStreet := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(20)+1)::int);
            varEmail := concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(10)+1)::int), '@'::text,
                    substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, ceil(RANDOM()*(26)+1)::int, ceil(RANDOM()*(10)+1)::int));
            varPhone := LPAD(ceil(RANDOM() * 10000000000)::text, 10, '0'::text);
            INSERT INTO Customer
                VALUES(varCustomerID,varName,varCountry,varState,varCity,varHouseNo,varStreet,varEmail,varPhone);
            c:=c+1;
        END LOOP;
END$$
LANGUAGE plpgsql;

DELETE FROM Customer;
CALL procCustDummyData(100);
SELECT * FROM Customer;

--Service--
DROP procedure procServiceDummyData;
CREATE PROCEDURE procServiceDummyData(IN N int)
AS $$

	DECLARE
	    varServiceID varchar(15);
        varServiceType varchar(20);
        varPackageType varchar(20);
        varWeight int;
        varAmount int;
        varSpeed varchar(20);
        c int;
        sp int;
        fl int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            varServiceID := concat('serv-',c);
            fl := FLOOR(RANDOM()*(3))+1;
            IF fl=1 THEN
                varPackageType:='Flat Envelope';
            ELSEIF fl=2 THEN
                varPackageType:='Small box';
            ELSE
                varPackageType:='Larger Box';
            END IF;
            IF fl=1 THEN
                varServiceType:='Prepaid';
            ELSEIF fl=2 THEN
                varServiceType:='Postpaid';
            ELSE
                varServiceType:='Normal';
            END IF;
            varWeight := FLOOR(RANDOM()*(99999))+1;
            varAmount := FLOOR(RANDOM()*(999))+1;
            sp := LPAD(FLOOR(RANDOM() * 10000000000)::text, 1, '0'::text);
            varSpeed := concat(sp,' Day Delivery');
            INSERT INTO Service
                VALUES(varServiceID,varServiceType,varPackageType,varWeight,varAmount,varSpeed);
            c:=c+1;
        END LOOP;
    END$$
LANGUAGE plpgsql;

DELETE FROM Service;
CALL procServiceDummyData(100);
SELECT * FROM Service;

--Package and International--
CREATE PROCEDURE procPackage_INTDummyData(IN N int)
AS $$

	DECLARE
	    PkgID varchar(15);
        IsFragile varchar(3);
        Description varchar(30);
        varWeight int;
        HazardousCategory varchar(20);
        Value int;
        Contents varchar(30);
        c int;
        fl int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            PkgID := concat('pkg-',c);
            fl := FLOOR(RANDOM()*(2))+1;
            IF fl=2 THEN
                IsFragile := 'YES';
            ELSE
                IsFragile := 'NO';
            END IF;
            Description := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(26)+1)::int);
            varWeight := FLOOR(RANDOM()*(99999))+1;
            fl := FLOOR(RANDOM()*(2))+1;
            IF fl=2 THEN
                HazardousCategory := 'NORMAL';
            ELSE
                HazardousCategory := 'RADIOACTIVE';
            END IF;
            INSERT INTO Package
                VALUES(PkgID,IsFragile,Description,varWeight,HazardousCategory);
            fl := FLOOR(RANDOM()*(25))+1;
            IF fl=12 THEN
                Contents := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(26)+1)::int);
                Value:=FLOOR(RANDOM()*(99999))+1;
                INSERT INTO International
                    VALUES(PkgID,Value,Contents);
            END IF;
            c:=c+1;
	    END LOOP;
    END$$
LANGUAGE plpgsql;

DROP PROCEDURE procPackage_INTDummyData;
CALL procPackage_INTDummyData(100);
SELECT * FROM Package;
SELECT * FROM International;

--Package Delivery--
CREATE PROCEDURE procPackageDeliveryDummyData(IN N int)
AS $$

	DECLARE CustomerID varchar(15);
        PkgID varchar(15);
        varRName varchar(30);
        varEmail varchar(30);
        varPhone varchar(10);
        varCountry varchar(30);
        varState varchar(30);
        varCity varchar(30);
        varZipcode varchar(10);
        varStreet varchar(30);
        DateOfRequest timestamp(0);
        c int;
        x int;
        sp int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            x:=FLOOR(RANDOM()*(25))+1;
            CustomerID := concat('cust-',x);
            PkgID := concat('pkg-',c);
            varRName := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            varCountry := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            varCity := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            varState := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            varStreet := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            varEmail := concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(10)+1)::int),'@'::text,
                    substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(10)+1)::int));
            varPhone := LPAD(FLOOR(RANDOM() * 10000000000)::text, 10, '0'::text);
            varZipcode := LPAD(FLOOR(RANDOM() * 10000000000)::text, 6, '0'::text);
            SELECT to_timestamp(EXTRACT(EPOCH FROM '2019-01-01 14:53:27'::timestamp) + FLOOR(0 + (RANDOM() * 63072000))::int) INTO DateOfRequest;
            INSERT INTO PackageDelivery
                VALUES(CustomerID,PkgID,varRName,varEmail,varPhone,varCountry,varState,varCity,varZipcode,varStreet,DateOfRequest);
            c:=c+1;
        END LOOP;
    END$$
LANGUAGE plpgsql;

DROP PROCEDURE procPackageDeliveryDummyData;
DELETE FROM PackageDelivery;
CALL procPackageDeliveryDummyData(100);
SELECT * FROM PackageDelivery;

--Transaction--

CREATE PROCEDURE procTransactionDummyData(IN N int)
AS $$

    DECLARE PkgID varchar(15);
        CustomerID varchar(15);
        ServiceID varchar(15);
        time timestamp(0);
        Amount int;
        PaymentType varchar(20);
        Account int;
        c int;
        sp int;
        x int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            x := FLOOR(RANDOM()*(99))+1;
            CustomerID := concat('cust-',x);
            PkgID := concat('pkg-',c);
            ServiceID := concat('serv-',c);
            SELECT to_timestamp(EXTRACT(EPOCH FROM '2019-01-01 14:53:27'::timestamp ) + FLOOR(0 + (RANDOM() * 63072000))::int) INTO time;
            Amount := FLOOR(RANDOM()*(999))+1;
            Account := LPAD(FLOOR(RANDOM() * 10000000000)::text, 8, '0'::text);
            PaymentType := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            INSERT INTO Transaction
                VALUES(PkgID,CustomerID,ServiceID,Time,Amount,PaymentType,Account);
            c:=c+1;
        END LOOP;
END$$
LANGUAGE plpgsql;

DROP PROCEDURE procTransactionDummyData;
DELETE FROM Transaction;
CALL procTransactionDummyData(100);
SELECT * FROM Transaction;

--Vaehicle WareHouse--
CREATE PROCEDURE procVehicle_WarehouseDummyData(IN N int)
AS $$

    DECLARE RegistrationNo varchar(15);
        Type varchar(30);
        VWCondition varchar(20);
        c int;
        fl int;
    BEGIN

        c:=0;

        WHILE(c<N) LOOP
            RegistrationNo := concat('KZ05-',c);
            fl := FLOOR(RANDOM()*(3))+1;
            IF fl=2 THEN
                Type := 'Truck';
            ELSEIF fl=1 THEN
                Type := 'Plane';
            ELSE
                Type := 'Warehouse';
            END IF;
            INSERT INTO Vehicle_Warehouse
                VALUES(RegistrationNo,Type);
            c:=c+1;
        END LOOP;
    END$$
LANGUAGE plpgsql;

DROP PROCEDURE procVehicle_WarehouseDummyData;
DELETE FROM Vehicle_Warehouse;
CALL procVehicle_WarehouseDummyData(100);
SELECT * FROM Vehicle_Warehouse;

--Tracking--
CREATE PROCEDURE procTrackingDummyData(IN N int)
AS $$

    DECLARE varPkgID varchar(15);
        RegistrationNo varchar(15);
        CurrentCity varchar(50);
        DeliveryTime timestamp(0);
        Status varchar(20);
        varStrtTime timestamp(0);
        varCurrentTime timestamp(0);
        c int;
        x int;
        fl int;
        cnt int;
        sn int;
    BEGIN

        c:=0;
        x:=0;

    WHILE(c<N*4) LOOP
        varPkgID := concat('pkg-',x);
        RegistrationNo := concat('UK07-',x);
        DeliveryTime:=NULL;
        Status:='Out For Delivery';
        SELECT DateOfRequest FROM PackageDelivery
        WHERE PkgID=varPkgID INTO varStrtTime;
        cnt:=0;
        sn:=FLOOR(RANDOM()*(5))+1;
        WHILE(cnt<sn) LOOP
            fl := FLOOR(RANDOM()*(50))+1;
            CurrentCity := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, FLOOR(RANDOM()*(26)+1)::int, FLOOR(RANDOM()*(20)+1)::int);
            RegistrationNo := concat('KZ05-',fl);
            -- SQLINES LICENSE FOR EVALUATION USE ONLY
            SELECT to_timestamp(extract(EPOCH FROM varStrtTime) + FLOOR(0 + (RANDOM() * 172800))::int) INTO varCurrentTime;
            varStrtTime:=varCurrentTime;
            DeliveryTime:=to_timestamp(extract(EPOCH FROM varStrtTime) + FLOOR(0 + (RANDOM() * 172800))::int);
            IF cnt=sn-1 THEN
                Status:='Delivered';
                DeliveryTime:=varStrtTime;
            END IF;
            INSERT INTO Tracking
                VALUES(varPkgID,RegistrationNo,CurrentCity,varStrtTime,DeliveryTime,Status);
            cnt:=cnt+1;
        END LOOP;
        x:=x+1;
        c:=c+4;
    END LOOP;
END$$
LANGUAGE plpgsql;

DELETE FROM Tracking;
CALL procTrackingDummyData(100);
SELECT * FROM Tracking;

-------------------------Queries-------------------------------

--1.1--
SELECT Name FROM Customer
WHERE Customer.CustomerID IN(
	SELECT CustomerID FROM PackageDelivery
	WHERE PkgID IN(
		SELECT DISTINCT PkgID
			FROM Tracking
			WHERE RegistrationNo='KZ05-11'
			AND Status = 'Out For Delivery'
			));

--1.2--
SELECT RecieverName FROM PackageDelivery
WHERE PkgID IN(
	SELECT DISTINCT PkgID FROM Tracking
	WHERE RegistrationNo='KZ05-11'
	AND Status = 'Out For Delivery');

--1.3--
SELECT PkgID FROM Tracking
WHERE DeliveryTime=(SELECT MAX(DeliveryTime) FROM Tracking
	WHERE RegistrationNo='KZ05-11'
	AND Status = 'Delivered');

--2--
SELECT CustomerID FROM packagedelivery
WHERE date_part('year', DateOfRequest)=2019 GROUP BY CustomerID ORDER BY count(*) DESC LIMIT 1;

--3--
SELECT CustomerID from Transaction
WHERE date_part('year', time)=2019
GROUP BY CustomerID
ORDER BY sum(amount) desc LIMIT 1;

--4--
SELECT Street FROM Customer GROUP BY Street ORDER BY count(*) DESC LIMIT 1;

--5--
SELECT DISTINCT Transaction.PkgID
FROM Transaction,Tracking,PackageDelivery,Service
WHERE Transaction.PkgID=Tracking.PkgID
AND Transaction.ServiceID=Service.ServiceID
AND PackageDelivery.PkgID=Transaction.PkgID
AND (PackageDelivery.DateOfRequest +
		concat(substring(Service.speed::text,1,1), 'days')::interval)<Tracking.CurrentTime;

--6.1--
SELECT Customer.Name, Customer.Street, Customer.HouseNo, Transaction.Amount,
       COUNT(Customer.Name) AS number,
       SUM(Transaction.Amount) AS total
FROM Customer, Transaction
GROUP BY Customer.Name, Customer.Street, Customer.HouseNo, Transaction.Amount;

--6.2--
SELECT Customer.Name, Service.ServiceType,-- Transaction.Amount,
       COUNT (Customer.name) AS cnt FROM Customer, Service, Transaction
GROUP BY Service.ServiceType, Customer.Name, Transaction.Amount;

--6.3--
SELECT Customer.Name, Service.PackageType, Transaction.Amount
    FROM Customer, Service, Transaction
GROUP BY Customer.Name, Service.PackageType, Transaction.Amount;