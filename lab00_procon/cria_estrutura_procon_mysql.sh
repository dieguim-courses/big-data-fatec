#!/bin/bash

# Parâmetros do banco de dados
USER='bdextensao'
PASS='ipiranga'
BASE='lab00_procon'

# Criando novo usuário/senha
mysql -u root <<EOF
CREATE USER IF NOT EXISTS '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL ON $BASE.* TO '$USER'@'localhost';
EOF

# Criando base de dados
mysql -u root <<EOF
DROP DATABASE IF EXISTS $BASE;
CREATE DATABASE $BASE;
EOF

# Criando a estrutura da tabela proconbase
mysql -u $USER -p$PASS -D $BASE <<EOF 
DROP TABLE IF EXISTS proconbase;
CREATE TABLE proconbase (
	AnoCalendario INT,
	DataArquivamento TIMESTAMP DEFAULT '0000-00-00 00:00:00',
	DataAbertura TIMESTAMP DEFAULT '0000-00-00 00:00:00',
	CodigoRegiao SMALLINT,
	Regiao VARCHAR(15),
	UF CHAR(2),
	strRazaoSocial VARCHAR(100),
	strNomeFantasia VARCHAR(80),
	Tipo VARCHAR(50),
	NumeroCNPJ VARCHAR(50),
	RadicalCNPJ VARCHAR(50),
	RazaoSocialRFB VARCHAR(150),
	NomeFantasiaRFB VARCHAR(100),
	CNAEPrincipal VARCHAR(100),
	DescCNAEPrincipal VARCHAR(200),
	Atendida VARCHAR(150),
	CodigoAssunto VARCHAR(150),
	DescricaoAssunto VARCHAR(150),
	CodigoProblema VARCHAR(150), 
	DescricaoProblema VARCHAR(500),
	SexoConsumidor VARCHAR(150),
	FaixaEtariaConsumidor VARCHAR(150) ,
	CEPConsumidor VARCHAR(120)
);
EOF

# Carregando os dados csv
for i in $(seq 2 6); do
	mysql -u $USER -p$PASS -D $BASE <<EOF 
	LOAD DATA LOCAL INFILE 'bases_procon/reclamacoes-fundamentadas-sindec-201$i.csv'
		INTO TABLE proconbase
		CHARACTER SET latin1
		FIELDS
			TERMINATED BY ','
			OPTIONALLY ENCLOSED BY '"'
			IGNORE 1 LINES
		(@c1, @c2, @c3, @c4, @c5, @c6, @c7, @c8, @c9, @c10, @c11, @c12, @c13, @c14, @c15, @c16, @c17, @c18, @c19, @c20, @c21, @c22, @c23)
		SET
			AnoCalendario = TRIM(@c1),
			DataArquivamento = TRIM(@c2),
			DataAbertura = TRIM(@c3),
			CodigoRegiao = TRIM(@c4),
			Regiao = TRIM(@c5),
			UF = TRIM(@c6),
			strRazaoSocial = TRIM(@c7),
			strNomeFantasia = TRIM(@c8),
			Tipo = TRIM(@c9),
			NumeroCNPJ = TRIM(@c10),
			RadicalCNPJ = TRIM(@c11),
			RazaoSocialRFB = TRIM(@c12),
			NomeFantasiaRFB = TRIM(@c13),
			CNAEPrincipal = TRIM(@c14),
			DescCNAEPrincipal = TRIM(@c15),
			Atendida = TRIM(@c16),
			CodigoAssunto = TRIM(@c17),
			DescricaoAssunto = TRIM(@c18),
			CodigoProblema = TRIM(@c19),
			DescricaoProblema = TRIM(@c20),
			SexoConsumidor = TRIM(@c21),
			FaixaEtariaConsumidor = TRIM(@c22),
			CEPConsumidor = TRIM(@c23)
	;
EOF
done
