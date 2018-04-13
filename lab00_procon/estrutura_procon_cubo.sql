
/************* REFAZENDO tempo *******************
12 de abril *******/
DROP TABLE tempo CASCADE CONSTRAINTS ;
CREATE TABLE tempo
( id_tempo INTEGER,
ano_calendario SMALLINT,
ano_abertura SMALLINT,
mes_abertura SMALLINT,
trim_abertura SMALLINT,
dt_abertura DATE,
dt_arquivamento DATE ,
qtde_data SMALLINT) ;

DROP SEQUENCE seq_temp ;
CREATE SEQUENCE seq_temp START WITH 500000 ;

-- populando tempo
INSERT INTO tempo ( ano_calendario, ano_abertura, mes_abertura, trim_abertura, dt_abertura, dt_arquivamento, qtde_data)
SELECT ano_calendario, EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), TO_NUMBER(TO_CHAR(dt_abertura, 'Q')),
TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY')), TO_DATE(TO_CHAR(dt_arquivamento, 'DD/MM/YYYY')), COUNT(*)
FROM procondw
GROUP BY ano_calendario, EXTRACT( YEAR FROM dt_abertura), EXTRACT(MONTH FROM dt_abertura), 
TO_NUMBER(TO_CHAR(dt_abertura, 'Q')), TO_DATE(TO_CHAR(dt_abertura, 'DD/MM/YYYY')), 
TO_DATE(TO_CHAR(dt_arquivamento, 'DD/MM/YYYY'))
ORDER BY 4 ;


UPDATE tempo SET id_tempo = seq_temp.nextval ; -- 3186

ALTER TABLE tempo ADD PRIMARY KEY ( id_tempo) ;

-- relacionando com tempo
ALTER TABLE procondw DROP COLUMN id_tempo ;
ALTER TABLE procondw ADD id_tempo INTEGER ;

/*** teste
INSERT INTO temporaria ( tempo, linha ) 
SELECT t.id_tempo, dw.rowid  FROM tempo t, procondw dw
WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))
AND dw.ano_calendario = 2016 ; ***/

CREATE INDEX idx_dtabre
ON procondw ( dt_abertura) ;

CREATE INDEX idx_dtabre_t
ON tempo ( dt_abertura) ;

-- outro metodo mais rápido
DROP TABLE temporaria CASCADE CONSTRAINTS ;
CREATE TABLE temporaria
( tempo SMALLINT,
linha CHAR(18)) ;

CREATE INDEX idx_timetemp ON temporaria (tempo) ;
CREATE INDEX idx_linha ON temporaria ( linha) ;


--teste com 1 ano só
INSERT INTO temporaria ( tempo, linha ) 
SELECT t.id_tempo, dw.rowid  FROM tempo t, procondw dw
WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))
AND TO_DATE(TO_CHAR(t.dt_arquivamento, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_arquivamento, 'DD/MM/YYYY'))
AND t.ano_calendario = dw.ano_calendario
AND dw.ano_calendario = 2016 ; ***/

-- menos de 5s
DECLARE
anoini SMALLINT := 2012 ;
BEGIN
WHILE anoini <= 2016 LOOP
INSERT INTO temporaria ( tempo, linha ) 
SELECT t.id_tempo, dw.rowid  FROM tempo t, procondw dw
WHERE TO_DATE(TO_CHAR(t.dt_abertura, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_abertura, 'DD/MM/YYYY'))
AND TO_DATE(TO_CHAR(t.dt_arquivamento, 'DD/MM/YYYY')) = TO_DATE(TO_CHAR(dw.dt_arquivamento, 'DD/MM/YYYY'))
AND t.ano_calendario = dw.ano_calendario
AND dw.ano_calendario = anoini ;
anoini := anoini + 1 ;
END LOOP ;
END ;

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

/******************************
-- tratamento consumidor
*******************************/
-- excluindo não se aplica ;
SELECT COUNT(*) FROM procondw WHERE faixa_etaria_consumidor LIKE '%aplica%' ;
DELETE FROM procondw WHERE faixa_etaria_consumidor LIKE '%aplica%' ;
SELECT MAX(LENGTH(TRIM(faixa_etaria_consumidor))) FROM procondw ;
SELECT MAX(LENGTH(TRIM(cep_consumidor))) FROM procondw ;
SELECT MAX(LENGTH(TRIM(sexo_consumidor))) FROM procondw ;
-- 2
DROP TABLE consumidor CASCADE CONSTRAINTS ;
CREATE TABLE consumidor
( id_consumidor SMALLINT ,
faixa_etaria CHAR(18),
cep_consumidor NUMBER(8),
sexo_consumidor CHAR(1),
count_consumidor SMALLINT );

