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


CREATE OR REPLACE FUNCTION verifica_sovrapposizione_date()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Addetto_Conservazione AC
                 JOIN Iniziativa_Conservazione IC ON AC.Id_iniziativa = IC.Id_iniziativa
        WHERE AC.CF = NEW.CF
          AND AC.Id_iniziativa != NEW.Id_iniziativa
          AND (
            (SELECT data_inizio FROM Iniziativa_Conservazione WHERE Id_iniziativa = NEW.Id_iniziativa) BETWEEN IC.data_inizio AND IC.data_fine OR
            (SELECT data_fine FROM Iniziativa_Conservazione WHERE Id_iniziativa = NEW.Id_iniziativa) BETWEEN IC.data_inizio AND IC.data_fine OR
            IC.data_inizio BETWEEN (SELECT data_inizio FROM Iniziativa_Conservazione WHERE Id_iniziativa = NEW.Id_iniziativa) AND (SELECT data_fine FROM Iniziativa_Conservazione WHERE Id_iniziativa = NEW.Id_iniziativa)
            )
    ) THEN
        RAISE EXCEPTION 'L''addetto è già assegnato a un''altra iniziativa nel periodo indicato.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_sovrapposizione
    BEFORE INSERT OR UPDATE ON Addetto_Conservazione
    FOR EACH ROW
EXECUTE FUNCTION verifica_sovrapposizione_date();






