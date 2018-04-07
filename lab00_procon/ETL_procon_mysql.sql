-----------------------------------
----- ETL base procon - mysql -----
-- --------------------------------
/*
                               <- Regiao
CNAE -> Empresa -> Reclamação  <- Assunto
                               <- Problema
							   <- Tempo
*/

-- extraindo dados da tabela base para criar tabelas referenciadas com código

-------------------
--- R E G I Ã O ---
-------------------
DROP TABLE IF EXISTS regiao;
CREATE TABLE regiao (
	cod_regiao SMALLINT,
	regiao VARCHAR(15)
);

INSERT INTO regiao(cod_regiao, regiao)
	SELECT DISTINCT
		regexp_replace(CodigoRegiao, '[^0-9]+', ''),
		TRIM(regiao)
	FROM proconbase;

-- definindo a PK
ALTER TABLE regiao ADD PRIMARY KEY (cod_regiao);

-- total de registros na tabela regiao
SELECT count(*) AS "REGIAO: TOTAL DE REGISTROS FINAL" FROM regiao;

---------------
--- C N A E ---
---------------
DROP TABLE IF EXISTS empresa; -- excluir antes para evitar erro de chave estrangeira
DROP TABLE IF EXISTS cnae;
CREATE TABLE cnae (
	cod_cnae INT,
	descr_cnae VARCHAR(165)
);

INSERT INTO cnae (cod_cnae, descr_cnae)
	SELECT DISTINCT
		regexp_replace(CNAEPrincipal, '[^0-9]+', ''),
		TRIM(DescCNAEPrincipal)
	FROM proconbase;

-- remove registros com cod_cnae NULL
DELETE FROM cnae WHERE cod_cnae IS NULL ;

-- verifica duplicatas
SELECT cod_cnae, count(*)
FROM cnae
GROUP BY cod_cnae
HAVING count(*) > 1;

SELECT * FROM cnae WHERE cod_cnae = 4751201;
-- limpeza feita a partir da duplicata encontrada
DELETE FROM cnae WHERE descr_cnae IS NULL;

-- definindo a PK
ALTER TABLE cnae ADD PRIMARY KEY (cod_cnae) ;

-- total de registros na tabela cnae
SELECT count(*) AS "CNAE: TOTAL DE REGISTROS FINAL" FROM cnae;

---------------------
--- E M P R E S A ---
---------------------
--SELECT MAX(LENGTH(TRIM(strRazaoSocial))) FROM proconbase ; --100
--SELECT MAX(LENGTH(TRIM(strNomeFantasia))) FROM proconbase ; --69
--SELECT MAX(LENGTH(TRIM(RazaoSocialRFB))) FROM proconbase ; --150
--SELECT MAX(LENGTH(TRIM(NomeFantasiaRFB))) FROM proconbase ; --55
--SELECT MAX(LENGTH(TRIM(NumeroCNPJ))) FROM proconbase ; -- 14

-- tabela empresa
DROP TABLE IF EXISTS empresa;
CREATE TABLE empresa (
	cnpj BIGINT,
	cnpj_radical INT,
	razao_social VARCHAR(100),
	nome_fantasia VARCHAR(75),
	rfb_razao_social VARCHAR(150),
	rfb_nome_fantasia VARCHAR(75),
	cod_cnae INT
);

INSERT INTO empresa (cnpj, cnpj_radical, razao_social, nome_fantasia, rfb_razao_social, rfb_nome_fantasia, cod_cnae)
	SELECT DISTINCT
		regexp_replace(NumeroCNPJ, '[^0-9]+', ''),
		regexp_replace(RadicalCNPJ, '[^0-9]+', ''),
		TRIM(strRazaoSocial),
		TRIM(strNomeFantasia),
		TRIM(RazaoSocialRFB),
		TRIM(NomeFantasiaRFB),
		regexp_replace(CNAEPrincipal, '[^0-9]+', '')
	FROM proconbase;

-- removendo registros com razao_social e cnpj nulos
DELETE FROM empresa WHERE razao_social IS NULL; 
DELETE FROM empresa WHERE cnpj IS NULL;

