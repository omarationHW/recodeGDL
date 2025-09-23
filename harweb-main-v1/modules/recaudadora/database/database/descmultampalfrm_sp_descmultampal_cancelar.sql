-- Stored Procedure: sp_descmultampal_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente de multa municipal principal
-- Generado para formulario: descmultampalfrm
-- Fecha: 2025-08-27 00:12:03

CREATE OR REPLACE FUNCTION sp_descmultampal_cancelar(
    p_id_descmultampal INTEGER,
    p_motivo TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
BEGIN
    UPDATE descmultampal SET
        estado = 'C',
        observacion = COALESCE(observacion,'') || '\nCANCELADO: ' || p_motivo,
        feccap = NOW(),
        capturista = p_usuario
    WHERE id_descmultampal = p_id_descmultampal;
    RETURN QUERY SELECT p_id_descmultampal, 'C';
END;
$$ LANGUAGE plpgsql;