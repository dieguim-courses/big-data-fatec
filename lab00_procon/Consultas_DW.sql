/***********************************
Consultas Procon DW
************************************/
/** Esquema 
procondw ( Ano_Calendario NUMBER, Dt_Arquivamento TIMESTAMP, Dt_Abertura TIMESTAMP, Cod_Regiao SMALLINT (FK),
UF CHAR(2), CNPJ NUMBER(14) (FK), Atendida CHAR(1), Cod_Assunto SMALLINT (FK), Cod_Problema SMALLINT (FK),
Sexo_Consumidor CHAR(1), Faixa_Etaria_Consumidor CHAR(20), CEP_Consumidor CHAR(8)) ;
Regiao ( Cod_Regiao(PK), regiao)
Empresa ( CNPJ (PK) , Razao_Social, ...., cod_CNAE(FK))
Assunto ( Cod_assunto(PK) , descr_assunto)
Problema ( Cod_Problema(PK) , descr_problema)
CNAE ( cod_CNAE(PK), descr_CNAE)
****/

-- 1 dimensão de agrupamento
-- assunto

SELECT a.descr_assunto, COUNT(*)
FROM procondw dw, assunto a
WHERE dw.cod_assunto = a.cod_assunto
GROUP BY a.descr_assunto ;

-- 2 dimensões
SELECT dw.ano_calendario, a.descr_assunto, COUNT(*)
FROM procondw dw, assunto a
WHERE dw.cod_assunto = a.cod_assunto
GROUP BY dw.ano_calendario,  a.descr_assunto
ORDER BY 1 ;

-- reclamações por regiao
SELECT r.regiao , COUNT(*)
FROM regiao r, procondw dw
WHERE r.codigo_regiao = dw.cod_regiao
GROUP BY r.regiao
ORDER BY 2 DESC ;

-- reclamações por regiao e Estado
SELECT r.regiao, u.nome_UF , COUNT(*)
FROM regiao r, procondw dw, UF u
WHERE r.codigo_regiao = dw.cod_regiao
AND u.uf = dw.uf
GROUP BY r.regiao, u.nome_uf
ORDER BY 3 DESC ;

-- reclamações por regiao e Estado e ano de abertura
SELECT r.regiao, u.nome_UF , t.ano_abertura , COUNT(*)
FROM regiao r, procondw dw, UF u, tempo t
WHERE r.codigo_regiao = dw.cod_regiao
AND u.uf = dw.uf
AND t.id_tempo = dw.id_tempo
GROUP BY r.regiao, u.nome_uf, t.ano_abertura
ORDER BY 1, 2, 3 ;

-- empresa com mais reclamações
SELECT TO_CHAR( e.cnpj, '99999999999999'), e.razao_social, cn.descr_CNAE
FROM empresa e, cnae cn
WHERE e.cod_cnae = cn.cod_cnae 
AND e.cnpj = ( 
              SELECT dw.cnpj
              FROM procondw dw
              GROUP BY dw.cnpj
              HAVING COUNT(*) = 
                                ( SELECT MAX(COUNT(*))
                                  FROM procondw dw
                                  GROUP BY dw.cnpj) ) ;

/***************************************
Atividade 01 : Business Intelligence e DataWarehouse
**************************************/
--1-Montar o Modelo Multidimensional Estrela para o Banco de Dados de Reclamações do Procon (procondw)

--2 – Com a instrução SELECT faça as seguintes consultas :
--a)	As 10 empresas que lideram as reclamações em 2014
SELECT e.razao_social, e.nome_fantasia, dezmais.* FROM ( 
SELECT TO_CHAR(dw.cnpj, '99999999999999') AS CNPJ, COUNT(*)
FROM procondw dw
WHERE dw.ano_calendario = 2014
GROUP BY dw.cnpj
ORDER BY 2 DESC ) dezmais
JOIN empresa e ON ( e.cnpj = dezmais.cnpj)
WHERE ROWNUM <= 10 ;

--b)A distribuição das reclamações por sexo do consumidor
-- a cada ano de abertura da reclamação
SELECT dw.sexo_consumidor, EXTRACT(YEAR FROM dw.dt_abertura) AS Ano_abertura,
COUNT(*) AS qtde_reclamacoes
FROM procondw dw
GROUP BY dw.sexo_consumidor, EXTRACT(YEAR FROM dw.dt_abertura) 
ORDER BY 2, 1 , 3;

SELECT dw.sexo_consumidor, tmp.ano_abertura AS Ano_abertura,
COUNT(*) AS qtde_reclamacoes
FROM procondw dw JOIN tempo tmp
ON dw.id_tempo = tmp.id_tempo
GROUP BY dw.sexo_consumidor, tmp.ano_abertura 
ORDER BY 2, 1 , 3;

--c)A distribuição das reclamações por tipo de problema
-- nas regiões Sul e Sudeste e por ano calendário
SELECT dw.ano_calendario, p.descr_problema, COUNT(*)
FROM procondw dw JOIN problema p
ON ( dw.cod_problema = p.cod_problema)
JOIN regiao r ON ( dw.cod_regiao = r.codigo_regiao)
WHERE ( UPPER ( r.regiao) LIKE '%SUDE%' OR 
UPPER ( r.regiao) LIKE '%SUL%' ) 
GROUP BY dw.ano_calendario, p.descr_problema
ORDER BY 1, 3 DESC ;

--d)A distribuição das reclamações por faixa etária
-- para assuntos ligados à ALIMENTAÇÃO
SELECT dw.faixa_etaria_consumidor, COUNT(*)
FROM procondw dw, assunto a
WHERE dw.cod_assunto = a.cod_assunto
AND UPPER(a.descr_assunto) LIKE '%ALIMENT%' 
GROUP BY dw.faixa_etaria_consumidor 
ORDER BY 2 DESC ;

--e)A empresa campeã de reclamações no segmento de
-- Telefonia Móvel Celular entre 2013 e 2015 ( ano calendário)
SELECT e.razao_social, e.nome_fantasia, mais1315.* FROM ( 
SELECT TO_CHAR(dw.cnpj, '99999999999999') AS CNPJ, COUNT(*)
FROM procondw dw, empresa e, cnae c
WHERE dw.ano_calendario = 2014
AND dw.cnpj = e.cnpj
AND e.cod_CNAE = c.cod_CNAE
AND UPPER ( c.descr_CNAE) LIKE '%MOVEL%' AND UPPER ( c.descr_CNAE) LIKE '%CELULAR%'
AND dw.ano_calendario BETWEEN 2013 AND 2015
GROUP BY dw.cnpj
ORDER BY 2 DESC ) mais1315
JOIN empresa e ON ( e.cnpj = mais1315.cnpj)
WHERE ROWNUM = 1 ;