-- Total de registros
SELECT count(*) AS "TOTAL DE REGISTROS" FROM empresa;

-- Total de cnpj unicos
SELECT count(*) AS "TOTAL CNPJ UNICOS"
FROM (
	SELECT DISTINCT cnpj FROM empresa
) AS t;

-- Total de cnpj que aparecem mais de uma vez
SELECT count(*) AS "CNPJ QUE REPETEM"
FROM (
	SELECT count(cnpj)
	FROM empresa GROUP BY cnpj HAVING count(cnpj) > 1
) AS t;

-- Total de registros repetidos (que devem ser apagados)
SELECT sum(n) AS "TOTAL DE REPETIÇÕES"
FROM (
	SELECT count(cnpj) - 1 AS n
	FROM empresa GROUP BY cnpj HAVING count(cnpj) > 1
) AS t;

-- adicionando uma coluna temporária (sequencial) auxiliar para remoção dos cnpj duplicados (obs.: o mysql exige que a coluna de identidade seja chave primária)
ALTER TABLE empresa ADD t_seq INT AUTO_INCREMENT PRIMARY KEY;

-- removendo duplicadas de cnpj
-- ** Para cada cnpj, a subquery calcula o t_seq mínimo. É usado um LEFT JOIN para a junção, dessa forma, tudo que não casar terá um valor NULL para manter.s. Esses registros serão os deletados **
DELETE e
FROM empresa e
LEFT JOIN (
	SELECT min(t_seq) as s
	FROM empresa e
	GROUP BY cnpj
) manter ON e.t_seq = manter.s
WHERE manter.s IS NULL;

-- removendo a coluna auxiliar
ALTER TABLE empresa DROP t_seq;

-- definindo a PK
ALTER TABLE empresa ADD PRIMARY KEY (cnpj);

-- defininido a FK cod_cnae
ALTER TABLE empresa ADD FOREIGN KEY (cod_cnae) REFERENCES cnae(cod_cnae);

-- Total de registros na tabela empresa
SELECT count(*) AS "EMPRESA: TOTAL DE REGISTROS FINAL" FROM empresa;

---------------------
--- A S S U N T O ---
---------------------
DROP TABLE IF EXISTS assunto;
CREATE TABLE assunto (
	cod_assunto INT,
	descr_assunto VARCHAR(150)
);

INSERT INTO assunto (cod_assunto, descr_assunto)
	SELECT DISTINCT
		regexp_replace(CodigoAssunto, '[^0-9]+', ''), 
		TRIM(DescricaoAssunto)
	FROM proconbase;

DELETE FROM assunto WHERE cod_assunto IS NULL;

-- Mesma estratégia da tabela empresa para remover as duplicatas:
ALTER TABLE assunto ADD t_seq INT AUTO_INCREMENT PRIMARY KEY;

DELETE a
FROM assunto a
LEFT JOIN (
	SELECT min(t_seq) as s
	FROM assunto a
	GROUP BY cod_assunto
) manter ON a.t_seq = manter.s
WHERE manter.s IS NULL;

ALTER TABLE assunto DROP t_seq;

-- definindo a PK
ALTER TABLE assunto ADD PRIMARY KEY (cod_assunto);

-- Total de registros na tabela assunto
SELECT count(*) AS "ASSUNTO: TOTAL DE REGISTROS FINAL" FROM assunto;

-----------------------
--- P R O B L E M A ---
-----------------------
DROP TABLE IF EXISTS problema;
CREATE TABLE problema (
	cod_problema INT,
	descr_problema VARCHAR(135)
);

INSERT INTO problema (cod_problema, descr_problema)
	SELECT DISTINCT
		regexp_replace(CodigoProblema, '[^0-9]+', ''), 
		TRIM(DescricaoProblema)
	FROM proconbase;

DELETE FROM problema WHERE cod_problema IS NULL;

-- Mesma estratégia da tabela empresa para remover as duplicatas:
ALTER TABLE problema ADD t_seq INT AUTO_INCREMENT PRIMARY KEY;

