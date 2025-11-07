-- ========================================
-- SEED DATA
-- ========================================

-- MUNICIPALITIES
INSERT INTO Municipalities(MunicipalityId, Name)
VALUES
('MN01','Hargeisa Central'),
('MN02','New Hargeisa'),
('MN03','Iftin District'),
('MN04','Mohamoud Haybe'),
('MN05','Ahmed Dhagah'),
('MN06','Gacan Libaax'),
('MN07','Masalaha'),
('MN08','Ga’an Libah'),
('MN09','Koodbuur'),
('MN10','Faraweyne'),
('MN11','Berbera City'),
('MN12','Borama Town'),
('MN13','Burao East'),
('MN14','Sheikh'),
('MN15','Gabiley Center'),
('MN16','Baligubadle'),
('MN17','Wajaale'),
('MN18','Sahil Zone'),
('MN19','Erigavo'),
('MN20','Las Anod'),
('MN21','Oog'),
('MN22','Odweyne'),
('MN23','Eil Afwein'),
('MN24','Garadag'),
('MN25','Dilla'),
('MN26','Togdheer'),
('MN27','Ceerigaabo'),
('MN28','Hodan Suburb'),
('MN29','Jigjiga-Yar'),
('MN30','North Hargeisa'),
('MN31','East Hargeisa'),
('MN32','West Burao'),
('MN33','South Burao'),
('MN34','Sheedaha Area'),
('MN35','Calaamada'),
('MN36','Sha’ab Area'),
('MN37','Hodan Village'),
('MN38','Guryosamo'),
('MN39','Ali Hussein'),
('MN40','Kaah District'),
('MN41','Hodan Zone'),
('MN42','Shacabka'),
('MN43','Gashaamo'),
('MN44','Riyadh Area'),
('MN45','Fagaare'),
('MN46','Kaabsan'),
('MN47','Dami'),
('MN48','Hodan Extension'),
('MN49','Iidaha'),
('MN50','Halaya');

-- WASTE TYPES
INSERT INTO WasteTypes(WasteTypeId, Name, CreditPerKg)
VALUES
('WT01','Plastic',2.50),
('WT02','Paper',1.00),
('WT03','Glass',1.75),
('WT04','Metal',3.00),
('WT05','Electronics',5.00),
('WT06','Organic',0.50),
('WT07','Textiles',1.25),
('WT08','Batteries',4.50),
('WT09','Tyres',2.75),
('WT10','Oil Waste',3.50);

