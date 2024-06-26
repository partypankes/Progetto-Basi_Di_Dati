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

drop view if exists Numero_Iniziative_per_Bacino;
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


create table Posizione
(
    latitudine      numeric,
    longitudine     numeric,
    area_geografica varchar(50) not null,
    altitudine      numeric     not null,
    primary key (latitudine, longitudine)
);


create table Bacino_Idrografico
(
    Id_bacino    smallint,
    volume_acqua int         not null,
    nome         varchar(25) not null,
    latitudine   numeric,
    longitudine  numeric,
    primary key (Id_bacino, latitudine, longitudine),
    constraint pk_posizione foreign key (latitudine, longitudine) references Posizione (latitudine, longitudine)
);


create table Specie
(
    nome_scientifico    varchar(30) primary key,
    nome_comune         varchar(20) not null,
    stato_conservazione varchar(30) not null,
    habitat             varchar(20),
    dieta               varchar(20),
    tipo_crescita       varchar(20),
    tipo_vegetazione    varchar(20),
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


create table Esistenza
(
    Id_bacino              smallint,
    latitudine             numeric,
    longitudine            numeric,
    nome_scientifico       varchar(30),
    percentuale_abbondanza int check (percentuale_abbondanza <= 100 and percentuale_abbondanza >= 0),
    primary key (Id_bacino, latitudine, longitudine, nome_scientifico),
    constraint pk_bacino_idrografico foreign key (Id_bacino, longitudine, latitudine) references Bacino_Idrografico (Id_bacino, longitudine, latitudine),
    constraint pk_specie foreign key (nome_scientifico) references Specie (nome_scientifico)
);

create table Stazione_Monitoraggio
(
    Id_Stazione       smallint primary key,
    Stato_attivazione boolean     not null,
    nome              varchar(20) not null
);

create table Sensore
(
    Id_Sensore         smallint,
    Id_Stazione        smallint,
    tipo               varchar(30) not null,
    precisione         int check (precisione <= 100 and precisione >= 0),
    N_dati             int         not null,
    data_installazione date        not null,
    primary key (Id_Sensore, Id_Stazione),
    constraint pk_stazione_monitoraggio foreign key (Id_Stazione) references Stazione_Monitoraggio (Id_Stazione)
);

create table Dato_Ambientale
(
    Id_Dato     smallint,
    Id_Sensore  smallint,
    Id_Stazione smallint,
    tipo        varchar(20) not null,
    valore      int         not null,
    valenza     boolean,
    primary key (Id_Dato, Id_Sensore, Id_Stazione),
    constraint pk_sensore foreign key (Id_Sensore, Id_Stazione) references Sensore (Id_Sensore, Id_Stazione)
);

create table Monitoraggio
(
    Id_Monitoraggio   smallint,
    Id_bacino         smallint,
    longitudine       numeric,
    latitudine        numeric,
    Id_Stazione       smallint,
    tipo_monitoraggio varchar(30) not null,
    data_inizio       date        not null,
    primary key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
    constraint pk_bacino_idrografico foreign key (Id_bacino, longitudine, latitudine) references Bacino_Idrografico (Id_bacino, longitudine, latitudine),
    constraint pk_stazione_monitoraggio foreign key (Id_Stazione) references Stazione_Monitoraggio (Id_Stazione)
);

create table Monitoraggio_Presente
(
    Id_Monitoraggio smallint,
    Id_bacino       smallint,
    longitudine     numeric,
    latitudine      numeric,
    Id_Stazione     smallint,
    progresso       int check (progresso <= 100 and progresso >= 0),
    primary key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
    constraint pk_monitoraggio foreign key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione) references Monitoraggio (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione)
);

create table Monitoraggio_Passato
(
    Id_Monitoraggio smallint,
    Id_bacino       smallint,
    longitudine     numeric,
    latitudine      numeric,
    Id_Stazione     smallint,
    data_fine       date not null,
    primary key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione),
    constraint pk_monitoraggio foreign key (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione) references Monitoraggio (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione)
);

create table Iniziativa_Conservazione
(
    Id_iniziativa       smallint,
    Id_bacino           smallint,
    longitudine         numeric,
    latitudine          numeric,
    data_inizio         date not null,
    data_fine           date,
    Indicatore_successo int,
    check (
        (Indicatore_successo is null and data_fine is null) or (
            (Indicatore_successo <= 100 and Indicatore_successo >= 0)
                and
            data_fine is not null
            )
        ),
    primary key (Id_iniziativa, Id_bacino, longitudine, latitudine),
    constraint pk_bacino_idrografico foreign key (Id_bacino, longitudine, latitudine) references Bacino_Idrografico (Id_bacino, longitudine, latitudine)
);

create table Addetto_Conservazione
(
    CF               varchar(30) primary key,
    Id_iniziativa    smallint    not null,
    Id_bacino        smallint    not null,
    longitudine      numeric     not null,
    latitudine       numeric     not null,
    nome             varchar(20) not null,
    cognome          varchar(20) not null,
    disponibilità    boolean     not null,
    Specializzazione varchar(20) not null,
    constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione (Id_iniziativa, Id_bacino, longitudine, latitudine)
);

create table Addetto_Monitoraggio
(
    CF                        varchar(30) primary key,
    Id_monitoraggio           smallint    not null,
    Id_Stazione               smallint    not null,
    Id_bacino                 smallint    not null,
    longitudine               numeric     not null,
    latitudine                numeric     not null,
    nome                      varchar(20) not null,
    cognome                   varchar(20) not null,
    disponibilità             boolean     not null,
    Competenze_tecniche       varchar(30) not null,
    Strumentazione_utilizzata varchar(30) not null,
    constraint pk_monitoraggio foreign key (Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine) references Monitoraggio (Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine)
);

create table Strategia
(
    Nome    varchar(30),
    Tecnica varchar(30),
    primary key (Nome, Tecnica)
);

