-- Stored Procedure: sp_descmultadiftransm_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento de multa de requerimiento de transmisión
-- Generado para formulario: DescMultaReqDifTrans
-- Fecha: 2025-08-27 00:14:47

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_cancelar(
    p_folio INTEGER,
    p_id_descmulta INTEGER,
    p_usuario VARCHAR
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    UPDATE descmultadiftransm
    SET estado = 'C', fecbaja = CURRENT_DATE, captbaja = p_usuario
    WHERE foliot = p_folio AND id_descmulta = p_id_descmulta;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;