-- WASTE REPORTS
INSERT INTO WasteReports(ReportId, UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, PhotoUrl, CreatedAt)
VALUES
('WR01','U001','WT01',4.2,'Hargeisa Central, Block A',9.562341,44.062345,'/img/wr01.jpg',DATEADD(DAY,-30,GETDATE())),
('WR02','U002','WT03',6.7,'Mohamoud Haybe',9.562332,44.062123,'/img/wr02.jpg',DATEADD(DAY,-29,GETDATE())),
('WR03','U001','WT02',3.1,'New Hargeisa',9.563311,44.062334,'/img/wr03.jpg',DATEADD(DAY,-28,GETDATE())),
('WR04','U002','WT05',5.0,'Ahmed Dhagah',9.561011,44.062112,'/img/wr04.jpg',DATEADD(DAY,-27,GETDATE())),
('WR05','CI94','WT06',7.5,'Masalaha Area',9.564444,44.063221,'/img/wr05.jpg',DATEADD(DAY,-26,GETDATE())),
('WR06','CI94','WT01',8.2,'Gacan Libaax',9.565001,44.064002,'/img/wr06.jpg',DATEADD(DAY,-25,GETDATE())),
('WR07','U001','WT07',2.8,'Iftin',9.567100,44.065000,'/img/wr07.jpg',DATEADD(DAY,-24,GETDATE())),
('WR08','U004','WT09',9.3,'Faraweyne',9.568900,44.066200,'/img/wr08.jpg',DATEADD(DAY,-23,GETDATE())),
('WR09','U002','WT02',5.1,'Berbera Road',9.569200,44.067110,'/img/wr09.jpg',DATEADD(DAY,-22,GETDATE())),
('WR10','U003','WT04',3.9,'Hodan Suburb',9.570400,44.068002,'/img/wr10.jpg',DATEADD(DAY,-21,GETDATE())),
('WR11','U001','WT10',7.7,'Iftin East',9.571300,44.068555,'/img/wr11.jpg',DATEADD(DAY,-20,GETDATE())),
('WR12','U004','WT03',2.6,'Borama Town',9.572000,44.069123,'/img/wr12.jpg',DATEADD(DAY,-19,GETDATE())),
('WR13','CI94','WT05',6.5,'Kaabsan',9.573000,44.070300,'/img/wr13.jpg',DATEADD(DAY,-18,GETDATE())),
('WR14','U001','WT07',4.4,'Erigavo',9.574220,44.071110,'/img/wr14.jpg',DATEADD(DAY,-17,GETDATE())),
('WR15','U004','WT06',5.9,'Togdheer',9.575100,44.072003,'/img/wr15.jpg',DATEADD(DAY,-16,GETDATE())),
('WR16','U002','WT08',3.2,'Riyadh Area',9.576000,44.073002,'/img/wr16.jpg',DATEADD(DAY,-15,GETDATE())),
('WR17','U003','WT01',9.9,'Wajaale',9.577200,44.074000,'/img/wr17.jpg',DATEADD(DAY,-14,GETDATE())),
('WR18','CI94','WT02',1.2,'Masalaha North',9.578000,44.075000,'/img/wr18.jpg',DATEADD(DAY,-13,GETDATE())),
('WR19','U004','WT03',8.6,'Hodan Extension',9.579000,44.076000,'/img/wr19.jpg',DATEADD(DAY,-12,GETDATE())),
('WR20','U001','WT04',7.1,'Guryosamo',9.580100,44.077000,'/img/wr20.jpg',DATEADD(DAY,-11,GETDATE())),
('WR21','U002','WT05',2.9,'Ga’an Libah',9.581200,44.078100,'/img/wr21.jpg',DATEADD(DAY,-10,GETDATE())),
('WR22','CI94','WT09',6.0,'Koodbuur',9.582000,44.079000,'/img/wr22.jpg',DATEADD(DAY,-9,GETDATE())),
('WR23','U004','WT10',5.2,'Dilla',9.583200,44.080000,'/img/wr23.jpg',DATEADD(DAY,-8,GETDATE())),
('WR24','U003','WT04',4.5,'Baligubadle',9.584000,44.081000,'/img/wr24.jpg',DATEADD(DAY,-7,GETDATE())),
('WR25','U001','WT07',9.0,'Hargeisa East',9.585000,44.082000,'/img/wr25.jpg',DATEADD(DAY,-6,GETDATE())),
('WR26','CI94','WT02',8.0,'Iidaha',9.586100,44.083000,'/img/wr26.jpg',DATEADD(DAY,-5,GETDATE())),
('WR27','U002','WT08',4.1,'Kaah District',9.587000,44.084000,'/img/wr27.jpg',DATEADD(DAY,-4,GETDATE())),
('WR28','U003','WT01',5.9,'Sha’ab',9.588000,44.085000,'/img/wr28.jpg',DATEADD(DAY,-3,GETDATE())),
('WR29','U004','WT04',3.0,'Dami',9.589000,44.086000,'/img/wr29.jpg',DATEADD(DAY,-2,GETDATE())),
('WR30','U001','WT06',2.4,'Calaamada',9.590000,44.087000,'/img/wr30.jpg',DATEADD(DAY,-1,GETDATE())),
('WR31','U002','WT09',8.4,'Ali Hussein',9.591000,44.088000,'/img/wr31.jpg',GETDATE()),
('WR32','U003','WT05',7.1,'Halaya',9.592000,44.089000,'/img/wr32.jpg',GETDATE()),
('WR33','U004','WT02',6.2,'Shacabka',9.593000,44.090000,'/img/wr33.jpg',GETDATE()),
('WR34','U001','WT01',3.7,'Fagaare',9.594000,44.091000,'/img/wr34.jpg',GETDATE()),
('WR35','U002','WT07',4.9,'Kaabsan',9.595000,44.092000,'/img/wr35.jpg',GETDATE()),
('WR36','U003','WT03',9.9,'Masalaha South',9.596000,44.093000,'/img/wr36.jpg',GETDATE()),
('WR37','U004','WT09',5.7,'Wajaale',9.597000,44.094000,'/img/wr37.jpg',GETDATE()),
('WR38','U001','WT04',6.4,'Hodan Central',9.598000,44.095000,'/img/wr38.jpg',GETDATE()),
('WR39','CI94','WT08',3.5,'Borama',9.599000,44.096000,'/img/wr39.jpg',GETDATE()),
('WR40','U002','WT05',4.2,'Berbera South',9.600000,44.097000,'/img/wr40.jpg',GETDATE()),
('WR41','U003','WT06',5.0,'Gacan Libaax',9.601000,44.098000,'/img/wr41.jpg',GETDATE()),
('WR42','U004','WT07',6.1,'Sheikh',9.602000,44.099000,'/img/wr42.jpg',GETDATE()),
('WR43','U001','WT08',8.9,'Gabiley',9.603000,44.100000,'/img/wr43.jpg',GETDATE()),
('WR44','U002','WT09',4.8,'Odweyne',9.604000,44.101000,'/img/wr44.jpg',GETDATE()),
('WR45','U003','WT01',7.7,'Erigavo',9.605000,44.102000,'/img/wr45.jpg',GETDATE()),
('WR46','U004','WT02',5.4,'Eil Afwein',9.606000,44.103000,'/img/wr46.jpg',GETDATE()),
('WR47','U001','WT03',9.8,'Oog',9.607000,44.104000,'/img/wr47.jpg',GETDATE()),
('WR48','U002','WT04',3.6,'Garadag',9.608000,44.105000,'/img/wr48.jpg',GETDATE()),
('WR49','U003','WT05',2.5,'Dilla',9.609000,44.106000,'/img/wr49.jpg',GETDATE()),
('WR50','U004','WT06',4.0,'Sheedaha',9.610000,44.107000,'/img/wr50.jpg',GETDATE());

