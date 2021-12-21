DROP INDEX IF EXISTS giri_data_passaggio;
DROP INDEX IF EXISTS atleti_cognomi;
DROP INDEX IF EXISTS atleti_nomi;
DROP VIEW IF EXISTS giriVelociAssolutiPiloti;
DROP VIEW IF EXISTS giriVelociPiloti;
DROP VIEW IF EXISTS dati_infortunio;
DROP VIEW IF EXISTS maxVisitePista;
DROP VIEW IF EXISTS presenzeTotali;
DROP VIEW IF EXISTS presenzePiste;
DROP VIEW IF EXISTS partecipazioneCorsi;  
DROP TABLE IF EXISTS partecipazione;
DROP TABLE IF EXISTS infortunio;
DROP TABLE IF EXISTS inclusioneEventoCategoria;
DROP TABLE IF EXISTS svolgimentoPistaEvento;
DROP TABLE IF EXISTS noleggio;
DROP TABLE IF EXISTS partecipazionePilotaCorso;
DROP TABLE IF EXISTS manutenzione;
DROP TABLE IF EXISTS fornitura;
DROP TABLE IF EXISTS licenza;
DROP TABLE IF EXISTS certificato;
DROP TABLE IF EXISTS macchinario;
DROP TABLE IF EXISTS giro;
DROP TABLE IF EXISTS fornitore;
DROP TABLE IF EXISTS corso;
DROP TABLE IF EXISTS allenamento;
DROP TABLE IF EXISTS istruttore;
DROP TABLE IF EXISTS pilota;
DROP TABLE IF EXISTS atleta;
DROP TABLE IF EXISTS ente;
DROP TABLE IF EXISTS moto;
DROP TABLE IF EXISTS noleggio;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS personale;
DROP TABLE IF EXISTS ristoro;
DROP TABLE IF EXISTS pista;

/* --- CREAZIONE TABELLE --- */

CREATE TABLE macchinario (
	targa CHAR(6) NOT NULL,
	marca VARCHAR(15) NOT NULL,
	modello VARCHAR(20) NOT NULL,
	data_acquisto DATE NOT NULL,
	km_effettuati INT NOT NULL,
	tipo VARCHAR(15) NOT NULL,
	PRIMARY KEY(targa)
);

