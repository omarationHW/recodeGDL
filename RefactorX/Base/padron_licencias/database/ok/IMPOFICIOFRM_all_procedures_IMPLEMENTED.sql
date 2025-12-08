-- ============================================
-- STORED PROCEDURES - IMPOFICIOFRM
-- Módulo: padron_licencias
-- Componente: ImpOficiofrm (Impresión de Oficios)
-- Schema: comun
-- ============================================
-- Descripción: Formulario para impresión de oficios relacionados
--              con trámites improcedentes. Permite seleccionar el
--              tipo de oficio y registrar la decisión en bitácora.
-- ============================================
-- Total SPs: 3
-- Fecha: 2025-11-20
-- ============================================

-- ============================================
-- SP 1/3: sp_imp_oficio_get_tramite_info
-- Tipo: CONSULTA
-- Descripción: Obtiene información básica de un trámite para el formulario de impresión de oficios
-- Parámetros:
--   p_id_tramite: ID del trámite a consultar
-- Retorna: Información completa del trámite incluyendo empresa, giro, ubicación
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_imp_oficio_get_tramite_info(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    numero_tramite VARCHAR,
    tipo_tramite VARCHAR,
    propietario VARCHAR,
    razon_social VARCHAR,
    rfc VARCHAR,
    giro VARCHAR,
    actividad VARCHAR,
    ubicacion TEXT,
    domicilio_completo TEXT,
    estatus VARCHAR,
    fecha_captura TIMESTAMP,
    fecha_impresion TIMESTAMP,
    id_empresa INTEGER,
    id_giro INTEGER,
    id_licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.numero_tramite,
        t.tipo_tramite,
        t.propietario,
        COALESCE(e.razon_social, t.propietario) as razon_social,
        COALESCE(e.rfc, t.rfc) as rfc,
        g.descripcion as giro,
        t.actividad,
        t.ubicacion,
        TRIM(
            COALESCE(t.ubicacion, '') || ' ' ||
            CASE WHEN t.numext_ubic IS NOT NULL
                 THEN '#' || t.numext_ubic::TEXT
                 ELSE ''
            END
        ) as domicilio_completo,
        t.estatus,
        t.feccap as fecha_captura,
        NOW() as fecha_impresion,
        t.id_empresa,
        t.id_giro,
        t.id_licencia
    FROM comun.tramites t
    LEFT JOIN comun.empresas e ON t.id_empresa = e.id_empresa
    LEFT JOIN comun.c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_oficio_get_tramite_info(INTEGER) IS
'Obtiene información básica del trámite para formulario de impresión de oficios - ImpOficiofrm';


-- ============================================
-- SP 2/3: sp_imp_oficio_tramite_info
-- Tipo: CONSULTA EXTENDIDA
-- Descripción: Obtiene información extendida del trámite con todos los detalles
--              necesarios para generar el oficio (empresa, representante, etc)
-- Parámetros:
--   p_id_tramite: ID del trámite
-- Retorna: Información detallada del trámite con datos relacionados
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_imp_oficio_tramite_info(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    numero_tramite VARCHAR,
    tipo_tramite VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    nombre_completo TEXT,
    razon_social VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    giro_codigo VARCHAR,
    giro_descripcion VARCHAR,
    actividad VARCHAR,
    ubicacion TEXT,
    colonia VARCHAR,
    codigo_postal VARCHAR,
    numext_ubic VARCHAR,
    numint_ubic VARCHAR,
    domicilio_completo TEXT,
    telefono VARCHAR,
    email VARCHAR,
    estatus VARCHAR,
    fecha_captura TIMESTAMP,
    fecha_autorizacion TIMESTAMP,
    usuario_captura VARCHAR,
    observaciones TEXT,
    id_empresa INTEGER,
    id_giro INTEGER,
    id_licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.numero_tramite,
        t.tipo_tramite,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        TRIM(
            COALESCE(t.propietario, '') || ' ' ||
            COALESCE(t.primer_ap, '') || ' ' ||
            COALESCE(t.segundo_ap, '')
        ) as nombre_completo,
        e.razon_social,
        COALESCE(e.rfc, t.rfc) as rfc,
        t.curp,
        g.codigo as giro_codigo,
        g.descripcion as giro_descripcion,
        t.actividad,
        t.ubicacion,
        t.colonia,
        t.codigo_postal,
        t.numext_ubic,
        t.numint_ubic,
        TRIM(
            COALESCE(t.ubicacion, '') || ' ' ||
            CASE WHEN t.numext_ubic IS NOT NULL
                 THEN '#' || t.numext_ubic
                 ELSE ''
            END ||
            CASE WHEN t.numint_ubic IS NOT NULL
                 THEN ' INT.' || t.numint_ubic
                 ELSE ''
            END ||
            CASE WHEN t.colonia IS NOT NULL
                 THEN ', COL. ' || t.colonia
                 ELSE ''
            END ||
            CASE WHEN t.codigo_postal IS NOT NULL
                 THEN ', C.P. ' || t.codigo_postal
                 ELSE ''
            END
        ) as domicilio_completo,
        t.telefono,
        t.email,
        t.estatus,
        t.feccap as fecha_captura,
        t.fecha_autorizacion,
        u.nombre as usuario_captura,
        t.observaciones,
        t.id_empresa,
        t.id_giro,
        t.id_licencia
    FROM comun.tramites t
    LEFT JOIN comun.empresas e ON t.id_empresa = e.id_empresa
    LEFT JOIN comun.c_giros g ON t.id_giro = g.id_giro
    LEFT JOIN comun.usuarios u ON t.usuario_captura = u.usuario
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_oficio_tramite_info(INTEGER) IS
'Obtiene información extendida del trámite para generación de oficios - ImpOficiofrm';


-- ============================================
-- SP 3/3: sp_imp_oficio_register
-- Tipo: CRUD (INSERT)
-- Descripción: Registra la decisión del usuario sobre el tipo de oficio a imprimir
--              para un trámite improcedente en la tabla de bitácora
-- Parámetros:
--   p_id_tramite: ID del trámite
--   p_tipo_oficio: Tipo de oficio (1=Uno, 2=Dos, 3=M24BIS, 4=Informativo)
--   p_id_usuario: ID del usuario que registra
--   p_observaciones: Observaciones opcionales
-- Retorna: Mensaje de confirmación con el tipo de oficio registrado
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_imp_oficio_register(
    p_id_tramite INTEGER,
    p_tipo_oficio INTEGER,
    p_id_usuario INTEGER,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_registro INTEGER,
    tipo_oficio_label TEXT
) AS $$
DECLARE
    v_tipo_oficio_label TEXT;
    v_id_registro INTEGER;
    v_tramite_exists BOOLEAN;
BEGIN
    -- Validar que el trámite existe
    SELECT EXISTS(
        SELECT 1 FROM comun.tramites WHERE id_tramite = p_id_tramite
    ) INTO v_tramite_exists;

    IF NOT v_tramite_exists THEN
        RETURN QUERY SELECT
            FALSE as success,
            'El trámite especificado no existe' as message,
            NULL::INTEGER as id_registro,
            NULL::TEXT as tipo_oficio_label;
        RETURN;
    END IF;

    -- Validar tipo de oficio
    IF p_tipo_oficio NOT IN (1, 2, 3, 4) THEN
        RETURN QUERY SELECT
            FALSE as success,
            'Tipo de oficio inválido. Debe ser 1, 2, 3 o 4' as message,
            NULL::INTEGER as id_registro,
            NULL::TEXT as tipo_oficio_label;
        RETURN;
    END IF;

    -- Determinar el label del tipo de oficio
    v_tipo_oficio_label := CASE p_tipo_oficio
        WHEN 1 THEN 'Uno'
        WHEN 2 THEN 'Dos'
        WHEN 3 THEN 'M24BIS'
        WHEN 4 THEN 'Informativo'
    END;

    -- Crear la tabla de bitácora si no existe
    CREATE TABLE IF NOT EXISTS comun.imp_oficio_bitacora (
        id SERIAL PRIMARY KEY,
        id_tramite INTEGER NOT NULL,
        tipo_oficio INTEGER NOT NULL,
        tipo_oficio_label VARCHAR(50) NOT NULL,
        id_usuario INTEGER NOT NULL,
        observaciones TEXT,
        fecha_registro TIMESTAMP DEFAULT NOW(),
        CONSTRAINT fk_imp_oficio_tramite
            FOREIGN KEY (id_tramite)
            REFERENCES comun.tramites(id_tramite)
            ON DELETE CASCADE
    );

    -- Crear índice si no existe
    CREATE INDEX IF NOT EXISTS idx_imp_oficio_bitacora_tramite
        ON comun.imp_oficio_bitacora(id_tramite);
    CREATE INDEX IF NOT EXISTS idx_imp_oficio_bitacora_fecha
        ON comun.imp_oficio_bitacora(fecha_registro);

    -- Registrar la decisión en la bitácora
    INSERT INTO comun.imp_oficio_bitacora(
        id_tramite,
        tipo_oficio,
        tipo_oficio_label,
        id_usuario,
        observaciones,
        fecha_registro
    )
    VALUES (
        p_id_tramite,
        p_tipo_oficio,
        v_tipo_oficio_label,
        p_id_usuario,
        p_observaciones,
        NOW()
    )
    RETURNING id INTO v_id_registro;

    -- Actualizar el estatus del trámite
    UPDATE comun.tramites
    SET estatus = 'IMPROCEDENTE',
        fecha_actualizacion = NOW()
    WHERE id_tramite = p_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE as success,
        'Oficio registrado correctamente: ' || v_tipo_oficio_label as message,
        v_id_registro as id_registro,
        v_tipo_oficio_label as tipo_oficio_label;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE as success,
            'Error al registrar el oficio: ' || SQLERRM as message,
            NULL::INTEGER as id_registro,
            NULL::TEXT as tipo_oficio_label;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_oficio_register(INTEGER, INTEGER, INTEGER, TEXT) IS
'Registra la decisión de impresión de oficio en la bitácora - ImpOficiofrm';


-- ============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
    AND p.proname IN (
        'sp_imp_oficio_get_tramite_info',
        'sp_imp_oficio_tramite_info',
        'sp_imp_oficio_register'
    );

    IF v_count = 3 THEN
        RAISE NOTICE '✓ Las 3 funciones de ImpOficiofrm fueron creadas exitosamente en schema comun';
    ELSE
        RAISE WARNING '⚠ Solo se crearon % de 3 funciones esperadas', v_count;
    END IF;
END $$;

-- ============================================
-- TABLA DE BITÁCORA (Definición)
-- ============================================
-- Nota: La tabla se crea automáticamente en sp_imp_oficio_register
-- pero aquí está la definición completa para referencia:

/*
CREATE TABLE IF NOT EXISTS comun.imp_oficio_bitacora (
    id SERIAL PRIMARY KEY,
    id_tramite INTEGER NOT NULL,
    tipo_oficio INTEGER NOT NULL CHECK (tipo_oficio IN (1,2,3,4)),
    tipo_oficio_label VARCHAR(50) NOT NULL,
    id_usuario INTEGER NOT NULL,
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_imp_oficio_tramite
        FOREIGN KEY (id_tramite)
        REFERENCES comun.tramites(id_tramite)
        ON DELETE CASCADE
);

CREATE INDEX idx_imp_oficio_bitacora_tramite ON comun.imp_oficio_bitacora(id_tramite);
CREATE INDEX idx_imp_oficio_bitacora_fecha ON comun.imp_oficio_bitacora(fecha_registro);
CREATE INDEX idx_imp_oficio_bitacora_usuario ON comun.imp_oficio_bitacora(id_usuario);

COMMENT ON TABLE comun.imp_oficio_bitacora IS
'Bitácora de impresiones de oficios para trámites improcedentes';
COMMENT ON COLUMN comun.imp_oficio_bitacora.tipo_oficio IS
'1=Uno, 2=Dos, 3=M24BIS, 4=Informativo';
*/

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- Ejemplo 1: Obtener información básica de un trámite
SELECT * FROM comun.sp_imp_oficio_get_tramite_info(123);

-- Ejemplo 2: Obtener información extendida del trámite
SELECT * FROM comun.sp_imp_oficio_tramite_info(123);

-- Ejemplo 3: Registrar impresión de oficio tipo "Uno"
SELECT * FROM comun.sp_imp_oficio_register(
    p_id_tramite := 123,
    p_tipo_oficio := 1,
    p_id_usuario := 45,
    p_observaciones := 'Trámite rechazado por falta de documentación'
);

-- Ejemplo 4: Registrar oficio tipo "M24BIS" sin observaciones
SELECT * FROM comun.sp_imp_oficio_register(123, 3, 45);

-- Ejemplo 5: Consultar historial de oficios de un trámite
SELECT
    id,
    tipo_oficio_label,
    id_usuario,
    observaciones,
    fecha_registro
FROM comun.imp_oficio_bitacora
WHERE id_tramite = 123
ORDER BY fecha_registro DESC;

-- Ejemplo 6: Estadísticas de oficios por tipo
SELECT
    tipo_oficio_label,
    COUNT(*) as total,
    COUNT(DISTINCT id_tramite) as tramites_unicos
FROM comun.imp_oficio_bitacora
GROUP BY tipo_oficio_label
ORDER BY total DESC;
*/

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
