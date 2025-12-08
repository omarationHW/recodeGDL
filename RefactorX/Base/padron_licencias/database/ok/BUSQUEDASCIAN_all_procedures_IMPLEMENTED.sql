-- ============================================================================
-- STORED PROCEDURES IMPLEMENTADOS - COMPONENTE: BusquedaScian
-- Módulo: padron_licencias
-- Schema: comun
-- Tabla Principal: c_scian (Catálogo SCIAN - Sistema de Clasificación Industrial)
-- ============================================================================
-- Descripción: Funciones para búsqueda y consulta del catálogo SCIAN
-- Total SPs: 2
-- Generado: 2025-11-20
-- ============================================================================

-- ============================================================================
-- TABLA PRINCIPAL: c_scian
-- ============================================================================
-- Descripción: Catálogo del Sistema de Clasificación Industrial de América del Norte
-- Campos principales:
--   - codigo_scian: Código numérico del SCIAN
--   - descripcion: Descripción de la actividad económica
--   - vigente: Estado de vigencia (V=Vigente, B=Baja)
--   - es_microgenerador: Indica si es microgenerador de residuos
--   - microgenerador_a/b/c/d: Clasificaciones específicas de microgenerador
--   - tipo: Tipo de clasificación
-- ============================================================================

-- ============================================================================
-- SP 1/2: catalogo_scian_busqueda
-- ============================================================================
-- Descripción: Búsqueda de registros SCIAN vigentes por código o descripción
-- Parámetros:
--   p_descripcion: Texto a buscar en descripción o código (NULL o vacío = todos)
-- Retorna: Lista de registros SCIAN vigentes que coincidan con el criterio
-- Características:
--   - Búsqueda case-insensitive
--   - Búsqueda en descripción y código_scian
--   - Solo registros vigentes
--   - Ordenado alfabéticamente por descripción
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.catalogo_scian_busqueda(p_descripcion TEXT)
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200),
    vigente CHAR(1),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    tipo CHAR(1)
) AS $$
DECLARE
    v_search_term TEXT;
BEGIN
    -- Normalizar el término de búsqueda
    v_search_term := TRIM(COALESCE(p_descripcion, ''));

    -- Log de la búsqueda
    RAISE DEBUG 'catalogo_scian_busqueda - Término búsqueda: %', v_search_term;

    -- Retornar registros filtrados
    RETURN QUERY
    SELECT
        cs.codigo_scian,
        cs.descripcion,
        cs.vigente,
        cs.es_microgenerador,
        cs.microgenerador_a,
        cs.microgenerador_b,
        cs.microgenerador_c,
        cs.microgenerador_d,
        cs.fecha_alta,
        cs.usuario_alta,
        cs.fecha_baja,
        cs.usuario_baja,
        cs.tipo
    FROM comun.c_scian cs
    WHERE cs.vigente = 'V'
      AND (
        v_search_term = ''
        OR UPPER(cs.descripcion) LIKE '%' || UPPER(v_search_term) || '%'
        OR CAST(cs.codigo_scian AS VARCHAR) LIKE '%' || v_search_term || '%'
      )
    ORDER BY cs.descripcion ASC;

    -- Log del total de resultados
    GET DIAGNOSTICS v_search_term = ROW_COUNT;
    RAISE DEBUG 'catalogo_scian_busqueda - Registros encontrados: %', v_search_term;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en catalogo_scian_busqueda: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- Comentarios del SP
COMMENT ON FUNCTION comun.catalogo_scian_busqueda(TEXT) IS
'Búsqueda de códigos SCIAN vigentes por descripción o código. Búsqueda case-insensitive en ambos campos.';

