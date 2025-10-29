-- Stored Procedure: sp_autorizades_alta
-- Tipo: CRUD
-- Descripción: Da de alta un descuento autorizado para un folio.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_alta(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_cveaut INTEGER,
    p_porcentaje INTEGER,
    p_fecha_alta DATE,
    p_usuario_id INTEGER
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
DECLARE
    v_estado SMALLINT := 1;
BEGIN
    -- Insertar en ta_15_autorizados
    INSERT INTO ta_15_autorizados (control, id_rec, cveaut, porcentaje, fecha_alta, id_usuarioa, fecha_baja, estado, id_usuario, fecha_actual)
    VALUES (p_id_control, p_id_rec, p_cveaut, p_porcentaje, p_fecha_alta, p_usuario_id, NULL, v_estado, p_usuario_id, NOW());
    -- Actualizar porcentaje en ta_15_apremios
    UPDATE ta_15_apremios SET porcentaje_multa = p_porcentaje WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE, 'Alta exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;