create table Organizzazione_Collaboratrice
(
    Id_organizzazione smallint primary key,
    contributo        varchar(20) not null,
    ruolo             varchar(20) not null,
    tipo              varchar(20) not null
);

create table Adesione
(
    Id_Organizzazione smallint,
    Id_iniziativa     smallint,
    Id_bacino         smallint,
    longitudine       numeric,
    latitudine        numeric,
    primary key (Id_Organizzazione, Id_iniziativa, Id_bacino, longitudine, latitudine),
    constraint pk_organizzazione_collaboratrice foreign key (Id_Organizzazione) references Organizzazione_Collaboratrice (Id_Organizzazione),
    constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione (Id_iniziativa, Id_bacino, longitudine, latitudine)
);

create table Sfrutta
(
    Nome_Strategia varchar(30),
    Tecnica        varchar(30),
    Id_iniziativa  smallint not null,
    Id_bacino      smallint not null,
    longitudine    numeric  not null,
    latitudine     numeric  not null,
    primary key (Nome_Strategia, Tecnica, Id_iniziativa, Id_bacino, longitudine, latitudine),
    constraint pk_strategia foreign key (Nome_Strategia, Tecnica) references Strategia (Nome, Tecnica),
    constraint pk_iniziativa_conservazione foreign key (Id_iniziativa, Id_bacino, longitudine, latitudine) references Iniziativa_Conservazione (Id_iniziativa, Id_bacino, longitudine, latitudine)
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


insert into Sensore (Id_Sensore, Id_Stazione, tipo, precisione, N_dati, data_installazione)
values
    (1, 1, 'Temperatura', 98, 1000, '2020-01-10'),
    (2, 1, 'PH Acqua', 95, 950, '2020-01-15'),
    (3, 2, 'Conducibilità', 90, 900, '2020-02-01'),
    (4, 2, 'Ossigeno Disciolto', 92, 920, '2020-02-05'),
    (5, 3, 'Turbidità', 87, 870, '2020-03-10'),
    (6, 3, 'Nutrienti', 93, 930, '2020-03-15'),
    (7, 4, 'Temperatura', 96, 960, '2020-04-01'),
    (8, 4, 'PH Acqua', 94, 940, '2020-04-05'),
    (9, 5, 'Conducibilità', 89, 890, '2020-05-01'),
    (10, 5, 'Ossigeno Disciolto', 91, 910, '2020-05-05'),
    (11, 6, 'Turbidità', 88, 880, '2020-06-01'),
    (12, 6, 'Nutrienti', 90, 900, '2020-06-05'),
    (13, 7, 'Temperatura', 97, 970, '2020-07-01'),
    (14, 7, 'PH Acqua', 95, 950, '2020-07-05'),
    (15, 8, 'Conducibilità', 90, 900, '2020-08-01'),
    (16, 8, 'Ossigeno Disciolto', 92, 920, '2020-08-05'),
    (17, 9, 'Turbidità', 89, 890, '2020-09-01'),
    (18, 9, 'Nutrienti', 91, 910, '2020-09-05'),
    (19, 10, 'Temperatura', 94, 940, '2020-10-01'),
    (20, 10, 'PH Acqua', 93, 930, '2020-10-05'),
    (21, 11, 'Conducibilità', 88, 880, '2020-11-01'),
    (22, 11, 'Ossigeno Disciolto', 92, 920, '2020-11-05'),
    (23, 12, 'Turbidità', 87, 870, '2020-12-01'),
    (24, 12, 'Nutrienti', 95, 950, '2020-12-05'),
    (25, 13, 'Temperatura', 96, 960, '2021-01-01'),
    (26, 13, 'PH Acqua', 94, 940, '2021-01-05'),
    (27, 14, 'Conducibilità', 91, 910, '2021-02-01'),
    (28, 14, 'Ossigeno Disciolto', 89, 890, '2021-02-05'),
    (29, 15, 'Turbidità', 93, 930, '2021-03-01'),
    (30, 15, 'Nutrienti', 96, 960, '2021-03-05');

insert into  Dato_Ambientale (Id_Dato, Id_Sensore, Id_Stazione, tipo, valore, valenza)
values
    (1, 1, 1, 'Temperatura', 15, TRUE),
    (2, 1, 1, 'Temperatura', 14, FALSE),
    (3, 2, 1, 'PH', 7, TRUE),
    (4, 3, 2, 'Conducibilità', 500, TRUE),
    (5, 4, 2, 'Ossigeno', 8, TRUE),
    (6, 5, 3, 'Turbidità', 10, TRUE),
    (7, 6, 3, 'Nutrienti', 200, TRUE),
    (8, 7, 4, 'Temperatura', 20, TRUE),
    (9, 8, 4, 'PH', 6.8, TRUE),
    (10, 9, 5, 'Conducibilità', 450, TRUE),
    (11, 10, 5, 'Ossigeno', 9, TRUE),
    (12, 11, 6, 'Turbidità', 30, TRUE),
    (13, 12, 6, 'Nutrienti', 250, TRUE),
    (14, 13, 7, 'Temperatura', 10, FALSE),
    (15, 14, 7, 'PH', 7.5, TRUE),
    (16, 15, 8, 'Conducibilità', 400, TRUE),
    (17, 16, 8, 'Ossigeno', 10, TRUE),
    (18, 17, 9, 'Turbidità', 20, TRUE),
    (19, 18, 9, 'Nutrienti', 180, TRUE),
    (20, 19, 10, 'Temperatura', 25, TRUE),
    (21, 20, 10, 'PH', 6.5, TRUE),
    (22, 21, 11, 'Conducibilità', 350, TRUE),
    (23, 22, 11, 'Ossigeno', 11, TRUE),
    (24, 23, 12, 'Turbidità', 15, TRUE),
    (25, 24, 12, 'Nutrienti', 300, FALSE),
    (26, 25, 13, 'Temperatura', 8, TRUE),
    (27, 26, 13, 'PH', 7.2, TRUE),
    (28, 27, 14, 'Conducibilità', 420, TRUE),
    (29, 28, 14, 'Ossigeno', 7, FALSE),
    (30, 29, 15, 'Turbidità', 25, TRUE),
    (31, 30, 15, 'Nutrienti', 210, TRUE),
    (32, 1, 1, 'Temperatura', 16, TRUE),
    (33, 2, 1, 'PH', 7.1, TRUE),
    (34, 3, 2, 'Conducibilità', 510, FALSE),
    (35, 4, 2, 'Ossigeno', 7.5, TRUE);

CREATE OR REPLACE FUNCTION verifica_sovrapposizione_monitoraggio()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Id_Monitoraggio IN (SELECT Id_Monitoraggio FROM Monitoraggio_Presente) AND
       NEW.Id_Monitoraggio IN (SELECT Id_Monitoraggio FROM Monitoraggio_Passato) THEN
        RAISE EXCEPTION 'Un monitoraggio non può essere presente e passato contemporaneamente';
    end if;
    return New;
end;
$$ LANGUAGE plpgsql;

-- Trigger verifica che in non ci sia un Monitoraggio sia presente che passato
CREATE TRIGGER verifica_sovrapposizione_monitoraggio_trigger
    BEFORE INSERT OR UPDATE ON Monitoraggio_Presente
    FOR EACH ROW EXECUTE FUNCTION verifica_sovrapposizione_monitoraggio();

CREATE TRIGGER verifica_sovrapposizione_monitoraggio_trigger
    BEFORE INSERT OR UPDATE ON Monitoraggio_Passato
    FOR EACH ROW EXECUTE FUNCTION verifica_sovrapposizione_monitoraggio();


insert into Monitoraggio (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione, tipo_monitoraggio, data_inizio)
values
    (1, 1, 12.0, 45.0, 1, 'Qualità acqua', '2023-01-01'),
    (2, 2, 12.5, 42.5, 2, 'Qualità acqua', '2023-01-02'),
    (3, 3, 11.0, 45.7, 3, 'Biodiversità', '2023-01-03'),
    (4, 4, 11.0, 43.7, 4, 'Biodiversità', '2023-01-04'),
    (5, 5, 8.2, 44.7, 5, 'Flora', '2023-01-05'),
    (6, 6, 10.5, 43.9, 6, 'Flora', '2023-01-06'),
    (7, 7, 11.6, 45.4, 7, 'Fauna', '2023-01-07'),
    (8, 8, 13.0, 46.3, 8, 'Fauna', '2023-01-08'),
    (9, 9, 12.4, 46.4, 9, 'Qualità aria', '2023-01-09'),
    (10, 10, 11.4, 44.4, 10, 'Qualità aria', '2023-01-10'),
    (11, 11, 9.4, 45.6, 11, 'Cambiamenti climatici', '2023-01-11'),
    (12, 12, 9.4, 46.1, 12, 'Cambiamenti climatici', '2023-01-12'),
    (13, 13, 10.1, 45.5, 13, 'Impatti umani', '2023-01-13'),
    (14, 14, 8.6, 45.7, 14, 'Impatti umani', '2023-01-14'),
    (15, 15, 14.2, 41.9, 15, 'Flora', '2023-01-15'),
    (16, 1, 12.0, 45.0, 1, 'Flora', '2023-01-16'),
    (17, 2, 12.5, 42.5, 2, 'Fauna', '2023-01-17'),
    (18, 3, 11.0, 45.7, 3, 'Fauna', '2023-01-18'),
    (19, 4, 11.0, 43.7, 4, 'Qualità acqua', '2023-01-19'),
    (20, 5, 8.2, 44.7, 5, 'Biodiversità', '2023-01-20'),
    (21, 6, 10.5, 43.9, 6, 'Biodiversità', '2023-01-21'),
    (22, 7, 11.6, 45.4, 7, 'Qualità aria', '2023-01-22'),
    (23, 8, 13.0, 46.3, 8, 'Qualità aria', '2023-01-23'),
    (24, 9, 12.4, 46.4, 9, 'Cambiamenti climatici', '2023-01-24'),
    (25, 10, 11.4, 44.4, 10, 'Cambiamenti climatici', '2023-01-25'),
    (26, 11, 9.4, 45.6, 11, 'Impatti umani', '2023-01-26'),
    (27, 12, 9.4, 46.1, 12, 'Impatti umani', '2023-01-27'),
    (28, 13, 10.1, 45.5, 13, 'Flora', '2023-01-28'),
    (29, 14, 8.6, 45.7, 14, 'Flora', '2023-01-29'),
    (30, 15, 14.2, 41.9, 15, 'Fauna', '2023-01-30'),
    (31, 1, 12.0, 45.0, 1, 'Fauna', '2023-02-01'),
    (32, 2, 12.5, 42.5, 2, 'Qualità aria', '2023-02-02'),
    (33, 3, 11.0, 45.7, 3, 'Qualità aria', '2023-02-03'),
    (34, 4, 11.0, 43.7, 4, 'Cambiamenti climatici', '2023-02-04'),
    (35, 5, 8.2, 44.7, 5, 'Cambiamenti climatici', '2023-02-05'),
    (36, 6, 10.5, 43.9, 6, 'Impatti umani', '2023-02-06'),
    (37, 7, 11.6, 45.4, 7, 'Impatti umani', '2023-02-07'),
    (38, 8, 13.0, 46.3, 8, 'Flora', '2023-02-08'),
    (39, 9, 12.4, 46.4, 9, 'Flora', '2023-02-09'),
    (40, 10, 11.4, 44.4, 10, 'Fauna', '2023-02-10'),
    (41, 11, 9.4, 45.6, 11, 'Fauna', '2025-02-11'),
    (42, 12, 9.4, 46.1, 12, 'Qualità acqua', '2025-02-12'),
    (43, 13, 10.1, 45.5, 13, 'Biodiversità', '2025-02-13'),
    (44, 14, 8.6, 45.7, 14, 'Biodiversità', '2025-02-14'),
    (45, 15, 14.2, 41.9, 15, 'Qualità acqua', '2025-02-15');

insert into Monitoraggio_Presente (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione, progresso)
values
    (1, 1, 12.0, 45.0, 1, 20),
    (3, 3, 11.0, 45.7, 3, 35),
    (5, 5, 8.2, 44.7, 5, 50),
    (7, 7, 11.6, 45.4, 7, 65),
    (9, 9, 12.4, 46.4, 9, 80),
    (11, 11, 9.4, 45.6, 11, 45),
    (13, 13, 10.1, 45.5, 13, 30),
    (15, 15, 14.2, 41.9, 15, 55),
    (17, 2, 12.5, 42.5, 2, 25),
    (19, 4, 11.0, 43.7, 4, 70),
    (21, 6, 10.5, 43.9, 6, 95),
    (23, 8, 13.0, 46.3, 8, 10),
    (25, 10, 11.4, 44.4, 10, 75),
    (27, 12, 9.4, 46.1, 12, 40),
    (29, 14, 8.6, 45.7, 14, 60),
    (31, 1, 12.0, 45.0, 1, 85),
    (33, 3, 11.0, 45.7, 3, 5),
    (35, 5, 8.2, 44.7, 5, 90),
    (37, 7, 11.6, 45.4, 7, 15),
    (39, 9, 12.4, 46.4, 9, 70);

insert into Monitoraggio_Passato (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione, data_fine)
values
    (2, 2, 12.5, 42.5, 2, '2023-05-01'),
    (4, 4, 11.0, 43.7, 4, '2023-05-02'),
    (6, 6, 10.5, 43.9, 6, '2023-05-03'),
    (8, 8, 13.0, 46.3, 8, '2023-05-04'),
    (10, 10, 11.4, 44.4, 10, '2023-05-05'),
    (12, 12, 9.4, 46.1, 12, '2023-05-06'),
    (14, 14, 8.6, 45.7, 14, '2023-05-07'),
    (16, 1, 12.0, 45.0, 1, '2023-05-08'),
    (18, 3, 11.0, 45.7, 3, '2023-05-09'),
    (20, 5, 8.2, 44.7, 5, '2023-05-10'),
    (22, 7, 11.6, 45.4, 7, '2023-05-11'),
    (24, 9, 12.4, 46.4, 9, '2023-05-12'),
    (26, 11, 9.4, 45.6, 11, '2023-05-13'),
    (28, 13, 10.1, 45.5, 13, '2023-05-14'),
    (30, 15, 14.2, 41.9, 15, '2023-05-15'),
    (32, 2, 12.5, 42.5, 2, '2023-05-16'),
    (34, 4, 11.0, 43.7, 4, '2023-05-17'),
    (36, 6, 10.5, 43.9, 6, '2023-05-18'),
    (38, 8, 13.0, 46.3, 8, '2023-05-19'),
    (40, 10, 11.4, 44.4, 10, '2023-05-20');


insert into Iniziativa_Conservazione (Id_iniziativa, Id_bacino, longitudine, latitudine, data_inizio, data_fine, Indicatore_successo)
values
    (1, 1, 12.0, 45.0, '2024-01-01', '2024-02-01', 80),
    (2, 2, 12.5, 42.5, '2024-01-02', '2024-02-02', 70),
    (3, 2, 12.5, 42.5, '2024-01-03', '2024-02-03', 90),
    (4, 3, 11.0, 45.7, '2024-01-04', '2024-02-04', 85),
    (5, 4, 11.0, 43.7, '2024-01-05', '2024-02-05', 75),
    (6, 5, 8.2, 44.7, '2024-01-06', '2024-02-06', 60),
    (7, 6, 10.5, 43.9, '2024-01-07', '2024-02-07', 88),
    (8, 7, 11.6, 45.4, '2024-01-08', '2024-02-08', 65),
    (9, 7, 11.6, 45.4, '2024-01-09', '2024-02-09', 72),
    (10, 10, 11.4, 44.4, '2024-01-10', '2024-02-10', 80),
    (11, 8, 13.0, 46.3, '2024-01-11', '2024-02-11', 90),
    (12, 1, 12.0, 45.0, '2024-01-12', '2024-02-12', 70),
    (13, 1, 12.0, 45.0, '2024-01-13', '2024-02-13', 85),
    (14, 3, 11.0, 45.7, '2024-01-14', '2024-02-14', 80),
    (15, 6, 10.5, 43.9, '2024-01-15', '2024-02-15', 78),
    (16, 9, 12.4, 46.4, '2024-01-16', '2024-02-16', 62),
    (17, 9, 12.4, 46.4, '2024-01-17', '2024-02-17', 90),
    (18, 1, 12.0, 45.0, '2024-01-18', '2024-02-18', 64),
    (19, 5, 8.2, 44.7, '2024-01-19', '2024-02-19', 70),
    (20, 10, 11.4, 44.4, '2024-01-20', '2024-02-20', 85),
    (21, 1, 12.0, 45.0, '2024-01-21', '2024-02-21', 92),
    (22, 6, 10.5, 43.9, '2024-01-22', '2024-02-22', 66),
    (23, 3, 11.0, 45.7, '2024-01-23', '2024-02-23', 83),
    (24, 8, 13.0, 46.3, '2024-01-24', '2024-02-24', 88),
    (25, 5, 8.2, 44.7, '2024-01-25', '2024-02-25', 79),
    (26, 6, 10.5, 43.9, '2024-01-26', '2024-02-26', 70),
    (27, 9, 12.4, 46.4, '2024-01-27', '2024-02-27', 90),
    (28, 8, 13.0, 46.3, '2024-01-28', '2024-02-28', 60),
    (29, 2, 12.5, 42.5, '2024-01-29', '2024-02-29', 80),
    (30, 10, 11.4, 44.4, '2024-01-30', '2024-02-28', 85),
    (31, 1, 12.0, 45.0, '2024-02-01', NULL, NULL),
    (32, 2, 12.5, 42.5, '2024-02-02', NULL, NULL),
    (33, 3, 11.0, 45.7, '2024-02-03', NULL, NULL),
    (34, 4, 11.0, 43.7, '2024-02-04', NULL, NULL),
    (35, 5, 8.2, 44.7, '2024-02-05', NULL, NULL),
    (36, 6, 10.5, 43.9, '2024-02-06', NULL, NULL),
    (37, 7, 11.6, 45.4, '2024-02-07', NULL, NULL),
    (38, 8, 13.0, 46.3, '2024-02-08', NULL, NULL),
    (39, 9, 12.4, 46.4, '2024-02-09', NULL, NULL),
    (40, 10, 11.4, 44.4, '2024-02-10', NULL, NULL);


-- Funzione che controlla validità CF
CREATE OR REPLACE FUNCTION verifica_codice_fiscale()
    RETURNS TRIGGER AS $$
BEGIN
    -- Verifica che il CF abbia esattamente 16 caratteri
    IF LENGTH(NEW.CF) != 16 THEN
        RAISE EXCEPTION 'Il codice fiscale deve contenere 16 caratteri.';
    END IF;

    -- Verifica il formato del CF
    IF NEW.CF !~ '^[A-Z0-9]{16}$' THEN
        RAISE EXCEPTION 'Il codice fiscale contiene caratteri non validi.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger per la tabella Addetto_Conservazione
CREATE TRIGGER verifica_cf_addetto_conservazione
    BEFORE INSERT OR UPDATE ON Addetto_Conservazione
    FOR EACH ROW EXECUTE FUNCTION verifica_codice_fiscale();

-- Trigger per la tabella Addetto_Monitoraggio
CREATE TRIGGER verifica_cf_addetto_monitoraggio
    BEFORE INSERT OR UPDATE ON Addetto_Monitoraggio
    FOR EACH ROW EXECUTE FUNCTION verifica_codice_fiscale();

-- Funzione unicità CF tra addetti
CREATE OR REPLACE FUNCTION unicità_cf()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 from Addetto_Conservazione WHERE CF = New.CF
        UNION ALL
        SELECT 1 from Addetto_Monitoraggio WHERE CF = New.CF
        ) THEN
        RAISE EXCEPTION 'Il codice fiscale deve essere unico tra gli addetti.';
    end if;
    return New;
