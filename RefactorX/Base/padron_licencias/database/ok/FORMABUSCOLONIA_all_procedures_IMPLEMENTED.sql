-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Formulario: formabuscolonia
-- Descripcion: Busqueda de colonias por municipio (codigo postal)
-- Implementado: 2025-11-21
-- Total SPs: 2
-- Schema: comun
-- ============================================

-- ============================================
-- INDICES RECOMENDADOS
-- ============================================
-- CREATE INDEX IF NOT EXISTS idx_cp_correos_c_mnpio ON comun.cp_correos(c_mnpio);
-- CREATE INDEX IF NOT EXISTS idx_cp_correos_colonia ON comun.cp_correos(colonia);
-- CREATE INDEX IF NOT EXISTS idx_cp_correos_colonia_upper ON comun.cp_correos(UPPER(colonia));
-- CREATE INDEX IF NOT EXISTS idx_cp_correos_mnpio_colonia ON comun.cp_correos(c_mnpio, colonia);
-- ============================================

-- SP 1/2: sp_buscar_colonias
-- Tipo: Catalog/Search
-- Descripcion: Busca colonias por municipio (c_mnpio) y filtro de nombre opcional.
--              Utiliza ILIKE para busqueda insensible a mayusculas/minusculas.
--              Si p_filtro es NULL o vacio, retorna todas las colonias del municipio.
-- Parametros:
--   p_c_mnpio: Codigo de municipio (requerido). Guadalajara = 39
--   p_filtro: Texto de busqueda para filtrar por nombre de colonia (opcional)
-- Retorna: Lista de colonias con codigo postal y tipo de asentamiento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_buscar_colonias(
    p_c_mnpio INTEGER,
    p_filtro TEXT DEFAULT NULL
)
RETURNS TABLE (
    colonia TEXT,
    d_codigopostal INTEGER,
    d_tipo_asenta TEXT
) AS $$
BEGIN
    -- Validacion: c_mnpio es requerido
    IF p_c_mnpio IS NULL THEN
        RAISE EXCEPTION 'El parametro p_c_mnpio es requerido y no puede ser NULL';
    END IF;

    -- Busqueda con filtro opcional
    RETURN QUERY
    SELECT
        cp.colonia::TEXT,
        cp.d_codigopostal::INTEGER,
        cp.d_tipo_asenta::TEXT
    FROM comun.cp_correos cp
    WHERE cp.c_mnpio = p_c_mnpio
      AND (
          p_filtro IS NULL
          OR TRIM(p_filtro) = ''
          OR cp.colonia ILIKE '%' || TRIM(p_filtro) || '%'
      )
    ORDER BY cp.colonia ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_buscar_colonias: % - %', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Comentario de uso:
-- SELECT * FROM comun.sp_buscar_colonias(39, NULL);           -- Todas las colonias de Guadalajara
-- SELECT * FROM comun.sp_buscar_colonias(39, '');             -- Todas las colonias de Guadalajara
-- SELECT * FROM comun.sp_buscar_colonias(39, 'centro');       -- Colonias que contengan 'centro'
-- SELECT * FROM comun.sp_buscar_colonias(39, 'JARDINES');     -- Busqueda insensible a mayusculas

-- ============================================

-- SP 2/2: sp_obtener_colonia_seleccionada
-- Tipo: Catalog/Get
-- Descripcion: Obtiene los datos de una colonia especifica por municipio y nombre exacto.
--              Utiliza comparacion exacta (case-sensitive) o ILIKE para mayor flexibilidad.
-- Parametros:
--   p_c_mnpio: Codigo de municipio (requerido). Guadalajara = 39
--   p_colonia: Nombre exacto de la colonia a buscar (requerido)
-- Retorna: Datos de la colonia encontrada (unico registro)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_obtener_colonia_seleccionada(
    p_c_mnpio INTEGER,
    p_colonia TEXT
)
RETURNS TABLE (
    colonia TEXT,
    d_codigopostal INTEGER,
    d_tipo_asenta TEXT
) AS $$
BEGIN
    -- Validacion: c_mnpio es requerido
    IF p_c_mnpio IS NULL THEN
        RAISE EXCEPTION 'El parametro p_c_mnpio es requerido y no puede ser NULL';
    END IF;

    -- Validacion: colonia es requerido
    IF p_colonia IS NULL OR TRIM(p_colonia) = '' THEN
        RAISE EXCEPTION 'El parametro p_colonia es requerido y no puede ser NULL o vacio';
    END IF;

    -- Busqueda exacta de colonia
    RETURN QUERY
    SELECT
        cp.colonia::TEXT,
        cp.d_codigopostal::INTEGER,
        cp.d_tipo_asenta::TEXT
    FROM comun.cp_correos cp
    WHERE cp.c_mnpio = p_c_mnpio
      AND UPPER(TRIM(cp.colonia)) = UPPER(TRIM(p_colonia))
    LIMIT 1;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_obtener_colonia_seleccionada: % - %', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Comentario de uso:
-- SELECT * FROM comun.sp_obtener_colonia_seleccionada(39, 'Centro');
-- SELECT * FROM comun.sp_obtener_colonia_seleccionada(39, 'Jardines del Bosque');

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================

-- RESUMEN DE IMPLEMENTACION:
-- ============================================
-- 1. sp_buscar_colonias
--    - Schema: comun
--    - Busqueda por municipio con filtro opcional
--    - Usa ILIKE para busqueda case-insensitive
--    - Validacion de parametro p_c_mnpio requerido
--    - Ordenamiento por nombre de colonia
--    - Manejo de errores con EXCEPTION
--
-- 2. sp_obtener_colonia_seleccionada
--    - Schema: comun
--    - Busqueda exacta por municipio y nombre de colonia
--    - Usa UPPER() para comparacion case-insensitive
--    - Validacion de ambos parametros requeridos
--    - Retorna maximo 1 registro (LIMIT 1)
--    - Manejo de errores con EXCEPTION
--
-- Tabla utilizada: comun.cp_correos
-- Columnas: colonia, d_codigopostal, d_tipo_asenta, c_mnpio
-- Municipio por defecto (Guadalajara): c_mnpio = 39
-- ============================================
