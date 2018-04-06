
--2 Com a instrução SELECT faça as seguintes consultas :
--a)   As 10 empresas que lideram as reclamações em 2014

SELECT * FROM (
    SELECT e.cnpj, e.razao_social, COUNT(*)AS "NUMERO DE RECLAMAÇÕES"
           FROM empresa e, procondw dw
           WHERE e.cnpj = dw.cnpj AND dw.ano_calendario = 2014
           GROUP BY e.cnpj, e.razao_social
           ORDER BY 3 DESC
    )
    WHERE ROWNUM <= 10
    
;

--b)  A distribuição das reclamações por sexo do consumidor a cada ano de abertura da reclamação

SELECT (SELECT COUNT(*) FROM procondw WHERE SExo_Consumidor = 'F') / COUNT(*) *100 AS Percentual m

FROM assunto a JOIN procondw dw
ON (a.cod_assunto = dw.cod_assunto)
WHERE dw.Sexo_Consumidor = 'F'
GROUP BY a.descr_assunto 
ORDER BY 2 DESC ;


/*
c)   A distribuição das reclamações por tipo de problema nas regiões Sul e Sudeste e por ano 
calendário
d)  A distribuição das reclamações por faixa etária para assuntos ligados à ALIMENTAÇÃO
e)   A empresa campeã de reclamações no segmento de Telefonia Móvel Celular entre 2013 e 2015 ( ano 
calendário)*/