-- PICKUP REQUESTS 
DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    INSERT INTO PickupRequests(PickupId, ReportId, CollectorId, Status, ScheduledAt, CompletedAt)
    VALUES(
        'PK' + RIGHT('00' + CAST(@i AS NVARCHAR(2)),2),
        'WR' + RIGHT('00' + CAST(@i AS NVARCHAR(2)),2),
        CASE WHEN @i % 4 = 0 THEN 'U003' ELSE 'U002' END,
        CASE WHEN @i % 5 = 0 THEN 'Collected' ELSE 'Assigned' END,
        DATEADD(DAY,-@i,GETDATE()),
        CASE WHEN @i % 5 = 0 THEN DATEADD(DAY,-(@i-1),GETDATE()) ELSE NULL END
    );
    SET @i += 1;
END;

-- REWARD POINTS
INSERT INTO RewardPoints(RewardId, UserId, Amount, Type, Reference)
SELECT 
    'RP' + RIGHT('00' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS NVARCHAR(2)),2),
    CASE WHEN ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 4 = 0 THEN 'U004' ELSE 'U001' END,
    50 + (ROW_NUMBER() OVER(ORDER BY (SELECT NULL))*2),
    'Credit',
    'Pickup ' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS NVARCHAR(10))
FROM sys.objects WHERE type = 'U' AND name NOT LIKE 'sys%' AND name NOT LIKE 'queue_%';

-- REDEMPTION REQUESTS
DECLARE @j INT = 1;
WHILE @j <= 50
BEGIN
    INSERT INTO RedemptionRequests(RedemptionId, UserId, Amount, Method, Status, RequestedAt)
    VALUES(
        'RD' + RIGHT('00' + CAST(@j AS NVARCHAR(2)),2),
        CASE WHEN @j % 3 = 0 THEN 'U002' ELSE 'U001' END,
        100 + (@j*3),
        'Mobile Money',
        CASE WHEN @j % 4 = 0 THEN 'Approved' ELSE 'Pending' END,
        DATEADD(DAY,-@j,GETDATE())
    );
    SET @j += 1;
END;

-- NOTIFICATIONS 
DECLARE @k INT = 1;
WHILE @k <= 50
BEGIN
    INSERT INTO Notifications(NotificationId, UserId, Title, Message)
    VALUES(
        'NT' + RIGHT('00' + CAST(@k AS NVARCHAR(2)),2),
        CASE WHEN @k % 2 = 0 THEN 'U001' ELSE 'CI94' END,
        'System Update #' + CAST(@k AS NVARCHAR(10)),
        'Notification message #' + CAST(@k AS NVARCHAR(10)) + ' - your report or reward has been processed.'
    );
    SET @k += 1;
END;

-- PICKUP VERIFICATIONS
DECLARE @v INT = 1;
WHILE @v <= 50
BEGIN
    INSERT INTO PickupVerifications(VerificationId, PickupId, VerifiedKg, MaterialType, VerificationMethod)
    VALUES(
        'PV' + RIGHT('00' + CAST(@v AS NVARCHAR(2)),2),
        'PK' + RIGHT('00' + CAST(@v AS NVARCHAR(2)),2),
        3.0 + (@v * 0.2),
        'Plastic',
        'Manual'
    );
    SET @v += 1;
END;