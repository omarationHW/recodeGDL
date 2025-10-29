-- Stored Procedure: sp_constancia_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las constancias ordenadas por año y folio descendente.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

CREATE OR REPLACE FUNCTION sp_constancia_list()
RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    RETURN QUERY SELECT * FROM constancias ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;