end;
$$ LANGUAGE plpgsql;

-- Trigger verifica che in Addetto_Conservazione e Addetto_Monitoraggio non ci siano CF uguali
CREATE TRIGGER unicità_cf_trigger
    BEFORE INSERT OR UPDATE ON Addetto_Conservazione
    FOR EACH ROW EXECUTE FUNCTION unicità_cf();

CREATE TRIGGER unicità_cf_trigger
    BEFORE INSERT OR UPDATE ON Addetto_Monitoraggio
    FOR EACH ROW EXECUTE FUNCTION unicità_cf();


insert into Addetto_Conservazione (CF, Id_iniziativa, Id_bacino, longitudine, latitudine, nome, cognome, disponibilità, Specializzazione)
values
    ('RSSMRA85M01H501T', 1, 1, 12.0, 45.0, 'Mario', 'Rossi', TRUE, 'Botanica'),
    ('BNCLGU82D15F205Z', 2, 2, 12.5, 42.5, 'Luigi', 'Bianchi', TRUE, 'Ittiologia'),
    ('VRDGNN87P08Z602P', 3, 2, 12.5, 42.5, 'Giovanni', 'Verdi', FALSE, 'Ornitologia'),
    ('NRAPLA76S41G912V', 4, 3, 11.0, 45.7, 'Paola', 'Neri', TRUE, 'Entomologia'),
    ('GLLANA84E55E514R', 5, 4, 11.0, 43.7, 'Anna', 'Gialli', TRUE, 'Micologia'),
    ('MRNSRA81A64L219D', 6, 5, 8.2, 44.7, 'Sara', 'Marrone', FALSE, 'Ecologia'),
    ('DNLNDE89T10A783K', 7, 6, 10.5, 43.9, 'Daniele', 'Viola', TRUE, 'Zoologia'),
    ('GRSELZ83R58D969M', 8, 7, 11.6, 45.4, 'Elisa', 'Grigio', TRUE, 'Botanica'),
    ('BLUFRC91M27Z404S', 9, 7, 11.6, 45.4, 'Federico', 'Blu', FALSE, 'Ittiologia'),
    ('RNCCRA89M65B405V', 10, 10, 11.4, 44.4, 'Chiara', 'Arancio', TRUE, 'Ornitologia'),
    ('VRDALX88P01F839J', 11, 8, 13.0, 46.3, 'Alessandro', 'Verde', TRUE, 'Zoologia'),
    ('FCSBTR90L28D612P', 12, 1, 12.0, 45.0, 'Beatrice', 'Fucsia', FALSE, 'Ecologia'),
    ('SNCCLR88E21Z100X', 13, 1, 12.0, 45.0, 'Carlo', 'Senape', TRUE, 'Entomologia'),
    ('DRLDRA84C41H501Q', 14, 3, 11.0, 45.7, 'Doriana', 'Ocra', TRUE, 'Botanica'),
    ('CYNERN85M08F205Z', 15, 6, 10.5, 43.9, 'Ernesto', 'Ciano', TRUE, 'Micologia');


