-- Stored Procedure: sp_descmultampal_agregar
-- Tipo: CRUD
-- Descripción: Agrega un nuevo descuento a multa municipal principal
-- Generado para formulario: descmultampalfrm
-- Fecha: 2025-08-27 00:12:03

CREATE OR REPLACE FUNCTION sp_descmultampal_agregar(
    p_id_multa INTEGER,
    p_tipo_descto CHAR(1),
    p_valor NUMERIC,
    p_autoriza INTEGER,
    p_observacion TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    -- Solo puede haber un descuento vigente por multa
    UPDATE descmultampal SET estado = 'C' WHERE id_multa = p_id_multa AND estado = 'V';
    INSERT INTO descmultampal (
        id_multa, tipo_descto, valor, autoriza, observacion, estado, feccap, capturista
    ) VALUES (
        p_id_multa, p_tipo_descto, p_valor, p_autoriza, p_observacion, 'V', NOW(), p_usuario
    ) RETURNING id_descmultampal INTO v_id;
    RETURN QUERY SELECT v_id, 'V';
END;
$$ LANGUAGE plpgsql;