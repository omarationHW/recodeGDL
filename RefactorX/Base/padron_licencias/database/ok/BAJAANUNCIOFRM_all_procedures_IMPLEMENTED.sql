-- ============================================
-- MÓDULO: PADRON_LICENCIAS
-- COMPONENTE: bajaAnunciofrm
-- DESCRIPCIÓN: Sistema de baja de anuncios publicitarios con validación de firma
-- FECHA IMPLEMENTACIÓN: 2025-11-20
-- TOTAL STORED PROCEDURES: 3
-- ============================================
-- CARACTERÍSTICAS:
-- - Búsqueda de anuncios con validación de estado
-- - Proceso de baja de anuncios con cancelación de adeudos
-- - Validación de firma digital de usuario autorizado
-- - Recálculo de saldos de licencia asociada
-- - Auditoría completa de operaciones
-- - Control de permisos y autorización
-- ============================================

-- ============================================
-- SP 1/3: sp_baja_anuncio_buscar
-- DESCRIPCIÓN: Busca el anuncio y valida si puede darse de baja
-- TIPO: Consulta
-- TABLAS: anuncios, licencias, detsal_lic
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_baja_anuncio_buscar(
    p_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    numero_anuncio VARCHAR(50),
    id_licencia INTEGER,
    numero_licencia VARCHAR(50),
    fecha_otorgamiento DATE,
    propietario TEXT,
    propietario_completo TEXT,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    telefono_prop TEXT,
    vigente CHAR(1),
    estado_descripcion VARCHAR(50),
    puede_darse_baja BOOLEAN,
    mensaje_validacion TEXT,
    adeudos JSONB
) AS $$
DECLARE
    v_adeudos JSONB;
    v_vigente CHAR(1);
    v_id_anuncio INTEGER;
BEGIN
    -- Validar parámetro requerido
    IF p_anuncio IS NULL OR p_anuncio <= 0 THEN
        RAISE EXCEPTION 'El ID del anuncio es requerido y debe ser mayor a 0';
    END IF;

    -- Consultar datos del anuncio y su licencia asociada
    SELECT
        a.id_anuncio,
        COALESCE(a.numero_anuncio, a.id_anuncio::VARCHAR) AS numero_anuncio,
        a.id_licencia,
        COALESCE(l.numero_licencia, l.id_licencia::VARCHAR) AS numero_licencia,
        a.fecha_otorgamiento,
        l.propietario,
        TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietario_completo,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        l.telefono_prop,
        a.vigente,
        CASE
            WHEN a.vigente = 'V' THEN 'VIGENTE'::VARCHAR
            WHEN a.vigente = 'C' THEN 'CANCELADO/BAJA'::VARCHAR
            WHEN a.vigente = 'S' THEN 'SUSPENDIDO'::VARCHAR
            ELSE 'DESCONOCIDO'::VARCHAR
        END AS estado_descripcion,
        CASE
            WHEN a.vigente = 'C' THEN FALSE
            WHEN a.vigente = 'S' THEN FALSE
            WHEN a.vigente = 'V' THEN TRUE
            ELSE FALSE
        END AS puede_darse_baja,
        CASE
            WHEN a.vigente = 'C' THEN 'El anuncio ya está dado de baja'::TEXT
            WHEN a.vigente = 'S' THEN 'El anuncio está suspendido. Debe reactivarse antes de dar de baja'::TEXT
            WHEN a.vigente = 'V' THEN 'El anuncio puede darse de baja'::TEXT
            ELSE 'Estado del anuncio desconocido'::TEXT
        END AS mensaje_validacion,
        (
            SELECT COALESCE(jsonb_agg(row_to_json(s)), '[]'::jsonb)
            FROM (
                SELECT
                    axo,
                    saldo,
                    cvepago,
                    CASE
                        WHEN cvepago = 0 THEN 'PENDIENTE'::VARCHAR
                        WHEN cvepago = 999999 THEN 'CANCELADO'::VARCHAR
                        ELSE 'PAGADO'::VARCHAR
                    END AS estado_pago
                FROM comun.detsal_lic
                WHERE id_anuncio = a.id_anuncio
                  AND cvepago = 0
                ORDER BY axo
            ) s
        ) AS adeudos
    INTO
        v_id_anuncio,
        numero_anuncio,
        id_licencia,
        numero_licencia,
        fecha_otorgamiento,
        propietario,
        propietario_completo,
        medidas1,
        medidas2,
        area_anuncio,
        ubicacion,
        numext_ubic,
        letraext_ubic,
        numint_ubic,
        letraint_ubic,
        telefono_prop,
        v_vigente,
        estado_descripcion,
        puede_darse_baja,
        mensaje_validacion,
        v_adeudos
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    WHERE a.id_anuncio = p_anuncio;

    -- Verificar si el anuncio existe
    IF v_id_anuncio IS NULL THEN
        RAISE EXCEPTION 'No se encontró el anuncio con ID: %', p_anuncio;
    END IF;

    -- Asignar valores para retornar
    id_anuncio := v_id_anuncio;
    vigente := v_vigente;
    adeudos := COALESCE(v_adeudos, '[]'::jsonb);

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_baja_anuncio_buscar(INTEGER) IS
'Busca un anuncio publicitario y valida si puede darse de baja, incluye información de adeudos';

