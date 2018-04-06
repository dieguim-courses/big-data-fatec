
--2 Com a instru��o SELECT fa�a as seguintes consultas :
--a)   As 10 empresas que lideram as reclama��es em 2014

SELECT * FROM (
    SELECT e.cnpj, e.razao_social, COUNT(*)AS "NUMERO DE RECLAMA��ES"
           FROM empresa e, procondw dw
           WHERE e.cnpj = dw.cnpj AND dw.ano_calendario = 2014
           GROUP BY e.cnpj, e.razao_social
           ORDER BY 3 DESC
    )
    WHERE ROWNUM <= 10
    
;

--b)  A distribui��o das reclama��es por sexo do consumidor a cada ano de abertura da reclama��o

SELECT (SELECT COUNT(*) FROM procondw WHERE SExo_Consumidor = 'F') / COUNT(*) *100 AS Percentual m

FROM assunto a JOIN procondw dw
ON (a.cod_assunto = dw.cod_assunto)
WHERE dw.Sexo_Consumidor = 'F'
GROUP BY a.descr_assunto 
ORDER BY 2 DESC ;


/*
c)   A distribui��o das reclama��es por tipo de problema nas regi�es Sul e Sudeste e por ano 
calend�rio
d)  A distribui��o das reclama��es por faixa et�ria para assuntos ligados � ALIMENTA��O
e)   A empresa campe� de reclama��es no segmento de Telefonia M�vel Celular entre 2013 e 2015 ( ano 
calend�rio)*/
