-- Stored Procedure: sp_create_actividad
-- Tipo: CRUD
-- Descripción: Crea una nueva actividad en el catálogo.
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-26 15:14:33

CREATE OR REPLACE FUNCTION sp_create_actividad(
    p_id_giro INTEGER,
    p_descripcion VARCHAR,
    p_observaciones VARCHAR DEFAULT NULL,
    p_vigente CHAR(1),
    p_usuario_alta VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO c_actividades_lic (id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta)
    VALUES (p_id_giro, p_descripcion, p_observaciones, p_vigente, NOW(), p_usuario_alta)
    RETURNING id_actividad INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;