INSERT INTO consumidor ( faixa_etaria, cep_consumidor, sexo_consumidor, count_consumidor)
SELECT TRIM(faixa_etaria_consumidor), CAST(regexp_replace(cep_consumidor, '[^0-9]+', '') as number),
TRIM(sexo_consumidor), COUNT(*)
from procondw
GROUP BY TRIM(faixa_etaria_consumidor), CAST(regexp_replace(cep_consumidor, '[^0-9]+', '') as number),
TRIM(sexo_consumidor)
ORDER BY 1,3,2 ; -- 547259

DROP SEQUENCE seq_customer ;
CREATE SEQUENCE seq_customer ;
UPDATE consumidor SET id_consumidor = seq_customer.nextval ;

ALTER TABLE consumidor ADD PRIMARY KEY ( id_consumidor) ;

-- outro metodo mais rápido
DROP TABLE temporariac CASCADE CONSTRAINTS ;
CREATE TABLE temporariac
( consumidor INTEGER,
linha CHAR(18)) ;

CREATE INDEX idx_consumtemp ON temporariac (consumidor) ;
CREATE INDEX idx_linhaconsum ON temporariac ( linha) ;


-- direto
INSERT INTO temporariac ( consumidor, linha ) 
SELECT c.id_consumidor, dw.rowid FROM consumidor c, procondw dw
WHERE c.faixa_etaria = TRIM(dw.faixa_etaria_consumidor)
AND c.cep_consumidor = CAST(regexp_replace(dw.cep_consumidor, '[^0-9]+', '') as number)
AND c.sexo_consumidor =  TRIM(dw.sexo_consumidor); --972302 / -- antes 907984

-- alterando procondw
ALTER TABLE procondw DROP COLUMN id_consumidor ;
ALTER TABLE procondw ADD id_consumidor INTEGER ;

-- usando cursor, mais rápido
DECLARE
CURSOR customer IS
SELECT consumidor, linha FROM temporariac ORDER BY linha ;
BEGIN
FOR k in customer LOOP
   UPDATE procondw SET id_consumidor = k.consumidor WHERE rowid = k.linha ; 
END LOOP;
END ; 
-- 179861

-- 907984
-- 244179 nulos
--
ALTER TABLE procondw ADD FOREIGN KEY (id_tempo) REFERENCES tempo ;

SELECT COUNT(*) FROM procondw
where id_consumidor IS NULL ;

SELECT faixa_etaria_consumidor, cep_consumidor, sexo_consumidor
FROM procondw
where id_consumidor IS NULL
AND ROWNUM < 100 
ORDER BY 2, 1 , 3;

SELECT * FROM consumidor WHERE cep_consumidor = '0' 
ORDER BY faixa_etaria, sexo_consumidor ;


/****************************************
-- tabela cubo
*****************************************/
DROP TABLE proconcubo CASCADE CONSTRAINTS ;
CREATE TABLE proconcubo (
id_tempo INTEGER REFERENCES tempo,
Cod_Regiao SMALLINT REFERENCES regiao,
UF CHAR(2) REFERENCES UF,
CNPJ NUMBER(14) REFERENCES empresa,
Cod_Assunto SMALLINT REFERENCES assunto,
Cod_Problema SMALLINT REFERENCES problema, 
Id_Consumidor SMALLINT REFERENCES consumidor,
atendida_sim INTEGER, 
contagem INTEGER,
PRIMARY KEY (id_tempo, cod_regiao, UF, cnpj, cod_assunto, cod_problema, id_consumidor));

-- antes de inserir checagem de nulos
SELECT COUNT(*) FROM procondw where id_consumidor IS NULL ; --179861
SELECT COUNT(*) FROM procondw where id_tempo IS NULL ; -- 0
SELECT COUNT(*) FROM procondw where cod_regiao IS NULL ;
SELECT COUNT(*) FROM procondw where cod_problema IS NULL ; -- 19
SELECT COUNT(*) FROM procondw where cod_assunto IS NULL ;
SELECT COUNT(*) FROM procondw where cnpj IS NULL ;
SELECT COUNT(*) FROM procondw where UF IS NULL ;

INSERT INTO proconcubo (id_tempo, cod_regiao, UF, cnpj, cod_assunto, cod_problema, id_consumidor,
atendida_sim, contagem)
SELECT id_tempo, cod_regiao, UF, cnpj, cod_assunto, cod_problema, id_consumidor, 
COUNT( CASE atendida WHEN 'S' THEN 1 WHEN 'N' THEN 0 END),
COUNT(*)
FROM procondw
WHERE id_consumidor IS NOT NULL AND cod_problema IS NOT NULL 
GROUP BY id_tempo, cod_regiao, UF, cnpj, cod_assunto, cod_problema, id_consumidor
ORDER BY 1;