DELETE p
FROM problema p
LEFT JOIN (
	SELECT min(t_seq) as s
	FROM problema p
	GROUP BY cod_problema
) manter ON p.t_seq = manter.s
WHERE manter.s IS NULL;

ALTER TABLE problema DROP t_seq;

-- definindo a PK
ALTER TABLE problema ADD PRIMARY KEY (cod_problema);

-- Total de registros na tabela problema
SELECT count(*) AS "PROBLEMA: TOTAL DE REGISTROS FINAL" FROM problema;

-----------
--- U F ---
-----------
DROP TABLE IF EXISTS uf;
CREATE TABLE uf (
	uf CHAR(2),
	nome_uf VARCHAR(50)
);

INSERT INTO uf (uf)
	SELECT DISTINCT TRIM(UF) FROM proconbase;

ALTER TABLE uf ADD PRIMARY KEY (uf) ;

UPDATE uf set nome_uf = 'SAO PAULO' WHERE uf = 'SP';
UPDATE uf set nome_uf = 'Acre' WHERE uf = 'AC' ;
UPDATE uf set nome_uf = 'Alagoas' WHERE uf = 'AL' ;
UPDATE uf set nome_uf = 'Amapa' WHERE uf = 'AP' ;
UPDATE uf set nome_uf = 'Amazonas' WHERE uf = 'AM' ;
UPDATE uf set nome_uf = 'Bahia' WHERE uf = 'BA' ;
UPDATE uf set nome_uf = 'Ceara' WHERE uf = 'CE' ;
UPDATE uf set nome_uf = 'Distrito Federal' WHERE uf = 'DF' ;
UPDATE uf set nome_uf = 'Espirito Santo' WHERE uf = 'ES' ;
UPDATE uf set nome_uf = 'Goias' WHERE uf = 'GO' ;
UPDATE uf set nome_uf = 'Maranhao' WHERE uf = 'MA' ; 
UPDATE uf set nome_uf = 'Mato Grosso' WHERE uf = 'MT' ; 
UPDATE uf set nome_uf = 'Mato Grosso do Sul' WHERE uf = 'MS' ; 
UPDATE uf set nome_uf = 'Minas Gerais' WHERE uf = 'MG' ; 
UPDATE uf set nome_uf = 'Para' WHERE uf = 'PA' ; 
UPDATE uf set nome_uf = 'Paraiba' WHERE uf = 'PB' ; 
UPDATE uf set nome_uf = 'Parana' WHERE uf = 'PR' ; 
UPDATE uf set nome_uf = 'Pernambuco' WHERE uf = 'PE' ; 
UPDATE uf set nome_uf = 'Piaui' WHERE uf = 'PI' ; 
UPDATE uf set nome_uf = 'Rio de Janeiro' WHERE uf = 'RJ' ;
UPDATE uf set nome_uf = 'Rio Grande do Norte' WHERE uf = 'RN' ; 
UPDATE uf set nome_uf = 'Rio Grande do Sul' WHERE uf = 'RS' ; 
UPDATE uf set nome_uf = 'Rondonia' WHERE uf = 'RO' ; 
UPDATE uf set nome_uf = 'Roraima' WHERE uf = 'RR' ; 
UPDATE uf set nome_uf = 'Santa Catarina' WHERE uf = 'SC' ; 
UPDATE uf set nome_uf = 'Sergipe' WHERE uf = 'SE' ; 
UPDATE uf set nome_uf = 'Tocantins' WHERE uf = 'TO' ;

UPDATE uf set nome_uf = UPPER(nome_uf);

-- Total de registros na tabela uf
SELECT count(*) AS "UF: TOTAL DE REGISTROS FINAL" FROM uf;

------------------------------
--- limpando a tabela base ---
------------------------------
--SELECT MAX(LENGTH(TRIM(UF))) FROM proconbase; -- 2
--SELECT MAX(LENGTH(TRIM(Atendida))) FROM proconbase; -- 1
--SELECT MAX(LENGTH(TRIM(SexoConsumidor))) FROM proconbase; -- 1
--SELECT DISTINCT TRIM(SexoConsumidor) FROM proconbase; -- tem NULL
--SELECT MAX(LENGTH(TRIM(CEPconsumidor))) FROM proconbase; -- 14 - tem 'Nao se aplica'
 
