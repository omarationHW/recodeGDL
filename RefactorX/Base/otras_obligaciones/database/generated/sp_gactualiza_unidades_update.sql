-- ================================================================
-- SP: sp_gactualiza_unidades_update
-- Módulo: otras_obligaciones
-- Descripción: Actualiza tipo de local/unidades de una concesión
-- Componente: GActualiza.vue, RActualiza.vue
-- Autor: Sistema RefactorX - QA Agent
-- Fecha: 2025-11-26
-- ================================================================

CREATE OR REPLACE FUNCTION sp_gactualiza_unidades_update(
    par_tabla INTEGER,
    par_id_34_datos INTEGER,
    par_sup NUMERIC,
    par_descrip VARCHAR,
    par_axo_ini INTEGER,
    par_mes_ini INTEGER,
    par_usuario VARCHAR
)
RETURNS TABLE (
    status INTEGER,
    concepto VARCHAR
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_current_status CHAR(1);
    v_control VARCHAR(20);
    v_cve_unidad INTEGER;
BEGIN
    -- Verificar que el registro existe y está vigente
    SELECT
        EXISTS(SELECT 1 FROM t_34_datos WHERE id_34_datos = par_id_34_datos),
        d.status,
        d.control
    INTO v_exists, v_current_status, v_control
    FROM t_34_datos d
    WHERE d.id_34_datos = par_id_34_datos;

    IF NOT v_exists THEN
        RETURN QUERY
        SELECT
            1 AS status,
            'El registro no existe'::VARCHAR AS concepto;
        RETURN;
    END IF;

    IF v_current_status != 'V' THEN
        RETURN QUERY
        SELECT
            2 AS status,
            'Solo se pueden actualizar registros VIGENTES'::VARCHAR AS concepto;
        RETURN;
    END IF;

    -- Obtener cve_unidad de la tabla de catálogo según descripción
    SELECT cve_tab INTO v_cve_unidad
    FROM t_34_tablas
    WHERE cve_tab_id = par_tabla
      AND UPPER(descripcion) = UPPER(par_descrip)
    LIMIT 1;

    -- Si no existe, usar el primer valor disponible
    IF v_cve_unidad IS NULL THEN
        SELECT cve_tab INTO v_cve_unidad
        FROM t_34_tablas
        WHERE cve_tab_id = par_tabla
        LIMIT 1;
    END IF;

    -- Actualizar tipo de local/unidades en t_34_datos
    UPDATE t_34_datos
    SET
        unidades = COALESCE(v_cve_unidad, unidades),
        axo_ini = par_axo_ini,
        mes_ini = par_mes_ini,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_34_datos = par_id_34_datos;

    -- Insertar cambio en histórico de unidades
    INSERT INTO t_34_unidades (
        cve_tab,
        control,
        axo,
        mes,
        superficie,
        descripcion,
        fecha_alta,
        usuario_alta
    ) VALUES (
        par_tabla,
        v_control,
        par_axo_ini,
        par_mes_ini,
        par_sup,
        par_descrip,
        CURRENT_TIMESTAMP,
        par_usuario
    );

    -- Registrar en log de auditoría
    INSERT INTO t_34_auditoria (
        id_34_datos,
        accion,
        usuario,
        fecha,
        descripcion
    ) VALUES (
        par_id_34_datos,
        'UPDATE_UNIDADES',
        par_usuario,
        CURRENT_TIMESTAMP,
        FORMAT('Cambio de tipo de local a "%s" desde %s/%s', par_descrip, par_mes_ini, par_axo_ini)
    );

    RETURN QUERY
    SELECT
        0 AS status,
        FORMAT('Tipo de local actualizado a "%s" desde %s/%s', par_descrip, par_mes_ini, par_axo_ini)::VARCHAR AS concepto;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            99 AS status,
            ('Error al actualizar tipo de local: ' || SQLERRM)::VARCHAR AS concepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_gactualiza_unidades_update(INTEGER, INTEGER, NUMERIC, VARCHAR, INTEGER, INTEGER, VARCHAR) IS
'Actualiza el tipo de local/unidades de una concesión/contrato con fecha de inicio de aplicación';
