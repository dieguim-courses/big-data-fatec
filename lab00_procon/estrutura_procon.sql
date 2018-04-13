AnoCalendario	DataArquivamento	DataAbertura	CodigoRegiao	Regiao	UF	strRazaoSocial	strNomeFantasia	Tipo	NumeroCNPJ	RadicalCNPJ	RazaoSocialRFB	NomeFantasiaRFB	CNAEPrincipal	DescCNAEPrincipal	Atendida	CodigoAssunto	DescricaoAssunto	CodigoProblema	DescricaoProblema	SexoConsumidor	FaixaEtariaConsumidor	CEPConsumidor

Alter Session Set nls_language='BRAZILIAN PORTUGUESE';
Alter Session Set NLS_TERRITORY = 'BRAZIL';
Alter Session Set NLS_NUMERIC_CHARACTERS=',.';
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
SET LINESIZE 100;
SET serveroutput ON ;

DROP TABLE proconbase CASCADE CONSTRAINTS;
CREATE TABLE proconbase (
AnoCalendario NUMBER,
DataArquivamento TIMESTAMP,
DataAbertura TIMESTAMP,
CodigoRegiao SMALLINT,
Regiao VARCHAR2(15),
UF CHAR(2),
strRazaoSocial VARCHAR2(100 ),
strNomeFantasia VARCHAR2(80),
Tipo VARCHAR2(50),
NumeroCNPJ VARCHAR2(50),
RadicalCNPJ VARCHAR2(50),
RazaoSocialRFB VARCHAR2(150),
NomeFantasiaRFB VARCHAR2(100),
CNAEPrincipal VARCHAR2(100),
DescCNAEPrincipal VARCHAR2(200),
Atendida VARCHAR2(150),
CodigoAssunto VARCHAR2(150),
DescricaoAssunto VARCHAR2(150),
CodigoProblema VARCHAR2(150), 
DescricaoProblema VARCHAR2(500),
SexoConsumidor VARCHAR2(150),
FaixaEtariaConsumidor VARCHAR2(150) ,
CEPConsumidor VARCHAR2(120)) ;

SELECT tablespace_name, max_size FROM dba_tablespaces ;

ALTER TABLESPACE SYSTEM ADD DATAFILE '\oraclexe\app\oracle\oradata\XE\system2.dbf' SIZE 200M;
ALTER TABLESPACE SYSTEM ADD DATAFILE '\oraclexe\app\oracle\oradata\XE\system3.dbf' SIZE 300M;

AnoCalendario VARCHAR2(200),
DataArquivamento VARCHAR2(200),
DataAbertura VARCHAR2(200),
CodigoRegiao VARCHAR2(200) -> Regiao
Regiao VARCHAR2(200)       -> Regiao
UF VARCHAR2(200)           
strRazaoSocial VARCHAR2(150 ), -> Empresa
strNomeFantasia VARCHAR2(200), -> Empresa
Tipo VARCHAR2(200),
NumeroCNPJ VARCHAR2(200), -> Empresa
RadicalCNPJ VARCHAR2(200), -> Empresa
RazaoSocialRFB VARCHAR2(200), -> Empresa
NomeFantasiaRFB VARCHAR2(200), -> Empresa
CNAEPrincipal VARCHAR2(200), ->CNAE
DescCNAEPrincipal VARCHAR2(200), ->CNAE
Atendida VARCHAR2(200),
CodigoAssunto VARCHAR2(200)    -> Assunto
DescricaoAssunto VARCHAR2(200) -> Assunto
CodigoProblema VARCHAR2(200)   -> Problema
DescricaoProblema VARCHAR2(500) -> Problema
SexoConsumidor VARCHAR2(200),
FaixaEtariaConsumidor VARCHAR2(200) ,
CEPConsumidor VARCHAR2(200)) ;

                               <- Regiao
CNAE -> Empresa -> Reclamação  <- Assunto
                               <- Problema
                       

SELECT MAX(LENGTH(LTRIM(CodigoRegiao))), MAX(LENGTH(LTRIM(Regiao))), MAX(LENGTH(TRIM(UF)))
FROM proconbase ;

SELECT TO_NUMBER(LTRIM(CodigoRegiao)), TRIM(Regiao), TRIM(UF)
FROM proconbase ;