CREATE TABLE pista (
	id SERIAL NOT NULL,
	lunghezza DECIMAL(3,2) NOT NULL,
	terreno VARCHAR(10) NOT NULL,
	notturna BOOLEAN NOT NULL,
	ranking_min INT NOT NULL,
	ranking_max INT NOT NULL,
	nome_fascia_ranking VARCHAR(10) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE fornitore (
	id SERIAL,
	nominativo VARCHAR(30) NOT NULL,
	cellulare CHAR(10) NOT NULL,
	cap CHAR(5) NOT NULL,
	civico VARCHAR(5) NOT NULL,
	via VARCHAR(20) NOT NULL,
	citta VARCHAR(20) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE atleta (
	cf CHAR(16) NOT NULL,
	sesso CHAR(1) NOT NULL,
	cognome VARCHAR(15) NOT NULL,
	nome VARCHAR(15) NOT NULL,
	data_nascita DATE NOT NULL,
	cap CHAR(5) NOT NULL,
	civico VARCHAR(5) NOT NULL,
	via VARCHAR(20) NOT NULL,
	citta VARCHAR(20) NOT NULL,
	email VARCHAR(20),
	cellulare CHAR(10) NOT NULL,
	scadenza_visita_medica DATE NOT NULL,
	ranking INT NOT NULL,
	PRIMARY KEY(cf)
);

CREATE TABLE istruttore (
	cf CHAR(16) NOT NULL,
	PRIMARY KEY(cf),
	FOREIGN KEY(cf) REFERENCES atleta(cf) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE pilota (
	cf CHAR(16) NOT NULL,
	PRIMARY KEY(cf),
	FOREIGN KEY(cf) REFERENCES atleta(cf) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ente (
	nominativo VARCHAR(15) NOT NULL,
	cap CHAR(5) NOT NULL,
	civico VARCHAR(5) NOT NULL,
	via VARCHAR(20) NOT NULL,
	citta VARCHAR(20) NOT NULL,
	PRIMARY KEY(nominativo)
);

CREATE TABLE licenza (
	codice CHAR(5) NOT NULL,
	ente VARCHAR(15) NOT NULL,
	data_emissione DATE NOT NULL,
	data_scadenza DATE NOT NULL,
	atleta CHAR(16) NOT NULL,
	PRIMARY KEY(codice,ente),
	FOREIGN KEY(ente) REFERENCES ente(nominativo) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY(atleta) REFERENCES atleta(cf) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE certificato (
	codice CHAR(5) NOT NULL,
	ente VARCHAR(15) NOT NULL,
	data_emissione DATE NOT NULL,
	data_scadenza DATE NOT NULL,
	ranking_min INT NOT NULL,
	ranking_max INT NOT NULL,
	istruttore CHAR(16) NOT NULL,
	PRIMARY KEY(codice,ente),
	FOREIGN KEY(ente) REFERENCES ente(nominativo) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY(istruttore) REFERENCES istruttore(cf) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE corso (
	data DATE NOT NULL,
	istruttore CHAR(16) NOT NULL,
	durata TIME NOT NULL,
	circuito INT NOT NULL,
	PRIMARY KEY(data,istruttore),
	FOREIGN KEY(istruttore) REFERENCES istruttore(cf) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(circuito) REFERENCES pista(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE partecipazionePilotaCorso (
	pilota CHAR(16) NOT NULL,
	data_corso DATE NOT NULL,
	istruttore CHAR(16) NOT NULL,
	PRIMARY KEY(pilota,data_corso,istruttore),
	FOREIGN KEY(pilota) REFERENCES pilota(cf) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(data_corso,istruttore) REFERENCES corso(data,istruttore) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE moto (
	n_telaio CHAR(10) NOT NULL,
	marca VARCHAR(15) NOT NULL,
	modello VARCHAR(20) NOT NULL,
	cilindrata INT NOT NULL,
	PRIMARY KEY(n_telaio,marca)
);

CREATE TABLE noleggio (
	pilota CHAR(16) NOT NULL,
	seriale_telaio CHAR(10) NOT NULL,
	marca VARCHAR(15) NOT NULL,
	data DATE NOT NULL,
	ore_utilizzo TIME NOT NULL,
	PRIMARY KEY(pilota,seriale_telaio,marca,data),
	FOREIGN KEY(pilota) REFERENCES pilota(cf) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(seriale_telaio,marca) REFERENCES moto(n_telaio,marca) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE evento (
	id SERIAL NOT NULL,
	tipo VARCHAR(20) NOT NULL,
	data DATE NOT NULL,
	piloti_ammessi INT NOT NULL,
	pubblico BOOLEAN NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE svolgimentoPistaEvento (
	pista INT NOT NULL,
	evento INT NOT NULL,
	PRIMARY KEY(pista,evento),
	FOREIGN KEY(pista) REFERENCES pista(id) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY(evento) REFERENCES evento(id) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE categoria (
	id SERIAL NOT NULL,
	ranking_min INT NOT NULL,
	ranking_max INT NOT NULL,
	cilindrata INT NOT NULL,
	sesso CHAR(1) NOT NULL,
	fascia_eta VARCHAR(10) NOT NULL,
	stock BOOLEAN NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE inclusioneEventoCategoria (
	evento INT NOT NULL,
	categoria INT NOT NULL,
	PRIMARY KEY(evento,categoria),
	FOREIGN KEY(evento) REFERENCES evento(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(categoria) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE partecipazione (
	atleta CHAR(16) NOT NULL,
	evento INT NOT NULL,
	categoria INT NOT NULL,
	n_gara VARCHAR(3) NOT NULL,
	marca VARCHAR(15) NOT NULL,
	modello VARCHAR(20) NOT NULL,
	PRIMARY KEY(atleta,evento,categoria),
	FOREIGN KEY(atleta) REFERENCES atleta(cf) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(evento) REFERENCES evento(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(categoria) REFERENCES categoria(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE ristoro (
	id SERIAL NOT NULL,
	apertura TIME NOT NULL,
	chiusura TIME NOT NULL,
	posti_a_sedere INT NOT NULL,
	circuito INT NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY(circuito) REFERENCES pista(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE fornitura (
	fornitore INT NOT NULL,
	ristoro INT NOT NULL,
	data DATE NOT NULL,
	descrizione TEXT NOT NULL,
	PRIMARY KEY(fornitore,ristoro,data),
	FOREIGN KEY(fornitore) REFERENCES fornitore(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY(ristoro) REFERENCES ristoro(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE personale (
	cf CHAR(16) NOT NULL,
	cognome VARCHAR(15) NOT NULL,
	nome VARCHAR(15) NOT NULL,
	data_nascita DATE NOT NULL,
	cap CHAR(5) NOT NULL,
	civico VARCHAR(5) NOT NULL,
	via VARCHAR(20) NOT NULL,
	citta VARCHAR(20) NOT NULL,
	email VARCHAR(20),
	cellulare CHAR(10) NOT NULL,
	impiego VARCHAR(15) NOT NULL,
	patentino CHAR(10) UNIQUE,
	impiego_ristoro INT,
	PRIMARY KEY(cf),
	FOREIGN KEY(impiego_ristoro) REFERENCES ristoro(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE manutenzione (
	pista INT NOT NULL,
	addetto CHAR(16) NOT NULL,
	mezzo CHAR(6) NOT NULL,
	data DATE NOT NULL,
	durata TIME NOT NULL,
	descrizione TEXT NOT NULL,
	PRIMARY KEY(pista,addetto,mezzo,data),
	FOREIGN KEY(pista) REFERENCES pista(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(addetto) REFERENCES personale(cf) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY(mezzo) REFERENCES macchinario(targa) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE allenamento (
	id SERIAL NOT NULL,
	data DATE NOT NULL,
	cadute INT NOT NULL,
	pilota CHAR(16) NOT NULL,
	circuito INT NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY(pilota) REFERENCES pilota(cf) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(circuito) REFERENCES pista(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE giro (
	id SERIAL NOT NULL,
	tempo_totale TIME NOT NULL,
	orario_passaggio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	settore_1 TIME NOT NULL,
	settore_2 TIME NOT NULL,
	settore_3 TIME NOT NULL,
	caduta BOOLEAN NOT NULL,
	sessione INT NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY(sessione) REFERENCES allenamento(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE infortunio (
	sessione INT NOT NULL,
	descrizione TEXT NOT NULL,
	PRIMARY KEY(sessione),
	FOREIGN KEY(sessione) REFERENCES allenamento(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* --- POPOLAMENTO TABELLE --- */

INSERT INTO macchinario (targa,tipo,marca,modello,data_acquisto,km_effettuati) VALUES
('AA123A','Trattore','New Holland','T4','2010-04-01',214679),
('DG000B','Trattore','New Holland','T5.130','2015-12-12',95443),
('EG443W','Trattore','Landini','serie 4','2017-03-01',43210),
('BC941Q','Escavatore','Komatsu','PC240LC','2012-04-03',67890),
('CZ138Z','Escavatore','New Holland','E245','2016-01-04',46441),
('FB672A','Escavatore','Hitachi','ZX 135','2019-06-14',14141);

INSERT INTO pista (id,lunghezza,terreno,notturna,ranking_min,ranking_max,nome_fascia_ranking) VALUES
(1,2.55,'Terra',true,1001,10000,'Pro'),
(2,1.95,'Sabbia',false,1001,10000,'Pro'),
(3,2.14,'Misto',false,1001,10000,'Pro'),
(4,1.87,'Terra',true,501,1000,'Amatore'),
(5,2.14,'Terra',true,501,1000,'Amatore'),
(6,1.67,'Sabbia',false,501,1000,'Amatore'),
(7,1.75,'Terra',true,201,500,'Beginner'),
(8,1.64,'Terra',false,201,500,'Beginner'),
(9,1.15,'Terra',true,0,200,'Baby'),
(10,0.97,'Erba',false,0,200,'Baby');

INSERT INTO fornitore (id,nominativo,cellulare,cap,citta,civico,via) VALUES
(1,'FAST&FOOD srl','0426489917','80100','Napoli','2/A','Via Roma'),
(2,'Herbalife Nutrition spa','0498912401','35031','Abano Terme','12','Via Monte Ricco'),
(3,'Macellerie Milanesi srl','0418547140','20019','Milano','41','Corso Stati Uniti'),
(4,'Panificio Stellin snc','0473214569','35100','Padova','14','Via delle nazioni'),
(5,'San Carlo spa','0496571294','35101','Padova','76','Via dell''industria');

INSERT INTO atleta (cf,sesso,cognome,nome,data_nascita,cap,citta,civico,via,email,cellulare,scadenza_visita_medica,ranking) VALUES
('CVLLSN00A04A001A','M','Cavaliere','Alessandro','2000-01-04','35036','Montegrotto Terme','28','Via Vivaldi','alecava@gmail.com','3479626868','2021-12-13',2141),
('CRACST05S11F839T','F','Cara','Celeste','1999-04-01','80128','Napoli','41','Viale Lavoro','cele.cara@yahoo.it','3281236619','2021-03-16',1200),
('BRGFPP00A01C743J','M','Brugnolaro','Filippo','2000-01-01','35013','Cittadella','4','Via Gufi','f.brugni@gmail.com','3214569870','2021-12-13',2953),
('RMGMGN76E16F011A','M','Magagna','Remigio','1976-05-16','35020','Masera','99','via Ronchi',NULL,'3462688621','2021-09-02',1943),
('DLNRME81R13H620I','M','Dalan','Remo','1981-10-13','45100','Rovigo','34','Via Stella',NULL,'3287652890','2021-10-10',1002),
('DPTSML02L07G478S','M','Di Patti','Samuele','2002-07-07','06121','Perugia','1','Via Tiepolo','sam.dp@hotmail.com','3478521345','2021-04-01',1441),
('NCLDNL10L09H501B','M','Nicoletti','Daniele','1980-09-07','35100','Padova','32','Via dei Martiri',NULL,'3332688688','2021-05-20',558),
('DLSDNT09C60H501K','M','Diamante','Dalessio','1968-03-31','00100','Roma','2','Via Foscolo',NULL,'3339991110','2021-11-17',943),
('VGNLSS91H20M082P','F','Vignali','Alessia','1991-06-20','01100','Viterbo','65','Via Patriarcati','vigna@gmail.com','3965431269','2021-09-12',732),
('BSGCST99P20L840H','M','Bisogni','Cristian','1999-09-20','36100','Vicenza','15','Via Napoli','cris.biso@apple.it','3589873613','2021-12-01',666),
('LNRNRC65E13F205E','M','Lunardi','Enrico','1965-05-13','20019','Milano','32','Via Previtali',NULL,'3487048672','2021-10-04',532),
('BRTGPP82S04L219F','M','Bertolaso','Giuseppe','1982-11-04','10125','Torino','8','Via Scagliara','berto.bep@gmail.com','3332798897','2021-08-15',899),
('GVNBCR84A01A007R','M','Baccarin','Giovanni','1997-12-12','35031','Abano Terme','14','Via Roma',NULL,'3483640134','2021-03-15',250),
('ZNCGCM00B23L900D','M','Zancarini','Giacomo','2000-02-23','35010','Vigonza','37','Via Roma',NULL,'3211234569','2021-12-02',204),
('CLGGDI97T28D969K','F','Calgaro','Giada','1997-12-28','16121','Genova','18','Via Mingoni','giadac@hotmail.com','3287657651','2021-05-02',339),
('PRSGLN56P09L270S','M','Pressato','Giuliano','1956-09-09','35038','Torreglia','47','Via Regazzoni',NULL,'0498911843','2021-09-01',449),
('GRBLRS93H15G273T','M','Giribuola','Loris','1993-06-15','90121','Palermo','32','Via Italia','l.giri@yahoo.it','3457681270','2021-07-04',439),
('LNRTMS98M24F529X','M','Lunardi','Tommaso','2008-08-24','35036','Montegrotto Terme','4','via Gobetti','tl@apple.it','3477697140','2021-02-14',5),
('ZNRSFO69P19E897F','F','Zanrosso','Sofia','2010-09-09','46100','Mantova','69','Corso Terme',NULL,'3288237490','2021-12-20',100),
('TMMFPP05E04C351B','M','Tommasin','Filippo','2005-05-04','95100','Catania','90','via Paura','f.tom@gmail.com','3329044851','2021-04-30',54);

INSERT INTO istruttore (cf)VALUES
('BRGFPP00A01C743J'),
('DPTSML02L07G478S'),
('LNRNRC65E13F205E'),
('BRTGPP82S04L219F');

INSERT INTO pilota (cf)VALUES
('CVLLSN00A04A001A'),
('CRACST05S11F839T'),
('RMGMGN76E16F011A'),
('DLNRME81R13H620I'),
('NCLDNL10L09H501B'),
('DLSDNT09C60H501K'),
('VGNLSS91H20M082P'),
('BSGCST99P20L840H'),
('GVNBCR84A01A007R'),
('ZNCGCM00B23L900D'),
('CLGGDI97T28D969K'),
('PRSGLN56P09L270S'),
('GRBLRS93H15G273T'),
('LNRTMS98M24F529X'),
('ZNRSFO69P19E897F'),
('TMMFPP05E04C351B');

INSERT INTO ente (nominativo,cap,citta,civico,via) VALUES
('CSEN','00191','Roma','57','Via Luigi Bodio'),
('FMI','00196','Roma','70','Viale Tiziano'),
('UISP','00155','Roma','73','Largo Francellucci'),
('ASI','00187','Roma','8','Via Piace');

INSERT INTO licenza (codice,ente,data_emissione,data_scadenza,atleta) VALUES
('00041','CSEN','2020-03-05','2021-03-04','CVLLSN00A04A001A'),
('00741','ASI','2020-07-10','2021-07-09','CRACST05S11F839T'),
('11334','FMI','2020-01-01','2020-12-31','BRGFPP00A01C743J'),
('04362','UISP','2020-01-14','2021-01-13','RMGMGN76E16F011A'),
('00002','ASI','2020-01-31','2021-01-30','DLNRME81R13H620I'),
('00231','UISP','2020-04-01','2020-03-31','DPTSML02L07G478S'),
('13456','CSEN','2020-02-12','2021-02-11','NCLDNL10L09H501B'),
('00123','CSEN','2020-02-12','2021-02-11','DLSDNT09C60H501K'),
('00123','FMI','2020-01-01','2020-12-31','VGNLSS91H20M082P'),
('02667','ASI','2020-03-12','2021-03-11','BSGCST99P20L840H'),
('04313','UISP','2020-03-02','2021-03-01','LNRNRC65E13F205E'),
('00012','ASI','2020-04-29','2021-04-28','BRTGPP82S04L219F'),
('04321','CSEN','2020-10-12','2021-10-11','GVNBCR84A01A007R'),
('00672','CSEN','2020-09-21','2021-09-20','ZNCGCM00B23L900D'),
('14567','ASI','2020-01-10','2021-01-09','CLGGDI97T28D969K'),
('14324','CSEN','2020-02-27','2020-02-26','PRSGLN56P09L270S'),
('13678','FMI','2020-01-01','2020-12-31','GRBLRS93H15G273T'),
('00141','UISP','2020-10-30','2021-10-29','LNRTMS98M24F529X'),
('09993','FMI','2020-01-01','2020-12-31','ZNRSFO69P19E897F'),
('03245','UISP','2020-05-15','2021-05-14','TMMFPP05E04C351B');

INSERT INTO certificato (codice,ente,data_emissione,data_scadenza,ranking_min,ranking_max,istruttore) VALUES
('00001','FMI','2020-01-01','2022-12-31',201,1000,'BRGFPP00A01C743J'),
('00002','FMI','2019-01-01','2021-12-31',1,200,'BRGFPP00A01C743J'),
('00743','UISP','2018-01-01','2020-12-31',201,500,'DPTSML02L07G478S'),
('00123','UISP','2020-01-01','2022-12-31',1,200,'LNRNRC65E13F205E'),
('00124','UISP','2020-01-01','2022-12-31',501,1000,'LNRNRC65E13F205E'),
('13244','ASI','2016-01-1','2025-12-31',201,1000,'BRTGPP82S04L219F');

INSERT INTO corso (data,istruttore,durata,circuito) VALUES
('2020-03-10','BRGFPP00A01C743J','06:00:00',4),
('2020-03-17','BRGFPP00A01C743J','08:00:00',4),
('2020-03-21','BRGFPP00A01C743J','06:00:00',5),
('2020-05-01','DPTSML02L07G478S','03:00:00',7),
('2020-06-02','DPTSML02L07G478S','03:00:00',7),
('2020-02-15','LNRNRC65E13F205E','04:00:00',9),
('2020-03-15','LNRNRC65E13F205E','04:00:00',4),
('2020-04-15','LNRNRC65E13F205E','04:00:00',9),
('2020-08-15','BRTGPP82S04L219F','05:00:00',5),
('2020-08-16','BRTGPP82S04L219F','03:00:00',5);

INSERT INTO partecipazionePilotaCorso (pilota,data_corso,istruttore) VALUES
('CVLLSN00A04A001A','2020-03-10','BRGFPP00A01C743J'),
('CRACST05S11F839T','2020-03-10','BRGFPP00A01C743J'),
('RMGMGN76E16F011A','2020-03-10','BRGFPP00A01C743J'),
('DLNRME81R13H620I','2020-03-10','BRGFPP00A01C743J'),
('NCLDNL10L09H501B','2020-03-10','BRGFPP00A01C743J'),
('DLSDNT09C60H501K','2020-03-10','BRGFPP00A01C743J'),
('VGNLSS91H20M082P','2020-03-10','BRGFPP00A01C743J'),
('BSGCST99P20L840H','2020-03-10','BRGFPP00A01C743J'),
('GVNBCR84A01A007R','2020-03-10','BRGFPP00A01C743J'),
('ZNCGCM00B23L900D','2020-03-10','BRGFPP00A01C743J'),
('CLGGDI97T28D969K','2020-03-10','BRGFPP00A01C743J'),
('PRSGLN56P09L270S','2020-03-10','BRGFPP00A01C743J'),
('GRBLRS93H15G273T','2020-03-10','BRGFPP00A01C743J'),
('CVLLSN00A04A001A','2020-03-17','BRGFPP00A01C743J'),
('CRACST05S11F839T','2020-03-17','BRGFPP00A01C743J'),
('NCLDNL10L09H501B','2020-03-17','BRGFPP00A01C743J'),
('DLSDNT09C60H501K','2020-03-17','BRGFPP00A01C743J'),
('VGNLSS91H20M082P','2020-03-17','BRGFPP00A01C743J'),
('BSGCST99P20L840H','2020-03-17','BRGFPP00A01C743J'),
('GVNBCR84A01A007R','2020-03-17','BRGFPP00A01C743J'),
('CLGGDI97T28D969K','2020-03-17','BRGFPP00A01C743J'),
('PRSGLN56P09L270S','2020-03-17','BRGFPP00A01C743J'),
('GRBLRS93H15G273T','2020-03-17','BRGFPP00A01C743J'),
('CVLLSN00A04A001A','2020-03-21','BRGFPP00A01C743J'),
('RMGMGN76E16F011A','2020-03-21','BRGFPP00A01C743J'),
('DLNRME81R13H620I','2020-03-21','BRGFPP00A01C743J'),
('DLSDNT09C60H501K','2020-03-21','BRGFPP00A01C743J'),
('VGNLSS91H20M082P','2020-03-21','BRGFPP00A01C743J'),
('BSGCST99P20L840H','2020-03-21','BRGFPP00A01C743J'),
('ZNCGCM00B23L900D','2020-03-21','BRGFPP00A01C743J'),
('CLGGDI97T28D969K','2020-03-21','BRGFPP00A01C743J'),
('PRSGLN56P09L270S','2020-03-21','BRGFPP00A01C743J'),
('GRBLRS93H15G273T','2020-03-21','BRGFPP00A01C743J'),
('CRACST05S11F839T','2020-05-01','DPTSML02L07G478S'),
('DLNRME81R13H620I','2020-05-01','DPTSML02L07G478S'),
('BSGCST99P20L840H','2020-05-01','DPTSML02L07G478S'),
('GVNBCR84A01A007R','2020-05-01','DPTSML02L07G478S'),
('ZNCGCM00B23L900D','2020-05-01','DPTSML02L07G478S'),
('GRBLRS93H15G273T','2020-05-01','DPTSML02L07G478S'),
('RMGMGN76E16F011A','2020-06-02','DPTSML02L07G478S'),
('DLNRME81R13H620I','2020-06-02','DPTSML02L07G478S'),
('NCLDNL10L09H501B','2020-06-02','DPTSML02L07G478S'),
('DLSDNT09C60H501K','2020-06-02','DPTSML02L07G478S'),
('ZNCGCM00B23L900D','2020-06-02','DPTSML02L07G478S'),
('CLGGDI97T28D969K','2020-06-02','DPTSML02L07G478S'),
('PRSGLN56P09L270S','2020-06-02','DPTSML02L07G478S'),
('GRBLRS93H15G273T','2020-06-02','DPTSML02L07G478S'),
('LNRTMS98M24F529X','2020-02-15','LNRNRC65E13F205E'),
('ZNRSFO69P19E897F','2020-02-15','LNRNRC65E13F205E'),
('CRACST05S11F839T','2020-03-15','LNRNRC65E13F205E'),
('RMGMGN76E16F011A','2020-03-15','LNRNRC65E13F205E'),
('DLNRME81R13H620I','2020-03-15','LNRNRC65E13F205E'),
('NCLDNL10L09H501B','2020-03-15','LNRNRC65E13F205E'),
('DLSDNT09C60H501K','2020-03-15','LNRNRC65E13F205E'),
('LNRTMS98M24F529X','2020-04-15','LNRNRC65E13F205E'),
('ZNRSFO69P19E897F','2020-04-15','LNRNRC65E13F205E'),
('TMMFPP05E04C351B','2020-04-15','LNRNRC65E13F205E'),
('DLNRME81R13H620I','2020-08-15','BRTGPP82S04L219F'),
('NCLDNL10L09H501B','2020-08-15','BRTGPP82S04L219F'),
('DLSDNT09C60H501K','2020-08-15','BRTGPP82S04L219F'),
('VGNLSS91H20M082P','2020-08-15','BRTGPP82S04L219F'),
('BSGCST99P20L840H','2020-08-15','BRTGPP82S04L219F'),
('GVNBCR84A01A007R','2020-08-15','BRTGPP82S04L219F'),
('ZNCGCM00B23L900D','2020-08-15','BRTGPP82S04L219F'),
('CLGGDI97T28D969K','2020-08-15','BRTGPP82S04L219F'),
('PRSGLN56P09L270S','2020-08-15','BRTGPP82S04L219F'),
('GRBLRS93H15G273T','2020-08-15','BRTGPP82S04L219F'),
('CRACST05S11F839T','2020-08-16','BRTGPP82S04L219F'),
('DLNRME81R13H620I','2020-08-16','BRTGPP82S04L219F'),
('VGNLSS91H20M082P','2020-08-16','BRTGPP82S04L219F'),
('GVNBCR84A01A007R','2020-08-16','BRTGPP82S04L219F'),
('ZNCGCM00B23L900D','2020-08-16','BRTGPP82S04L219F'),
('CLGGDI97T28D969K','2020-08-16','BRTGPP82S04L219F');

INSERT INTO moto(n_telaio,marca,modello,cilindrata) VALUES
('AX20200001','Honda','CRF 250R',250),
('AX20080441','Honda','CR 250R',250),
('AX20200014','Honda','CRF 450R',450),
('KX20181112','Kawasaki','KXF 250F',250),
('KX20190001','Kawasaki','KXF 250F',250),
('KX20200041','Kawasaki','KXF 450F',450),
('HX20201413','Husqvarna','TC 125',125),
('HX20201000','Husqvarna','FC 250',250),
('HX20201100','Husqvarna','FC 450',450),
('YX20169941','Yamaha','YZ 125',125),
('YX20200002','Yamaha','YZF 250',250),
('YX20191237','Yamaha','YZF 450',450);

INSERT INTO noleggio (pilota,seriale_telaio,marca,data,ore_utilizzo) VALUES
('RMGMGN76E16F011A','AX20200001','Honda','2020-03-15','02:30:00'),
('RMGMGN76E16F011A','HX20201413','Husqvarna','2020-05-07','3:00:00'),
('NCLDNL10L09H501B','KX20190001','Kawasaki','2020-10-14','2:45:00'),
('BSGCST99P20L840H','YX20191237','Yamaha','2020-09-17','3:15:00'),
('PRSGLN56P09L270S','AX20200001','Honda','2020-04-01','2:00:00'),
('PRSGLN56P09L270S','AX20200014','Honda','2020-01-04','1:30:00'),
('GRBLRS93H15G273T','HX20201000','Husqvarna','2020-02-27','1:45:00'),
('VGNLSS91H20M082P','KX20190001','Kawasaki','2020-06-19','3:30:00'),
('DLSDNT09C60H501K','YX20191237','Yamaha','2020-11-11','2:15:00'),
('GVNBCR84A01A007R','AX20200014','Honda','2020-08-01','3:00:00');

INSERT INTO evento(id,tipo,data,piloti_ammessi,pubblico) VALUES
(1,'Gara individuale','2019-12-08',300,true),
(2,'Endurance','2020-06-01',200,false),
(3,'Gara individuale','2020-08-19',150,false);

INSERT INTO svolgimentoPistaEvento(pista,evento) VALUES
(4,1),
(4,2),
(5,2),
(6,3);

INSERT INTO categoria(id,ranking_min,ranking_max,cilindrata,sesso,fascia_eta,stock) VALUES
(1,1001,10000,250,'M','Elite',false),
(2,1001,10000,250,'M','Elite',true),
(3,1001,10000,450,'M','Elite',false),
(4,1001,10000,125,'M','Elite',false),
(5,501,1000,125,'M','Elite',false),
(6,501,1000,250,'F','Elite',true),
(7,501,1000,250,'M','Elite',true),
(8,501,1000,450,'M','Elite',true),
(9,201,500,125,'M','Senior',true),
(10,201,500,250,'M','Senior',true),
(11,201,500,250,'F','Senior',true),
(12,201,500,450,'M','Senior',true),
(13,201,500,250,'M','Veteran',true),
(14,201,500,450,'M','Veteran',true),
(15,1,200,85,'M','Junior',true),
(16,1,200,65,'M','Junior',true),
(17,1,200,85,'F','Junior',true),
(18,1,200,65,'F','Junior',true);

INSERT INTO inclusioneEventoCategoria(evento,categoria) VALUES
(1,1),
(1,3),
(1,4),
(1,13),
(1,14),
(1,9),
(2,10),
(2,11),
(2,12),
(3,15),
(3,16),
(3,17),
(3,18),
(3,7);

INSERT INTO partecipazione(atleta,evento,categoria,n_gara,marca,modello) VALUES
('CVLLSN00A04A001A',1,2,'41','Honda','CRF 250'),
('BRGFPP00A01C743J',1,2,'13','Kawasaki','KXF 250'),
('RMGMGN76E16F011A',1,3,'14','KTM','SXF 450'),
('DLNRME81R13H620I',1,3,'15','GASGAS','MCF 450'),
('GVNBCR84A01A007R',1,9,'16','KTM','SX 125'),
('ZNCGCM00B23L900D',1,9,'9','Husqvarna','TC 125'),
('GRBLRS93H15G273T',1,9,'4','Yamaha','YZ 125'),
('PRSGLN56P09L270S',1,9,'50','Honda','CR 125'),
('CLGGDI97T28D969K',2,11,'1','Honda','CRF 250'),
('ZNCGCM00B23L900D',2,10,'2','KTM','SXF 250'),
('GVNBCR84A01A007R',2,10,'3','Suzuki','RMZ 250'),
('PRSGLN56P09L270S',2,14,'4','Honda','CRF 450'),
('GRBLRS93H15G273T',2,14,'5','Honda','CRF 450'),
('TMMFPP05E04C351B',3,15,'17','KTM','SX 85'),
('ZNRSFO69P19E897F',3,17,'19','Yamaha','YZ 85'),
('LNRTMS98M24F529X',3,15,'28','Suzuki','RM 85'),
('BRTGPP82S04L219F',3,7,'54','Suzuki','RMZ 250'),
('LNRNRC65E13F205E',3,7,'87','Honda','CRF 250'),
('BSGCST99P20L840H',3,7,'25','KTM','SXF 250'),
('DLSDNT09C60H501K',3,7,'16','Yamaha','YZF 250'),
('NCLDNL10L09H501B',3,7,'3','Kawaski','KXF 250');

INSERT INTO ristoro(id,apertura,chiusura,posti_a_sedere,circuito) VALUES
(1,'08:00:00','18:00:00',50,1),
(2,'8:30:00','17:00:00',100,2),
(3,'7:30:00','15:00:00',30,3),
(4,'9:00:00','19:00:00',45,4),
(5,'7:00:00','17:30:00',70,5),
(6,'10:00:00','19:00:00',30,6),
(7,'10:00:00','19:00:00',20,7),
(8,'8:00:00','17:00:00',25,8),
(9,'7:00:00','18:00:00',50,9),
(10,'10:00:00','15:00:00',35,10);

INSERT INTO fornitura(fornitore,ristoro,data,descrizione) VALUES
(1,1,'2020-10-10','Rifornimento panini, piadine e altri cibi rapidi'),
(2,1,'2020-08-12','Rifornimento integratori sportivi'),
(3,2,'2020-11-04','Rifornimento carni di mucca, maiale e vitello'),
(4,3,'2020-07-15','Rifornimento pane vario surgelato'),
(1,4,'2020-10-10','Rifornimento panini, piadine e altri cibi rapidi'),
(5,5,'2020-09-15','Rifornimento stuzzichini vari'),
(5,6,'2020-09-15','Rifornimento stuzzichini vari'),
(2,7,'2020-08-12','Rifornimento integratori sportivi'),
(5,8,'2020-09-15','Rifornimento stuzzichini vari'),
(3,9,'2020-11-04','Rifornimento carni di mucca, maiale e vitello'),
(4,10,'2020-07-15','Rifornimento pane vario surgelato');

INSERT INTO personale(cf,cognome,nome,data_nascita,cap,citta,civico,via,email,cellulare,impiego,patentino,impiego_ristoro) VALUES
('DLBMRZ80A01A757S','Del Barba','Maurizio','1980-01-01','32100','Belluno','34','Via Roma',NULL,'3392699055','Escavatorista','AA123BC932',NULL),
('DLLRRT66S60F382B','Dalla Bona','Roberta','1966-11-20','35043','Monselice','41','Via Italia','roby.dalla@gmail.com','3284351780','Barista',NULL,1),
('FVRNDR80T12L565F','Favero','Andrea','1980-12-12','31049','Valdobbiadene','15','Via Pieruzzi',NULL,'3477675449','Escavatorista','AA123BC933',NULL),
('MRSMTT01M29F229M','Moressa','Mattia','2001-08-29','30034','Mira','29','Via Venezia','benna@gmail.com','3487625340','Escavatorista','AC435ZZ012',NULL),
('GRNSRN01A20L378L','Gorini','Sabrina','2001-01-20','30014','Trento','5','Via Stazione',NULL,'3332688044','Barista',NULL,2),
('GRNMNL63L13L378N','Gorini','Emanuele','1963-07-13','30014','Trento','5','Via Stazione',NULL,'3382548711','Barista',NULL,2),
('NNCLSS95A14A714N','Innocenti','Alessio','1995-01-14','35041','Battaglia Terme','92','Via del Lavoro','ale.inn@apple.it','0498911382','Barista',NULL,3),
('CVLPLA00A04I799L','Cavaliere','Paolo','2000-04-01','35047','Solesino','93','Via Cervi',NULL,'3487048321','Barista',NULL,4),
('TBLMRZ59A10A001M','Tibaldi','Maurizio','1959-01-10','35031','Abano Terme','32','Via Previtali','mauro@gmail.com','3459871204','Barista',NULL,5),
('BRGSFO65S49L736U','Bergamasco','Sofia','1965-11-09','30125','Venezia','3','Via Roma',NULL,'3491236570','Barista',NULL,6),
('GCMVSS97D69G855J','Giacomini','Vanessa','1997-04-29','35020','Ponte San Nicolo','10','Via Parini','vane.giac@gmail.com','3484810631','Barista',NULL,7),
('CNTGPP96T12H703E','Conte','Giuseppe','1996-12-12','84121','Salerno','45','Via Napoli',NULL,'3290431982','Barista',NULL,8),
('DMIFPP94E13A161F','Di Maio','Filippo','1994-05-13','35020','Albignasego','23','Via Roma',NULL,'3395481052','Barista',NULL,9),
('MLSLGN60E07D496B','Malesan','Luigino','1960-05-07','36030','Fara Vicentino','1','Via Stella',NULL,'3477634932','Barista',NULL,10),
('PRSGLN56P09L270S','Pressato','Giuliano','1956-09-09','35038','Torreglia','47','Via Regazzoni',NULL,'0498911843','Escavatorista','AC541FF543',NULL),
('GRNDGI88E13I829Q','Gringo','Diego','1988-05-13','23100','Sondrio','43','Via Martiri',NULL,'3282688544','Escavatorista','AB435CF543',NULL);

INSERT INTO manutenzione(pista,addetto,mezzo,data,durata,descrizione) VALUES
(1,'DLBMRZ80A01A757S','AA123A','2020-11-02','2:00:00','Fresatura del terreno'),
(1,'FVRNDR80T12L565F','FB672A','2020-12-01','3:00:00','Rifacimento di paraboliche e salti'),
(2,'MRSMTT01M29F229M','DG000B','2020-05-14','1:30:00','Fresatura del terreno'),
(3,'DLBMRZ80A01A757S','CZ138Z','2020-06-16','2:00:00','Rifacimento di paraboliche e salti'),
(4,'GRNDGI88E13I829Q','CZ138Z','2020-07-23','2:30:00','Rifacimento di paraboliche e salti'),
(5,'DLBMRZ80A01A757S','DG000B','2020-03-03','00:30:00','Fresatura del terreno'),
(6,'PRSGLN56P09L270S','CZ138Z','2020-10-29','2:00:00','Rifacimento di paraboliche e salti'),
(5,'FVRNDR80T12L565F','FB672A','2020-03-03','3:00:00','Rifacimento di paraboliche e salti');

INSERT INTO allenamento(id,data,cadute,pilota,circuito) VALUES
(1,'2020-09-04',0,'CVLLSN00A04A001A',1),
(2,'2020-09-15',0,'CVLLSN00A04A001A',2),
(3,'2020-05-10',3,'DLNRME81R13H620I',3),
(4,'2020-02-13',2,'NCLDNL10L09H501B',5),
(5,'2020-08-17',1,'ZNCGCM00B23L900D',6),
(6,'2020-10-29',0,'PRSGLN56P09L270S',7),
(7,'2020-11-05',0,'LNRTMS98M24F529X',8),
(8,'2020-10-12',2,'LNRTMS98M24F529X',9),
(9,'2020-11-12',1,'RMGMGN76E16F011A',1),
(10,'2020-09-03',0,'VGNLSS91H20M082P',5),
(11,'2020-02-13',2,'BSGCST99P20L840H',4),
(12,'2020-02-13',1,'PRSGLN56P09L270S',7);

INSERT INTO giro(id,orario_passaggio,tempo_totale,settore_1,settore_2,settore_3,caduta,sessione) VALUES
(1,'2020-09-04 14:00:00','00:01:59','00:00:49','00:00:31','00:00:39',false,1),
(2,'2020-09-04 14:01:49','00:01:49','00:00:45','00:00:30','00:00:34',false,1),
(3,'2020-09-04 14:03:37','00:01:48','00:00:44','00:00:31','00:00:33',false,1),
(4,'2020-09-04 14:05:25','00:01:48','00:00:43','00:00:32','00:00:33',false,1),
(5,'2020-09-04 14:07:12','00:01:47','00:00:43','00:00:31','00:00:34',false,1),
(6,'2020-11-12 11:05:33','00:02:05','00:00:55','00:00:35','00:00:35',false,9),
(7,'2020-11-12 11:07:28','00:01:55','00:00:50','00:00:32','00:00:33',false,9),
(8,'2020-11-12 11:09:19','00:01:51','00:00:48','00:00:31','00:00:32',false,9),
(9,'2020-11-12 11:12:24','00:03:05','00:00:47','00:01:38','00:00:40',true,9),
(10,'2020-11-12 11:14:16','00:01:52','00:00:47','00:00:32','00:00:33',false,9),
(11,'2020-09-15 17:33:24','00:01:45','00:00:45','00:00:32','00:00:28',false,2),
(12,'2020-09-15 17:35:05','00:01:41','00:00:43','00:00:30','00:00:28',false,2),
(13,'2020-09-15 17:36:46','00:01:41','00:00:42','00:00:30','00:00:29',false,2),
(14,'2020-09-15 17:38:25','00:01:39','00:00:39','00:00:31','00:00:29',false,2),
(15,'2020-09-15 17:40:08','00:01:43','00:00:42','00:00:33','00:00:27',false,2),
(16,'2020-05-10 09:41:18','00:01:40','00:00:35','00:00:39','00:00:26',true,3),
(17,'2020-05-10 09:42:57','00:01:39','00:00:35','00:00:38','00:00:26',true,3),
(18,'2020-05-10 09:44:37','00:01:40','00:00:34','00:00:39','00:00:27',true,3),
(19,'2020-05-10 09:46:18','00:01:39','00:00:34','00:00:37','00:00:28',false,3),
(20,'2020-05-10 09:52:01','00:05:43','00:00:34','00:00:36','00:03:23',true,3),
(21,'2020-02-13 16:02:20','00:02:20','00:00:49','00:00:41','00:00:50',false,11),
(22,'2020-02-13 16:06:32','00:04:12','00:00:45','00:02:40','00:00:47',true,11),
(23,'2020-02-13 16:08:45','00:02:13','00:00:44','00:00:42','00:00:47',false,11),
(24,'2020-02-13 16:10:55','00:02:10','00:00:44','00:00:40','00:00:46',false,11),
(25,'2020-02-13 16:15:54','00:04:59','00:00:45','00:00:41','00:03:33',true,11),
(26,'2020-02-13 15:54:00','00:01:35','00:00:35','00:00:31','00:00:29',false,4),
(27,'2020-02-13 15:55:33','00:01:33','00:00:34','00:00:31','00:00:28',false,4),
(28,'2020-02-13 15:57:38','00:02:05','00:00:34','00:00:50','00:00:41',true,4),
(29,'2020-02-13 15:59:14','00:01:36','00:00:36','00:00:32','00:00:28',false,4),
(30,'2020-02-13 16:00:48','00:01:34','00:00:34','00:00:32','00:00:28',false,4),
(36,'2020-09-03 13:00:00','00:01:45','00:00:42','00:00:33','00:00:30',false,10),
(37,'2020-09-03 13:01:34','00:01:34','00:00:35','00:00:31','00:00:28',false,10),
(38,'2020-09-03 13:03:24','00:01:50','00:00:47','00:00:32','00:00:31',true,10),
(39,'2020-09-03 13:04:57','00:01:33','00:00:33','00:00:33','00:00:27',false,10),
(40,'2020-09-03 13:06:28','00:01:31','00:00:32','00:00:32','00:00:27',false,10),
(31,'2020-08-17 08:31:48','00:01:45','00:00:30','00:00:45','00:00:30',false,5),
(32,'2020-08-17 08:33:34','00:01:46','00:00:32','00:00:44','00:00:30',false,5),
(33,'2020-08-17 08:35:19','00:01:45','00:00:31','00:00:45','00:00:29',false,5),
(34,'2020-08-17 08:37:03','00:01:44','00:00:31','00:00:44','00:00:29',false,5),
(35,'2020-08-17 08:40:03','00:03:00','00:00:31','00:00:49','00:01:40',true,5),
(41,'2020-10-29 11:13:32','00:01:30','00:00:27','00:00:30','00:00:33',false,6),
(42,'2020-10-29 11:15:00','00:01:28','00:00:26','00:00:29','00:00:33',false,6),
(43,'2020-10-29 11:16:29','00:01:29','00:00:28','00:00:29','00:00:31',false,6),
(44,'2020-10-29 11:18:09','00:01:40','00:00:32','00:00:35','00:00:33',false,6),
(45,'2020-10-29 11:19:44','00:01:35','00:00:30','00:00:32','00:00:33',false,6),
(46,'2020-11-05 12:45:58','00:01:10','00:00:30','00:00:22','00:00:18',false,7),
(47,'2020-11-05 12:47:03','00:01:05','00:00:26','00:00:21','00:00:18',false,7),
(48,'2020-11-05 12:48:09','00:01:06','00:00:25','00:00:22','00:00:19',false,7),
(49,'2020-11-05 12:49:13','00:01:04','00:00:24','00:00:23','00:00:17',false,7),
(50,'2020-11-05 12:50:28','00:01:15','00:00:35','00:00:22','00:00:18',false,7),
(51,'2020-10-12 12:31:12','00:00:43','00:00:15','00:00:18','00:00:10',false,8),
(52,'2020-10-12 12:31:57','00:00:45','00:00:16','00:00:17','00:00:12',false,8),
(53,'2020-10-12 12:32:39','00:00:42','00:00:14','00:00:16','00:00:12',false,8),
(54,'2020-10-12 12:33:44','00:01:05','00:00:15','00:00:38','00:00:13',true,8),
(55,'2020-10-12 12:38:00','00:05:00','00:00:16','00:00:24','00:04:20',true,8),
(56,'2020-02-13 14:17:13','00:01:32','00:00:29','00:00:30','00:00:33',false,12),
(57,'2020-02-13 14:18:54','00:01:41','00:00:35','00:00:32','00:00:34',false,12),
(58,'2020-02-13 14:22:11','00:03:17','00:00:28','00:00:32','00:02:17',true,12);

INSERT INTO infortunio(descrizione,sessione) VALUES
('Il pilota perdeva il controllo della moto durante la percorrenza di una curva, cadendo pesantemente sulla spalla sinistra.',3),
('L''atleta durante un salto perde i piedi dalle pedane e cade violentemente di schiena.',11),
('Il pilota scivola banalmente nell''ingresso di una curva, con la gamba incastrata tra moto e terreno.',5),
('Il pilota perde il controllo del mezzo durante una frenata, venendo catapultato in avanti.',8),
('L''atleta durante la percorrenza di una curva, perde il controllo dell''anteriore appoggiando in modo violento il ginocchio',12);


/* --- QUERY --- */

/* Elenco ordinato degli istruttori che hanno raccolto il maggior numero di partecipazioni ai loro corsi. */
DROP VIEW IF EXISTS partecipazioneCorsi;

CREATE VIEW partecipazioneCorsi(data_corso,istruttore,num_partecipanti) AS
SELECT data_corso,istruttore,COUNT(*)
FROM partecipazionePilotaCorso
GROUP BY data_corso,istruttore;

SELECT cognome, nome, SUM(num_partecipanti) AS partecipazioniTotali
FROM partecipazioneCorsi, istruttore, atleta
WHERE partecipazioneCorsi.istruttore = istruttore.cf AND istruttore.cf = atleta.cf
GROUP BY cognome, nome
ORDER BY partecipazioniTotali DESC;

/* Elenco ordinato degli enti che hanno registrato il maggior numero di infortuni in allenamento per una determinata fascia di ranking.  */
DROP VIEW IF EXISTS dati_infortunio;

CREATE VIEW dati_infortunio (cod_licenza,ente,pilota,allenamento,data) AS
SELECT codice, ente, pilota, a.id, a.data
FROM licenza l, pilota p, allenamento a, infortunio i, ente e, atleta at
WHERE e.nominativo = l.ente AND l.atleta = at.cf AND p.cf = at.cf AND p.cf = a.pilota AND i.sessione = a.id;

SELECT ente, COUNT(*) AS num_infortuni
FROM dati_infortunio, pilota, atleta
WHERE pilota.cf = atleta.cf AND dati_infortunio.pilota = pilota.cf AND ranking BETWEEN 1 AND 1000
GROUP BY ente
ORDER BY num_infortuni DESC;

/* Per ogni pilota determinare la pista che ha frequentato di maggiormente (in termini di eventi, corsi e allenamenti). Se un pilota ha frequentato maggiormente più piste (stesso numero di presenze), mostrare tutte le tuple. */
DROP VIEW IF EXISTS presenzePiste;

CREATE VIEW presenzePiste (pilota,pista,presenze) AS
SELECT pilota, circuito, COUNT(*)
FROM allenamento
GROUP BY pilota, circuito
UNION ALL
SELECT pilota,circuito,COUNT(*)
FROM partecipazionePilotaCorso AS p, corso AS c
WHERE p.data_corso = c.data AND p.istruttore = c.istruttore
GROUP BY pilota, circuito
UNION ALL
SELECT atleta, pista, COUNT(*)
FROM atleta, pilota, partecipazione AS p, evento, svolgimentoPistaEvento AS s
WHERE atleta.cf = pilota.cf AND atleta.cf = p.atleta AND p.evento = evento.id AND evento.id = s.evento
GROUP BY atleta, pista;

DROP VIEW IF EXISTS presenzeTotali;

CREATE VIEW presenzeTotali(pilota, pista, presenze) AS
SELECT pilota, pista, SUM(presenze) 
FROM presenzePiste
GROUP BY pilota, pista;

DROP VIEW IF EXISTS maxVisitePista;

CREATE VIEW maxVisitePista (pilota,presenze) AS
SELECT pilota, MAX(presenze)
FROM presenzeTotali
GROUP BY pilota;

SELECT *
FROM presenzeTotali
WHERE (pilota,presenze) IN (SELECT * FROM maxVisitePista)
ORDER BY pilota;

/* Elenco dei piloti (e corrispettiva data) che hanno subito un infortunio lo stesso giorno in cui hanno fatto il loro giro più veloce in una pista. */
DROP VIEW IF EXISTS giriVelociPiloti;

CREATE VIEW giriVelociPiloti (pilota, circuito, sessione, tempo_totale) AS
SELECT pilota, circuito, allenamento.id, MIN(tempo_totale) 
FROM giro, allenamento
WHERE giro.sessione = allenamento.id
GROUP BY pilota, circuito,allenamento.id;

DROP VIEW IF EXISTS giriVelociAssolutiPiloti;

CREATE VIEW giriVelociAssolutiPiloti (pilota, circuito, sessione, tempo_totale) AS
SELECT *
FROM giriVelociPiloti
EXCEPT
SELECT g1.pilota, g1.circuito, g1.sessione, g1.tempo_totale
FROM giriVelociPiloti g1, giriVelociPiloti g2
WHERE g1.sessione != g2.sessione AND g1.pilota = g2.pilota AND g1.circuito = g2.circuito AND g1.tempo_totale > g2.tempo_totale;

SELECT g.pilota, a.data
FROM giriVelociAssolutiPiloti g, allenamento a, infortunio i
WHERE g.sessione = a.id AND i.sessione = a.id;

/* Per ogni circuito, restituire il miglior tempo assoluto, indicando anche il pilota che detiene il record. */
SELECT circuito, cognome, nome, tempo_totale 
FROM (SELECT circuito, pilota, tempo_totale
	FROM giriVelociPiloti
	EXCEPT
	SELECT g1.circuito, g1.pilota, g1.tempo_totale
	FROM giriVelociPiloti g1, giriVelociPiloti g2
	WHERE g1.circuito = g2.circuito AND g1.tempo_totale > g2.tempo_totale) AS g, pilota, atleta
WHERE g.pilota = pilota.cf AND pilota.cf = atleta.cf
ORDER BY circuito;

/* Trovare i membri del personale che sono anche piloti e che hanno eseguito un'operazione di manutenzione e un allenamento durante la stessa giornata. */
SELECT p.cognome, p.nome, m.data
FROM personale p, atleta a, pilota pi, allenamento al, manutenzione m
WHERE p.cf = a.cf AND a.cf = pi.cf AND pi.cf = al.pilota AND p.cf = m.addetto and m.data = al.data
ORDER BY p.cognome, p.nome;



/* --- INDICI --- */
DROP INDEX IF EXISTS atleti_cognomi;
CREATE INDEX atleti_cognomi ON atleta  USING hash (cognome);

DROP INDEX IF EXISTS atleti_nomi;
CREATE INDEX atleti_nomi ON atleta  USING hash (nome);

DROP INDEX IF EXISTS giri_data_passaggio;
CREATE INDEX giri_data_passaggio ON giro(orario_passaggio);































