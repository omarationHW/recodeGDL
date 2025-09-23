-- Stored Procedure: sp_descmultampal_editar
-- Tipo: CRUD
-- Descripción: Edita un descuento vigente de multa municipal principal
-- Generado para formulario: descmultampalfrm
-- Fecha: 2025-08-27 00:12:03

CREATE OR REPLACE FUNCTION sp_descmultampal_editar(
    p_id_descmultampal INTEGER,
    p_tipo_descto CHAR(1),
    p_valor NUMERIC,
    p_autoriza INTEGER,
    p_observacion TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
BEGIN
    UPDATE descmultampal SET
        tipo_descto = p_tipo_descto,
        valor = p_valor,
        autoriza = p_autoriza,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE id_descmultampal = p_id_descmultampal;
    RETURN QUERY SELECT p_id_descmultampal, 'V';
END;
$$ LANGUAGE plpgsql;