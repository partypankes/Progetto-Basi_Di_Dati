/*create database gruppo23_hidric
    with
    owner = postgres
    encoding = 'UTF8'
    lc_collate = 'Italian_Italy.1252'
    lc_ctype = 'Italian_Italy.1252'
    locale_provider = 'libc'
    tablespace = pg_default
    connection limit = -1
    is_template = False;




create schema hidric;
set schema 'hidric';
*/

drop table if exists Addetto_Monitoraggio;
drop table if exists Addetto_Conservazione;
drop table if exists Iniziativa_Conservazione;
drop table if exists Monitoraggio;
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


insert into Posizione (latitudine, longitudine, area_geografica, altitudine)
values
    (45.0, 12.0, 'Pianura', 45),           -- Bacino del Po
    (42.5, 12.5, 'Collina', 100),          -- Bacino del Tevere
    (45.7, 11.0, 'Montagna', 250),         -- Bacino del fiume Adige
    (43.7, 11.0, 'Montagna', 100);        -- Bacino del fiume Arno


insert into Bacino_Idrografico(Id_bacino, volume_acqua, nome, latitudine, longitudine)
values
    (1, 150000, 'Bacino del fiume Po', 45.0, 12.0),
    (2, 50000, 'Bacino del fiume Tevere', 42.5, 12.5),
    (3, 80000, 'Bacino del fiume Adige', 45.7, 11.0),
    (4, 60000, 'Bacino del fiume Arno', 43.7, 11.0);

