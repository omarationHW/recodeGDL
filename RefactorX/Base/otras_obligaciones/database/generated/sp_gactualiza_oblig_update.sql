-- ================================================================
-- SP: sp_gactualiza_oblig_update
-- Módulo: otras_obligaciones
-- Descripción: Actualiza fecha de inicio de obligación de una concesión
-- Componente: GActualiza.vue, RActualiza.vue
-- Autor: Sistema RefactorX - QA Agent
-- Fecha: 2025-11-26
-- ================================================================

CREATE OR REPLACE FUNCTION sp_gactualiza_oblig_update(
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
    v_fecha_inicio DATE;
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

    -- Validar año y mes
    IF par_axo_ini < 2000 OR par_axo_ini > 2099 THEN
        RETURN QUERY
        SELECT
            3 AS status,
            'El año debe estar entre 2000 y 2099'::VARCHAR AS concepto;
        RETURN;
    END IF;

    IF par_mes_ini < 1 OR par_mes_ini > 12 THEN
        RETURN QUERY
        SELECT
            4 AS status,
            'El mes debe estar entre 1 y 12'::VARCHAR AS concepto;
        RETURN;
    END IF;

    -- Construir fecha de inicio
    v_fecha_inicio := TO_DATE(par_axo_ini || '-' || LPAD(par_mes_ini::TEXT, 2, '0') || '-01', 'YYYY-MM-DD');

    -- Actualizar fecha de inicio de obligación en t_34_datos
    UPDATE t_34_datos
    SET
        axo_ini = par_axo_ini,
        mes_ini = par_mes_ini,
        fechainicio = v_fecha_inicio,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_34_datos = par_id_34_datos;

    -- Insertar cambio en histórico de unidades (registramos el cambio)
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
        'UPDATE_INICIO_OBLIG',
        par_usuario,
        CURRENT_TIMESTAMP,
        FORMAT('Cambio de inicio de obligación a %s/%s', par_mes_ini, par_axo_ini)
    );

    RETURN QUERY
    SELECT
        0 AS status,
        FORMAT('Inicio de obligación actualizado a %s/%s', par_mes_ini, par_axo_ini)::VARCHAR AS concepto;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            99 AS status,
            ('Error al actualizar inicio de obligación: ' || SQLERRM)::VARCHAR AS concepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_gactualiza_oblig_update(INTEGER, INTEGER, NUMERIC, VARCHAR, INTEGER, INTEGER, VARCHAR) IS
'Actualiza la fecha de inicio de obligación de una concesión/contrato';