SELECT CodigoRegiao, TRIM(Regiao), TRIM(UF)
FROM proconbase
WHERE TRIM(CodigoRegiao) = '02' ;

SELECT TO_NUMBER(codigoregiao) FROM proconbase ;

SELECT DISTINCT cast(regexp_replace(CodigoRegiao, '[^0-9]+', '') as number) FROM proconbase
WHERE  TRIM(CodigoRegiao) = '02' ;

/***********************
-- R E G I Ã O 
*************************/
DROP TABLE regiao CASCADE CONSTRAINTS PURGE ;
CREATE TABLE regiao
( codigo_regiao SMALLINT,
regiao VARCHAR2(15));

INSERT INTO regiao ( codigo_regiao, regiao)
SELECT DISTINCT cast(regexp_replace(CodigoRegiao, '[^0-9]+', '') as number),
TRIM(regiao) FROM proconbase ;

ALTER TABLE regiao ADD PRIMARY KEY ( codigo_regiao) ;

/****************************
-- C N A E
*****************************/
SELECT MAX(LENGTH(TRIM(DescCNAEPrincipal))) FROM proconbase ; -- 164

DROP TABLE CNAE CASCADE CONSTRAINTS PURGE ;
CREATE TABLE CNAE
( cod_CNAE SMALLINT,
descr_CNAE VARCHAR2(165));

INSERT INTO CNAE ( cod_CNAE, descr_CNAE)
SELECT DISTINCT cast(regexp_replace(CNAEPrincipal, '[^0-9]+', '') as number),
TRIM(DescCNAEPrincipal) FROM proconbase ;

DELETE FROM Cnae WHERE cod_cnae IS NULL ;

- verifica duplicatas
SELECT cod_cnae, COUNT(*) FROM cnae
GROUP BY cod_cnae
HAVING COUNT(*) > 1 ;

SELECT * FROM cnae WHERE Cod_cnae = 4751201 ;
DELETE FROM CNAE WHERE TRIM(descr_cnae) = 'NULL' ;
-- definindo a PK
ALTER TABLE CNAE ADD PRIMARY KEY ( cod_CNAE) ;

/*************************
-- E M P R E S A 
**************************/
SELECT MAX(LENGTH(TRIM(strRazaoSocial))) FROM proconbase ; --100
SELECT MAX(LENGTH(TRIM(strNomeFantasia))) FROM proconbase ; --69
SELECT MAX(LENGTH(TRIM(RazaoSocialRFB))) FROM proconbase ; --150
SELECT MAX(LENGTH(TRIM(NomeFantasiaRFB))) FROM proconbase ; --55
SELECT MAX(LENGTH(TRIM(NumeroCNPJ))) FROM proconbase ; -- 14
-- tabela empresa
DROP TABLE empresa CASCADE CONSTRAINTS PURGE;
CREATE TABLE empresa
( CNPJ NUMBER(14) ,
CNPJ_radical INTEGER,
Razao_Social VARCHAR2(100) ,
Nome_Fantasia VARCHAR2(75),
RFB_Razao_Social VARCHAR2(150),
RFB_Nome_Fantasia VARCHAR2(75),
cod_CNAE SMALLINT );

SELECT COUNT(*) FROM proconbase
WHERE numeroCNPJ = 'NULL' ; -- 52507

SELECT COUNT(*) FROM proconbase
WHERE RadicalCNPJ = 'NULL' ; -- 53616

SELECT COUNT(*) FROM proconbase p
WHERE p.strRazaoSocial = 'NULL' ; -- 8  deletar

DELETE FROM proconbase WHERE strRazaoSocial = 'NULL' ; 

DELETE FROM proconbase
WHERE numeroCNPJ = '0' ; -- 52507 - 52499 + 8 de antes

-- base final 1.152.892

--UPDATE proconbase SET numeroCNPJ = '0' WHERE numeroCNPJ = 'NULL' ;

INSERT INTO empresa ( CNPJ, CNPJ_radical, Razao_Social, Nome_Fantasia, RFB_Razao_Social, RFB_Nome_Fantasia, cod_CNAE)
SELECT DISTINCT cast(regexp_replace(NumeroCNPJ, '[^0-9]+', '') as number),
cast(regexp_replace(RadicalCNPJ, '[^0-9]+', '') as number),
TRIM(strRazaoSocial), TRIM(strNomeFantasia), TRIM(RazaoSocialRFB),
TRIM(NomeFantasiaRFB),
cast(regexp_replace(CNAEPrincipal, '[^0-9]+', '') as number)
FROM proconbase ; 
-- 135059 linhas