insert into Addetto_Monitoraggio (CF, Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine, nome, cognome, disponibilità, Competenze_tecniche, Strumentazione_utilizzata)
values
    ('GLLANT86H13D969L', 1, 1, 1, 12.0, 45.0, 'Antonio', 'Gialli', TRUE, 'Biologia Acquatica', 'pHmetro'),
    ('VRDBEA87D45E203Y', 2, 2, 2, 12.5, 42.5, 'Beatrice', 'Verde', FALSE, 'Biologia Marittima', 'Sonar'),
    ('BLUCRL89P12F205W', 3, 3, 3, 11.0, 45.7, 'Carlo', 'Blu', TRUE, 'Qualità dell acqua', 'Turbidimetro'),
    ('MRNDNL90M14L219U', 4, 4, 4, 11.0, 43.7, 'Daniela', 'Marrone', FALSE, 'Ecologia Fluviale', 'Oxygen Kit'),
    ('RSSLEN85S54H501J', 5, 5, 5, 8.2, 44.7, 'Elena', 'Rossa', TRUE, 'Geologia', 'Sismografo'),
    ('NRIFBO84M11G912C', 6, 6, 6, 10.5, 43.9, 'Fabio', 'Neri', FALSE, 'Meteorologia', 'Anemometro'),
    ('BNCGLI89T50F205X', 7, 7, 7, 11.6, 45.4, 'Giulia', 'Bianchi', TRUE, 'Botanica', 'GPS'),
    ('SRTHEC88M20Z600R', 8, 8, 8, 13.0, 46.3, 'Hector', 'Sarto', FALSE, 'Chimica Ambientale', 'Spectrometer'),
    ('FCSIRN92E54D612F', 9, 9, 9, 12.4, 46.4, 'Irene', 'Fucsia', TRUE, 'Controllo Emissioni', 'Particulate Monitor'),
    ('OCRLGI81A61B405H', 10, 10, 10, 11.4, 44.4, 'Luigi', 'Ocra', FALSE, 'Monitoraggio Fauna', 'Camera Trap'),
    ('VRDMNC88D48F839B', 11, 11, 11, 9.4, 45.6, 'Monica', 'Verde', TRUE, 'Climatologia', 'Barometro'),
    ('CNONDH86P08Z203T', 12, 12, 12, 9.4, 46.1, 'Nadia', 'Ciano', FALSE, 'Idrologia', 'Flow Meter'),
    ('VLACOS87M29A783G', 13, 13, 13, 10.1, 45.5, 'Oscar', 'Viola', TRUE, 'Ricerca della Biodiversità', 'Microscopio'),
    ('LILPLA90L52G912K', 14, 14, 14, 8.6, 45.7, 'Paola', 'Lilla', FALSE, 'Studi Ambientali', 'Drone'),
    ('AZZQTN91E13E514V', 15, 15, 15, 14.2, 41.9, 'Quentin', 'Azzurro', TRUE, 'Analisi dell aria', 'Gas Chromatograph');

