CREATE DATABASE db22_penyewaan;

USE db22_penyewaan;

CREATE TABLE customer(
	id_customer nvarchar(5) PRIMARY KEY,
	nama nvarchar(50),
	telp nvarchar(15),
	alamat nvarchar(255),
	tgl_regist date,
	jenis_layanan nvarchar(20)
)

CREATE TABLE mobil(
	no_plat nvarchar (10) PRIMARY KEY,
	nama_mobil nvarchar (50),
	warna nvarchar (30),
	harga_sewa int,
	status int,
)

CREATE TABLE sewa(
	no_transaksi nvarchar (5) Primary Key,
	id_customer nvarchar (5),
	no_plat nvarchar (10),
	tgl_sewa date,
	lama_sewa int,
)

INSERT INTO customer VALUES('CS001','Ratu','085777546521','Jl. Warung Pojok','2015-01-10', 'Regular')
INSERT INTO customer VALUES('CS002', 'Ibrahim', '088121216335', 'Jl. Sudirman', '2015-03-13', 'Regular')
INSERT INTO customer VALUES('CS003','Syaiful','082132887469','Jl. Plumpang','2016-04-01', 'High')
INSERT INTO customer VALUES('CS004','Indah','081321547795','Jl. Tipar Cakung','2016-05-06','Regular')
INSERT INTO customer VALUES('CS005','Angga','081122224468','Jl. Tipar Timur','2017-03-15','High')

INSERT INTO mobil VALUES('B1108KLI','Toyota Yaris','Hitam','320000',1)
INSERT INTO mobil VALUES('B8655FXA','Honda Jazz','Silver','330000',1)	
INSERT INTO mobil VALUES('B9001HUL','Honda Brio','Hitam','295000',0)	
INSERT INTO mobil VALUES('B1248UXX','Daihatsu Ceria','Merah','310000',0)	
INSERT INTO mobil VALUES('B6654JKO','Daihatsu Ayla','Putih','280000',1)	
INSERT INTO mobil VALUES('B5587JJK','Nissan GT-R','Merah','370000',1)	
INSERT INTO mobil VALUES('B6588KHL','Toyota Corona','Hitam','350000',1)	


INSERT INTO sewa VALUES('TR001','CS004','B5587JJK','2017-02-15',1)	
INSERT INTO sewa VALUES('TR002','CS003','B8655FXA','2017-02-22',3)	
INSERT INTO sewa VALUES('TR003','CS005','B6654JKO','2017-03-05',2)	
INSERT INTO sewa VALUES('TR004','CS001','B1108KLI','2017-03-14',5)	
INSERT INTO sewa VALUES('TR005','CS002','B6588KHL','2017-03-20',1)	
---------------------------------------------------------------------------------

SELECT * FROM customer

--- a.	Tampilkan data mobil yang berwarna hitam
SELECT * FROM mobil WHERE warna = 'hitam'
--- b.	Tampilkan harga mobil diatas Rp. 300,000,-
SELECT harga_sewa FROM mobil WHERE harga_sewa > 300000
--- c.	Ubahlah layanan menjadi High untuk customer yang memiliki ID CS001
UPDATE customer SET jenis_layanan = 'High' WHERE id_customer = 'CS001'
--- d.	Tampilkan data customer yang menyewa mobil pada tanggal 05 Maret 2017
SELECT * FROM sewa INNER JOIN customer 
			ON customer.id_customer = sewa.id_customer 
			WHERE tgl_sewa = '2017-03-05'
--- e.	Tampilkan data transaksi untuk customer yang memiliki tgl_regist pada tahun 2015 – 2016

SELECT sewa.* FROM sewa INNER JOIN customer 
			ON customer.id_customer = sewa.id_customer 
			WHERE tgl_regist BETWEEN '2015-01-10' AND '2016-05-06'
			
--- f.	Tampilkan nama_customer, telp, nama_mobil, harga_sewa dan lama_sewa untuk transaksi yang memiliki tgl_sewa pada bulan maret 2017
SELECT nama, telp, nama_mobil, harga_sewa  FROM sewa INNER JOIN customer 
			ON customer.id_customer = sewa.id_customer 
			INNER JOIN mobil ON mobil.no_plat = sewa.no_plat
			WHERE tgl_sewa BETWEEN '2017-03-05' AND '2017-03-20'
			
--- g.	Delete Record TR005

DELETE FROM sewa WHERE no_transaksi = 'TR005'

--- h.	Buatlah trigger untuk mengupdate status menjadi 1 untuk no_plat yang diinput pada tabel sewa

GO
CREATE TRIGGER update_status ON sewa AFTER INSERT 
	AS BEGIN
		 DECLARE @no_plat nvarchar(15) 
		 SELECT @no_plat = no_plat FROM inserted
		 UPDATE mobil SET status = 1 WHERE no_plat = @no_plat
	END
GO
INSERT INTO sewa VALUES('TR005','CS002','B6588KHL','2017-03-20',1)
--- i.	Buatlah trigger untuk mengupdate status menjadi 0 untuk no_plat yang dihapus dari tabel sewa

GO
CREATE TRIGGER del_sewa ON sewa AFTER DELETE 
	AS BEGIN
		 DECLARE @no_plat nvarchar(15) 
		 SELECT @no_plat = no_plat FROM deleted
		 UPDATE mobil SET status = 0 WHERE no_plat = @no_plat
	END
GO
DELETE FROM sewa WHERE no_transaksi = 'TR005'

--- j. Buatlah procedure untuk menampilkan pesan “Mobil dengan no plat XXX sedang disewa selama XX” dengan menginput no_plat. (XXX adalah no_plat dan XX adalah lama_sewa)
GO
ALTER PROC tampilkan_Pesan (@no_plat nvarchar(10))
AS BEGIN
	DECLARE @h int
	SET @h = (SELECT lama_sewa FROM sewa
			INNER JOIN mobil ON mobil.no_plat = sewa.no_plat
			WHERE sewa.no_plat = @no_plat)
	PRINT 'Mobil dengan no plat '+@no_plat+' sedang disewa selama' + CAST(@h AS VARCHAR)
END
GO

EXEC tampilkan_Pesan 'B8655FXA'
--- Buatlah procedure untuk memunculkan jumlah customer yang memiliki layanan
--- Regular/High dengan menginput tipe layanan yang ingin ditampilkan

GO
CREATE PROC munc_jum_cust (@layanan nvarchar(10))
AS BEGIN
	DECLARE @h int
	SET @h = (SELECT COUNT(jenis_layanan) FROM customer WHERE jenis_layanan = @layanan)
	PRINT 'Jumlah Customer ' + CAST(@h AS VARCHAR)
END
GO

EXEC munc_jum_cust 'High'

---Buatlah procedure untuk menampilkan data transaksi sewa suatu mobil dengan menginput nama_mobil

GO
ALTER PROC menam_data_transaksi__ (@nama_mobil nvarchar(10))
AS BEGIN
	SELECT * FROM mobil
			LEFT JOIN sewa ON mobil.no_plat = sewa.no_plat
			WHERE nama_mobil = @nama_mobil
END
GO

EXEC menam_data_transaksi 'Honda Jazz'
