--Permette di contare il numero di presenze di una specie nei Bacini Idrografici
select s.nome_scientifico,count(BI.nome) as numero_di_presenze
from Specie s
join Esistenza E on s.nome_scientifico = E.nome_scientifico
join Bacino_Idrografico BI on BI.Id_bacino = E.Id_bacino and BI.longitudine = E.longitudine and BI.latitudine = E.latitudine
group by s.nome_scientifico;

--Restituiscie i Bacini Idrografici con volume d'acqua > 10000 e senza interventi passati
select bi.nome,bi.volume_acqua as grandi_bacini_senza_interventi_passati
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
/*
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
*/

--Unisce i nomi e il CF degli Addetti al Monitoraggio e degli Addetti alla Conservazione disponibili
select am.CF,am.nome
from Addetto_Monitoraggio am
where am.disponibilità = true
union
select ac.CF,ac.nome
from Addetto_Conservazione ac
where ac.disponibilità = true;


drop view if exists numero_iniziative_per_bacino;

--Trova il numero di Iniziative di Conservazione per Bacino Idrografico
create view Numero_Iniziative_per_Bacino as (select count(Id_iniziativa) as numero_iniziative,Iniziativa_Conservazione.Id_bacino
from Iniziativa_Conservazione
group by  Iniziativa_Conservazione.Id_bacino
order by Iniziativa_Conservazione.Id_bacino
);

--Seleziona il Bacino Idrografico col maggior numero di Iniziative di Conservazione
select numero_iniziative,BI.Id_bacino ,BI.nome from Numero_Iniziative_per_Bacino join Bacino_Idrografico BI on Numero_Iniziative_per_Bacino.Id_bacino = BI.Id_bacino
where numero_iniziative = (
select max(numero_iniziative)
from Numero_Iniziative_per_Bacino
);