insert into Organizzazione_Collaboratrice (Id_organizzazione, contributo, ruolo, tipo)
values
    (1, 'Finanziario', 'Supporto', 'Non-profit'),
    (2, 'Tecnico', 'Principale', 'Governativa'),
    (3, 'Logistico', 'Collaborativo', 'Privata'),
    (4, 'Consultativo', 'Consultivo', 'Internazionale'),
    (5, 'Educativo', 'Supporto', 'Accademica'),
    (6, 'Scientifico', 'Principale', 'Non-profit'),
    (7, 'Materiale', 'Collaborativo', 'Privata'),
    (8, 'Finanziario', 'Supporto', 'Internazionale'),
    (9, 'Tecnico', 'Consultivo', 'Governativa'),
    (10, 'Logistico', 'Principale', 'Non-profit'),
    (11, 'Consultativo', 'Collaborativo', 'Accademica'),
    (12, 'Educativo', 'Supporto', 'Privata'),
    (13, 'Scientifico', 'Principale', 'Internazionale'),
    (14, 'Materiale', 'Collaborativo', 'Governativa'),
    (15, 'Finanziario', 'Consultivo', 'Accademica'),
    (16, 'Tecnico', 'Supporto', 'Non-profit'),
    (17, 'Logistico', 'Principale', 'Privata'),
    (18, 'Consultativo', 'Collaborativo', 'Internazionale'),
    (19, 'Educativo', 'Supporto', 'Governativa'),
    (20, 'Scientifico', 'Principale', 'Accademica');


