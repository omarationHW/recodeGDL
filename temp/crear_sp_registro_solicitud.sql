-- =====================================================
-- CREAR SPs PARA REGISTRO DE SOLICITUD
-- Base de datos: padron_licencias
-- Esquema: comun
-- =====================================================

-- 1. SP para registrar solicitud/trámite
CREATE OR REPLACE FUNCTION comun.sp_registro_solicitud(
    p_tipo_tramite INTEGER,
    p_id_giro INTEGER,
    p_actividad VARCHAR,
    p_propietario VARCHAR,
    p_telefono VARCHAR,
    p_email VARCHAR DEFAULT NULL,
    p_calle VARCHAR,
    p_colonia VARCHAR,
    p_cp VARCHAR DEFAULT NULL,
    p_numext VARCHAR DEFAULT NULL,
    p_numint VARCHAR DEFAULT NULL,
    p_letraext VARCHAR DEFAULT NULL,
    p_letraint VARCHAR DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_sup_const NUMERIC(10,2) DEFAULT NULL,
    p_sup_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT NULL,
    p_num_empleados INTEGER DEFAULT NULL,
    p_inversion NUMERIC(15,2) DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_curp VARCHAR DEFAULT NULL,
    p_especificaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio VARCHAR,
    fecha_registro TIMESTAMP,
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_tramite INTEGER;
    v_folio VARCHAR;
    v_fecha TIMESTAMP;
    v_anio INTEGER;
    v_consecutivo INTEGER;
BEGIN
    -- Obtener fecha actual
    v_fecha := NOW();
    v_anio := EXTRACT(YEAR FROM v_fecha);

    -- Generar folio secuencial
    -- Formato: TRAM-YYYY-NNNNNN
    SELECT COALESCE(MAX(CAST(SUBSTRING(folio FROM 11) AS INTEGER)), 0) + 1
    INTO v_consecutivo
    FROM comun.tramites
    WHERE EXTRACT(YEAR FROM fecha_registro) = v_anio;

    v_folio := 'TRAM-' || v_anio || '-' || LPAD(v_consecutivo::TEXT, 6, '0');

    -- Insertar en tabla tramites
    INSERT INTO comun.tramites (
        folio,
        tipo_tramite,
        id_giro,
        actividad,
        propietario,
        telefono,
        email,
        calle,
        colonia,
        cp,
        numext,
        numint,
        letraext,
        letraint,
        zona,
        subzona,
        sup_const,
        sup_autorizada,
        num_cajones,
        num_empleados,
        inversion,
        rfc,
        curp,
        especificaciones,
        estatus,
        fecha_registro,
        usuario_registro
    ) VALUES (
        v_folio,
        p_tipo_tramite,
        p_id_giro,
        p_actividad,
        p_propietario,
        p_telefono,
        p_email,
        p_calle,
        p_colonia,
        p_cp,
        p_numext,
        p_numint,
        p_letraext,
        p_letraint,
        p_zona,
        p_subzona,
        p_sup_const,
        p_sup_autorizada,
        p_num_cajones,
        p_num_empleados,
        p_inversion,
        p_rfc,
        p_curp,
        p_especificaciones,
        'REGISTRADO',
        v_fecha,
        p_usuario
    )
    RETURNING id INTO v_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        v_id_tramite,
        v_folio,
        v_fecha,
        TRUE::BOOLEAN,
        'Solicitud registrada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- Retornar error
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::TIMESTAMP,
            FALSE::BOOLEAN,
            ('Error al registrar solicitud: ' || SQLERRM)::TEXT;
END;
$$;

-- =====================================================
-- 2. SP para agregar documentos a un trámite
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_agregar_documento(
    p_id_tramite INTEGER,
    p_tipo_documento VARCHAR,
    p_nombre_archivo VARCHAR,
    p_ruta_archivo VARCHAR,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE (
    id_documento INTEGER,
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_documento INTEGER;
BEGIN
    -- Insertar documento
    INSERT INTO comun.tramite_documentos (
        id_tramite,
        tipo_documento,
        nombre_archivo,
        ruta_archivo,
        observaciones,
        fecha_carga,
        usuario_carga
    ) VALUES (
        p_id_tramite,
        p_tipo_documento,
        p_nombre_archivo,
        p_ruta_archivo,
        p_observaciones,
        NOW(),
        p_usuario
    )
    RETURNING id INTO v_id_documento;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        v_id_documento,
        TRUE::BOOLEAN,
        'Documento agregado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- Retornar error
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE::BOOLEAN,
            ('Error al agregar documento: ' || SQLERRM)::TEXT;
END;
$$;

-- =====================================================
-- 3. Verificar que las tablas existen
-- =====================================================

-- Comentarios sobre las tablas requeridas:
-- Si las tablas no existen, se deben crear primero:

/*
-- Tabla de trámites
CREATE TABLE IF NOT EXISTS comun.tramites (
    id SERIAL PRIMARY KEY,
    folio VARCHAR(50) UNIQUE NOT NULL,
    tipo_tramite INTEGER NOT NULL,
    id_giro INTEGER NOT NULL,
    actividad VARCHAR(255) NOT NULL,
    propietario VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    calle VARCHAR(255) NOT NULL,
    colonia VARCHAR(255) NOT NULL,
    cp VARCHAR(10),
    numext VARCHAR(20),
    numint VARCHAR(20),
    letraext VARCHAR(5),
    letraint VARCHAR(5),
    zona INTEGER,
    subzona INTEGER,
    sup_const NUMERIC(10,2),
    sup_autorizada NUMERIC(10,2),
    num_cajones INTEGER,
    num_empleados INTEGER,
    inversion NUMERIC(15,2),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    especificaciones TEXT,
    estatus VARCHAR(50) DEFAULT 'REGISTRADO',
    fecha_registro TIMESTAMP DEFAULT NOW(),
    usuario_registro VARCHAR(50)
);

-- Tabla de documentos de trámites
CREATE TABLE IF NOT EXISTS comun.tramite_documentos (
    id SERIAL PRIMARY KEY,
    id_tramite INTEGER NOT NULL REFERENCES comun.tramites(id),
    tipo_documento VARCHAR(100) NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL,
    observaciones TEXT,
    fecha_carga TIMESTAMP DEFAULT NOW(),
    usuario_carga VARCHAR(50)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tramites_folio ON comun.tramites(folio);
CREATE INDEX IF NOT EXISTS idx_tramites_estatus ON comun.tramites(estatus);
CREATE INDEX IF NOT EXISTS idx_tramites_fecha ON comun.tramites(fecha_registro);
CREATE INDEX IF NOT EXISTS idx_tramites_propietario ON comun.tramites(propietario);
CREATE INDEX IF NOT EXISTS idx_tramite_docs_tramite ON comun.tramite_documentos(id_tramite);
*/

-- =====================================================
-- PERMISOS (ajustar según usuario de la aplicación)
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.sp_registro_solicitud TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_agregar_documento TO refact;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

SELECT 'SPs creados exitosamente en esquema comun' AS resultado;
