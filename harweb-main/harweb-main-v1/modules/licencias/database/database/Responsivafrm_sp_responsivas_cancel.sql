-- Stored Procedure: sp_responsivas_cancel
-- Tipo: CRUD
-- Descripción: Cancela una responsiva.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION sp_responsivas_cancel(axo_in INTEGER, folio_in INTEGER, motivo_in TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE responsivas SET vigente = 'C', observacion = motivo_in WHERE axo = axo_in AND folio = folio_in;
END;
$$ LANGUAGE plpgsql;