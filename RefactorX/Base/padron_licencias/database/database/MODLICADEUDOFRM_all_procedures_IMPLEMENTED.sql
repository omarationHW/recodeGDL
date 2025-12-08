-- =====================================================================================
-- ARCHIVO: MODLICADEUDOFRM_all_procedures_IMPLEMENTED.sql
-- MÓDULO: padron_licencias
-- COMPONENTE: modlicAdeudofrm
-- DESCRIPCIÓN: Stored Procedures para recálculo y modificación de adeudos de licencias
-- AUTOR: Claude Code Assistant
-- FECHA: 2025-11-21
-- VERSION: 1.0.0
-- =====================================================================================
-- CONTENIDO:
--   1. Tabla de auditoría: comun.bitacora_saldos
--   2. SP Principal: comun.sp_calc_sdoslsr
--   3. Alias: comun.calc_sdoslsr
--   4. Alias: comun.modlicAdeudofrm_calc_sdoslsr
-- =====================================================================================

-- =============================================================================
-- SECCIÓN 1: TABLA DE AUDITORÍA PARA REGISTRO DE CAMBIOS EN SALDOS
-- =============================================================================

CREATE TABLE IF NOT EXISTS comun.bitacora_saldos (
    id BIGSERIAL PRIMARY KEY,
    licencia_id INTEGER NOT NULL,
    saldo_anterior NUMERIC(12,2),
    saldo_nuevo NUMERIC(12,2),
    diferencia NUMERIC(12,2),
    usuario VARCHAR(50),
    motivo VARCHAR(200),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para optimizar consultas de auditoría
CREATE INDEX IF NOT EXISTS idx_bitacora_saldos_licencia_id
    ON comun.bitacora_saldos(licencia_id);
CREATE INDEX IF NOT EXISTS idx_bitacora_saldos_created_at
    ON comun.bitacora_saldos(created_at);
CREATE INDEX IF NOT EXISTS idx_bitacora_saldos_usuario
    ON comun.bitacora_saldos(usuario);

COMMENT ON TABLE comun.bitacora_saldos IS 'Tabla de auditoría para registro de recálculos de saldos de licencias';
COMMENT ON COLUMN comun.bitacora_saldos.licencia_id IS 'ID de la licencia recalculada';
COMMENT ON COLUMN comun.bitacora_saldos.saldo_anterior IS 'Saldo antes del recálculo';
COMMENT ON COLUMN comun.bitacora_saldos.saldo_nuevo IS 'Saldo después del recálculo';
COMMENT ON COLUMN comun.bitacora_saldos.diferencia IS 'Diferencia entre saldo nuevo y anterior';
COMMENT ON COLUMN comun.bitacora_saldos.usuario IS 'Usuario que ejecutó el recálculo';
COMMENT ON COLUMN comun.bitacora_saldos.motivo IS 'Motivo o descripción del recálculo';
COMMENT ON COLUMN comun.bitacora_saldos.created_at IS 'Fecha y hora del recálculo';

-- =============================================================================
-- SECCIÓN 2: SP PRINCIPAL - sp_calc_sdoslsr
-- Recalcular saldo de licencia
-- =============================================================================

CREATE OR REPLACE FUNCTION comun.sp_calc_sdoslsr(
    p_licencia_id INTEGER,
    p_usuario VARCHAR(50),
    p_recalcular_todo BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    licencia_id INTEGER,
    saldo_anterior NUMERIC(12,2),
    saldo_nuevo NUMERIC(12,2),
    diferencia NUMERIC(12,2),
    detalles_actualizados INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_licencia_existe BOOLEAN;
    v_numero_licencia VARCHAR(50);
    v_saldo_anterior NUMERIC(12,2);
    v_saldo_nuevo NUMERIC(12,2);
    v_diferencia NUMERIC(12,2);
    v_total_cargos NUMERIC(12,2);
    v_total_abonos NUMERIC(12,2);
    v_detalles_count INTEGER;
    v_motivo VARCHAR(200);
BEGIN
    -- =========================================================================
    -- PASO 1: Validar que la licencia existe
    -- =========================================================================
    SELECT
        TRUE,
        l.numero_licencia,
        COALESCE(l.saldo, 0)
    INTO
        v_licencia_existe,
        v_numero_licencia,
        v_saldo_anterior
    FROM comun.licencias l
    WHERE l.id_licencia = p_licencia_id;

    -- Si la licencia no existe, retornar error
    IF NOT FOUND OR v_licencia_existe IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error: La licencia con ID %s no existe en el sistema', p_licencia_id)::TEXT,
            p_licencia_id,
            0::NUMERIC(12,2),
            0::NUMERIC(12,2),
            0::NUMERIC(12,2),
            0::INTEGER;
        RETURN;
    END IF;

    -- =========================================================================
    -- PASO 2: Calcular total de cargos (tipo='C')
    -- =========================================================================
    IF p_recalcular_todo THEN
        -- Recalcular desde el primer registro (todos los movimientos)
        SELECT COALESCE(SUM(d.importe), 0)
        INTO v_total_cargos
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id
          AND UPPER(d.tipo) = 'C';
    ELSE
        -- Recalcular solo movimientos del año actual
        SELECT COALESCE(SUM(d.importe), 0)
        INTO v_total_cargos
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id
          AND UPPER(d.tipo) = 'C'
          AND d.anio >= EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    END IF;

    -- =========================================================================
    -- PASO 3: Calcular total de abonos (tipo='A')
    -- =========================================================================
    IF p_recalcular_todo THEN
        -- Recalcular desde el primer registro (todos los movimientos)
        SELECT COALESCE(SUM(d.importe), 0)
        INTO v_total_abonos
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id
          AND UPPER(d.tipo) = 'A';
    ELSE
        -- Recalcular solo movimientos del año actual
        SELECT COALESCE(SUM(d.importe), 0)
        INTO v_total_abonos
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id
          AND UPPER(d.tipo) = 'A'
          AND d.anio >= EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    END IF;

    -- =========================================================================
    -- PASO 4: Calcular nuevo saldo (cargos - abonos)
    -- =========================================================================
    v_saldo_nuevo := v_total_cargos - v_total_abonos;
    v_diferencia := v_saldo_nuevo - v_saldo_anterior;

    -- Contar registros procesados
    IF p_recalcular_todo THEN
        SELECT COUNT(*)
        INTO v_detalles_count
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id;

        v_motivo := 'Recálculo completo desde origen';
    ELSE
        SELECT COUNT(*)
        INTO v_detalles_count
        FROM comun.detsal_lic d
        WHERE d.licencia_id = p_licencia_id
          AND d.anio >= EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;

        v_motivo := FORMAT('Recálculo parcial año %s', EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
    END IF;

    -- =========================================================================
    -- PASO 5: Actualizar saldo en tabla licencias
    -- =========================================================================
    UPDATE comun.licencias
    SET saldo = v_saldo_nuevo
    WHERE id_licencia = p_licencia_id;

    -- =========================================================================
    -- PASO 6: Registrar en bitácora de auditoría
    -- =========================================================================
    INSERT INTO comun.bitacora_saldos (
        licencia_id,
        saldo_anterior,
        saldo_nuevo,
        diferencia,
        usuario,
        motivo,
        created_at
    ) VALUES (
        p_licencia_id,
        v_saldo_anterior,
        v_saldo_nuevo,
        v_diferencia,
        COALESCE(p_usuario, 'SISTEMA'),
        v_motivo,
        NOW()
    );

    -- =========================================================================
    -- PASO 7: Retornar resultado comparativo
    -- =========================================================================
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        FORMAT('Saldo recalculado exitosamente para licencia %s. Cargos: %s, Abonos: %s',
               v_numero_licencia,
               v_total_cargos::TEXT,
               v_total_abonos::TEXT)::TEXT,
        p_licencia_id,
        v_saldo_anterior,
        v_saldo_nuevo,
        v_diferencia,
        v_detalles_count;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, la transacción se revierte automáticamente
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error al recalcular saldo: %s', SQLERRM)::TEXT,
            p_licencia_id,
            COALESCE(v_saldo_anterior, 0)::NUMERIC(12,2),
            0::NUMERIC(12,2),
            0::NUMERIC(12,2),
            0::INTEGER;
END;
$$;

COMMENT ON FUNCTION comun.sp_calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) IS
'Recalcula el saldo de una licencia sumando cargos y restando abonos del detalle de saldos.
Parámetros:
  - p_licencia_id: ID de la licencia a recalcular
  - p_usuario: Usuario que ejecuta (para auditoría)
  - p_recalcular_todo: Si TRUE recalcula desde el primer registro, si FALSE solo el año actual
Retorna: success, message, licencia_id, saldo_anterior, saldo_nuevo, diferencia, detalles_actualizados';

-- =============================================================================
-- SECCIÓN 3: ALIAS calc_sdoslsr (sin prefijo sp_)
-- =============================================================================

CREATE OR REPLACE FUNCTION comun.calc_sdoslsr(
    p_licencia_id INTEGER,
    p_usuario VARCHAR(50),
    p_recalcular_todo BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    licencia_id INTEGER,
    saldo_anterior NUMERIC(12,2),
    saldo_nuevo NUMERIC(12,2),
    diferencia NUMERIC(12,2),
    detalles_actualizados INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delegar al SP principal
    RETURN QUERY SELECT * FROM comun.sp_calc_sdoslsr(
        p_licencia_id,
        p_usuario,
        p_recalcular_todo
    );
END;
$$;

COMMENT ON FUNCTION comun.calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) IS
'Alias de comun.sp_calc_sdoslsr - Recalcula el saldo de una licencia';

-- =============================================================================
-- SECCIÓN 4: ALIAS modlicAdeudofrm_calc_sdoslsr (compatibilidad con componente)
-- =============================================================================

CREATE OR REPLACE FUNCTION comun.modlicAdeudofrm_calc_sdoslsr(
    p_licencia_id INTEGER,
    p_usuario VARCHAR(50),
    p_recalcular_todo BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    licencia_id INTEGER,
    saldo_anterior NUMERIC(12,2),
    saldo_nuevo NUMERIC(12,2),
    diferencia NUMERIC(12,2),
    detalles_actualizados INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delegar al SP principal
    RETURN QUERY SELECT * FROM comun.sp_calc_sdoslsr(
        p_licencia_id,
        p_usuario,
        p_recalcular_todo
    );
END;
$$;

COMMENT ON FUNCTION comun.modlicAdeudofrm_calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) IS
'Alias de comun.sp_calc_sdoslsr - Compatibilidad con componente modlicAdeudofrm';

-- =============================================================================
-- SECCIÓN 5: GRANTS Y PERMISOS
-- =============================================================================

-- Permisos para el SP principal y aliases
GRANT EXECUTE ON FUNCTION comun.sp_calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.modlicAdeudofrm_calc_sdoslsr(INTEGER, VARCHAR, BOOLEAN) TO PUBLIC;

-- Permisos para la tabla de auditoría
GRANT SELECT, INSERT ON comun.bitacora_saldos TO PUBLIC;
GRANT USAGE, SELECT ON SEQUENCE comun.bitacora_saldos_id_seq TO PUBLIC;

-- =============================================================================
-- SECCIÓN 6: VERIFICACIÓN DE INSTALACIÓN
-- =============================================================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar tabla de auditoría
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'comun'
      AND table_name = 'bitacora_saldos';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] Tabla comun.bitacora_saldos creada correctamente';
    ELSE
        RAISE WARNING '[ERROR] Tabla comun.bitacora_saldos NO fue creada';
    END IF;

    -- Verificar SP principal
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
      AND routine_name = 'sp_calc_sdoslsr';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] Función comun.sp_calc_sdoslsr instalada correctamente';
    ELSE
        RAISE WARNING '[ERROR] Función comun.sp_calc_sdoslsr NO fue instalada';
    END IF;

    -- Verificar alias calc_sdoslsr
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
      AND routine_name = 'calc_sdoslsr';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] Alias comun.calc_sdoslsr instalado correctamente';
    ELSE
        RAISE WARNING '[ERROR] Alias comun.calc_sdoslsr NO fue instalado';
    END IF;

    -- Verificar alias modlicAdeudofrm_calc_sdoslsr
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
      AND routine_name = 'modlicadeudofrm_calc_sdoslsr';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] Alias comun.modlicAdeudofrm_calc_sdoslsr instalado correctamente';
    ELSE
        RAISE WARNING '[ERROR] Alias comun.modlicAdeudofrm_calc_sdoslsr NO fue instalado';
    END IF;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'INSTALACIÓN COMPLETADA - modlicAdeudofrm';
    RAISE NOTICE '============================================';
END;
$$;

-- =============================================================================
-- FIN DEL ARCHIVO
-- =============================================================================
-- RESUMEN DE OBJETOS CREADOS:
--   1. comun.bitacora_saldos (TABLE) - Auditoría de recálculos
--   2. comun.sp_calc_sdoslsr (FUNCTION) - SP principal de recálculo
--   3. comun.calc_sdoslsr (FUNCTION) - Alias sin prefijo
--   4. comun.modlicAdeudofrm_calc_sdoslsr (FUNCTION) - Alias componente
--
-- USO EJEMPLO:
--   SELECT * FROM comun.sp_calc_sdoslsr(12345, 'usuario_test', FALSE);
--   SELECT * FROM comun.sp_calc_sdoslsr(12345, 'usuario_test', TRUE);
--
-- CONSULTAR AUDITORÍA:
--   SELECT * FROM comun.bitacora_saldos WHERE licencia_id = 12345 ORDER BY created_at DESC;
-- =============================================================================
