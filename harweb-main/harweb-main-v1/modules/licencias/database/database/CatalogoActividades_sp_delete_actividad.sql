-- Stored Procedure: sp_delete_actividad
-- Tipo: CRUD
-- Descripción: Cancela (da de baja lógica) una actividad.
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-26 15:14:33

CREATE OR REPLACE FUNCTION sp_delete_actividad(
    p_id_actividad INTEGER,
    p_usuario_baja VARCHAR,
    p_motivo_baja VARCHAR DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    UPDATE c_actividades_lic
    SET vigente = 'C',
        fecha_baja = NOW(),
        usuario_baja = p_usuario_baja,
        motivo_baja = p_motivo_baja
    WHERE id_actividad = p_id_actividad;
END;
$$ LANGUAGE plpgsql;