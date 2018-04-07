/**********************
 *** LAB00 - PROCON ***
 **** Atividade 01 ****
 **********************/

/*******

(2) Com a instru��o SELECT fa�a as seguintes consultas:

*******/

/* a) As 10 empresas que lideram as reclama��es em 2014 */

-- mysql
SELECT
	e.cnpj AS "CNPJ",
	e.razao_social AS "RAZ�O SOCIAL",
	count(*) AS "NUMERO DE RECLAMA��ES"
FROM empresa e, procondw dw
WHERE dw.cnpj = e.cnpj AND dw.ano_calendario = 2014
GROUP BY e.cnpj, e.razao_social
ORDER BY 3 DESC
LIMIT 10
;

/*
-- oracle
SELECT *
FROM (
	SELECT e.cnpj, e.razao_social, count(*) AS "NUMERO DE RECLAMA��ES"
	FROM empresa e, procondw dw
	WHERE e.cnpj = dw.cnpj AND dw.ano_calendario = 2014
	GROUP BY e.cnpj, e.razao_social
	ORDER BY 3 DESC
)
WHERE ROWNUM <= 10
;
*/

/* b) A distribui��o das reclama��es por sexo do consumidor a cada ano de abertura da reclama��o */

-- mysql
SELECT
	YEAR(dw.dt_abertura) AS "ANO DE ABERTURA",
	dw.sexo_consumidor AS "SEXO",
	CONCAT((count(*) / t.total_ano) * 100, '%') AS "PERCENTUAL DE RECLAMA��ES"
FROM
	procondw dw,
	(
		SELECT YEAR(dt_abertura) ano, count(*) total_ano
		FROM procondw
		WHERE sexo_consumidor IN ('F', 'M')
		GROUP BY YEAR(dt_abertura)
	) t
WHERE YEAR(dw.dt_abertura) = t.ano AND dw.sexo_consumidor IN ('F', 'M')
GROUP BY YEAR(dw.dt_abertura), dw.sexo_consumidor
;

/* c) A distribui��o das reclama��es por tipo de problema nas regi�es Sul e Sudeste e por ano calend�rio */

-- mysql
SELECT
	dw.ano_calendario AS "ANO CALEND�RIO",
	p.descr_problema AS "TIPO DE PROBLEMA",
	count(*) AS "N�MERO DE RECLAMA��ES NO ANO",
	CONCAT((count(*) / t.total_ano) * 100, '%') AS "PERCENTUAL DE RECLAMA��ES NO ANO"
FROM
	procondw dw,
	problema p,
	regiao r,
	(
		SELECT dw.ano_calendario ano, count(*) total_ano
		FROM procondw dw, regiao r
		WHERE dw.cod_regiao = r.cod_regiao AND r.regiao IN ('Sul', 'Sudeste')
		GROUP BY ano
	) t
WHERE
	dw.cod_problema = p.cod_problema AND
	dw.cod_regiao = r.cod_regiao AND
	dw.ano_calendario = t.ano AND
	r.regiao IN ('Sul', 'Sudeste')
GROUP BY dw.ano_calendario, p.descr_problema
ORDER BY dw.ano_calendario, 3 DESC
;

/* d) A distribui��o das reclama��es por faixa et�ria para assuntos ligados � ALIMENTA��O */

--mysql
SELECT
	dw.faixa_etaria_consumidor AS "FAIXA ET�RIA",
	CONCAT((
		count(*) / (
			SELECT count(*) FROM procondw WHERE cod_assunto IN (
				SELECT cod_assunto FROM assunto WHERE UPPER(descr_assunto) like UPPER('%aliment%')
			)
		)
	) * 100, '%') AS "PERCENTUAL DE RECLAMA��ES"
FROM procondw dw, assunto a
WHERE
	dw.cod_assunto = a.cod_assunto AND
	UPPER(a.descr_assunto) like UPPER('%aliment%')
GROUP BY dw.faixa_etaria_consumidor
;

/* e) A empresa campe� de reclama��es no segmento de Telefonia M�vel Celular entre 2013 e 2015 (ano calend�rio) */

--mysql
SELECT
	e.cnpj AS "CNPJ",
	e.razao_social AS "RAZ�O SOCIAL",
	count(*) AS "N�MERO DE RECLAMA��ES"
FROM procondw dw, empresa e
WHERE
	dw.cnpj = e.cnpj AND
	e.cod_cnae IN (
		SELECT cod_cnae FROM cnae WHERE UPPER(descr_cnae) like UPPER('%telefonia movel%')
	) AND
	dw.ano_calendario >= 2013 AND dw.ano_calendario <= 2015
GROUP BY e.cnpj
HAVING count(*) = (
	SELECT MAX(c) m
	FROM (
		SELECT count(*) AS c
		FROM procondw dw, empresa e
		WHERE
			dw.cnpj = e.cnpj AND
			e.cod_cnae IN (
				SELECT cod_cnae FROM cnae WHERE UPPER(descr_cnae) like UPPER('%telefonia movel%')
			) AND
			dw.ano_calendario >= 2013 AND dw.ano_calendario <= 2015
		GROUP BY e.cnpj
	) AS t
)
;