-- verificando duplicatas de CNPJ
SELECT e.cnpj, COUNT(e.cnpj)
FROM empresa e
GROUP BY e.cnpj
HAVING COUNT(e.cnpj) > 1 ;  --14620

-- tabela auxiliar com os CNPJs repetidos
CREATE TABLE cnpj2
( cnpjduplo NUMBER(14) );

INSERT INTO cnpj2 (cnpjduplo) 
SELECT e.cnpj
FROM empresa e
GROUP BY e.cnpj
HAVING COUNT(e.cnpj) > 1 ;

SELECT * FROM cnpj2 order by 1 ;

-- alterando a estrutura para pegar os duplicados
ALTER TABLE empresa ADD repetido SMALLINT ;

SELECT DISTINCT cnpjduplo FROM cnpj2 ;
-- bloco anônimo para setar o número de repitções do memso cnpj
DECLARE
CURSOR duplo IS
SELECT cnpjduplo FROM cnpj2 ;
contador INTEGER := 0 ;
BEGIN
FOR j IN duplo LOOP
     contador := 0 ;
     FOR k IN ( SELECT rowid, e.cnpj, e.repetido FROM empresa e WHERE e.cnpj = j.cnpjduplo) LOOP
	     contador := contador + 1 ;
	    UPDATE empresa SET repetido = contador WHERE rowid = k.rowid ;
		DBMS_OUTPUT.PUT_LINE (contador||'//'|| k.rowid||'-'||TO_CHAR(k.cnpj,'99999999999999'));
      END LOOP ;
END LOOP ;
END ;

DELETE FROM empresa WHERE repetido > 1 ;

SELECT DISTINCT cnpj FROM empresa ; --89606


SELECT rowid, cnpj, Razao_Social
FROM empresa
WHERE cnpj = 97837181002190 ;

SELECT COUNT(*) FROM proconbase
WHERE numeroCNPJ = '0' ;

-- por fim
ALTER TABLE empresa ADD PRIMARY KEY ( cnpj) ;

/**********************
-- A S S U N T O
***********************/
SELECT DISTINCT codigoassunto FROM proconbase ;
SELECT COUNT(codigoassunto) FROM proconbase WHERE codigoassunto IS NULL ; - 'NULO'
SELECT MAX(LENGTH(TRIM(descricaoassunto))) FROM proconbase ; --148


SELECT DISTINCT CAST(regexp_replace(codigoassunto, '[^0-9]+', '') as number) AS codAssunto, 
TRIM ( descricaoassunto) FROM proconbase
ORDER BY 1  ;

-- assunto
DROP TABLE assunto CASCADE CONSTRAINTS ;
CREATE TABLE assunto
( cod_assunto SMALLINT ,
descr_assunto VARCHAR2(150) );

INSERT INTO assunto ( cod_assunto, descr_assunto)
SELECT DISTINCT CAST(regexp_replace(codigoassunto, '[^0-9]+', '') as number), 
TRIM ( descricaoassunto) FROM proconbase ;

SELECT cod_assunto, COUNT(*)
FROM assunto
GROUP BY cod_assunto
HAVING COUNT(*) > 1 ;  -- tem 7 repetidos

DROP TABLE assuntoduplo CASCADE CONSTRAINTS ;
CREATE TABLE assuntoduplo
( cod_assunto2 SMALLINT ) ;

INSERT INTO assuntoduplo ( cod_assunto2)
SELECT cod_assunto
FROM assunto
GROUP BY cod_assunto
HAVING COUNT(*) > 1 ;

-- alterando a estrutura para pegar os duplicados
ALTER TABLE assunto ADD repetido SMALLINT ;