-- ============================================================================
-- SP 2/2: catalogo_scian_get_by_id
-- ============================================================================
-- Descripción: Obtiene un registro SCIAN específico por su código
-- Parámetros:
--   p_codigo_scian: Código SCIAN a buscar
-- Retorna: Registro completo del SCIAN solicitado
-- Validaciones:
--   - Código SCIAN requerido
--   - Verifica existencia del código
-- Características:
--   - Retorna información completa del código SCIAN
--   - Incluye información de vigencia y microgeneradores
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.catalogo_scian_get_by_id(p_codigo_scian INTEGER)
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200),
    vigente CHAR(1),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    tipo CHAR(1)
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Validar parámetro requerido
    IF p_codigo_scian IS NULL THEN
        RAISE EXCEPTION 'El código SCIAN es requerido';
    END IF;

    -- Log de la consulta
    RAISE DEBUG 'catalogo_scian_get_by_id - Código SCIAN: %', p_codigo_scian;

    -- Verificar existencia
    SELECT EXISTS(
        SELECT 1 FROM comun.c_scian
        WHERE comun.c_scian.codigo_scian = p_codigo_scian
    ) INTO v_exists;

    IF NOT v_exists THEN
        RAISE EXCEPTION 'Código SCIAN % no encontrado', p_codigo_scian;
    END IF;

    -- Retornar el registro
    RETURN QUERY
    SELECT
        cs.codigo_scian,
        cs.descripcion,
        cs.vigente,
        cs.es_microgenerador,
        cs.microgenerador_a,
        cs.microgenerador_b,
        cs.microgenerador_c,
        cs.microgenerador_d,
        cs.fecha_alta,
        cs.usuario_alta,
        cs.fecha_baja,
        cs.usuario_baja,
        cs.tipo
    FROM comun.c_scian cs
    WHERE cs.codigo_scian = p_codigo_scian;

    RAISE DEBUG 'catalogo_scian_get_by_id - Registro encontrado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en catalogo_scian_get_by_id: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- Comentarios del SP
COMMENT ON FUNCTION comun.catalogo_scian_get_by_id(INTEGER) IS
'Obtiene un registro completo del catálogo SCIAN por su código. Valida existencia del código.';

-- ============================================================================
-- FUNCIONES AUXILIARES Y DE SOPORTE
-- ============================================================================

-- ============================================================================
-- FUNCIÓN: catalogo_scian_list_all
-- ============================================================================
-- Descripción: Lista todos los códigos SCIAN (vigentes y no vigentes)
-- Uso: Administración y consultas generales
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.catalogo_scian_list_all()
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200),
    vigente CHAR(1),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    tipo CHAR(1)
) AS $$
BEGIN
    RAISE DEBUG 'catalogo_scian_list_all - Listando todos los códigos SCIAN';

    RETURN QUERY
    SELECT
        cs.codigo_scian,
        cs.descripcion,
        cs.vigente,
        cs.es_microgenerador,
        cs.microgenerador_a,
        cs.microgenerador_b,
        cs.microgenerador_c,
        cs.microgenerador_d,
        cs.fecha_alta,
        cs.usuario_alta,
        cs.fecha_baja,
        cs.usuario_baja,
        cs.tipo
    FROM comun.c_scian cs
    ORDER BY cs.descripcion ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en catalogo_scian_list_all: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.catalogo_scian_list_all() IS
'Lista todos los códigos SCIAN (vigentes y no vigentes) ordenados alfabéticamente.';

-- ============================================================================
-- FUNCIÓN: catalogo_scian_get_microgeneradores
-- ============================================================================
-- Descripción: Obtiene todos los códigos SCIAN clasificados como microgeneradores
-- Uso: Consultas específicas de regulación ambiental
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.catalogo_scian_get_microgeneradores()
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    tipo CHAR(1)
) AS $$
BEGIN
    RAISE DEBUG 'catalogo_scian_get_microgeneradores - Listando microgeneradores vigentes';

    RETURN QUERY
    SELECT
        cs.codigo_scian,
        cs.descripcion,
        cs.es_microgenerador,
        cs.microgenerador_a,
        cs.microgenerador_b,
        cs.microgenerador_c,
        cs.microgenerador_d,
        cs.tipo
    FROM comun.c_scian cs
    WHERE cs.vigente = 'V'
      AND cs.es_microgenerador = 'S'
    ORDER BY cs.descripcion ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en catalogo_scian_get_microgeneradores: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.catalogo_scian_get_microgeneradores() IS
'Obtiene códigos SCIAN vigentes clasificados como microgeneradores de residuos.';

