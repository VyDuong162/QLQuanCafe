CREATE DATABASE QuanLyQuanCoffee
GO

USE QuanLyQuanCoffee
GO
--Food
--Table
--FoodCategory
--Account
--Bill
--Billinfo
CREATE TABLE TableFood
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL,
	status NVARCHAR(100) NOT NULL DEFAULT N'Trống', -- trống hoặc không trống
)
GO
CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,
	FullName NVARCHAR(100) NOT NULL,
	PassWord NVARCHAR(1000) NOT NULL,
	TYPE INT NOT NULL DEFAULT 0, -- admin or nhân viên
)
GO
CREATE TABLE FoodCategory
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL
)
GO
CREATE TABLE Food
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL,
	idCategory INT NOT NULL,
	price FLoat NOT NULL,
	
)
GO
ALTER TABLE dbo.Food 
ADD CONSTRAINT FK_Food__idCategory
 FOREIGN KEY (idCategory) 
 REFERENCES dbo.FoodCategory (id)
 ON DELETE CASCADE;
CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	CheckIn DATE NOT NULL DEFAULT GETDATE(),
	CheckOut DATE NULL,
	idTable INT NOT NULL,
	status INT NOT NULL DEFAULT 0, -- 1 đã thanh toán hoặc 0 chưa
	discount INT DEFAULT 0,
	
)
GO
ALTER TABLE dbo.Bill 
ADD CONSTRAINT FK_Bill__idTable
 FOREIGN KEY (idTable) 
 REFERENCES dbo.TableFood (id)
 ON DELETE CASCADE;
CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood INT NOT NULL,
	count INT NOT NULL DEFAULT 0 -- 1 đã thanh toán hoặc 0 chưa
	
)
GO
ALTER TABLE dbo.BillInfo
ADD CONSTRAINT FK_BillInfo__idBill
 FOREIGN KEY (idBill) 
 REFERENCES dbo.Bill (id)
 ON DELETE CASCADE;
ALTER TABLE dbo.BillInfo
ADD CONSTRAINT FK_BillInfo__idFood
FOREIGN KEY (idFood) 
 REFERENCES dbo.Food (id)
ON DELETE CASCADE;
INSERT INTO [dbo].[Account]
           ([UserName]
           ,[FullName]
           ,[PassWord]
           ,[TYPE])
     VALUES
           (N'B1805734'
           ,N'Duong Vy'
           ,N'123456'
           ,1),
           (N'B1800000'
           ,N'Nhân viên'
           ,N'123456'
           ,0)
