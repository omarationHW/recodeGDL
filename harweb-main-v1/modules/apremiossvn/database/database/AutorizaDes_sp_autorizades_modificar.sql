-- Stored Procedure: sp_autorizades_modificar
-- Tipo: CRUD
-- Descripción: Modifica un descuento autorizado existente.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_modificar(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_cveaut INTEGER,
    p_porcentaje INTEGER,
    p_fecha_alta DATE,
    p_usuario_id INTEGER
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
BEGIN
    UPDATE ta_15_autorizados
    SET cveaut = p_cveaut, porcentaje = p_porcentaje, fecha_alta = p_fecha_alta, id_usuario = p_usuario_id, fecha_actual = NOW()
    WHERE control = p_id_control AND estado = 1;
    UPDATE ta_15_apremios SET porcentaje_multa = p_porcentaje WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE, 'Modificación exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;