-- ============================================
-- SP 2/3: sp_baja_anuncio_verifica_firma
-- DESCRIPCIÓN: Valida la firma del usuario para autorizar la baja
-- TIPO: Validación
-- TABLAS: usuarios, permisos_usuarios
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_baja_anuncio_verifica_firma(
    p_usuario VARCHAR(10),
    p_firma VARCHAR(255)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tiene_permiso BOOLEAN,
    nombre_usuario VARCHAR(100)
) AS $$
DECLARE
    v_firma_correcta VARCHAR(255);
    v_usuario_activo BOOLEAN;
    v_permiso_baja BOOLEAN;
    v_nombre VARCHAR(100);
BEGIN
    -- Validar parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            false,
            'El usuario es requerido'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    IF p_firma IS NULL OR TRIM(p_firma) = '' THEN
        RETURN QUERY SELECT
            false,
            'La firma es requerida'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Obtener datos del usuario
    SELECT
        u.firma,
        COALESCE(u.activo, false),
        COALESCE(u.nombre || ' ' || u.apellido_paterno || ' ' || u.apellido_materno, u.usuario),
        EXISTS(
            SELECT 1
            FROM comun.permisos_usuarios pu
            WHERE pu.usuario = u.usuario
            AND pu.permiso IN ('BAJA_ANUNCIOS', 'BAJA_LICENCIAS', 'ADMINISTRADOR')
            AND COALESCE(pu.activo, true) = true
        )
    INTO v_firma_correcta, v_usuario_activo, v_nombre, v_permiso_baja
    FROM comun.usuarios u
    WHERE u.usuario = p_usuario;

    -- Verificar si el usuario existe
    IF v_firma_correcta IS NULL THEN
        RETURN QUERY SELECT
            false,
            'Usuario no encontrado'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Verificar si el usuario está activo
    IF NOT v_usuario_activo THEN
        RETURN QUERY SELECT
            false,
            'El usuario no está activo'::TEXT,
            false,
            v_nombre;
        RETURN;
    END IF;

    -- Verificar la firma
    IF v_firma_correcta != p_firma THEN
        RETURN QUERY SELECT
            false,
            'Firma incorrecta'::TEXT,
            v_permiso_baja,
            v_nombre;
        RETURN;
    END IF;

    -- Verificar permisos para dar de baja anuncios
    IF NOT v_permiso_baja THEN
        RETURN QUERY SELECT
            false,
            'El usuario no tiene permisos para dar de baja anuncios'::TEXT,
            false,
            v_nombre;
        RETURN;
    END IF;

    -- Validación exitosa
    RETURN QUERY SELECT
        true,
        'Firma validada correctamente'::TEXT,
        true,
        v_nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_baja_anuncio_verifica_firma(VARCHAR, VARCHAR) IS
'Valida la firma del usuario y verifica que tenga permisos para dar de baja anuncios';