UPDATE proconbase SET SexoConsumidor = '' WHERE SexoConsumidor IS NULL;
UPDATE proconbase SET CEPConsumidor = '' WHERE CEPConsumidor like '%Nao se aplica%';

-----------------------
--- P R O C O N D W ---
-----------------------
DROP TABLE IF EXISTS procondw;
CREATE TABLE procondw (
	ano_calendario INT,
	dt_arquivamento TIMESTAMP,
	dt_abertura TIMESTAMP,
	cod_regiao SMALLINT,
	uf CHAR(2),
	cnpj BIGINT,
	atendida CHAR(1),
	cod_assunto INT,
	cod_problema INT, 
	sexo_consumidor CHAR(1),
	faixa_etaria_consumidor CHAR(20),
	cep_consumidor CHAR(9)
);

INSERT INTO procondw (ano_calendario, dt_arquivamento, dt_abertura, cod_regiao, uf, cnpj, atendida, cod_assunto, cod_problema, sexo_consumidor, faixa_etaria_consumidor, cep_consumidor)
	SELECT
		AnoCalendario,
		DataArquivamento,
		DataAbertura,
		regexp_replace(CodigoRegiao, '[^0-9]+', ''),
		TRIM(UF),
		regexp_replace(NumeroCNPJ, '[^0-9]+', ''), 
		TRIM(Atendida),
		regexp_replace(CodigoAssunto, '[^0-9]+', ''),
		regexp_replace(CodigoProblema, '[^0-9]+', ''),
		TRIM(Sexoconsumidor),
		TRIM(FaixaEtariaConsumidor),
		TRIM(CEPConsumidor)
	FROM proconbase;

-- adicionando as FKs
ALTER TABLE procondw ADD FOREIGN KEY(cod_assunto) REFERENCES assunto(cod_assunto);
ALTER TABLE procondw ADD FOREIGN KEY(cod_problema) REFERENCES problema(cod_problema);
ALTER TABLE procondw ADD FOREIGN KEY(cod_regiao) REFERENCES regiao(cod_regiao);
ALTER TABLE procondw ADD FOREIGN KEY(cnpj) REFERENCES empresa(cnpj);
ALTER TABLE procondw ADD FOREIGN KEY(uf) REFERENCES uf(uf);

-- Total de registros na tabela procondw
SELECT count(*) AS "PROCONDW: TOTAL DE REGISTROS FINAL" FROM procondw;

-----------------------------------------------
------------------ T E M P O ------------------
-- criado depois da tabela procondw populada --
-----------------------------------------------
DROP TABLE IF EXISTS tempo;
CREATE TABLE tempo (
	id_tempo INT AUTO_INCREMENT PRIMARY KEY,
	ano_abertura SMALLINT,
	mes_abertura SMALLINT,
	trim_abertura SMALLINT,
	dt_abertura DATE,
	qtde_data SMALLINT
);

INSERT INTO tempo (ano_abertura, mes_abertura, trim_abertura, dt_abertura, qtde_data)
	SELECT
		YEAR(dt_abertura),
		MONTH(dt_abertura),
		QUARTER(dt_abertura),
		DATE(dt_abertura),
		COUNT(*)
	FROM procondw
	GROUP BY
		YEAR(dt_abertura),
		MONTH(dt_abertura),
		QUARTER(dt_abertura),
		DATE(dt_abertura)
	ORDER BY 4;

-- Total de registros na tabela tempo
SELECT count(*) AS "TEMPO: TOTAL DE REGISTROS FINAL" FROM tempo;

/*******

-- relacionando procondw com tempo
ALTER TABLE procondw ADD id_tempo INT;

UPDATE procondw dw
SET id_tempo = (
	SELECT id_tempo
	FROM tempo t
	WHERE t.dt_abertura = dw.dt_abertura
);

********/