--Flora
insert into Specie(nome_scientifico, nome_comune, stato_conservazione, habitat, dieta, tipo_crescita, tipo_vegetazione)
values
    ('Fagus sylvatica', 'Faggio', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Pinus nigra', 'Pino Nero', 'Basso rischio', NULL, NULL, 'Albero', 'Conifera'),
    ('Quercus robur', 'Quercia', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia'),
    ('Rosa canina', 'Rosa Canina', 'Rischio minimo', NULL, NULL, 'Arbusto', 'Rosaceae'),
    ('Abies alba', 'Abete Bianco', 'Rischio minimo', NULL, NULL, 'Albero', 'Conifera'),
    ('Picea abies', 'Abete Rosso', 'Rischio minimo', NULL, NULL, 'Albero', 'Conifera'),
    ('Acer campestre', 'Acero Campestre', 'Rischio minimo', NULL, NULL, 'Albero', 'Latifoglia');

--Fauna
insert into Specie (nome_scientifico, nome_comune, stato_conservazione, habitat, dieta, tipo_crescita, tipo_vegetazione)
values
    ('Salmo salar', 'Salmone Atlantico', 'Basso rischio', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Oncorhynchus mykiss', 'Trota Arcobaleno', 'Vulnerabile', 'Fiume', 'Onnivoro', NULL, NULL),
    ('Esox lucius', 'Luccio', 'Rischio minimo', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Anguilla anguilla', 'Anguilla Europea', 'Critico', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Perca fluviatilis', 'Persico Reale', 'Rischio minimo', 'Lago', 'Carnivoro', NULL, NULL),
    ('Silurus glanis', 'Siluro', 'Rischio minimo', 'Fiume', 'Carnivoro', NULL, NULL),
    ('Coregonus albula', 'Coregone Bianco', 'Rischio minimo', 'Lago', 'Carnivoro', NULL, NULL);


insert into Esistenza (Id_bacino, latitudine, longitudine, nome_scientifico, percentuale_abbondanza)
values
    (1, 45.0, 12.0, 'Salmo salar', 10),
    (1, 45.0, 12.0, 'Oncorhynchus mykiss', 15),
    (1, 45.0, 12.0, 'Esox lucius', 20),
    (1, 45.0, 12.0, 'Anguilla anguilla', 5),
    (1, 45.0, 12.0, 'Perca fluviatilis', 8),
    (1, 45.0, 12.0, 'Silurus glanis', 5),
    (1, 45.0, 12.0, 'Abies alba', 5),
    (1, 45.0, 12.0, 'Coregonus albula', 5),
    (2, 42.5, 12.5, 'Silurus glanis', 12),
    (2, 42.5, 12.5, 'Coregonus albula', 7),
    (4, 43.7, 11.0, 'Fagus sylvatica', 30),
    (4, 43.7, 11.0, 'Pinus nigra', 20),
    (4, 43.7, 11.0, 'Quercus robur', 15),
    (4, 43.7, 11.0, 'Rosa canina', 10),
    (3, 45.7, 11.0, 'Picea abies', 8),
    (3, 45.7, 11.0, 'Quercus robur', 15),
    (2, 42.5, 12.5, 'Perca fluviatilis', 10),
    (4, 43.7, 11.0, 'Salmo salar', 6),
    (4, 43.7, 11.0, 'Acer campestre', 25);

insert into Stazione_Monitoraggio (Id_Stazione, Stato_attivazione, nome)
values
    (1, TRUE, 'Stazione 1'),
    (2, FALSE, 'Stazione 2'),
    (3, TRUE, 'Stazione 3'),
    (4, FALSE, 'Stazione 4');

insert into Monitoraggio (Id_Monitoraggio, Id_bacino, longitudine, latitudine, Id_Stazione, tipo_monitoraggio, data_inizio)
values
    (1, 1, 12.0, 45.0, 1, 'Qualità acqua', '2023-01-01'),
    (2, 2, 12.5, 42.5, 2, 'Qualità acqua', '2023-01-02'),
    (3, 3, 11.0, 45.7, 3, 'Biodiversità', '2023-01-03'),
    (4, 4, 11.0, 43.7, 4, 'Biodiversità', '2023-01-04');

insert into Iniziativa_Conservazione (Id_iniziativa, Id_bacino, longitudine, latitudine, data_inizio, data_fine, Indicatore_successo)
values
    (1, 1, 12.0, 45.0, '2024-01-01', '2024-02-01', 80),
    (2, 2, 12.5, 42.5, '2024-01-02', '2024-02-02', 70),
    (3, 2, 12.5, 42.5, '2024-01-03', '2024-02-03', 90),
    (4, 3, 11.0, 45.7, '2024-01-04', '2024-02-04', 85),
    (5, 4, 11.0, 43.7, '2024-01-05', '2024-02-05', 75),
    (6, 1, 12.0, 45.0, '2024-01-12', '2024-02-12', 70),
    (7, 1, 12.0, 45.0, '2024-01-13', '2024-02-13', 85),
    (8, 3, 11.0, 45.7, '2024-01-14', '2024-02-14', 80),
    (9, 1, 12.0, 45.0, '2024-01-18', '2024-02-18', 64),
    (10, 2, 12.5, 42.5, '2024-01-29', '2024-02-29', 80),
    (11, 1, 12.0, 45.0, '2024-02-01', NULL, NULL),
    (12, 2, 12.5, 42.5, '2024-02-02', NULL, NULL),
    (13, 3, 11.0, 45.7, '2024-02-03', NULL, NULL),
    (14, 4, 11.0, 43.7, '2024-02-04', NULL, NULL);

insert into Addetto_Conservazione (CF, Id_iniziativa, Id_bacino, longitudine, latitudine, nome, cognome, disponibilità, Specializzazione)
values
    ('RSSMRA85M01H501T', 1, 1, 12.0, 45.0, 'Mario', 'Rossi', TRUE, 'Botanica'),
    ('BNCLGU82D15F205Z', 2, 2, 12.5, 42.5, 'Luigi', 'Bianchi', TRUE, 'Ittiologia'),
    ('VRDGNN87P08Z602P', 3, 2, 12.5, 42.5, 'Giovanni', 'Verdi', FALSE, 'Ornitologia'),
    ('NRAPLA76S41G912V', 4, 3, 11.0, 45.7, 'Paola', 'Neri', TRUE, 'Entomologia'),
    ('GLLANA84E55E514R', 5, 4, 11.0, 43.7, 'Anna', 'Gialli', TRUE, 'Micologia');


insert into Addetto_Monitoraggio (CF, Id_monitoraggio, Id_Stazione, Id_bacino, longitudine, latitudine, nome, cognome, disponibilità, Competenze_tecniche, Strumentazione_utilizzata)
values
    ('GLLANT86H13D969L', 1, 1, 1, 12.0, 45.0, 'Antonio', 'Gialli', TRUE, 'Biologia Acquatica', 'pHmetro'),
    ('VRDBEA87D45E203Y', 2, 2, 2, 12.5, 42.5, 'Beatrice', 'Verde', FALSE, 'Biologia Marittima', 'Sonar'),
    ('BLUCRL89P12F205W', 3, 3, 3, 11.0, 45.7, 'Carlo', 'Blu', TRUE, 'Qualità dell acqua', 'Turbidimetro'),
    ('MRNDNL90M14L219U', 4, 4, 4, 11.0, 43.7, 'Daniela', 'Marrone', FALSE, 'Ecologia Fluviale', 'Oxygen Kit');
