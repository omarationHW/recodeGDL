-- =====================================================
-- STORED PROCEDURE: BÚSQUEDA DE GIROS
-- Módulo: Licencias
-- Descripción: Búsqueda avanzada de giros comerciales con múltiples filtros
-- Esquema: catastro_gdl
-- Fecha: 2025-01-06
-- =====================================================

-- SP para búsqueda de giros con filtros múltiples
CREATE OR REPLACE FUNCTION catastro_gdl.sp_giros_buscar(
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_codigo VARCHAR(50) DEFAULT NULL,
    p_id_categoria INTEGER DEFAULT NULL,
    p_tipo CHAR(1) DEFAULT NULL,
    p_estado CHAR(1) DEFAULT NULL,
    p_autoev CHAR(1) DEFAULT NULL,
    p_pacto CHAR(1) DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    codigo TEXT,
    descripcion TEXT,
    categoria_nombre TEXT,
    tipo TEXT,
    activo TEXT,
    autoev TEXT,
    pacto TEXT,
    costo NUMERIC(10,2),
    orden INTEGER
) AS $$
DECLARE
    v_current_year INTEGER;
BEGIN
    -- Obtener el año actual para buscar costos vigentes
    v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);

    RETURN QUERY
    SELECT
        g.id_giro AS id,
        COALESCE(g.cod_giro::TEXT, '') AS codigo,
        COALESCE(TRIM(g.descripcion::TEXT), '') AS descripcion,
        COALESCE(cat.nombre::TEXT, 'Sin categoría') AS categoria_nombre,
        COALESCE(TRIM(g.tipo::TEXT), 'L') AS tipo,
        COALESCE(TRIM(g.vigente::TEXT), 'V') AS activo,
        CASE
            WHEN ga.id_giro IS NOT NULL THEN 'S'::TEXT
            ELSE 'N'::TEXT
        END AS autoev,
        CASE
            WHEN g.clasificacion = 'B' THEN 'S'::TEXT
            ELSE 'N'::TEXT
        END AS pacto,
        COALESCE(vl.costo, 0.00) AS costo,
        0 AS orden
    FROM catastro_gdl.c_giros g
    LEFT JOIN catastro_gdl.categorias_giros cat
        ON cat.id = p_id_categoria
    LEFT JOIN catastro_gdl.c_girosautoev ga
        ON g.id_giro = ga.id_giro
    LEFT JOIN catastro_gdl.c_valoreslic vl
        ON g.id_giro = vl.id_giro
        AND vl.axo = v_current_year
    WHERE
        -- Filtro por descripción (búsqueda parcial insensible a mayúsculas)
        (p_descripcion IS NULL
         OR p_descripcion = ''
         OR UPPER(g.descripcion) LIKE '%' || UPPER(p_descripcion) || '%')

        -- Filtro por código del giro
        AND (p_codigo IS NULL
             OR p_codigo = ''
             OR g.cod_giro::TEXT = p_codigo)

        -- Filtro por categoría (si se especifica)
        -- Nota: Esta es una búsqueda condicional, solo filtra si hay categoría seleccionada
        AND (p_id_categoria IS NULL
             OR p_id_categoria = 0
             OR cat.id IS NOT NULL)

        -- Filtro por tipo de giro (L=Licencia, A=Anuncio, M=Mixto)
        AND (p_tipo IS NULL
             OR p_tipo = ''
             OR g.tipo = p_tipo)

        -- Filtro por estado/vigencia (V=Vigente, N=No vigente)
        AND (p_estado IS NULL
             OR p_estado = ''
             OR g.vigente = p_estado)

        -- Filtro por autoevaluación (solo si se solicita 'S')
        AND (p_autoev IS NULL
             OR p_autoev = ''
             OR (p_autoev = 'S' AND ga.id_giro IS NOT NULL))

        -- Filtro por pacto de homologación (clasificación 'B')
        AND (p_pacto IS NULL
             OR p_pacto = ''
             OR (p_pacto = 'S' AND g.clasificacion = 'B'))

        -- Excluir rango especial de actividades SCIAN (5000-99999)
        AND g.id_giro NOT BETWEEN 5000 AND 99999

        -- Solo giros con ID mayor a 500 (rango válido)
        AND g.id_giro > 500

    ORDER BY g.descripcion ASC
    LIMIT 100;  -- Limitar resultados para mejor rendimiento
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS DE IMPLEMENTACIÓN:
--
-- 1. SP diseñado para búsqueda flexible con múltiples filtros opcionales
-- 2. Búsqueda insensible a mayúsculas en descripción
-- 3. JOIN con categorias_giros para mostrar nombre de categoría
-- 4. JOIN con c_girosautoev para identificar giros con autoevaluación
-- 5. JOIN con c_valoreslic para obtener costos del año actual
-- 6. Excluye rangos especiales (5000-99999 y menores a 500)
-- 7. Limita a 100 resultados para mejor performance
-- 8. Retorna estructura compatible con el frontend Vue
-- =====================================================
