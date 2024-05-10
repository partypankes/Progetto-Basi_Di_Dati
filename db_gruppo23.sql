-- Database: gruppo23_hidric

-- DROP DATABASE IF EXISTS gruppo23_hidric;

/*CREATE DATABASE gruppo23_hidric
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Italian_Italy.1252'
    LC_CTYPE = 'Italian_Italy.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

create schema hidric;
set schema 'hidric';
*/
drop table if exists Sfrutta;
drop table if exists Adesione;
drop table if exists Organizzazione_Collaboratrice;
drop table if exists Strategia;
drop table if exists Addetto_Monitoraggio;
drop table if exists Addetto_Conservazione;
drop table if exists Iniziativa_Conservazione;
drop table if exists Monitoraggio_Passato;
drop table if exists Monitoraggio_Presente;
drop table if exists Monitoraggio;
drop table if exists Dato_Ambientale;
drop table if exists Sensore;
drop table if exists Stazione_Monitoraggio;
drop table if exists Esistenza;
drop table if exists Specie;
drop table if exists Bacino_Idrografico;
drop table if exists Posizione;


create table Posizione (
                           latitudine numeric,
                           longitudine numeric,
                           area_geografica varchar(50) not null,
                           altitudine numeric not null,
                           primary key (latitudine, longitudine)
);


create table Bacino_Idrografico (
                                    Id_bacino smallint,
                                    volume_acqua int not null,
                                    nome varchar(25) not null,
                                    latitudine numeric,
                                    longitudine numeric,
                                    primary key (Id_bacino,latitudine,longitudine),
                                    constraint pk_posizione foreign key (latitudine, longitudine) references Posizione(latitudine, longitudine)
);


create table Specie (
                        nome_scientifico varchar(30) primary key,
                        nome_comune varchar(20) not null,
                        stato_conservazione varchar(30) not null,
                        habitat varchar(20),
                        dieta varchar(20),
                        tipo_crescita varchar(20),
                        tipo_vegetazione varchar(20),
                        check (
                            (
                                habitat is not null and dieta is not null
                                    and tipo_crescita is null and tipo_vegetazione is null

                                )
                                or
                            (
                                habitat is null and dieta is null
                                    and tipo_crescita is not null and tipo_vegetazione is not null
                                )
                            )
);


create table Esistenza (
                           Id_bacino smallint,
                           latitudine numeric,
                           longitudine numeric,
                           nome_scientifico varchar(30),
                           percentuale_abbondanza int check(percentuale_abbondanza <= 100 and percentuale_abbondanza >= 0),
                           primary key (Id_bacino,latitudine,longitudine,nome_scientifico),
                           constraint pk_bacino_idrografico foreign key (Id_bacino,longitudine,latitudine) references Bacino_Idrografico(Id_bacino,longitudine,latitudine),
                           constraint pk_specie foreign key (nome_scientifico) references Specie(nome_scientifico)
);

create table Stazione_Monitoraggio (
                                       Id_Stazione smallint primary key,
                                       Stato_attivazione boolean not null,
                                       nome varchar(20) not null
);

create table Sensore (
                         Id_Sensore smallint,
                         Id_Stazione smallint,
                         tipo varchar(30) not null,
                         precisione int check (precisione <= 100 and precisione >= 0),
                         N_dati int not null,
                         data_installazione date not null,
                         primary key (Id_Sensore, Id_Stazione),
                         constraint pk_stazione_monitoraggio foreign key (Id_Stazione) references Stazione_Monitoraggio(Id_Stazione)
);

create table Dato_Ambientale (
                                 Id_Dato smallint,
                                 Id_Sensore smallint,
                                 Id_Stazione smallint,
                                 tipo varchar(20) not null,
                                 valore int not null,
                                 valenza boolean,
                                 primary key(Id_Dato, Id_Sensore, Id_Stazione),
                                 constraint pk_sensore foreign key (Id_Sensore, Id_Stazione) references Sensore(Id_Sensore, Id_Stazione)
);