GO
--tạo dữ liệu cho bản TableFood
DECLARE @i INT = 1
WHILE @i <= 10
BEGIN
	INSERT dbo.TableFood (name) VALUES  ( N'Bàn ' + CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END
GO
INSERT dbo.FoodCategory
	(name)
	VALUES (N'Cafe phin'),
			(N'Trà'),
			(N'Trà sữa'),
			(N'Trà trái cây')
GO
INSERT dbo.Food
	(name,idCategory,price)
	VALUES (N'Cafe đen dá',1,15000),
			(N'Bạc xĩu',1,20000),
			(N'Trà bạc hà',2,15000),
			(N'Trà sữa ô long',3,25000),
			(N'Trà sữa Matcha',3,25000),
			(N'Trà thanh long',4,22000)
GO
INSERT dbo.Bill
	(CheckIn, CheckOut, idTable, status)
VALUES (GETDATE(),NULL,1,0)	,
		(GETDATE(),NULL,2,0),	
	(GETDATE(),GETDATE(),3,1)	
GO
INSERT dbo.BillInfo
	(idBill,idFood,count)
	VALUES (1,1,2),
			(1,3,1),
			(2,1,1),
			(2,2,3),
			(3,4,2),
			(3,5,2)
GO
CREATE PROC USP_GetAccountByUserName
@Username NVarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName =@Username;
END
GO

CREATE PROC USP_Login
@Username nvarchar(100), @Password nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @Username AND PassWord = @Password
END
GO
Exec USP_Login @Username =N'B1800000' , @Password=N'123456';

-- Procedure TableFood
CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableFood
GO
-- tao bill
CREATE PROC USP_InsertBill
@idTable INT
AS
BEGIN
INSERT dbo.Bill
		(CheckIn, CheckOut, idTable, status, discount)
		VALUES (GETDATE() , NULL , @idTable, 0, 0)
END
GO
-- tao BillInfor

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS
BEGIN
	DECLARE @isExitsBillInfo INT
	DECLARE @foodCount INT = 1
	SELECT @isExitsBillInfo = id, @foodCount = b.count
	FROM dbo.BillInfo as b
	WHERE idBill = @idBill AND idFood = @idFood
	
	IF(@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @foodCount + @count WHERE idFood = @idFood
		IF (@newCount > 0)
			UPDATE dbo.BillInfo SET count = @foodCount + @count
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
	END
	ELSE
	BEGIN
		INSERT dbo.BillInfo
		(idBill, idFood, count)
		VALUES (@idBill , @idFood , @count)
	END
END
GO
-- kiểm tra tạo mới bill
CREATE TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = idBill FROM Inserted
	
	DECLARE @idTable INT
	
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0
	
	UPDATE dbo.TableFood SET status = N'Không trống' WHERE id = @idTable
END
GO
--kiểm tra cập nhật bill
CREATE TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = idBill FROM Inserted
	
	DECLARE @idTable INT
	
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0
	DECLARE @countBillInfo INT
	SELECT  @countBillInfo = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idBill
	IF(@countBillInfo > 0)
	UPDATE dbo.TableFood SET status = N'Không trống' WHERE id = @idTable
	ELSE
	UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
	
END
GO

-- chuyển bàn

CREATE PROC USP_SwitchTabel
@idTable1 INT, @idTable2 INT
AS BEGIN 
	DECLARE @idFirstBill INT
	DECLARE @idSeconrdBill INT
	
	DECLARE @isFirstTablEmty INT = 1
	DECLARE @isSecondTablEmty INT = 1
	
	
	SELECT @idSeconrdBill = id FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
	
	PRINT @idFirstBill
	PRINT @idSeconrdBill
	PRINT '-----------'
	
	IF(@idFirstBill IS NULL)
	BEGIN
		INSERT dbo.Bill
		(CheckIn, CheckOut, idTable, status, discount)
		VALUES (GETDATE() , NULL , @idTable1, 0, 0)
		SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTable =@idTable1 AND status =0
	END
		SELECT @isFirstTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill
	IF(@idSeconrdBill IS NULL)
	BEGIN
		INSERT dbo.Bill
		(CheckIn, CheckOut, idTable, status, discount)
		VALUES (GETDATE() , NULL , @idTable2, 0, 0)
		SELECT @idSeconrdBill = MAX(id) FROM dbo.Bill WHERE idTable =@idTable2 AND status =0
	END
	
	SELECT @isSecondTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSeconrdBill
	
	PRINT @idFirstBill
	PRINT @idSeconrdBill
	PRINT '-----------'

	SELECT id INTO IDBillInfoTable FROM dbo.BillInfo WHERE idBill = @idSeconrdBill
	
	UPDATE dbo.BillInfo SET idBill = @idSeconrdBill WHERE idBill = @idFirstBill
	
	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)
	
	DROP TABLE IDBillInfoTable
	
	IF (@isFirstTablEmty = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable2
		
	IF (@isSecondTablEmty= 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable1
END
GO
-- cập nhật lại bàn khi chuyển
CREATE TRIGGER USP_UpdateTable
ON dbo.TableFood FOR UPDATE
AS
BEGIN
	DECLARE @idTable INT
	DECLARE @status NVARCHAR(100)
	
	SELECT @idTable = id, @status = inserted.status FROM Inserted
	
	DECLARE @idBill INT
	SELECT @idBill = id FROM dbo.Bill WHERE idTable = @idTable AND status =0
	
	DECLARE @countBillInfo INT
	SELECT @countBillInfo = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idBill
	IF(@countBillInfo > 0 AND @status <> N'Không trống')
	UPDATE dbo.TableFood SET status = N'Không trống' WHERE id = @idTable
	ELSE IF(@countBillInfo <= 0 AND @status <> N'Không')
	UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO
-- lấy list bill
Create PROC USP_GetListBillByDate
@checkIn date, @checkOut date
AS
BEGIN
	SELECT t.name [Tên bàn], CheckIn [Ngày vào], CheckOut [Ngày ra],b.totalPrice [Tổng tiền], discount [Giảm giá]
	FROM dbo.Bill as b, dbo.TableFood AS t
	WHERE CheckIn >= @checkIn AND CheckOut <= @checkOut AND b.status=1
	AND t.id = b.idTable
END
GO
-- thay doi thong tin ca nha
CREATE PROC USP_UpdateAccount
@Username NVARCHAR(100), @Fullname NVARCHAR(100), @password NVARCHAR(100), @newPass NVARCHAR(100)
AS
BEGIN
	DECLARE @isRightPass INT =0
	
	SELECT @isRightPass = COUNT(*) FROM dbo.Account WHERE UserName = @Username
	IF (@isRightPass = 1)
	BEGIN
		IF(@newPass = NULL OR @newPass = '')
		BEGIN
			UPDATE dbo.Account SET FullName = @Fullname WHERE UserName = @Username
		END
		ELSE
		UPDATE dbo.Account SET FullName = @Fullname, PassWord = @newPass WHERE UserName = @Username
	END
END
GO
-- kiểm tra xóa thông tin bill của bàn
CREATE TRIGGER UTG_DeleteBillInfo
ON dbo.BillInfo FOR DELETE
AS 
BEGIN
	DECLARE @idBillInfo INT
	DECLARE @idBill INT
	SELECT @idBillInfo = id, @idBill = Deleted.idBill FROM Deleted
	
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count INT = 0
	
	SELECT @count = COUNT(*) FROM dbo.BillInfo AS bi, dbo.Bill AS b WHERE b.id = bi.idBill AND b.id = @idBill AND b.status = 0
	
	IF (@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO
-- phân trang thống kê
CREATE PROC USP_GetListBillByDateAndPage
@checkIn date, @checkOut date, @page int
AS 
BEGIN
	DECLARE @pageRows INT = 10
	DECLARE @selectRows INT = @pageRows
	DECLARE @exceptRows INT = (@page - 1) * @pageRows
	
	;WITH BillShow AS( SELECT b.ID, t.name AS [Tên bàn], b.totalPrice AS [Tổng tiền], CheckIn AS [Ngày vào], CheckOut AS [Ngày ra], discount AS [Giảm giá]
	FROM dbo.Bill AS b,dbo.TableFood AS t
	WHERE CheckIn >= @checkIn AND CheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable)
	
	SELECT TOP (@selectRows) * FROM BillShow WHERE id NOT IN (SELECT TOP (@exceptRows) id FROM BillShow)
END
GO

CREATE PROC USP_GetNumBillByDate
@checkIn date, @checkOut date
AS 
BEGIN
	SELECT COUNT(*)
	FROM dbo.Bill AS b,dbo.TableFood AS t
	WHERE CheckIn >= @checkIn AND CheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable
END
GO
-- báo cáo doanh thu
CREATE PROC USP_GetListBillByDateForReport
@checkIn date, @checkOut date
AS 
BEGIN
	SELECT t.name,  CheckIn, CheckOut,b.totalPrice, discount
	FROM dbo.Bill AS b,dbo.TableFood AS t
	WHERE CheckIn >= @checkIn AND CheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable
END
GO