insert into Adesione (Id_Organizzazione, Id_iniziativa, Id_bacino, longitudine, latitudine)
values
    (1, 1, 1, 12.0, 45.0),
    (2, 1, 1, 12.0, 45.0),
    (3, 1, 1, 12.0, 45.0),
    (4, 1, 1, 12.0, 45.0),

    (1, 2, 2, 12.5, 42.5),
    (2, 2, 2, 12.5, 42.5),
    (3, 2, 2, 12.5, 42.5),
    (4, 2, 2, 12.5, 42.5),

    (1, 3, 2, 12.5, 42.5),
    (2, 3, 2, 12.5, 42.5),
    (3, 3, 2, 12.5, 42.5),
    (4, 3, 2, 12.5, 42.5),

    (1, 4, 3, 11.0, 45.7),
    (2, 4, 3, 11.0, 45.7),
    (3, 4, 3, 11.0, 45.7),
    (4, 4, 3, 11.0, 45.7),

    (1, 5, 4, 11.0, 43.7),
    (2, 5, 4, 11.0, 43.7),
    (3, 5, 4, 11.0, 43.7),
    (4, 5, 4, 11.0, 43.7),

    (1, 6, 5, 8.2, 44.7),
    (2, 6, 5, 8.2, 44.7),
    (3, 6, 5, 8.2, 44.7),
    (4, 6, 5, 8.2, 44.7),

    (1, 7, 6, 10.5, 43.9),
    (2, 7, 6, 10.5, 43.9),
    (3, 7, 6, 10.5, 43.9),
    (4, 7, 6, 10.5, 43.9),

    (1, 8, 7, 11.6, 45.4),
    (2, 8, 7, 11.6, 45.4),
    (3, 8, 7, 11.6, 45.4),
    (4, 8, 7, 11.6, 45.4),

    (1, 9, 7, 11.6, 45.4),
    (2, 9, 7, 11.6, 45.4),
    (3, 9, 7, 11.6, 45.4),
    (4, 9, 7, 11.6, 45.4),

    (1, 10, 10, 11.4, 44.4),
    (2, 10, 10, 11.4, 44.4),
    (3, 10, 10, 11.4, 44.4),
    (4, 10, 10, 11.4, 44.4),

    (1, 11, 8, 13.0, 46.3),
    (2, 11, 8, 13.0, 46.3),
    (3, 11, 8, 13.0, 46.3),
    (4, 11, 8, 13.0, 46.3),

    (1, 12, 1, 12.0, 45.0),
    (2, 12, 1, 12.0, 45.0),
    (3, 12, 1, 12.0, 45.0),
    (4, 12, 1, 12.0, 45.0),
    
    (1, 13, 1, 12.0, 45.0),
    (2, 13, 1, 12.0, 45.0);