-- bloco anônimo para setar o número de repitções do memso cnpj
DECLARE
CURSOR duplo IS
SELECT cod_assunto2 FROM assuntoduplo ;
contador INTEGER := 0 ;
BEGIN
FOR j IN duplo LOOP
     contador := 0 ;
     FOR k IN ( SELECT rowid, a.cod_assunto, a.repetido FROM assunto a WHERE a.cod_assunto = j.cod_assunto2) LOOP
	     contador := contador + 1 ;
	    UPDATE assunto SET repetido = contador WHERE rowid = k.rowid ;
		DBMS_OUTPUT.PUT_LINE (contador||'//'|| k.rowid||'-'||TO_CHAR(k.cod_assunto));
      END LOOP ;
END LOOP ;
END ;

SELECT * FROM assunto where repetido > 1 ;

DELETE FROM assunto WHERE repetido > 1 ;

-- por fim
ALTER TABLE assunto ADD PRIMARY KEY ( cod_assunto) ;

/*************************
-- P R O B L E M A
**************************/
codigoProblema, descricaoProblema

SELECT DISTINCT codigoProblema FROM proconbase ; -- 261
SELECT COUNT(*) FROM proconbase WHERE  codigoProblema IS NULL ; --'NULO' ;
SELECT MAX(LENGTH(TRIM(descricaoProblema))) FROM proconbase ; --148


SELECT DISTINCT CAST(regexp_replace(codigoProblema, '[^0-9]+', '') as number), 
TRIM ( descricaoProblema) FROM proconbase
ORDER BY 1  ; -- 281

--tabela problema
DROP TABLE problema CASCADE CONSTRAINTS;
CREATE TABLE problema
( cod_problema SMALLINT ,
descr_problema VARCHAR2(135) ) ;

INSERT INTO problema ( cod_problema, descr_problema)
SELECT DISTINCT CAST(regexp_replace(codigoProblema, '[^0-9]+', '') as number), 
TRIM ( descricaoProblema) FROM proconbase ;

SELECT cod_problema, COUNT(*)
FROM problema
GROUP BY cod_problema
HAVING COUNT(*) > 1 ;  -- tem 20 repetidos

DROP TABLE problemaduplo CASCADE CONSTRAINTS ;
CREATE TABLE problemaduplo
( cod_problema2 SMALLINT ) ;

INSERT INTO problemaduplo ( cod_problema2)
SELECT cod_problema
FROM problema
GROUP BY cod_problema
HAVING COUNT(*) > 1 ;

-- alterando a estrutura para pegar os duplicados
ALTER TABLE problema ADD repetido SMALLINT ;

-- bloco anônimo para setar o número de repetções do mesmo problema
DECLARE
CURSOR duplo IS
SELECT cod_problema2 FROM problemaduplo ;
contador INTEGER := 0 ;
BEGIN
FOR j IN duplo LOOP
     contador := 0 ;
     FOR k IN ( SELECT rowid, p.cod_problema, p.repetido FROM problema p WHERE p.cod_problema = j.cod_problema2) LOOP
	     contador := contador + 1 ;
	    UPDATE problema SET repetido = contador WHERE rowid = k.rowid ;
		DBMS_OUTPUT.PUT_LINE (contador||'//'|| k.rowid||'-'||TO_CHAR(k.cod_problema));
      END LOOP ;
END LOOP ;
END ;

SELECT * FROM problema where repetido > 1 ;

DELETE FROM problema WHERE repetido > 1 ; -- ficou com 260

-- por fim
ALTER TABLE problema ADD PRIMARY KEY ( cod_problema) ;

/****************
UF
*****************/
SELECT DISTINCT TRIM(UF) FROM proconbase ; 

DROP TABLE UF CASCADE CONSTRAINTS ;
CREATE TABLE UF
( UF CHAR(2) ,
Nome_UF VARCHAR2(50) ) ;

-- populando
INSERT INTO UF ( UF)
SELECT DISTINCT TRIM(UF) FROM proconbase ;  

ALTER TABLE UF ADD PRIMARY KEY (UF) ;