create table Monitoraggio (
                              Id_Monitoraggio smallint,
                              Id_bacino smallint,
                              longitudine numeric,
                              latitudine numeric,
                              Id_Stazione smallint,
                              tipo_monitoraggio varchar(20) not null,
                              data_inizio date not null,
                              primary key(Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
                              constraint pk_bacino_idrografico foreign key (Id_bacino, longitudine, latitudine) references Bacino_Idrografico(Id_bacino, longitudine, latitudine),
                              constraint pk_stazione_monitoraggio foreign key (Id_Stazione) references Stazione_Monitoraggio(Id_Stazione)
);

create table Monitoraggio_Presente (
                                       Id_Monitoraggio smallint,
                                       Id_bacino smallint,
                                       longitudine numeric,
                                       latitudine numeric,
                                       Id_Stazione smallint,
                                       progresso int check(progresso <= 100 and progresso >= 0),
                                       primary key(Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
                                       constraint pk_monitoraggio foreign key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione) references Monitoraggio(Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione)
);

create table Monitoraggio_Passato (
                                      Id_Monitoraggio smallint,
                                      Id_bacino smallint,
                                      longitudine numeric,
                                      latitudine numeric,
                                      Id_Stazione smallint,
                                      data_fine date not null,
                                      primary key(Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
                                      constraint pk_monitoraggio foreign key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione) references Monitoraggio(Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione)
);

create table Iniziativa_Conservazione (
                                          Id_iniziativa smallint,
                                          Id_bacino smallint,
                                          longitudine numeric,
                                          latitudine numeric,
                                          data_fine date,
                                          Indicatore_successo int,
                                          check (
                                              (Indicatore_successo
                                                   is null and data_fine is null) or (
                                                  (Indicatore_successo <= 100 and Indicatore_successo >= 0)
                                                      and
                                                  data_fine is not null
                                                  )
                                              ),
                                          primary key (Id_iniziativa, Id_bacino, longitudine, latitudine),
                                          constraint pk_bacino_idrografico foreign key (Id_bacino, longitudine, latitudine) references Bacino_Idrografico(Id_bacino, longitudine, latitudine)
);

create table Addetto_Conservazione (
                                       CF varchar(30) primary key,
                                       Id_iniziativa smallint not null,
                                       Id_bacino smallint not null,
                                       longitudine numeric not null,
                                       latitudine numeric not null,
                                       nome varchar(20) not null,
                                       cognome varchar(20) not null,
                                       disponibilità boolean not null,
                                       Specializzazione varchar(20) not null,
                                       constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione(Id_iniziativa, Id_bacino, longitudine, latitudine)
);

create table Addetto_Monitoraggio (
                                      CF smallint primary key,
                                      Id_monitoraggio smallint not null,
                                      Id_Stazione smallint not null,
                                      Id_bacino smallint not null,
                                      longitudine numeric not null,
                                      latitudine numeric not null,
                                      nome varchar(20) not null,
                                      cognome varchar(20) not null,
                                      disponibilità boolean not null,
                                      Competenze_tecniche varchar(20) not null,
                                      Strumentazione_utilizzata varchar(20) not null,
                                      constraint pk_monitoraggio foreign key (Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine) references Monitoraggio(Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine)
);

create table Strategia (
                           Nome varchar(20),
                           Tecnica varchar(20),
                           primary key (Nome, Tecnica)
);

create table Organizzazione_Collaboratrice (
                                               Id_organizzazione smallint primary key,
                                               contributo varchar(20) not null,
                                               ruolo varchar(20) not null,
                                               tipo varchar(20) not null
);

create table Adesione (
                          Id_Organizzazione smallint,
                          Id_iniziativa smallint,
                          Id_bacino smallint,
                          longitudine numeric,
                          latitudine numeric,
                          primary key(Id_Organizzazione, Id_iniziativa, Id_bacino, longitudine, latitudine),
                          constraint pk_organizzazione_collaboratrice foreign key (Id_Organizzazione) references Organizzazione_Collaboratrice(Id_Organizzazione),
                          constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione(Id_iniziativa, Id_bacino, longitudine, latitudine)
);

create table Sfrutta (
                         Nome_Strategia varchar(20),
                         Tecnica varchar(20),
                         Id_iniziativa smallint not null,
                         Id_bacino smallint not null,
                         longitudine numeric not null,
                         latitudine numeric not null,
                         primary key (Nome_Strategia, Tecnica),
                         constraint pk_strategia foreign key (Nome_Strategia, Tecnica) references Strategia(Nome, Tecnica),
                         constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione(Id_iniziativa, Id_bacino, longitudine, latitudine)
);



insert into Posizione (latitudine, longitudine, area_geografica, altitudine)
values
    (45.0, 12.0, 'Pianura', 45),           -- Bacino del Po
    (42.5, 12.5, 'Collina', 100),          -- Bacino del Tevere
    (45.7, 11.0, 'Montagna', 250),         -- Bacino del fiume Adige
    (43.7, 11.0, 'Montagna', 100),         -- Bacino del fiume Arno
    (44.7, 8.2, 'Collina', 170),           -- Bacino del fiume Tanaro
    (43.9, 10.5, 'Montagna', 200),         -- Bacino del fiume Serchio
    (45.4, 11.6, 'Montagna', 100),         -- Bacino del fiume Brenta
    (46.3, 13.0, 'Montagna', 220),         -- Bacino del fiume Tagliamento
    (46.4, 12.4, 'Montagna', 180),         -- Bacino del fiume Piave
    (44.4, 11.4, 'Collina', 50),           -- Bacino del fiume Reno
    (45.6, 9.4, 'Montagna', 160),          -- Bacino del fiume Lambro
    (46.1, 9.4, 'Montagna', 400),          -- Bacino del fiume Adda
    (45.5, 10.1, 'Montagna', 350),         -- Bacino del fiume Oglio
    (45.7, 8.6, 'Montagna', 150),          -- Bacino del fiume Ticino
    (41.9, 14.2, 'Collina', 500),          -- Bacino del fiume Sangro
    (41.1, 14.1, 'Collina', 200),          -- Bacino del fiume Volturno
    (40.6, 15.2, 'Montagna', 300),         -- Bacino del fiume Sele
    (40.5, 16.4, 'Collina', 350),          -- Bacino del fiume Basento
    (41.2, 15.6, 'Collina', 250),          -- Bacino del fiume Ofanto
    (40.0, 16.5, 'Collina', 150);          -- Bacino del fiume Sinni



insert into Bacino_Idrografico(Id_bacino, volume_acqua, nome, latitudine, longitudine)
values
    (1, 150000, 'fiume Po', 45.0, 12.0),
    (2, 50000, 'fiume Tevere', 42.5, 12.5),
    (3, 80000, 'fiume Adige', 45.7, 11.0),
    (4, 60000, 'fiume Arno', 43.7, 11.0),
    (5, 70000, 'fiume Tanaro', 44.7, 8.2),
    (6, 45000, 'fiume Serchio', 43.9, 10.5),
    (7, 70000, 'fiume Brenta', 45.4, 11.6),
    (8, 65000, 'fiume Tagliamento', 46.3, 13.0),
    (9, 72000, 'fiume Piave', 46.4, 12.4),
    (10, 62000, 'fiume Reno', 44.4, 11.4),
    (11, 53000, 'fiume Lambro', 45.6, 9.4),
    (12, 75000, 'fiume Adda', 46.1, 9.4),
    (13, 61000, 'fiume Oglio', 45.5, 10.1),
    (14, 90000, 'fiume Ticino', 45.7, 8.6),
    (15, 54000, 'fiume Sangro', 41.9, 14.2),
    (16, 58000, 'fiume Volturno', 41.1, 14.1),
    (17, 56000, 'fiume Sele', 40.6, 15.2),
    (18, 62000, 'fiume Basento', 40.5, 16.4),
    (19, 68000, 'fiume Ofanto', 41.2, 15.6),
    (20, 72000, 'fiume Sinni', 40.0, 16.5);


--Flora
insert into Specie(nome_scientifico, nome_comune, stato_conservazione, habitat, dieta, tipo_crescita, tipo_vegetazione)
values
    ('Fagus sylvatica', 'Faggio', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Pinus nigra', 'Pino Nero', 'Basso rischio', NULL, NULL, 'Albero', 'Conifera'),
    ('Quercus robur', 'Quercia', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Rosa canina', 'Rosa Canina', 'Rischio minimo', NULL, NULL, 'Arbusto', 'Rosaceae'),
    ('Abies alba', 'Abete Bianco', 'Rischio minimo', NULL, NULL, 'Albero', 'Conifera'),
    ('Picea abies', 'Abete Rosso', 'Rischio minimo', NULL, NULL, 'Albero', 'Conifera'),
    ('Acer campestre', 'Acero Campestre', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Fraxinus excelsior', 'Frassino Comune', 'Prossimo alla minaccia', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Hedera helix', 'Edera', 'Rischio minimo', NULL, NULL, 'Rampicante', 'Araliaceae'),
    ('Tilia cordata', 'Tiglio Selvatico', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Castanea sativa', 'Castagno', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Prunus avium', 'Ciliegio Selvatico', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Sambucus nigra', 'Sambuco Nero', 'Rischio minimo', NULL, NULL, 'Arbusto', 'Caprifoliaceae'),
    ('Carpinus betulus', 'Carpino Bianco', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Aesculus hippocastanum', 'Ippocastano', 'Vulnerabile', NULL, NULL, 'Albero', 'Latifoglia');


--Fauna
insert into Specie (nome_scientifico, nome_comune, stato_conservazione, habitat, dieta, tipo_crescita, tipo_vegetazione)
values
    ('Salmo salar', 'Salmone Atlantico', 'Basso rischio', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Oncorhynchus mykiss', 'Trota Arcobaleno', 'Vulnerabile', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Esox lucius', 'Luccio', 'Rischio minimo', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Anguilla anguilla', 'Anguilla Europea', 'Critico', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Perca fluviatilis', 'Persico Reale', 'Rischio minimo', 'Lago', 'Carnivoro', NULL, NULL),
    ('Silurus glanis', 'Siluro', 'Rischio minimo', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Coregonus albula', 'Coregone Bianco', 'Rischio minimo', 'Lago', 'Carnivoro', NULL, NULL),
    ('Alburnus alburnus', 'Alborella', 'Rischio minimo', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Gobio gobio', 'Gobione', 'Rischio minimo', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Cyprinus carpio', 'Carpa', 'Rischio minimo', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Rutilus rutilus', 'Rutilo', 'Rischio minimo', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Lepomis gibbosus', 'Persico Sole', 'Rischio minimo', 'Lago', 'Carnivoro', NULL, NULL),
    ('Tinca tinca', 'Tinca', 'Rischio minimo', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Scardinius erythrophthalmus', 'Scardola', 'Rischio minimo', 'Lago', 'Onnivoro', NULL, NULL),
    ('Sander lucioperca', 'Luciperca', 'Rischio minimo', 'Fiume', 'Carnivoro', NULL, NULL);


insert into Esistenza (Id_bacino, latitudine, longitudine, nome_scientifico, percentuale_abbondanza)
values
    (1, 45.0, 12.0, 'Salmo salar', 10),
    (1, 45.0, 12.0, 'Oncorhynchus mykiss', 15),
    (1, 45.0, 12.0, 'Esox lucius', 20),
    (1, 45.0, 12.0, 'Anguilla anguilla', 5),
    (1, 45.0, 12.0, 'Perca fluviatilis', 8),
    (2, 42.5, 12.5, 'Silurus glanis', 12),
    (2, 42.5, 12.5, 'Coregonus albula', 7),
    (2, 42.5, 12.5, 'Alburnus alburnus', 10),
    (2, 42.5, 12.5, 'Gobio gobio', 18),
    (2, 42.5, 12.5, 'Cyprinus carpio', 12),
    (3, 45.7, 11.0, 'Rutilus rutilus', 15),
    (3, 45.7, 11.0, 'Lepomis gibbosus', 5),
    (3, 45.7, 11.0, 'Tinca tinca', 25),
    (3, 45.7, 11.0, 'Scardinius erythrophthalmus', 30),
    (3, 45.7, 11.0, 'Sander lucioperca', 10),
    (4, 43.7, 11.0, 'Fagus sylvatica', 30),
    (4, 43.7, 11.0, 'Pinus nigra', 20),
    (4, 43.7, 11.0, 'Quercus robur', 15),
    (4, 43.7, 11.0, 'Rosa canina', 10),
    (4, 43.7, 11.0, 'Abies alba', 25),
    (5, 44.7, 8.2, 'Picea abies', 15),
    (5, 44.7, 8.2, 'Acer campestre', 18),
    (5, 44.7, 8.2, 'Fraxinus excelsior', 20),
    (5, 44.7, 8.2, 'Hedera helix', 10),
    (5, 44.7, 8.2, 'Tilia cordata', 25),
    (6, 43.9, 10.5, 'Castanea sativa', 10),
    (6, 43.9, 10.5, 'Prunus avium', 15),
    (6, 43.9, 10.5, 'Sambucus nigra', 20),
    (6, 43.9, 10.5, 'Carpinus betulus', 12),
    (6, 43.9, 10.5, 'Aesculus hippocastanum', 18),
    (7, 45.4, 11.6, 'Salmo salar', 14),
    (7, 45.4, 11.6, 'Oncorhynchus mykiss', 10),
    (7, 45.4, 11.6, 'Esox lucius', 18),
    (7, 45.4, 11.6, 'Anguilla anguilla', 12),
    (7, 45.4, 11.6, 'Perca fluviatilis', 16),
    (8, 46.3, 13.0, 'Silurus glanis', 10),
    (8, 46.3, 13.0, 'Coregonus albula', 12),
    (8, 46.3, 13.0, 'Alburnus alburnus', 14),
    (8, 46.3, 13.0, 'Gobio gobio', 16),
    (8, 46.3, 13.0, 'Cyprinus carpio', 20),
    (9, 46.4, 12.4, 'Rutilus rutilus', 25),
    (9, 46.4, 12.4, 'Lepomis gibbosus', 30),
    (9, 46.4, 12.4, 'Tinca tinca', 35),
    (9, 46.4, 12.4, 'Scardinius erythrophthalmus', 10),
    (9, 46.4, 12.4, 'Sander lucioperca', 15),
    (10, 44.4, 11.4, 'Fagus sylvatica', 20),
    (10, 44.4, 11.4, 'Pinus nigra', 18),
    (10, 44.4, 11.4, 'Quercus robur', 25),
    (10, 44.4, 11.4, 'Rosa canina', 12),
    (10, 44.4, 11.4, 'Abies alba', 15);

insert into Stazione_Monitoraggio (Id_Stazione, Stato_attivazione, nome)
values
    (1, TRUE, 'Stazione 1'),
    (2, FALSE, 'Stazione 2'),
    (3, TRUE, 'Stazione 3'),
    (4, FALSE, 'Stazione 4'),
    (5, TRUE, 'Stazione 5'),
    (6, FALSE, 'Stazione 6'),
    (7, TRUE, 'Stazione 7'),
    (8, FALSE, 'Stazione 8'),
    (9, TRUE, 'Stazione 9'),
    (10, FALSE, 'Stazione 10'),
    (11, TRUE, 'Stazione 11'),
    (12, FALSE, 'Stazione 12'),
    (13, TRUE, 'Stazione 13'),
    (14, FALSE, 'Stazione 14'),
    (15, TRUE, 'Stazione 15');

--Permette di contare il numero di presenze di una specie nei bacini
select s.nome_scientifico,count(BI.nome) as numero_di_presenze
from Specie s
join Esistenza E on s.nome_scientifico = E.nome_scientifico
join Bacino_Idrografico BI on BI.Id_bacino = E.Id_bacino and BI.longitudine = E.longitudine and BI.latitudine = E.latitudine
group by s.nome_scientifico;

--Restituisce il numero di bacini con volume d'acqua > 100 senza iniziative di conservazione passate o presenti
select count(bi.nome) as grandi_bacini_senza_interventi
from Bacino_Idrografico bi
where bi.volume_acqua > 100 and not exists (select nome from Bacino_Idrografico join Iniziativa_Conservazione on Bacino_Idrografico.Id_bacino = Iniziativa_Conservazione.Id_bacino and Bacino_Idrografico.longitudine = Iniziativa_Conservazione.longitudine and Bacino_Idrografico.latitudine = Iniziativa_Conservazione.latitudine);

--Unisce i nomi e il CF degli Addetti al Monitoraggio e degli Addetti alla Conservazione disponibili
select am.CF,am.nome
from Addetto_Monitoraggio am
where am.disponibilità = true
union
select ac.CF,ac.nome
from Addetto_Conservazione ac
where ac.disponibilità = true;

--Trova il numero di organizzazioni per Iniziativa Di Conservazione
create view N_Organizzazioni_per_Intervento as (select count(adesione.Id_Organizzazione) as numero_organizzazioni,Adesione.Id_iniziativa from Adesione group by Adesione.Id_iniziativa);

--Seleziona l'intervento col maggior numero di organizzazioni
select * from N_Organizzazioni_per_Intervento where numero_organizzazioni = (select max(numero_organizzazioni) from N_Organizzazioni_per_Intervento);