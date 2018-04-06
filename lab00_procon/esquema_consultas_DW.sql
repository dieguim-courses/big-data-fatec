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
CNAE ( cod_CNAE(PK), descr_CNAE
****/

-- consultas DW
-- 1 dimensão de agrupamento
-- qtde de reclamações por assunto
SELECT a.descr_assunto , COUNT(*)
FROM assunto a , procondw dw
WHERE a.cod_assunto = dw.cod_assunto
GROUP BY a.descr_assunto 
order by 2 desc ;

-- qtde de reclamacoes por assunto e por ano calendario
SELECT dw.ano_calendario, a.descr_assunto , COUNT(*)
FROM assunto a , procondw dw
WHERE a.cod_assunto = dw.cod_assunto
GROUP BY dw.ano_calendario, a.descr_assunto 
order by 1, 3 desc ;

-- reclamações por regiao
SELECT r.regiao, COUNT(*)
FROM regiao r JOIN procondw dw
ON ( r.codigo_regiao = dw.cod_regiao)
GROUP BY r.regiao
ORDER BY 2 DESC ;

-- reclamações por regiao
SELECT r.regiao, u.nome_uf,  COUNT(*)
FROM regiao r JOIN procondw dw
ON ( r.codigo_regiao = dw.cod_regiao)
JOIN UF u ON ( u.uf = dw.uf) 
GROUP BY r.regiao,u.nome_uf 
ORDER BY 3 DESC, 2;

-- empresas com mais reclamações
SELECT cnpj, Razao_social, RFB_Razao_Social FROM empresa
WHERE cnpj = 
(SELECT e.cnpj 
FROM empresa e, procondw dw
WHERE e.cnpj = dw.cnpj
GROUP BY e.cnpj
HAVING COUNT(*) =
     ( SELECT MAX(COUNT(*))
       FROM empresa e, procondw dw
       WHERE e.cnpj = dw.cnpj
       GROUP BY e.cnpj ) );
-- ranking do que as mulheres mais reclamam
SELECT a.descr_assunto, (COUNT(*)/ (SELECT COUNT(*) FROM procondw
                                  WHERE SExo_Consumidor = 'F'))*100 AS Percentual
FROM assunto a JOIN procondw dw
ON (a.cod_assunto = dw.cod_assunto)
WHERE dw.Sexo_Consumidor = 'F'
GROUP BY a.descr_assunto 
ORDER BY 2 DESC ;