UPDATE UF set nome_uf = 'SAO PAULO' WHERE uf = 'SP';
UPDATE UF set nome_uf = 'Acre' WHERE uf = 'AC' ;
UPDATE UF set nome_uf = 'Alagoas' WHERE uf = 'AL' ;
UPDATE UF set nome_uf = 'Amapa' WHERE uf = 'AP' ;
UPDATE UF set nome_uf = 'Amazonas' WHERE uf = 'AM' ;
UPDATE UF set nome_uf = 'Bahia' WHERE uf = 'BA' ;
UPDATE UF set nome_uf = 'Ceara' WHERE uf = 'CE' ;
UPDATE UF set nome_uf = 'Distrito Federal' WHERE uf = 'DF' ;
UPDATE UF set nome_uf = 'Espirito Santo' WHERE uf = 'ES' ;
UPDATE UF set nome_uf = 'Goias' WHERE uf = 'GO' ;
UPDATE UF set nome_uf = 'Maranhao' WHERE uf = 'MA' ; 
UPDATE UF set nome_uf = 'Mato Grosso' WHERE uf = 'MT' ; 
UPDATE UF set nome_uf = 'Mato Grosso do Sul' WHERE uf = 'MS' ; 
UPDATE UF set nome_uf = 'Minas Gerais' WHERE uf = 'MG' ; 
UPDATE UF set nome_uf = 'Para' WHERE uf = 'PA' ; 
UPDATE UF set nome_uf = 'Paraiba' WHERE uf = 'PB' ; 
UPDATE UF set nome_uf = 'Parana' WHERE uf = 'PR' ; 
UPDATE UF set nome_uf = 'Pernambuco' WHERE uf = 'PE' ; 
UPDATE UF set nome_uf = 'Piaui' WHERE uf = 'PI' ; 
UPDATE UF set nome_uf = 'Rio de Janeiro' WHERE uf = 'RJ' ;
UPDATE UF set nome_uf = 'Rio Grande do Norte' WHERE uf = 'RN' ; 
UPDATE UF set nome_uf = 'Rio Grande do Sul' WHERE uf = 'RS' ; 
UPDATE UF set nome_uf = 'Rondonia' WHERE uf = 'RO' ; 
UPDATE UF set nome_uf = 'Roraima' WHERE uf = 'RR' ; 
UPDATE UF set nome_uf = 'Santa Catarina' WHERE uf = 'SC' ; 
UPDATE UF set nome_uf = 'Sergipe' WHERE uf = 'SE' ; 
UPDATE UF set nome_uf = 'Tocantins' WHERE uf = 'TO' ;

UPDATE UF set nome_UF = UPPER(nome_UF);

/************************************************
tempo -- criado depois da tabela procondw populada
**************************************************/
DROP TABLE tempo CASCADE CONSTRAINTS ;
CREATE TABLE tempo
( id_tempo INTEGER,
ano_abertura SMALLINT,
mes_abertura SMALLINT,
trim_abertura SMALLINT,
dt_abertura DATE,
qtde_data SMALLINT) ;

CREATE SEQUENCE seq_temp START WITH 10000 ;

-- populando tempo
INSERT INTO tempo ( ano_abertura, mes_abertura, trim_abertura, dt_abertura, qtde_data)
SELECT EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), TO_NUMBER(TO_CHAR(dt_abertura, 'Q')),
TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY')), COUNT(*)
FROM procondw
GROUP BY EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), TO_NUMBER(TO_CHAR(dt_abertura, 'Q')),
TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY'))
ORDER BY 4 ;


UPDATE tempo SET id_tempo = seq_temp.nextval ; -- 3186

ALTER TABLE tempo ADD PRIMARY KEY ( id_tempo) ;


/****************************
limpando a tabela base
*****************************/
SELECT MAX(LENGTH(TRIM(UF))) FROM proconbase ; -- 2
SELECT MAX(LENGTH(TRIM(Atendida))) FROM proconbase ; -- 1
SELECT MAX(LENGTH(TRIM(SexoConsumidor))) FROM proconbase ; -- 1
SELECT DISTINCT TRIM(SexoConsumidor) FROM proconbase ;
SELECT MAX(LENGTH(TRIM(CEPconsumidor))) FROM proconbase ; -- 13 - tem um 'Não se aplica' limpar

UPDATE proconbase SET cepconsumidor = '0' WHERE UPPER(cepconsumidor) LIKE '%APLICA%' ;

SELECT MAX(LENGTH(regexp_replace(CodigoProblema, '[^0-9]+', ''))) FROM proconbase ;

