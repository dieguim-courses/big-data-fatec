options (errors=9999999, rows=5)
load data
 characterset WE8ISO8859P1
 infile '/Extensao_BigData/reclamacoes-fundamentadas-sindec-2012.csv'
 infile '/Extensao_BigData/reclamacoes-fundamentadas-sindec-2013.csv'
 infile '/Extensao_BigData/reclamacoes-fundamentadas-sindec-2014.csv'
 infile '/Extensao_BigData/reclamacoes-fundamentadas-sindec-2015.csv'
 infile '/Extensao_BigData/reclamacoes-fundamentadas-sindec-2016.csv'
 badfile '/Extensao_BigData/procon.bad'
 discardfile '/Extensao_BigData/procon.dsc'
 truncate
 into table proconbase
 fields terminated by "," optionally enclosed by '"'
 TRAILING NULLCOLS
(AnoCalendario "TO_NUMBER(TRIM(:AnoCalendario))",DataArquivamento "TO_TIMESTAMP(TRIM(:DataArquivamento),'YYYY-MM-DD HH24:MI:SS.FF9')"
,DataAbertura "TO_TIMESTAMP(TRIM(:DataAbertura),'YYYY-MM-DD HH24:MI:SS.FF9')",CodigoRegiao "TO_NUMBER(TRIM(:CodigoRegiao))",
Regiao "TRIM(:Regiao)",UF "TRIM(:UF)",strRazaoSocial "TRIM(:strRazaoSocial)" ,strNomeFantasia "TRIM(:strNomeFantasia)",
Tipo "LTRIM(:Tipo)", NumeroCNPJ "TRIM(:NumeroCNPJ)",RadicalCNPJ "TRIM(:RadicalCNPJ)",
RazaoSocialRFB "TRIM(:RazaoSocialRFB)" ,NomeFantasiaRFB "TRIM(:NomeFantasiaRFB)",
CNAEPrincipal "TRIM(:CNAEPrincipal)",DescCNAEPrincipal "TRIM(:DescCNAEPrincipal)",
Atendida "TRIM(:Atendida)" ,CodigoAssunto "TRIM(:CodigoAssunto)",
DescricaoAssunto "TRIM(:DescricaoAssunto)",CodigoProblema "TRIM(:CodigoProblema)",
DescricaoProblema "TRIM(:DescricaoProblema)",SexoConsumidor "TRIM(:SexoConsumidor)",
FaixaEtariaConsumidor "TRIM(:FaixaEtariaConsumidor)",CEPConsumidor "TRIM(:CEPConsumidor)")