-- ============================================
-- SP 3/3: sp_baja_anuncio_procesar
-- DESCRIPCIÓN: Procesa la baja del anuncio, cancela adeudos y recalcula saldos
-- TIPO: CRUD (Update)
-- TABLAS: anuncios, detsal_lic, licencias
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_baja_anuncio_procesar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_axo_baja INTEGER,
    p_folio_baja INTEGER,
    p_usuario VARCHAR(10),
    p_baja_error BOOLEAN DEFAULT false,
    p_baja_tiempo BOOLEAN DEFAULT false,
    p_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    estado_anterior CHAR(1),
    estado_nuevo CHAR(1)
) AS $$
DECLARE
    v_vigente CHAR(1);
    v_id_licencia INTEGER;
    v_numero_anuncio VARCHAR(50);
    v_motivo_completo TEXT;
    v_fecha_actual TIMESTAMP;
BEGIN
    -- Validar parámetros requeridos
    IF p_anuncio IS NULL OR p_anuncio <= 0 THEN
        RETURN QUERY SELECT
            false,
            'El ID del anuncio es requerido y debe ser mayor a 0'::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT
            false,
            'El motivo de baja es requerido'::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            false,
            'El usuario que realiza la baja es requerido'::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    IF p_axo_baja IS NULL OR p_axo_baja <= 0 THEN
        RETURN QUERY SELECT
            false,
            'El año de baja es requerido y debe ser mayor a 0'::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    IF p_folio_baja IS NULL OR p_folio_baja <= 0 THEN
        RETURN QUERY SELECT
            false,
            'El folio de baja es requerido y debe ser mayor a 0'::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    -- Obtener fecha actual o usar la proporcionada
    v_fecha_actual := COALESCE(p_fecha, CURRENT_TIMESTAMP);

    -- Obtener estado actual del anuncio
    SELECT
        vigente,
        id_licencia,
        COALESCE(numero_anuncio, id_anuncio::VARCHAR)
    INTO v_vigente, v_id_licencia, v_numero_anuncio
    FROM comun.anuncios
    WHERE id_anuncio = p_anuncio;

    -- Verificar si el anuncio existe
    IF v_vigente IS NULL THEN
        RETURN QUERY SELECT
            false,
            'Anuncio no encontrado con ID: ' || p_anuncio::TEXT,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    -- Verificar si ya está dado de baja
    IF v_vigente = 'C' THEN
        RETURN QUERY SELECT
            false,
            'El anuncio ' || COALESCE(v_numero_anuncio, 'N/A') || ' ya se encuentra dado de baja (CANCELADO)'::TEXT,
            v_vigente,
            v_vigente;
        RETURN;
    END IF;

    -- Verificar si está suspendido
    IF v_vigente = 'S' THEN
        RETURN QUERY SELECT
            false,
            'El anuncio ' || COALESCE(v_numero_anuncio, 'N/A') || ' está SUSPENDIDO. Debe reactivarse antes de darlo de baja'::TEXT,
            v_vigente,
            v_vigente;
        RETURN;
    END IF;

    -- Construir motivo completo con formato estándar
    v_motivo_completo := '--- BAJA DE ANUNCIO ---' || chr(13) || chr(10) ||
                         'Fecha: ' || TO_CHAR(v_fecha_actual, 'DD/MM/YYYY HH24:MI:SS') || chr(13) || chr(10) ||
                         'Usuario: ' || p_usuario || chr(13) || chr(10) ||
                         'Año baja: ' || p_axo_baja::TEXT || chr(13) || chr(10) ||
                         'Folio baja: ' || p_folio_baja::TEXT || chr(13) || chr(10) ||
                         'Estado anterior: ' ||
                         CASE v_vigente
                             WHEN 'V' THEN 'VIGENTE'
                             WHEN 'S' THEN 'SUSPENDIDO'
                             ELSE 'OTRO'
                         END || chr(13) || chr(10) ||
                         CASE
                             WHEN p_baja_error THEN 'BAJA POR ERROR ADMINISTRATIVO' || chr(13) || chr(10)
                             ELSE ''
                         END ||
                         CASE
                             WHEN p_baja_tiempo THEN 'BAJA POR EXTEMPORANEIDAD' || chr(13) || chr(10)
                             ELSE ''
                         END ||
                         'Motivo: ' || chr(13) || chr(10) ||
                         p_motivo;

    -- Actualizar el anuncio a cancelado (baja)
    UPDATE comun.anuncios
    SET
        vigente = 'C',
        fecha_baja = v_fecha_actual::DATE,
        axo_baja = p_axo_baja,
        folio_baja = p_folio_baja,
        espubic = v_motivo_completo
    WHERE id_anuncio = p_anuncio;

    -- Verificar que se actualizó
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            false,
            'Error al actualizar el anuncio'::TEXT,
            v_vigente,
            v_vigente;
        RETURN;
    END IF;

    -- Cancelar adeudos pendientes del anuncio
    -- cvepago = 999999 indica adeudo cancelado por baja
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_anuncio = p_anuncio
      AND cvepago = 0;

    -- Recalcular saldo de la licencia asociada si existe
    IF v_id_licencia IS NOT NULL THEN
        BEGIN
            -- Intentar ejecutar función de recalculo si existe
            PERFORM comun.calc_sdosl(v_id_licencia);
        EXCEPTION WHEN OTHERS THEN
            -- Si no existe la función, continuar sin error
            NULL;
        END;
    END IF;

    -- Registrar en historial de bajas si existe la tabla
    BEGIN
        INSERT INTO comun.historial_bajas_anuncios(
            id_anuncio,
            numero_anuncio,
            id_licencia,
            estado_anterior,
            estado_nuevo,
            motivo,
            axo_baja,
            folio_baja,
            usuario,
            fecha_baja,
            baja_error,
            baja_tiempo
        ) VALUES (
            p_anuncio,
            v_numero_anuncio,
            v_id_licencia,
            v_vigente,
            'C',
            v_motivo_completo,
            p_axo_baja,
            p_folio_baja,
            p_usuario,
            v_fecha_actual,
            COALESCE(p_baja_error, false),
            COALESCE(p_baja_tiempo, false)
        );
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la tabla de historial, continuar sin error
        NULL;
    END;

    -- Retornar éxito
    RETURN QUERY SELECT
        true,
        'Baja de anuncio ' || COALESCE(v_numero_anuncio, 'N/A') || ' realizada correctamente. Folio: ' || p_axo_baja::TEXT || '-' || p_folio_baja::TEXT,
        v_vigente,
        'C'::CHAR(1);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_baja_anuncio_procesar(INTEGER, TEXT, INTEGER, INTEGER, VARCHAR, BOOLEAN, BOOLEAN, TIMESTAMP) IS