-- ============================================================================
-- FUNCIÓN: catalogo_scian_count_by_vigencia
-- ============================================================================
-- Descripción: Obtiene estadísticas de códigos SCIAN por vigencia
-- Uso: Reportes y análisis del catálogo
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.catalogo_scian_count_by_vigencia()
RETURNS TABLE (
    vigente CHAR(1),
    total INTEGER,
    microgeneradores INTEGER
) AS $$
BEGIN
    RAISE DEBUG 'catalogo_scian_count_by_vigencia - Calculando estadísticas';

    RETURN QUERY
    SELECT
        cs.vigente,
        COUNT(*)::INTEGER as total,
        COUNT(CASE WHEN cs.es_microgenerador = 'S' THEN 1 END)::INTEGER as microgeneradores
    FROM comun.c_scian cs
    GROUP BY cs.vigente
    ORDER BY cs.vigente;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en catalogo_scian_count_by_vigencia: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.catalogo_scian_count_by_vigencia() IS
'Estadísticas de códigos SCIAN agrupados por vigencia, incluyendo conteo de microgeneradores.';

-- ============================================================================
-- PERMISOS Y SEGURIDAD
-- ============================================================================

-- Permisos para roles de aplicación (ajustar según necesidad)
-- GRANT EXECUTE ON FUNCTION comun.catalogo_scian_busqueda(TEXT) TO app_licencias_user;
-- GRANT EXECUTE ON FUNCTION comun.catalogo_scian_get_by_id(INTEGER) TO app_licencias_user;
-- GRANT EXECUTE ON FUNCTION comun.catalogo_scian_list_all() TO app_licencias_user;
-- GRANT EXECUTE ON FUNCTION comun.catalogo_scian_get_microgeneradores() TO app_licencias_user;
-- GRANT EXECUTE ON FUNCTION comun.catalogo_scian_count_by_vigencia() TO app_licencias_user;

-- ============================================================================
-- EJEMPLOS DE USO
-- ============================================================================

/*
-- Ejemplo 1: Búsqueda por descripción
SELECT * FROM comun.catalogo_scian_busqueda('comercio');

-- Ejemplo 2: Búsqueda por código
SELECT * FROM comun.catalogo_scian_busqueda('4111');

-- Ejemplo 3: Obtener todos los vigentes
SELECT * FROM comun.catalogo_scian_busqueda('');
SELECT * FROM comun.catalogo_scian_busqueda(NULL);

-- Ejemplo 4: Obtener un código específico
SELECT * FROM comun.catalogo_scian_get_by_id(411110);

-- Ejemplo 5: Listar todos los códigos SCIAN
SELECT * FROM comun.catalogo_scian_list_all();

-- Ejemplo 6: Obtener microgeneradores
SELECT * FROM comun.catalogo_scian_get_microgeneradores();

-- Ejemplo 7: Estadísticas por vigencia
SELECT * FROM comun.catalogo_scian_count_by_vigencia();
*/

-- ============================================================================
-- NOTAS TÉCNICAS
-- ============================================================================
-- 1. SCIAN (Sistema de Clasificación Industrial de América del Norte)
--    - Estándar internacional para clasificación de actividades económicas
--    - Usado por México, Estados Unidos y Canadá
--    - Códigos de 2 a 6 dígitos según nivel de detalle
--
-- 2. Microgeneradores
--    - Clasificación específica para regulación ambiental mexicana
--    - Categorías A, B, C, D según tipo y volumen de residuos
--    - Importante para trámites de licencias ambientales
--
-- 3. Rendimiento
--    - Índices recomendados: codigo_scian (PK), descripcion, vigente
--    - Para búsquedas frecuentes considerar índice en UPPER(descripcion)
--    - Tabla relativamente pequeña (< 10,000 registros típicamente)
--
-- 4. Integración
--    - Tabla de catálogo usada por múltiples módulos
--    - Referencias desde: licencias, tramites, giros
--    - No permite eliminación física de registros (solo baja lógica)
-- ============================================================================

-- ============================================================================
-- FIN DEL ARCHIVO
-- Total de funciones implementadas: 5 (2 principales + 3 auxiliares)
-- Schema: comun
-- Tabla principal: c_scian
-- ============================================================================
