-- criando novo usuario/senha
CREATE USER bdextensao IDENTIFIED BY ipiranga;
GRANT DBA TO bdextensao ;

connect bdextensao/ipiranga ;

-- para rodar o loader na linha de comando do Windows
sqlldr usuario/senha control=nomearquivo.ctl skip=1
preferencialmente ir para o diretorio onde está o arquivo ctl
set PATH=%PATH%;C:\oraclexe\app\oracle\product\11.2.0\server\bin

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