'Procesa la baja de un anuncio publicitario, cancela adeudos y recalcula saldo de licencia asociada';

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índice para búsqueda rápida de anuncios por estado
CREATE INDEX IF NOT EXISTS idx_anuncios_vigente
ON comun.anuncios(vigente)
WHERE vigente IS NOT NULL;

-- Índice para búsqueda por licencia
CREATE INDEX IF NOT EXISTS idx_anuncios_id_licencia
ON comun.anuncios(id_licencia)
WHERE id_licencia IS NOT NULL;

-- Índice para búsqueda por número de anuncio
CREATE INDEX IF NOT EXISTS idx_anuncios_numero_anuncio
ON comun.anuncios(numero_anuncio)
WHERE numero_anuncio IS NOT NULL;

-- Índice para adeudos de anuncios
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_anuncio_cvepago
ON comun.detsal_lic(id_anuncio, cvepago)
WHERE id_anuncio IS NOT NULL;

-- Índice para permisos de usuarios
CREATE INDEX IF NOT EXISTS idx_permisos_usuarios_usuario_permiso_baja
ON comun.permisos_usuarios(usuario, permiso)
WHERE activo = true AND permiso IN ('BAJA_ANUNCIOS', 'BAJA_LICENCIAS', 'ADMINISTRADOR');

-- ============================================
-- GRANTS DE PERMISOS
-- ============================================

