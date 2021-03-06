CREATE DATABASE BAITHI

USE BAITHI

CREATE TABLE NHACUNGCAP
(
	MANCC CHAR(5) PRIMARY KEY,
	TENNCC VARCHAR(50),
	QUOCGIA VARCHAR(50),
	LOAINCC VARCHAR(50)
)


CREATE TABLE DUOCPHAM
(
	MADP CHAR(4) PRIMARY KEY,
	TENDP VARCHAR(50),
	LOAIDP VARCHAR(50),
	GIA MONEY
)


CREATE TABLE PHIEUNHAP
(
	SOPN CHAR(5) PRIMARY KEY,
	NGNHAP SMALLDATETIME,
	MANCC CHAR(5),
	LOAINHAP VARCHAR(50)
)



CREATE TABLE CTPN
(
	SOPN CHAR(5) NOT NULL,
	MADP CHAR(5) NOT NULL,
	SOLUONG INT
)



ALTER TABLE PHIEUNHAP
ADD CONSTRAINT FK_PN_NCC FOREIGN KEY (MANCC)
REFERENCES NHACUNGCAP (MANCC)



ALTER TABLE CTPN
ADD CONSTRAINT PK_CTPN_PN_DP PRIMARY KEY (SOPN, MADP)


INSERT INTO NHACUNGCAP(MANCC, TENNCC, QUOCGIA, LOAINCC ) VALUES ('NCC01', 'Phuc Hung', 'Viet Nam', 'Thuong xuyen' )
INSERT INTO NHACUNGCAP(MANCC, TENNCC, QUOCGIA, LOAINCC ) VALUES ('NCC02', 'J. B. Pharmaceuticals', 'India', 'Vang lai')
INSERT INTO NHACUNGCAP(MANCC, TENNCC, QUOCGIA, LOAINCC ) VALUES ('NCC03', 'Sapharco', 'Singapore', 'Vang lai' )
SELECT * FROM NHACUNGCAP


INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA ) VALUES ('DP01', 'Thuoc ho PH', 'Siro', 120000 )
INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA ) VALUES ('DP02', 'Zecuf Herbal CouchRemedy', 'Vien nen', 200000 )
INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA ) VALUES ('DP03', 'Cotrim', 'Vien sui', 80000 )
SELECT * FROM DUOCPHAM


SET DATEFORMAT DMY
INSERT INTO PHIEUNHAP(SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00001', '22/11/2017', 'NCC01', 'Noi dia' )
INSERT INTO PHIEUNHAP(SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00002', '04/12/2017', 'NCC03', 'Nhap khau' )
INSERT INTO PHIEUNHAP(SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00003', '10/12/2017', 'NCC02', 'Nhap khau' )
SELECT * FROM PHIEUNHAP


INSERT INTO CTPN (SOPN, MADP, SOLUONG ) VALUES ('00001', 'DP01', 100 )
INSERT INTO CTPN (SOPN, MADP, SOLUONG ) VALUES ('00001', 'DP02', 200 )
INSERT INTO CTPN (SOPN, MADP, SOLUONG ) VALUES ('00003', 'DP03', 543 )
SELECT * FROM CTPN



CREATE TRIGGER I_U_DP
ON DUOCPHAM 
FOR INSERT, UPDATE
AS
BEGIN
	IF (EXISTS (	SELECT *
					FROM INSERTED I
					WHERE LOAIDP = 'Siro' AND GIA <= 100000
				)
		)
		BEGIN
		PRINT 'ERROR: TAT CA CAC DUOCPHAM LOAIDP LA SIRO DEU CO GIA > 100.000'
		ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
		PRINT 'THEM HOAC SUA THANH CONG'
		END
END;



CREATE TRIGGER U_NCC
ON NHACUNGCAP
FOR UPDATE
AS
BEGIN
	IF (EXISTS (	SELECT *
					FROM INSERTED I JOIN PHIEUNHAP PN ON PN.MANCC = I.MANCC
					WHERE QUOCGIA <> 'Viet Nam' AND LOAINHAP <> 'Nhap khau'
				)
		)
		BEGIN
		PRINT 'ERROR: PHIEUNHAP CUA NHACUNGCAP O QUOCGIA KHAC VIETNAM DEO O LOAINHAP LA NHAPKHAU'
		ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
		PRINT 'SUA THANH CONG'
		END
END;



CREATE TRIGGER I_U_PN
ON PHIEUNHAP
FOR UPDATE, INSERT
AS
BEGIN
	IF (EXISTS (	SELECT *
					FROM INSERTED I JOIN NHACUNGCAP NCC ON NCC.MANCC = I.MANCC
					WHERE QUOCGIA <> 'Viet Nam' AND LOAINHAP <> 'Nhap khau'
				)
		)
		BEGIN
		PRINT 'ERROR: PHIEUNHAP CUA NHACUNGCAP O QUOCGIA KHAC VIETNAM DEO O LOAINHAP LA NHAPKHAU'
		ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
		PRINT 'THEM HOAC SUA THANH CONG'
		END
END;



SELECT *
FROM PHIEUNHAP 
WHERE MONTH(NGNHAP) IN (10, 11, 12) AND YEAR(NGNHAP) = 2017
ORDER BY DAY(NGNHAP) ASC



SELECT DP.MADP, TENDP, LOAIDP, GIA
FROM DUOCPHAM DP JOIN CTPN ON DP.MADP = CTPN.MADP 
		JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
WHERE YEAR(NGNHAP) = 2017 AND SOLUONG >= ALL ( SELECT SOLUONG
												FROM CTPN C JOIN PHIEUNHAP P ON C.SOPN = P.SOPN
												WHERE YEAR(NGNHAP) = 2017
											)



SELECT DP.MADP, TENDP, LOAIDP, GIA
FROM DUOCPHAM DP JOIN CTPN ON DP.MADP = CTPN.MADP 
		JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
		JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
WHERE LOAINCC = 'Thuong xuyen' and DP.MADP NOT IN (	SELECT D.MADP
													FROM DUOCPHAM D JOIN CTPN C ON D.MADP = C.MADP 
															JOIN PHIEUNHAP P ON P.SOPN = C.SOPN
															JOIN NHACUNGCAP N ON N.MANCC = P.MANCC
													WHERE LOAINCC = 'Vang lai' 
													)



SELECT DP.MADP, TENDP, LOAIDP, GIA
FROM DUOCPHAM DP JOIN CTPN ON DP.MADP = CTPN.MADP 
		JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
		JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
WHERE LOAINCC = 'Thuong xuyen' and PN.MANCC NOT IN (	SELECT MANCC
														FROM NHACUNGCAP
														WHERE LOAINCC = 'Vang lai' 
													)



SELECT NCC.MANCC , TENNCC, QUOCGIA, LOAINCC
FROM NHACUNGCAP NCC JOIN PHIEUNHAP PN ON PN.MANCC = NCC.MANCC
WHERE YEAR(NGNHAP) = 2017 AND NOT EXISTS (	SELECT *
					FROM DUOCPHAM DP
					WHERE GIA > 100000 AND NOT EXISTS (	SELECT * 
														FROM CTPN
														WHERE CTPN.MADP = DP.MADP AND CTPN.SOPN = PN.SOPN
														)
					)