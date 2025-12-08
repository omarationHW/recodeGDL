-- ================================================================
-- SP: sp_gactualiza_grales_update
-- Módulo: otras_obligaciones
-- Descripción: Actualiza datos generales (concesionario, ubicación, licencia, etc.)
-- Componente: GActualiza.vue, RActualiza.vue
-- Autor: Sistema RefactorX - QA Agent
-- Fecha: 2025-11-26
-- ================================================================

CREATE OR REPLACE FUNCTION sp_gactualiza_grales_update(
    par_id_34_datos INTEGER,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_lic INTEGER,
    par_nomcom VARCHAR,
    par_lugar VARCHAR,
    par_obs VARCHAR,
    par_usuario VARCHAR
)
RETURNS TABLE (
    status INTEGER,
    concepto VARCHAR
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_current_status CHAR(1);
BEGIN
    -- Verificar que el registro existe
    SELECT EXISTS(
        SELECT 1 FROM t_34_datos WHERE id_34_datos = par_id_34_datos
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY
        SELECT
            1 AS status,
            'El registro no existe'::VARCHAR AS concepto;
        RETURN;
    END IF;

    -- Verificar que el registro está vigente
    SELECT status INTO v_current_status
    FROM t_34_datos
    WHERE id_34_datos = par_id_34_datos;

    IF v_current_status != 'V' THEN
        RETURN QUERY
        SELECT
            2 AS status,
            'Solo se pueden actualizar registros VIGENTES'::VARCHAR AS concepto;
        RETURN;
    END IF;

    -- Actualizar datos generales
    UPDATE t_34_datos
    SET
        concesionario = CASE WHEN par_conces != 'nada' AND par_conces != '' THEN par_conces ELSE concesionario END,
        ubicacion = CASE WHEN par_ubica != 'nada' AND par_ubica != '' THEN par_ubica ELSE ubicacion END,
        licencia = CASE WHEN par_lic > 0 THEN par_lic::VARCHAR ELSE licencia END,
        nomcomercial = CASE WHEN par_nomcom != 'nada' AND par_nomcom != '' THEN par_nomcom ELSE nomcomercial END,
        lugar = CASE WHEN par_lugar != 'nada' AND par_lugar != '' THEN par_lugar ELSE lugar END,
        obs = CASE WHEN par_obs != 'nada' AND par_obs != '' THEN par_obs ELSE obs END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_34_datos = par_id_34_datos;

    -- Registrar en log de auditoría
    INSERT INTO t_34_auditoria (
        id_34_datos,
        accion,
        usuario,
        fecha,
        descripcion
    ) VALUES (
        par_id_34_datos,
        'UPDATE_DATOS_GRALES',
        par_usuario,
        CURRENT_TIMESTAMP,
        'Actualización de datos generales'
    );

    RETURN QUERY
    SELECT
        0 AS status,
        'Datos generales actualizados correctamente'::VARCHAR AS concepto;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            99 AS status,
            ('Error al actualizar: ' || SQLERRM)::VARCHAR AS concepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_gactualiza_grales_update(INTEGER, VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
'Actualiza datos generales de una concesión/contrato (concesionario, ubicación, licencia, nombre comercial, lugar, observaciones)';