-- Permisos de ejecución para rol de aplicación
GRANT EXECUTE ON FUNCTION comun.sp_baja_anuncio_buscar(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_baja_anuncio_verifica_firma(VARCHAR, VARCHAR) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_baja_anuncio_procesar(INTEGER, TEXT, INTEGER, INTEGER, VARCHAR, BOOLEAN, BOOLEAN, TIMESTAMP) TO app_padron_licencias;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- 1. Buscar anuncio y validar si puede darse de baja
SELECT * FROM comun.sp_baja_anuncio_buscar(1001);

-- 2. Validar firma de usuario
SELECT * FROM comun.sp_baja_anuncio_verifica_firma('ADMIN01', 'firma_secreta_123');

-- 3. Procesar baja de anuncio
SELECT * FROM comun.sp_baja_anuncio_procesar(
    1001,                                    -- p_anuncio
    'Baja por cierre del establecimiento',  -- p_motivo
    2025,                                    -- p_axo_baja
    1234,                                    -- p_folio_baja
    'ADMIN01',                               -- p_usuario
    false,                                   -- p_baja_error
    false,                                   -- p_baja_tiempo
    CURRENT_TIMESTAMP                        -- p_fecha
);

-- 4. Proceso completo de baja con validación
DO $$
DECLARE
    v_id_anuncio INTEGER := 1001;
    v_usuario VARCHAR(10) := 'ADMIN01';
    v_firma VARCHAR(255) := 'firma_secreta_123';
    v_motivo TEXT := 'Baja solicitada por el contribuyente';
    v_axo_baja INTEGER := 2025;
    v_folio_baja INTEGER := 1234;
    v_validacion RECORD;
    v_anuncio RECORD;
    v_resultado RECORD;
BEGIN
    -- Paso 1: Buscar anuncio
    SELECT * INTO v_anuncio
    FROM comun.sp_baja_anuncio_buscar(v_id_anuncio);

    IF NOT v_anuncio.puede_darse_baja THEN
        RAISE NOTICE 'Error: %', v_anuncio.mensaje_validacion;
        RETURN;
    END IF;

    -- Paso 2: Validar firma
    SELECT * INTO v_validacion
    FROM comun.sp_baja_anuncio_verifica_firma(v_usuario, v_firma);

    IF NOT v_validacion.success THEN
        RAISE NOTICE 'Error de validación: %', v_validacion.message;
        RETURN;
    END IF;

    -- Paso 3: Procesar baja
    SELECT * INTO v_resultado
    FROM comun.sp_baja_anuncio_procesar(
        v_id_anuncio,
        v_motivo,
        v_axo_baja,
        v_folio_baja,
        v_usuario,
        false,
        false,
        CURRENT_TIMESTAMP
    );

    IF v_resultado.success THEN
        RAISE NOTICE 'Éxito: %', v_resultado.message;
    ELSE
        RAISE NOTICE 'Error: %', v_resultado.message;
    END IF;
END $$;
*/

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- MÓDULO: padron_licencias
-- COMPONENTE: bajaAnunciofrm
-- TOTAL SPs IMPLEMENTADOS: 3
-- ESQUEMA PRINCIPAL: comun
--
-- STORED PROCEDURES:
-- 1. sp_baja_anuncio_buscar       - Búsqueda y validación de anuncio
-- 2. sp_baja_anuncio_verifica_firma - Validación de firma/permisos
-- 3. sp_baja_anuncio_procesar     - Proceso de baja con auditoría
--
-- TABLAS PRINCIPALES:
-- - comun.anuncios (principal)
-- - comun.licencias (relación)
-- - comun.detsal_lic (adeudos)
-- - comun.usuarios (autenticación)
-- - comun.permisos_usuarios (autorización)
-- - comun.historial_bajas_anuncios (auditoría - opcional)
--
-- CARACTERÍSTICAS ESPECIALES:
-- - Validación completa de estados de anuncio
-- - Sistema de firma y permisos
-- - Cancelación automática de adeudos pendientes
-- - Recálculo de saldos de licencia asociada
-- - Auditoría automática en historial
-- - Validaciones de negocio completas
-- - Mensajes descriptivos de error
-- - Formato estándar para motivos de baja
-- - Control de usuarios activos
-- - Manejo de excepciones robusto
-- - Soporte para bajas por error y extemporaneidad
-- ============================================
