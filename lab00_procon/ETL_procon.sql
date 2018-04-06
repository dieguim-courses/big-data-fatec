-- ETL - 06/abril
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


                               <- Regiao
CNAE -> Empresa -> Reclamação  <- Assunto
                               <- Problema
                       
-- extraindo dados da tabela base para criar tabelas referenciadas com código
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

DELETE FROM proconbase WHERE strRazaoSocial = 'NULL' ; 
UPDATE proconbase SET numeroCNPJ = '0' WHERE numeroCNPJ = 'NULL' ;

DELETE FROM proconbase
WHERE numeroCNPJ = '0' ; -- 52507 - 52499 + 8 de antes

-- base final 1.152.892

-- populando empresa
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
-- populando a nova tabela com CNPJs repetidos
INSERT INTO cnpj2 (cnpjduplo) 
SELECT e.cnpj
FROM empresa e
GROUP BY e.cnpj
HAVING COUNT(e.cnpj) > 1 ;

SELECT * FROM cnpj2 order by 1 ;

-- alterando a estrutura para pegar os duplicados
ALTER TABLE empresa ADD repetido SMALLINT ;

SELECT DISTINCT cnpjduplo FROM cnpj2 ;
-- bloco anônimo para setar o número de repitições do memso cnpj
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

-- excluindo os CNPJs repetidos
DELETE FROM empresa WHERE repetido > 1 ; --45453
-- quantos sobraram únicos
SELECT DISTINCT cnpj FROM empresa ; --89606
-- por fim
ALTER TABLE empresa ADD PRIMARY KEY ( cnpj) ;

/**********************
-- A S S U N T O
***********************/
-- assunto
DROP TABLE assunto CASCADE CONSTRAINTS ;
CREATE TABLE assunto
( cod_assunto SMALLINT ,
descr_assunto VARCHAR2(150) );

INSERT INTO assunto ( cod_assunto, descr_assunto)
SELECT DISTINCT CAST(regexp_replace(codigoassunto, '[^0-9]+', '') as number), 
TRIM ( descricaoassunto) FROM proconbase ;

-- verificando repetidos
SELECT cod_assunto, COUNT(*)
FROM assunto
GROUP BY cod_assunto
HAVING COUNT(*) > 1 ;  -- tem 7 repetidos

-- mesma estratégia de empresa, copia os repetidos pra outra tabela
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

--tabela problema
DROP TABLE problema CASCADE CONSTRAINTS;
CREATE TABLE problema
( cod_problema SMALLINT ,
descr_problema VARCHAR2(135) ) ;

INSERT INTO problema ( cod_problema, descr_problema)
SELECT DISTINCT CAST(regexp_replace(codigoProblema, '[^0-9]+', '') as number), 
TRIM ( descricaoProblema) FROM proconbase ; -- 281

SELECT cod_problema, COUNT(*)
FROM problema
GROUP BY cod_problema
HAVING COUNT(*) > 1 ;  -- tem 20 repetidos

-- mesma estratégia que assunto
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

SELECT cod_problema FROM problema WHERE cod_problema IS NULL ;
DELETE FROM problema WHERE cod_problema IS NULL ; 

-- por fim
ALTER TABLE problema ADD PRIMARY KEY ( cod_problema) ;

/****************
UF
*****************/
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

/****************************
limpando a tabela base
*****************************/
SELECT MAX(LENGTH(TRIM(UF))) FROM proconbase ; -- 2
SELECT MAX(LENGTH(TRIM(Atendida))) FROM proconbase ; -- 1
SELECT MAX(LENGTH(TRIM(SexoConsumidor))) FROM proconbase ; -- 1
SELECT DISTINCT TRIM(SexoConsumidor) FROM proconbase ; --4 tem NULL escrito
SELECT MAX(LENGTH(TRIM(CEPconsumidor))) FROM proconbase ; -- 13 - tem um 'Não se aplica' limpar
 
UPDATE proconbase SET SexoConsumidor = '' WHERE sexoconsumidor = 'NULL' ;


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
FROM proconbase  ;  --1152892

-- adicionando as FKs
ALTER TABLE procondw ADD FOREIGN KEY(cod_assunto) REFERENCES assunto ;
ALTER TABLE procondw ADD FOREIGN KEY(cod_problema) REFERENCES problema;
ALTER TABLE procondw ADD FOREIGN KEY(cod_regiao) REFERENCES regiao;
ALTER TABLE procondw ADD FOREIGN KEY(cnpj) REFERENCES empresa;
ALTER TABLE procondw ADD FOREIGN KEY(UF) REFERENCES UF;
ALTER TABLE empresa ADD FOREIGN KEY ( cod_cnae) REFERENCES CNAE ;

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
ORDER BY 4 ; -- 3186


UPDATE tempo SET id_tempo = seq_temp.nextval ; -- 3186

ALTER TABLE tempo ADD PRIMARY KEY ( id_tempo) ;

-- relacionando com tempo
ALTER TABLE procondw ADD id_tempo SMALLINT ;

-- usando a estrategia de criar uma tanbela temporaria para armazenar o id e o id da linha da tabela procondw
-- pq usar o update aninhado leva muito tempo
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


--UPDATE procondw dw SET dw.id_tempo = ( SELECT id_tempo FROM temporaria WHERE linha = dw.rowid ) ;
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

-- verificando
SELECT COUNT(id_tempo) FROM procondw ; -- ok

--
ALTER TABLE procondw ADD FOREIGN KEY (id_tempo) REFERENCES tempo ;