insert into Strategia (Nome, Tecnica)
values
    ('Conservazione diretta', 'Ripristino habitat'),
    ('Conservazione diretta', 'Corridoi ecologici'),
    ('Conservazione diretta', 'Esclusioni predatorie'),
    ('Conservazione diretta', 'Reintroduzione specie'),
    ('Conservazione diretta', 'Banca geni'),
    ('Conservazione indiretta', 'Educazione ambientale'),
    ('Conservazione indiretta', 'Turismo ecologico'),
    ('Conservazione indiretta', 'Sovvenzioni'),
    ('Conservazione indiretta', 'Regolamenti di caccia'),
    ('Conservazione indiretta', 'Monitoraggio biodiversità'), --10
    ('Conservazione integrata', 'Gestione integrata risorse'),
    ('Conservazione integrata', 'Piani uso terra'),
    ('Conservazione integrata', 'Agroecologia'),
    ('Conservazione integrata', 'Acquacoltura sostenibile'),
    ('Conservazione integrata', 'Energia rinnovabile'),
    ('Ricerca e sviluppo', 'Tecnologie innovative'),
    ('Ricerca e sviluppo', 'Bioingegneria'),
    ('Ricerca e sviluppo', 'Bioremediation'),
    ('Ricerca e sviluppo', 'Satelliti e droni'),
    ('Ricerca e sviluppo', 'Modeling ecologico'), --20
    ('Gestione risorse', 'Acque sotterranee'),
    ('Gestione risorse', 'Risorse forestali'),
    ('Gestione risorse', 'Pesca sostenibile'),
    ('Gestione risorse', 'Risorse minerarie'),
    ('Gestione risorse', 'Risorse eoliche'),
    ('Sostenibilità', 'Cicli di materiali'),
    ('Sostenibilità', 'Efficienza energetica'),
    ('Sostenibilità', 'Riduzione emissioni'),
    ('Sostenibilità', 'Riciclo rifiuti'),
    ('Sostenibilità', 'Prodotti biodegradabili'), --30
    ('Adattamento climatico', 'Barriere contro maree'),
    ('Adattamento climatico', 'Foreste urbane'),
    ('Adattamento climatico', 'Agricoltura resistente'),
    ('Adattamento climatico', 'Sistemi di allarme'),
    ('Adattamento climatico', 'Infrastrutture resilienti'),
    ('Salvaguardia ambientale', 'Zone protette'),
    ('Salvaguardia ambientale', 'Legislazione ambientale'),
    ('Salvaguardia ambientale', 'Sicurezza alimentare'),
    ('Salvaguardia ambientale', 'Controllo inquinamento'),
    ('Salvaguardia ambientale', 'Gestione rifiuti'), --40
    ('Ripristino ambientale', 'Bonifica siti'),
    ('Ripristino ambientale', 'Riforestazione'),
    ('Ripristino ambientale', 'Rigenerazione naturale'),
    ('Ripristino ambientale', 'Ricostruzione ecosistemi'),
    ('Ripristino ambientale', 'Gestione specie invasive'); --45

