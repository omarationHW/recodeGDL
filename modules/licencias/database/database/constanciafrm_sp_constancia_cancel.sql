-- Stored Procedure: sp_constancia_cancel
-- Tipo: CRUD
-- Descripción: Cancela una constancia y registra el motivo en observacion.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

CREATE OR REPLACE FUNCTION sp_constancia_cancel(
    p_axo integer,
    p_folio integer,
    p_observacion varchar
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    UPDATE constancias SET
        vigente = 'C',
        observacion = p_observacion
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT * FROM constancias WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;