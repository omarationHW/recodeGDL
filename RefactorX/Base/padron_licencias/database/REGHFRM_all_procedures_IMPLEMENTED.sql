-- =====================================================================================
-- REGHFRM - Formulario de Registros Históricos del Catastro
-- Módulo: padron_licencias
-- Schema: comun
-- Descripción: Gestiona el historial de cambios catastrales por cuenta
-- Fecha: 2025-11-21
-- =====================================================================================

-- =====================================================================================
-- PASO 1: CREAR TABLA SI NO EXISTE
-- =====================================================================================

CREATE TABLE IF NOT EXISTS comun.h_catastro (
    id BIGSERIAL PRIMARY KEY,
    cvecuenta INTEGER NOT NULL,
    axocomp INTEGER NOT NULL,
    nocomp INTEGER NOT NULL,
    tipo_movimiento VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT NOW(),
    usuario VARCHAR(50),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(50),
    UNIQUE(cvecuenta, axocomp, nocomp)
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_h_catastro_cvecuenta ON comun.h_catastro(cvecuenta);
CREATE INDEX IF NOT EXISTS idx_h_catastro_axocomp ON comun.h_catastro(axocomp);
CREATE INDEX IF NOT EXISTS idx_h_catastro_fecha ON comun.h_catastro(fecha_registro);

COMMENT ON TABLE comun.h_catastro IS 'Tabla de registros históricos del catastro';
COMMENT ON COLUMN comun.h_catastro.cvecuenta IS 'Clave de cuenta catastral';
COMMENT ON COLUMN comun.h_catastro.axocomp IS 'Año del componente/movimiento';
COMMENT ON COLUMN comun.h_catastro.nocomp IS 'Número de componente/movimiento';
COMMENT ON COLUMN comun.h_catastro.tipo_movimiento IS 'Tipo de movimiento catastral';
COMMENT ON COLUMN comun.h_catastro.fecha_registro IS 'Fecha de registro del movimiento';
COMMENT ON COLUMN comun.h_catastro.usuario IS 'Usuario que registró el movimiento';
COMMENT ON COLUMN comun.h_catastro.observaciones IS 'Observaciones adicionales';

-- =====================================================================================
-- SP 1: sp_reghfrm_get_historic_records
-- Descripción: Obtener registros históricos por cuenta catastral
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.sp_reghfrm_get_historic_records(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_reghfrm_get_historic_records(
    p_cvecuenta INTEGER
)
RETURNS TABLE(
    id BIGINT,
    cvecuenta INTEGER,
    axocomp INTEGER,
    nocomp INTEGER,
    tipo_movimiento VARCHAR,
    fecha_registro TIMESTAMP,
    usuario VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_cvecuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro cvecuenta es requerido';
    END IF;

    RETURN QUERY
    SELECT
        h.id,
        h.cvecuenta,
        h.axocomp,
        h.nocomp,
        h.tipo_movimiento::VARCHAR,
        h.fecha_registro,
        h.usuario::VARCHAR,
        h.observaciones
    FROM comun.h_catastro h
    WHERE h.cvecuenta = p_cvecuenta
      AND h.deleted_at IS NULL
    ORDER BY h.axocomp DESC, h.nocomp DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener registros históricos: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION comun.sp_reghfrm_get_historic_records(INTEGER) IS
'Obtiene los registros históricos de una cuenta catastral ordenados por año y número descendente';

-- =====================================================================================
-- SP 2: sp_reghfrm_get_record_detail
-- Descripción: Obtener detalle de un registro histórico específico
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.sp_reghfrm_get_record_detail(BIGINT, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_reghfrm_get_record_detail(
    p_id BIGINT DEFAULT NULL,
    p_cvecuenta INTEGER DEFAULT NULL,
    p_axocomp INTEGER DEFAULT NULL,
    p_nocomp INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    cvecuenta INTEGER,
    axocomp INTEGER,
    nocomp INTEGER,
    tipo_movimiento VARCHAR,
    fecha_registro TIMESTAMP,
    usuario VARCHAR,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar que se proporcione al menos un método de búsqueda
    IF p_id IS NULL AND (p_cvecuenta IS NULL OR p_axocomp IS NULL OR p_nocomp IS NULL) THEN
        RAISE EXCEPTION 'Debe proporcionar p_id o la combinación (p_cvecuenta, p_axocomp, p_nocomp)';
    END IF;

    -- Búsqueda por ID
    IF p_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            h.id,
            h.cvecuenta,
            h.axocomp,
            h.nocomp,
            h.tipo_movimiento::VARCHAR,
            h.fecha_registro,
            h.usuario::VARCHAR,
            h.observaciones,
            h.created_at,
            h.updated_at
        FROM comun.h_catastro h
        WHERE h.id = p_id
          AND h.deleted_at IS NULL;
    ELSE
        -- Búsqueda por combinación de campos
        RETURN QUERY
        SELECT
            h.id,
            h.cvecuenta,
            h.axocomp,
            h.nocomp,
            h.tipo_movimiento::VARCHAR,
            h.fecha_registro,
            h.usuario::VARCHAR,
            h.observaciones,
            h.created_at,
            h.updated_at
        FROM comun.h_catastro h
        WHERE h.cvecuenta = p_cvecuenta
          AND h.axocomp = p_axocomp
          AND h.nocomp = p_nocomp
          AND h.deleted_at IS NULL;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener detalle del registro: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION comun.sp_reghfrm_get_record_detail(BIGINT, INTEGER, INTEGER, INTEGER) IS
'Obtiene el detalle completo de un registro histórico por ID o por combinación cvecuenta+axocomp+nocomp';

-- =====================================================================================
-- SP 3: sp_reghfrm_create_record
-- Descripción: Crear nuevo registro histórico
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.sp_reghfrm_create_record(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_reghfrm_create_record(
    p_cvecuenta INTEGER,
    p_axocomp INTEGER,
    p_nocomp INTEGER,
    p_tipo_movimiento VARCHAR(50) DEFAULT NULL,
    p_usuario VARCHAR(50) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
    v_cuenta_existe BOOLEAN;
    v_duplicado_existe BOOLEAN;
BEGIN
    -- Validar parámetros requeridos
    IF p_cvecuenta IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro cvecuenta es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    IF p_axocomp IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro axocomp es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    IF p_nocomp IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro nocomp es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    -- Validar que cvecuenta exista en el catastro (verificar en tabla de cuentas si existe)
    -- Nota: Se asume que existe una tabla de cuentas, si no, se puede omitir esta validación
    BEGIN
        SELECT EXISTS(
            SELECT 1 FROM comun.cuentas WHERE cvecuenta = p_cvecuenta
        ) INTO v_cuenta_existe;
    EXCEPTION
        WHEN undefined_table THEN
            -- Si la tabla no existe, asumimos que la cuenta es válida
            v_cuenta_existe := TRUE;
    END;

    IF NOT COALESCE(v_cuenta_existe, TRUE) THEN
        RETURN QUERY SELECT FALSE, 'La cuenta catastral no existe'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    -- Validar que no exista duplicado (cvecuenta + axocomp + nocomp)
    SELECT EXISTS(
        SELECT 1 FROM comun.h_catastro
        WHERE cvecuenta = p_cvecuenta
          AND axocomp = p_axocomp
          AND nocomp = p_nocomp
          AND deleted_at IS NULL
    ) INTO v_duplicado_existe;

    IF v_duplicado_existe THEN
        RETURN QUERY SELECT FALSE,
            FORMAT('Ya existe un registro para la cuenta %s, año %s, componente %s',
                   p_cvecuenta, p_axocomp, p_nocomp)::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Insertar nuevo registro
    INSERT INTO comun.h_catastro (
        cvecuenta,
        axocomp,
        nocomp,
        tipo_movimiento,
        fecha_registro,
        usuario,
        observaciones,
        created_at
    ) VALUES (
        p_cvecuenta,
        p_axocomp,
        p_nocomp,
        COALESCE(p_tipo_movimiento, 'MODIFICACION'),
        NOW(),
        COALESCE(p_usuario, 'SISTEMA'),
        p_observaciones,
        NOW()
    )
    RETURNING comun.h_catastro.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro histórico creado exitosamente'::TEXT, v_new_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT FALSE, 'Error: Ya existe un registro con esos datos'::TEXT, NULL::BIGINT;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, FORMAT('Error al crear registro: %s', SQLERRM)::TEXT, NULL::BIGINT;
END;
$$;

COMMENT ON FUNCTION comun.sp_reghfrm_create_record(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT) IS
'Crea un nuevo registro histórico validando existencia de cuenta y duplicados';

-- =====================================================================================
-- SP 4: sp_reghfrm_update_record
-- Descripción: Actualizar registro histórico existente
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.sp_reghfrm_update_record(BIGINT, VARCHAR, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_reghfrm_update_record(
    p_id BIGINT,
    p_tipo_movimiento VARCHAR(50) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_registro_existe BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Validar parámetro requerido
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro id es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validar que el registro exista
    SELECT EXISTS(
        SELECT 1 FROM comun.h_catastro
        WHERE id = p_id
          AND deleted_at IS NULL
    ) INTO v_registro_existe;

    IF NOT v_registro_existe THEN
        RETURN QUERY SELECT FALSE, FORMAT('No existe el registro con id %s', p_id)::TEXT;
        RETURN;
    END IF;

    -- Actualizar registro
    UPDATE comun.h_catastro
    SET
        tipo_movimiento = COALESCE(p_tipo_movimiento, tipo_movimiento),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario = COALESCE(p_usuario, usuario),
        updated_at = NOW()
    WHERE id = p_id
      AND deleted_at IS NULL;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo actualizar el registro'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, FORMAT('Error al actualizar registro: %s', SQLERRM)::TEXT;
END;
$$;

COMMENT ON FUNCTION comun.sp_reghfrm_update_record(BIGINT, VARCHAR, TEXT, VARCHAR) IS
'Actualiza un registro histórico existente validando su existencia';

-- =====================================================================================
-- SP 5: sp_reghfrm_delete_record
-- Descripción: Eliminar registro histórico (soft delete con bitácora)
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.sp_reghfrm_delete_record(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_reghfrm_delete_record(
    p_id BIGINT,
    p_usuario VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_registro_existe BOOLEAN;
    v_rows_affected INTEGER;
    v_registro_info RECORD;
BEGIN
    -- Validar parámetro requerido
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro id es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validar que el registro exista
    SELECT EXISTS(
        SELECT 1 FROM comun.h_catastro
        WHERE id = p_id
          AND deleted_at IS NULL
    ) INTO v_registro_existe;

    IF NOT v_registro_existe THEN
        RETURN QUERY SELECT FALSE, FORMAT('No existe el registro con id %s o ya fue eliminado', p_id)::TEXT;
        RETURN;
    END IF;

    -- Obtener información del registro para bitácora
    SELECT cvecuenta, axocomp, nocomp
    INTO v_registro_info
    FROM comun.h_catastro
    WHERE id = p_id;

    -- Soft delete: marcar como eliminado y registrar quién lo eliminó
    UPDATE comun.h_catastro
    SET
        deleted_at = NOW(),
        deleted_by = COALESCE(p_usuario, 'SISTEMA'),
        updated_at = NOW()
    WHERE id = p_id
      AND deleted_at IS NULL;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Registrar en bitácora si existe la tabla
    BEGIN
        INSERT INTO comun.bitacora_operaciones (
            tabla,
            operacion,
            registro_id,
            usuario,
            fecha,
            detalle
        ) VALUES (
            'h_catastro',
            'DELETE',
            p_id,
            COALESCE(p_usuario, 'SISTEMA'),
            NOW(),
            FORMAT('Eliminado registro histórico: cuenta=%s, año=%s, comp=%s',
                   v_registro_info.cvecuenta, v_registro_info.axocomp, v_registro_info.nocomp)
        );
    EXCEPTION
        WHEN undefined_table THEN
            -- Si no existe la tabla de bitácora, continuar sin error
            NULL;
    END;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE,
            FORMAT('Registro eliminado exitosamente por usuario %s', COALESCE(p_usuario, 'SISTEMA'))::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo eliminar el registro'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, FORMAT('Error al eliminar registro: %s', SQLERRM)::TEXT;
END;
$$;

COMMENT ON FUNCTION comun.sp_reghfrm_delete_record(BIGINT, VARCHAR) IS
'Elimina (soft delete) un registro histórico y registra en bitácora quién lo eliminó';

-- =====================================================================================
-- PASO 2: CREAR TABLA DE BITÁCORA SI NO EXISTE (Para el delete)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS comun.bitacora_operaciones (
    id BIGSERIAL PRIMARY KEY,
    tabla VARCHAR(100),
    operacion VARCHAR(20),
    registro_id BIGINT,
    usuario VARCHAR(50),
    fecha TIMESTAMP DEFAULT NOW(),
    detalle TEXT
);

CREATE INDEX IF NOT EXISTS idx_bitacora_tabla ON comun.bitacora_operaciones(tabla);
CREATE INDEX IF NOT EXISTS idx_bitacora_fecha ON comun.bitacora_operaciones(fecha);

COMMENT ON TABLE comun.bitacora_operaciones IS 'Tabla de bitácora para registrar operaciones sobre tablas';

-- =====================================================================================
-- VERIFICACIONES
-- =====================================================================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE '=========================================================';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES - REGHFRM';
    RAISE NOTICE '=========================================================';

    -- Verificar tabla h_catastro
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'comun' AND table_name = 'h_catastro';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] Tabla comun.h_catastro existe';
    ELSE
        RAISE NOTICE '[ERROR] Tabla comun.h_catastro NO existe';
    END IF;

    -- Verificar SP 1
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun' AND routine_name = 'sp_reghfrm_get_historic_records';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] SP comun.sp_reghfrm_get_historic_records existe';
    ELSE
        RAISE NOTICE '[ERROR] SP comun.sp_reghfrm_get_historic_records NO existe';
    END IF;

    -- Verificar SP 2
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun' AND routine_name = 'sp_reghfrm_get_record_detail';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] SP comun.sp_reghfrm_get_record_detail existe';
    ELSE
        RAISE NOTICE '[ERROR] SP comun.sp_reghfrm_get_record_detail NO existe';
    END IF;

    -- Verificar SP 3
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun' AND routine_name = 'sp_reghfrm_create_record';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] SP comun.sp_reghfrm_create_record existe';
    ELSE
        RAISE NOTICE '[ERROR] SP comun.sp_reghfrm_create_record NO existe';
    END IF;

    -- Verificar SP 4
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun' AND routine_name = 'sp_reghfrm_update_record';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] SP comun.sp_reghfrm_update_record existe';
    ELSE
        RAISE NOTICE '[ERROR] SP comun.sp_reghfrm_update_record NO existe';
    END IF;

    -- Verificar SP 5
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun' AND routine_name = 'sp_reghfrm_delete_record';

    IF v_count > 0 THEN
        RAISE NOTICE '[OK] SP comun.sp_reghfrm_delete_record existe';
    ELSE
        RAISE NOTICE '[ERROR] SP comun.sp_reghfrm_delete_record NO existe';
    END IF;

    RAISE NOTICE '=========================================================';
    RAISE NOTICE 'VERIFICACIÓN COMPLETADA';
    RAISE NOTICE '=========================================================';
END;
$$;

-- =====================================================================================
-- EJEMPLOS DE USO
-- =====================================================================================

/*
-- Ejemplo 1: Obtener registros históricos de una cuenta
SELECT * FROM comun.sp_reghfrm_get_historic_records(12345);

-- Ejemplo 2: Obtener detalle por ID
SELECT * FROM comun.sp_reghfrm_get_record_detail(p_id := 1);

-- Ejemplo 3: Obtener detalle por combinación de campos
SELECT * FROM comun.sp_reghfrm_get_record_detail(
    p_cvecuenta := 12345,
    p_axocomp := 2024,
    p_nocomp := 1
);

-- Ejemplo 4: Crear nuevo registro
SELECT * FROM comun.sp_reghfrm_create_record(
    p_cvecuenta := 12345,
    p_axocomp := 2024,
    p_nocomp := 1,
    p_tipo_movimiento := 'ALTA',
    p_usuario := 'admin',
    p_observaciones := 'Registro inicial de la cuenta'
);

-- Ejemplo 5: Actualizar registro
SELECT * FROM comun.sp_reghfrm_update_record(
    p_id := 1,
    p_tipo_movimiento := 'MODIFICACION',
    p_observaciones := 'Actualización de datos',
    p_usuario := 'admin'
);

-- Ejemplo 6: Eliminar registro
SELECT * FROM comun.sp_reghfrm_delete_record(
    p_id := 1,
    p_usuario := 'admin'
);
*/

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