insert into Sfrutta (Nome_Strategia, Tecnica, Id_iniziativa, Id_bacino, longitudine, latitudine)
values 
    ('Conservazione diretta', 'Ripristino habitat', 1, 1, 12.0, 45.0),
    ('Conservazione diretta', 'Corridoi ecologici', 1, 1, 12.0, 45.0),
    ('Conservazione diretta', 'Esclusioni predatorie', 2, 2, 12.5, 42.5),
    ('Conservazione diretta', 'Reintroduzione specie', 2, 2, 12.5, 42.5),
    ('Conservazione diretta', 'Banca geni', 3, 2, 12.5, 42.5),
    ('Conservazione indiretta', 'Educazione ambientale', 3, 2, 12.5, 42.5),
    ('Conservazione indiretta', 'Turismo ecologico', 4, 3, 11.0, 45.7),
    ('Conservazione indiretta', 'Sovvenzioni', 4, 3, 11.0, 45.7),
    ('Conservazione indiretta', 'Regolamenti di caccia', 5, 4, 11.0, 43.7),
    ('Conservazione indiretta', 'Monitoraggio biodiversità', 5, 4, 11.0, 43.7),
    ('Conservazione integrata', 'Gestione integrata risorse', 6, 5, 8.2, 44.7),
    ('Conservazione integrata', 'Piani uso terra', 6, 5, 8.2, 44.7),
    ('Conservazione integrata', 'Agroecologia', 7, 6, 10.5, 43.9),
    ('Conservazione integrata', 'Acquacoltura sostenibile', 7, 6, 10.5, 43.9),
    ('Conservazione integrata', 'Energia rinnovabile', 8, 7, 11.6, 45.4),
    ('Ricerca e sviluppo', 'Tecnologie innovative', 8, 7, 11.6, 45.4),
    ('Ricerca e sviluppo', 'Bioingegneria', 9, 7, 11.6, 45.4),
    ('Ricerca e sviluppo', 'Bioremediation', 9, 7, 11.6, 45.4),
    ('Ricerca e sviluppo', 'Satelliti e droni', 10, 10, 11.4, 44.4),
    ('Ricerca e sviluppo', 'Modeling ecologico', 10, 10, 11.4, 44.4),
    ('Gestione risorse', 'Acque sotterranee', 11, 8, 13.0, 46.3),
    ('Gestione risorse', 'Risorse forestali', 11, 8, 13.0, 46.3),
    ('Gestione risorse', 'Pesca sostenibile', 12, 1, 12.0, 45.0),
    ('Gestione risorse', 'Risorse minerarie', 12, 1, 12.0, 45.0),
    ('Gestione risorse', 'Risorse eoliche', 13, 1, 12.0, 45.0),
    ('Sostenibilità', 'Cicli di materiali', 13, 1, 12.0, 45.0),
    ('Sostenibilità', 'Efficienza energetica', 14, 3, 11.0, 45.7),
    ('Sostenibilità', 'Riduzione emissioni', 14, 3, 11.0, 45.7),
    ('Sostenibilità', 'Riciclo rifiuti', 15, 6, 10.5, 43.9),
    ('Sostenibilità', 'Prodotti biodegradabili', 15, 6, 10.5, 43.9),
    ('Adattamento climatico', 'Barriere contro maree', 16, 9, 12.4, 46.4),
    ('Adattamento climatico', 'Foreste urbane', 16, 9, 12.4, 46.4),
    ('Adattamento climatico', 'Agricoltura resistente', 17, 9, 12.4, 46.4),
    ('Adattamento climatico', 'Sistemi di allarme', 17, 9, 12.4, 46.4),
    ('Adattamento climatico', 'Infrastrutture resilienti', 18, 1, 12.0, 45.0),
    ('Salvaguardia ambientale', 'Zone protette', 18, 1, 12.0, 45.0),
    ('Salvaguardia ambientale', 'Legislazione ambientale', 19, 5, 8.2, 44.7),
    ('Salvaguardia ambientale', 'Sicurezza alimentare', 19, 5, 8.2, 44.7),
    ('Salvaguardia ambientale', 'Controllo inquinamento', 20, 10, 11.4, 44.4),
    ('Salvaguardia ambientale', 'Gestione rifiuti', 20, 10, 11.4, 44.4),
    ('Ripristino ambientale', 'Bonifica siti', 21, 1, 12.0, 45.0),
    ('Ripristino ambientale', 'Riforestazione', 21, 1, 12.0, 45.0),
    ('Ripristino ambientale', 'Rigenerazione naturale', 22, 6, 10.5, 43.9),
    ('Ripristino ambientale', 'Ricostruzione ecosistemi', 22, 6, 10.5, 43.9),
    ('Ripristino ambientale', 'Gestione specie invasive', 23, 3, 11.0, 45.7),
    ('Conservazione diretta', 'Ripristino habitat', 23, 3, 11.0, 45.7),
    ('Conservazione diretta', 'Corridoi ecologici', 24, 8, 13.0, 46.3),
    ('Conservazione diretta', 'Esclusioni predatorie', 24, 8, 13.0, 46.3),
    ('Conservazione diretta', 'Reintroduzione specie', 25, 5, 8.2, 44.7),
    ('Conservazione diretta', 'Banca geni', 25, 5, 8.2, 44.7);




--Permette di contare il numero di presenze di una specie nei Bacini Idrografici
select s.nome_scientifico,count(BI.nome) as numero_di_presenze
from Specie s
join Esistenza E on s.nome_scientifico = E.nome_scientifico
join Bacino_Idrografico BI on BI.Id_bacino = E.Id_bacino and BI.longitudine = E.longitudine and BI.latitudine = E.latitudine
group by s.nome_scientifico;

--Restituiscie il numero di Bacini Idrografici con volume d'acqua > 10000 e senza interventi passati
select count(bi.nome) as grandi_bacini_senza_interventi_passati
from Bacino_Idrografico bi
where bi.volume_acqua > 10000 and exists (
    select 1
    from Bacino_Idrografico b
    join Iniziativa_Conservazione ic on b.Id_bacino = ic.Id_bacino
        and b.longitudine = ic.longitudine
        and b.latitudine = ic.latitudine
    where ic.data_fine is null
      and bi.Id_bacino = b.Id_bacino
);


--Unisce i nomi e il CF degli Addetti al Monitoraggio e degli Addetti alla Conservazione disponibili
select am.CF,am.nome
from Addetto_Monitoraggio am
where am.disponibilità = true
union
select ac.CF,ac.nome
from Addetto_Conservazione ac
where ac.disponibilità = true;

--Trova il numero di Iniziative di Conservazione per Bacino Idrografico
create view Numero_Iniziative_per_Bacino as (select count(Id_iniziativa) as numero_iniziative,Iniziativa_Conservazione.Id_bacino
from Iniziativa_Conservazione
group by  Iniziativa_Conservazione.Id_bacino
order by Iniziativa_Conservazione.Id_bacino
);

--Seleziona il Bacino Idrografico col maggior numero di Iniziative di Conservazione
select * from Numero_Iniziative_per_Bacino
where numero_iniziative = (
select max(numero_iniziative)
from Numero_Iniziative_per_Bacino
);



