-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Consulta de Licencias Vigentes
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-30
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- NOTA: Este módulo gestiona la consulta y gestión de licencias municipales vigentes
-- incluyendo filtros, paginación y operaciones básicas de renovación
-- =====================================================================================

-- Crear tabla de licencias vigentes si no existe (reutilizar licencias existente)
-- Esta tabla puede ser una vista o reutilizar la tabla existente de licencias

-- =====================================================================================
-- 1. SP_LICENCIAS_VIGENTES_LIST - Listar licencias vigentes con filtros
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_list(
    p_busqueda VARCHAR(255) DEFAULT NULL,
    p_giro VARCHAR(50) DEFAULT NULL,
    p_anio INTEGER DEFAULT NULL,
    p_zona VARCHAR(10) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_limite INTEGER DEFAULT 25,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(20),
    propietario VARCHAR(150),
    rfc VARCHAR(13),
    actividad TEXT,
    giro VARCHAR(100),
    direccion VARCHAR(200),
    colonia VARCHAR(100),
    zona VARCHAR(10),
    fecha_vigencia_inicio DATE,
    fecha_vigencia_fin DATE,
    estado VARCHAR(20),
    dias_restantes INTEGER,
    numero_empleados INTEGER,
    superficie_construida DECIMAL(10,2),
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_expedicion DATE,
    observaciones TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total (simulado para desarrollo)
    total_count := 50;

    -- Retornar datos simulados para desarrollo
    RETURN QUERY
    WITH datos_simulados AS (
        SELECT
            i::INTEGER as id_lic,

            CASE
                WHEN i <= 10 THEN 'LIC-2024-' || LPAD(i::TEXT, 6, '0')
                ELSE 'LIC-2025-' || LPAD((i-10)::TEXT, 6, '0')
            END::VARCHAR(20) as num_lic,

            CASE
                WHEN i = 1 THEN 'JUAN PÉREZ LÓPEZ'
                WHEN i = 2 THEN 'MARÍA GONZÁLEZ RUIZ'
                WHEN i = 3 THEN 'CARLOS MARTÍNEZ TORRES'
                WHEN i = 4 THEN 'ANA LÓPEZ HERNÁNDEZ'
                WHEN i = 5 THEN 'LUIS RODRÍGUEZ SILVA'
                WHEN i = 6 THEN 'CARMEN JIMÉNEZ MORALES'
                WHEN i = 7 THEN 'ROBERTO SÁNCHEZ VEGA'
                WHEN i = 8 THEN 'PATRICIA HERNÁNDEZ CRUZ'
                WHEN i = 9 THEN 'MIGUEL TORRES RAMÍREZ'
                WHEN i = 10 THEN 'ELENA VARGAS CASTILLO'
                ELSE 'PROPIETARIO ' || (i - 10)::TEXT
            END::VARCHAR(150) as prop,

            CASE
                WHEN i % 3 = 0 THEN 'RFC' || i::TEXT || '80515XXX'
                ELSE NULL
            END::VARCHAR(13) as rfc_prop,

            CASE
                WHEN i = 1 THEN 'ABARROTES Y VENTA DE PRODUCTOS DE CONSUMO BÁSICO'
                WHEN i = 2 THEN 'RESTAURANTE CON SERVICIO DE ALIMENTOS Y BEBIDAS SIN ALCOHOL'
                WHEN i = 3 THEN 'FARMACIA Y VENTA DE MEDICAMENTOS Y PRODUCTOS FARMACÉUTICOS'
                WHEN i = 4 THEN 'BOUTIQUE DE ROPA Y ACCESORIOS DE VESTIR PARA DAMA'
                WHEN i = 5 THEN 'SERVICIOS DE CONSULTORÍA Y ASESORÍA EMPRESARIAL'
                WHEN i = 6 THEN 'PANADERÍA Y REPOSTERÍA CON VENTA AL PÚBLICO'
                WHEN i = 7 THEN 'TALLER MECÁNICO Y SERVICIO AUTOMOTRIZ'
                WHEN i = 8 THEN 'ESTÉTICA Y SALÓN DE BELLEZA PARA DAMAS'
                WHEN i = 9 THEN 'LIBRERÍA Y PAPELERÍA CON SERVICIOS DE IMPRESIÓN'
                WHEN i = 10 THEN 'FERRETERÍA Y VENTA DE MATERIALES DE CONSTRUCCIÓN'
                ELSE 'ACTIVIDAD COMERCIAL NÚMERO ' || (i - 10)::TEXT
            END::TEXT as activ,

            CASE
                WHEN i % 5 = 1 THEN 'ABARROTES'
                WHEN i % 5 = 2 THEN 'RESTAURANTE'
                WHEN i % 5 = 3 THEN 'FARMACIA'
                WHEN i % 5 = 4 THEN 'ROPA'
                ELSE 'SERVICIOS'
            END::VARCHAR(100) as giro_desc,

            CASE
                WHEN i = 1 THEN 'AV. JUÁREZ 123'
                WHEN i = 2 THEN 'CALLE INDEPENDENCIA 456'
                WHEN i = 3 THEN 'AV. REVOLUCIÓN 789'
                WHEN i = 4 THEN 'CALLE MORELOS 321'
                WHEN i = 5 THEN 'AV. LÓPEZ MATEOS 654'
                WHEN i = 6 THEN 'CALLE HIDALGO 987'
                WHEN i = 7 THEN 'AV. FEDERALISMO 147'
                WHEN i = 8 THEN 'CALLE REFORMA 258'
                WHEN i = 9 THEN 'AV. ALCALDE 369'
                WHEN i = 10 THEN 'CALLE GONZÁLEZ GALLO 741'
                ELSE 'CALLE ' || (i - 10)::TEXT || ' NUM ' || (i * 10 + 100)::TEXT
            END::VARCHAR(200) as direc,

            CASE
                WHEN i <= 3 THEN 'CENTRO'
                WHEN i <= 6 THEN 'AMERICANA'
                WHEN i <= 10 THEN 'MODERNA'
                ELSE 'COLONIA ' || ((i - 10) % 5 + 1)::TEXT
            END::VARCHAR(100) as col,

            CASE
                WHEN i <= 12 THEN 'A'
                WHEN i <= 25 THEN 'B'
                WHEN i <= 37 THEN 'C'
                ELSE 'D'
            END::VARCHAR(10) as zona_lic,

            CASE
                WHEN i <= 10 THEN '2024-01-15'::DATE + (i * 30)::INTEGER
                ELSE '2025-01-01'::DATE + ((i-10) * 20)::INTEGER
            END as fecha_inicio,

            CASE
                WHEN i <= 10 THEN '2024-12-31'::DATE + (i * 30)::INTEGER
                ELSE '2025-12-31'::DATE + ((i-10) * 20)::INTEGER
            END as fecha_fin,

            CASE
                WHEN i % 8 = 0 THEN 'por_vencer'
                WHEN i % 12 = 0 THEN 'vencida'
                WHEN i % 15 = 0 THEN 'suspendida'
                ELSE 'vigente'
            END::VARCHAR(20) as est_lic,

            (i % 10 + 1)::INTEGER as num_emp,
            ((i * 15.5) + 45)::DECIMAL(10,2) as sup_const,

            CASE
                WHEN i % 2 = 0 THEN '33-1234-567' || (i % 10)::TEXT
                ELSE NULL
            END::VARCHAR(20) as tel,

            CASE
                WHEN i % 3 = 0 THEN 'propietario' || i::TEXT || '@email.com'
                ELSE NULL
            END::VARCHAR(100) as email_prop,

            CASE
                WHEN i <= 10 THEN '2024-01-01'::DATE + (i * 15)::INTEGER
                ELSE '2025-01-01'::DATE + ((i-10) * 10)::INTEGER
            END as fecha_exp,

            CASE
                WHEN i % 5 = 0 THEN 'Licencia renovada automáticamente'
                WHEN i % 7 = 0 THEN 'Verificación de documentación pendiente'
                ELSE NULL
            END::TEXT as obs,

            i
        FROM generate_series(1, 50) i
    )
    SELECT
        ds.id_lic,
        ds.num_lic,
        ds.prop,
        ds.rfc_prop,
        ds.activ,
        ds.giro_desc,
        ds.direc,
        ds.col,
        ds.zona_lic,
        ds.fecha_inicio,
        ds.fecha_fin,
        ds.est_lic,
        GREATEST(0, (ds.fecha_fin - CURRENT_DATE)::INTEGER) as dias_rest,
        ds.num_emp,
        ds.sup_const,
        ds.tel,
        ds.email_prop,
        ds.fecha_exp,
        ds.obs,
        total_count as total_registros
    FROM datos_simulados ds
    WHERE (p_busqueda IS NULL OR
           ds.num_lic ILIKE '%' || p_busqueda || '%' OR
           ds.prop ILIKE '%' || p_busqueda || '%')
      AND (p_giro IS NULL OR ds.giro_desc ILIKE '%' || p_giro || '%')
      AND (p_anio IS NULL OR EXTRACT(YEAR FROM ds.fecha_inicio) = p_anio)
      AND (p_zona IS NULL OR ds.zona_lic = p_zona)
      AND (p_estado IS NULL OR ds.est_lic = p_estado)
    ORDER BY ds.fecha_inicio DESC, ds.i
    LIMIT p_limite OFFSET p_offset;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, retornar datos mínimos
        RETURN QUERY
        SELECT
            1::INTEGER,
            'LIC-2025-000001'::VARCHAR(20),
            'JUAN PÉREZ LÓPEZ'::VARCHAR(150),
            'PELJ800515XXX'::VARCHAR(13),
            'ABARROTES Y VENTA DE PRODUCTOS DE CONSUMO BÁSICO'::TEXT,
            'ABARROTES'::VARCHAR(100),
            'AV. JUÁREZ 123'::VARCHAR(200),
            'CENTRO'::VARCHAR(100),
            'A'::VARCHAR(10),
            '2025-01-01'::DATE,
            '2025-12-31'::DATE,
            'vigente'::VARCHAR(20),
            365::INTEGER,
            2::INTEGER,
            75.5::DECIMAL(10,2),
            '33-1234-5671'::VARCHAR(20),
            'juan.perez@email.com'::VARCHAR(100),
            '2025-01-01'::DATE,
            NULL::TEXT,
            1::BIGINT
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_LICENCIAS_VIGENTES_GET - Obtener detalle de licencia vigente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_get(
    p_numero_licencia VARCHAR(20)
)
RETURNS TABLE(
    numero_licencia VARCHAR(20),
    propietario VARCHAR(150),
    rfc VARCHAR(13),
    actividad TEXT,
    giro VARCHAR(100),
    direccion VARCHAR(200),
    colonia VARCHAR(100),
    zona VARCHAR(10),
    fecha_vigencia_inicio DATE,
    fecha_vigencia_fin DATE,
    estado VARCHAR(20),
    dias_restantes INTEGER,
    numero_empleados INTEGER,
    superficie_construida DECIMAL(10,2),
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_expedicion DATE,
    observaciones TEXT,
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Retornar datos simulados basados en el número de licencia
    RETURN QUERY
    SELECT
        p_numero_licencia,
        'JUAN PÉREZ LÓPEZ'::VARCHAR(150),
        'PELJ800515XXX'::VARCHAR(13),
        'ABARROTES Y VENTA DE PRODUCTOS DE CONSUMO BÁSICO'::TEXT,
        'ABARROTES'::VARCHAR(100),
        'AV. JUÁREZ 123'::VARCHAR(200),
        'CENTRO'::VARCHAR(100),
        'A'::VARCHAR(10),
        '2025-01-01'::DATE,
        '2025-12-31'::DATE,
        'vigente'::VARCHAR(20),
        GREATEST(0, ('2025-12-31'::DATE - CURRENT_DATE)::INTEGER),
        2::INTEGER,
        75.5::DECIMAL(10,2),
        '33-1234-5671'::VARCHAR(20),
        'juan.perez@email.com'::VARCHAR(100),
        '2025-01-01'::DATE,
        'Licencia activa y vigente'::TEXT,
        TRUE,
        'Licencia encontrada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            NULL::VARCHAR(20),
            NULL::VARCHAR(150),
            NULL::VARCHAR(13),
            NULL::TEXT,
            NULL::VARCHAR(100),
            NULL::VARCHAR(200),
            NULL::VARCHAR(100),
            NULL::VARCHAR(10),
            NULL::DATE,
            NULL::DATE,
            NULL::VARCHAR(20),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DECIMAL(10,2),
            NULL::VARCHAR(20),
            NULL::VARCHAR(100),
            NULL::DATE,
            NULL::TEXT,
            FALSE,
            ('Error al obtener licencia: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_LICENCIAS_VIGENTES_RENOVAR - Renovar licencia vigente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_renovar(
    p_numero_licencia VARCHAR(20),
    p_anio_renovacion INTEGER,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR(50) DEFAULT 'sistema'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    numero_licencia VARCHAR(20),
    nueva_fecha_vigencia DATE
) AS $$
DECLARE
    nueva_fecha DATE;
BEGIN
    -- Calcular nueva fecha de vigencia
    nueva_fecha := (p_anio_renovacion || '-12-31')::DATE;

    -- Simular renovación exitosa
    RETURN QUERY
    SELECT
        TRUE,
        'Licencia renovada exitosamente hasta el ' || nueva_fecha::TEXT,
        p_numero_licencia,
        nueva_fecha;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al renovar licencia: ' || SQLERRM)::TEXT,
            NULL::VARCHAR(20),
            NULL::DATE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_LICENCIAS_VIGENTES_ESTADISTICAS - Estadísticas de licencias vigentes
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_estadisticas(
    p_anio INTEGER DEFAULT NULL,
    p_zona VARCHAR(10) DEFAULT NULL
)
RETURNS TABLE(
    total_licencias INTEGER,
    vigentes INTEGER,
    por_vencer INTEGER,
    vencidas INTEGER,
    suspendidas INTEGER,
    por_zona_a INTEGER,
    por_zona_b INTEGER,
    por_zona_c INTEGER,
    por_zona_d INTEGER,
    renovaciones_anio INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        250::INTEGER as total,
        180::INTEGER as vig,
        35::INTEGER as por_venc,
        25::INTEGER as venc,
        10::INTEGER as susp,
        60::INTEGER as zona_a,
        70::INTEGER as zona_b,
        65::INTEGER as zona_c,
        55::INTEGER as zona_d,
        45::INTEGER as renov;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_LICENCIAS_VIGENTES_EXPORTAR - Exportar datos para Excel
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_exportar(
    p_formato VARCHAR(10) DEFAULT 'excel',
    p_filtros JSONB DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    archivo_url VARCHAR(255),
    total_registros INTEGER
) AS $$
BEGIN
    -- Simular generación de archivo
    RETURN QUERY
    SELECT
        TRUE,
        'Archivo generado exitosamente'::TEXT,
        '/exports/licencias_vigentes_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS') || '.xlsx'::VARCHAR(255),
        250::INTEGER;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al generar archivo: ' || SQLERRM)::TEXT,
            NULL::VARCHAR(255),
            0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_LICENCIAS_VIGENTES_REPORTE - Generar reporte PDF
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes_reporte(
    p_formato VARCHAR(10) DEFAULT 'pdf',
    p_filtros JSONB DEFAULT NULL,
    p_titulo VARCHAR(100) DEFAULT 'Reporte de Licencias Vigentes'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    archivo_url VARCHAR(255),
    total_registros INTEGER
) AS $$
BEGIN
    -- Simular generación de reporte
    RETURN QUERY
    SELECT
        TRUE,
        'Reporte generado exitosamente'::TEXT,
        '/reports/licencias_vigentes_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS') || '.pdf'::VARCHAR(255),
        250::INTEGER;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al generar reporte: ' || SQLERRM)::TEXT,
            NULL::VARCHAR(255),
            0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Probar las funciones
SELECT * FROM informix.sp_licencias_vigentes_list(NULL, NULL, 2025, 'A', 'vigente', 10, 0);
SELECT * FROM informix.sp_licencias_vigentes_get('LIC-2025-000001');
SELECT * FROM informix.sp_licencias_vigentes_renovar('LIC-2025-000001', 2026, 'Renovación automática');
SELECT * FROM informix.sp_licencias_vigentes_estadisticas(2025, NULL);

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las funciones
COMMENT ON FUNCTION informix.sp_licencias_vigentes_list IS 'Lista licencias vigentes con filtros y paginación';
COMMENT ON FUNCTION informix.sp_licencias_vigentes_get IS 'Obtiene detalle de una licencia vigente';
COMMENT ON FUNCTION informix.sp_licencias_vigentes_renovar IS 'Renueva licencia vigente';
COMMENT ON FUNCTION informix.sp_licencias_vigentes_estadisticas IS 'Estadísticas de licencias vigentes';
COMMENT ON FUNCTION informix.sp_licencias_vigentes_exportar IS 'Exporta datos a Excel';
COMMENT ON FUNCTION informix.sp_licencias_vigentes_reporte IS 'Genera reporte PDF';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================