DROP TABLE procondw CASCADE CONSTRAINTS;
CREATE TABLE procondw (
Ano_Calendario NUMBER,
Dt_Arquivamento TIMESTAMP,
Dt_Abertura TIMESTAMP,
Cod_Regiao SMALLINT,
UF CHAR(2),
CNPJ NUMBER(14),
Atendida CHAR(1),
Cod_Assunto SMALLINT,
Cod_Problema SMALLINT, 
Sexo_Consumidor CHAR(1),
Faixa_Etaria_Consumidor CHAR(20) ,
CEP_Consumidor CHAR(8)) ;


INSERT INTO procondw ( Ano_Calendario, Dt_arquivamento, Dt_Abertura, Cod_Regiao, UF, CNPJ,
                       Atendida, Cod_assunto, Cod_problema, Sexo_consumidor,
					   Faixa_Etaria_consumidor, CEP_Consumidor)
SELECT anocalendario, dataarquivamento, dataabertura,
CAST(regexp_replace(CodigoRegiao, '[^0-9]+', '') as number),
TRIM (UF) , 
CAST(regexp_replace(NumeroCNPJ, '[^0-9]+', '') as number), 
TRIM(Atendida) , 
CAST(regexp_replace(CodigoAssunto, '[^0-9]+', '') as number),
CAST(regexp_replace(CodigoProblema, '[^0-9]+', '') as number), TRIM(Sexoconsumidor) ,
TRIM(FaixaEtariaConsumidor), TRIM(CEPConsumidor)
FROM proconbase  ;

-- adicionando as FKs
ALTER TABLE procondw ADD FOREIGN KEY(cod_assunto) REFERENCES assunto ;
ALTER TABLE procondw ADD FOREIGN KEY(cod_problema) REFERENCES problema;
ALTER TABLE procondw ADD FOREIGN KEY(cod_regiao) REFERENCES regiao;
ALTER TABLE procondw ADD FOREIGN KEY(cnpj) REFERENCES empresa;
ALTER TABLE procondw ADD FOREIGN KEY(UF) REFERENCES UF;
ALTER TABLE empresa ADD FOREIGN KEY ( cod_cnae) REFERENCES CNAE ;

SELECT faixaetariaconsumidor, sexoconsumidor, cepconsumidor, COUNT(*)
from proconbase
GROUP BY faixaetariaconsumidor, sexoconsumidor, cepconsumidor
HAVING COUNT(*) > 1 ;

-- relacionando com tempo
ALTER TABLE procondw ADD id_tempo SMALLINT ;

INSERT INTO temporaria ( tempo, linha ) 
SELECT t.id_tempo, dw.rowid  FROM tempo t, procondw dw
WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))
AND dw.ano_calendario = 2016 ;

CREATE INDEX idx_dtabre
ON procondw ( dt_abertura) ;

CREATE INDEX idx_dtabre_t
ON tempo ( dt_abertura) ;

-- outro metodo mais rápido
CREATE TABLE temporaria
( tempo SMALLINT,
linha CHAR(18)) ;

CREATE INDEX idx_timetemp ON temporaria (tempo) ;
CREATE INDEX idx_linha ON temporaria ( linha) ;

-- menos de 5s
DECLARE
anoini SMALLINT := 2012 ;
BEGIN
WHILE anoini <= 2016 LOOP
INSERT INTO temporaria ( tempo, linha ) 
SELECT t.id_tempo, dw.rowid  FROM tempo t, procondw dw
WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))
AND dw.ano_calendario = anoini ;
anoini := anoini + 1 ;
END LOOP ;
END ;

UPDATE procondw dw SET dw.id_tempo = ( SELECT id_tempo FROM temporaria WHERE linha = dw.rowid ) ;
-- muito demorado

-- usando cursor, mais rápido
DECLARE
CURSOR temp IS
SELECT tempo, linha FROM temporaria ORDER BY linha ;
BEGIN
FOR j in temp LOOP
   UPDATE procondw SET id_tempo = j.tempo WHERE rowid = j.linha ; 
END LOOP;
END ;

--
ALTER TABLE procondw ADD FOREIGN KEY (id_tempo) REFERENCES tempo ;



/****************************************
-- tabela cubo
*****************************************/
DROP TABLE proconcubo CASCADE CONSTRAINTS ;
CREATE TABLE proconcubo
()
;


