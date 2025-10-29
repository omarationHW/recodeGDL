-- Stored Procedure: sp_responsivas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva responsiva.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION sp_responsivas_create(tipo_in TEXT, licencia_in TEXT, capturista_in TEXT)
RETURNS TABLE(axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
DECLARE
    lic_id INTEGER;
    folio INTEGER;
    now_date DATE := CURRENT_DATE;
BEGIN
    SELECT id_licencia INTO lic_id FROM licencias WHERE licencia = licencia_in;
    IF lic_id IS NULL THEN
        RAISE EXCEPTION 'Licencia no encontrada';
    END IF;
    folio := next_responsiva_folio(tipo_in, EXTRACT(YEAR FROM now_date)::INTEGER);
    INSERT INTO responsivas(axo, folio, id_licencia, tipo, vigente, feccap, capturista)
    VALUES (EXTRACT(YEAR FROM now_date)::INTEGER, folio, lic_id, tipo_in, 'V', now_date, capturista_in)
    RETURNING axo, folio, id_licencia, tipo, vigente, feccap, capturista;
END;
$$ LANGUAGE plpgsql;