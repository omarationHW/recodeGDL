-- Stored Procedure: sp_update_actividad
-- Tipo: CRUD
-- Descripción: Actualiza una actividad existente.
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-26 15:14:33

CREATE OR REPLACE FUNCTION sp_update_actividad(
    p_id_actividad INTEGER,
    p_id_giro INTEGER,
    p_descripcion VARCHAR,
    p_observaciones VARCHAR DEFAULT NULL,
    p_vigente CHAR(1),
    p_usuario_baja VARCHAR DEFAULT NULL,
    p_motivo_baja VARCHAR DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    UPDATE c_actividades_lic
    SET id_giro = p_id_giro,
        descripcion = p_descripcion,
        observaciones = p_observaciones,
        vigente = p_vigente,
        fecha_baja = CASE WHEN p_vigente = 'C' THEN NOW() ELSE NULL END,
        usuario_baja = CASE WHEN p_vigente = 'C' THEN p_usuario_baja ELSE NULL END,
        motivo_baja = CASE WHEN p_vigente = 'C' THEN p_motivo_baja ELSE NULL END
    WHERE id_actividad = p_id_actividad;
END;
$$ LANGUAGE plpgsql;