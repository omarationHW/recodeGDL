-- ================================================================
-- SP: sp_gactualiza_sup_update
-- Módulo: otras_obligaciones
-- Descripción: Actualiza superficie de una concesión con fecha de inicio
-- Componente: GActualiza.vue, RActualiza.vue
-- Autor: Sistema RefactorX - QA Agent
-- Fecha: 2025-11-26
-- ================================================================

CREATE OR REPLACE FUNCTION sp_gactualiza_sup_update(
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

    -- Validar superficie
    IF par_sup <= 0 THEN
        RETURN QUERY
        SELECT
            3 AS status,
            'La superficie debe ser mayor a cero'::VARCHAR AS concepto;
        RETURN;
    END IF;

    -- Actualizar superficie en t_34_datos
    UPDATE t_34_datos
    SET
        superficie = par_sup,
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
        'UPDATE_SUPERFICIE',
        par_usuario,
        CURRENT_TIMESTAMP,
        FORMAT('Cambio de superficie a %s m² desde %s/%s', par_sup, par_mes_ini, par_axo_ini)
    );

    RETURN QUERY
    SELECT
        0 AS status,
        FORMAT('Superficie actualizada a %s m² desde %s/%s', par_sup, par_mes_ini, par_axo_ini)::VARCHAR AS concepto;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            99 AS status,
            ('Error al actualizar superficie: ' || SQLERRM)::VARCHAR AS concepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_gactualiza_sup_update(INTEGER, INTEGER, NUMERIC, VARCHAR, INTEGER, INTEGER, VARCHAR) IS
'Actualiza la superficie de una concesión/contrato con fecha de inicio de aplicación';