-- abandonado, demora muito
DECLARE
CURSOR tempo IS
SELECT id_tempo, dt_abertura
FROM tempo
WHERE id_tempo < 11000
ORDER BY 1 ;
contador SMALLINT := 1 ;
BEGIN
FOR k IN tempo LOOP
    FOR w IN ( SELECT dw.rowid AS linha
	           FROM procondw dw
	           WHERE TO_DATE(TO_CHAR(k.dt_abertura, 'DD/MM/YYYY')) =
            		   TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))) LOOP
	DBMS_OUTPUT.PUT_LINE ( contador||'/'||w.linha);
	UPDATE procondw SET id_tempo = k.id_tempo
	WHERE rowid = w.linha ;
	contador := contador + 1 ;
	END LOOP ;
END LOOP;
END ;	



UPDATE procondw dw SET dw.id_tempo = ( 
   SELECT t.id_tempo FROM tempo t
    WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY')) 
	AND t.)
WHERE dw.ano_calendario = 2016 ;



SELECT EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), TO_NUMBER(TO_CHAR(dt_abertura, 'Q')),
TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY')), COUNT(*)
FROM procondw
GROUP BY EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), TO_NUMBER(TO_CHAR(dt_abertura, 'Q')),
TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY'))
ORDER BY 4 ;



/********************* acabei não usando
DROP SEQUENCE cnpjvazio ;
CREATE SEQUENCE cnpjvazio START WITH 900000 ;
UPDATE empresa SET cnpj = cnpjvazio.nextval
WHERE cnpj = 0 ;
********************************/

-- tentativa frustrada
SELECT cnpj FROM empresa
WHERE TRIM(RFB_Razao_Social) IN ( SELECT DISTINCT TRIM(strRazaoSocial) FROM proconbase WHERE NumeroCNPJ = '0');

DECLARE
contagem INTEGER := 0 ;
CURSOR selecao IS
SELECT e.cnpj, COUNT(e.cnpj) 
	 FROM empresa e WHERE TRIM(e.Razao_Social)IN 
	 ( SELECT DISTINCT TRIM(strRazaoSocial) AS Rzsoc FROM proconbase )
	 --WHERE NumeroCNPJ = '0') 
GROUP BY e.cnpj 
HAVING COUNT(e.cnpj) > 1 ;
BEGIN
FOR j IN selecao LOOP
contagem := contagem + 1 ;
   DBMS_OUTPUT.PUT_LINE ( 'Alerta !!! '||j.cnpj||'\\'||contagem)  ;
END LOOP ;
END ;


-- traz cnpj duplicado para o mesmo nome, mas pode ser filial
SELECT e.cnpj, COUNT(e.cnpj) 
	 FROM empresa e WHERE TRIM(e.Razao_Social)IN 
	 ( SELECT DISTINCT TRIM(strRazaoSocial) AS Rzsoc FROM proconbase WHERE NumeroCNPJ = '0') 
GROUP BY e.cnpj ;

SELECT e.cnpj FROM empresa e 
WHERE e.cnpj = 0 ;

SELECT COUNT(p.NumeroCNPJ) FROM proconbase p
WHERE p.NumeroCNPJ = '0' ; 52k

SELECT COUNT(p.RadicalCNPJ) FROM proconbase p
WHERE p.RadicalCNPJ = 'NULL' ; 53k

SELECT COUNT(*) FROM proconbase p
WHERE p.strRazaoSocial = 'NULL' ; 

-- não funciona por causa do IN
UPDATE proconbase pb SET pb.NumeroCNPJ IN ( SELECT DISTINCT TO_CHAR(e.CNPJ)
FROM empresa e WHERE TRIM(pb.strRazaoSocial) = TRIM(e.Razao_Social))  
WHERE pb.NumeroCNPJ = '0' ;

SELECT COUNT(*) FROM empresa
WHERE TRIM(NumeroCNPJ) = 'NULL' ;

-- testes formato data 
SELECT EXTRACT(YEAR FROM TO_TIMESTAMP(dataabertura)), TO_CHAR(dataabertura, 'DD/MM/YYYY'), COUNT(*)
FROM proconbase
GROUP BY EXTRACT(YEAR FROM TO_DATE(dataabertura)), TO_CHAR(dataabertura, 'DD/MM/YYYY');
