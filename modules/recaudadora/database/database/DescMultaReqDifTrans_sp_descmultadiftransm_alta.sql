-- Stored Procedure: sp_descmultadiftransm_alta
-- Tipo: CRUD
-- Descripción: Da de alta un descuento de multa de requerimiento de transmisión
-- Generado para formulario: DescMultaReqDifTrans
-- Fecha: 2025-08-27 00:14:47

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_alta(
    p_folio INTEGER,
    p_porcentaje INTEGER,
    p_usuario VARCHAR,
    p_autoriza INTEGER,
    p_cvedepto INTEGER
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descmultadiftransm (id_descmulta, foliot, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, folio, autoriza, cvedepto)
    VALUES (DEFAULT, p_folio, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 'V', NULL, NULL, p_autoriza, p_cvedepto)
    RETURNING id_descmulta INTO v_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;