-- =====================================================
-- STORED PROCEDURE: LicenciasVigentesfrm_sp_licencias_vigentes
-- =====================================================
-- Obtiene el listado de licencias vigentes con paginación y filtros
-- Compatible con la interfaz del componente Vue
-- =====================================================

DROP FUNCTION IF EXISTS public.licenciasvigentesfrm_sp_licencias_vigentes(
    integer, integer, text, text, text, text, text, text
);

CREATE OR REPLACE FUNCTION public.licenciasvigentesfrm_sp_licencias_vigentes(
    p_page integer DEFAULT 1,
    p_limit integer DEFAULT 25,
    p_giro text DEFAULT NULL,
    p_zona text DEFAULT NULL,
    p_estado text DEFAULT NULL,
    p_fecha_desde text DEFAULT NULL,
    p_fecha_hasta text DEFAULT NULL,
    p_propietario text DEFAULT NULL
)
RETURNS TABLE(
    numero integer,
    propietario text,
    giro text,
    direccion text,
    zona text,
    estado text,
    fecha_otorgamiento text,
    vigencia_hasta text,
    total_records bigint
) AS $$
DECLARE
    v_offset integer;
    v_total_count bigint;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Crear tabla temporal con los resultados filtrados
    DROP TABLE IF EXISTS temp_licencias_vigentes;
    CREATE TEMP TABLE temp_licencias_vigentes AS
    SELECT
        l.licencia as numero,
        TRIM(l.propietario)::TEXT as propietario,
        COALESCE(g.descripcion::TEXT, 'Sin Giro') as giro,
        CONCAT(
            COALESCE(l.ubicacion, ''),
            ' #', COALESCE(CAST(l.numext_ubic AS TEXT), 'S/N'),
            CASE WHEN l.letraext_ubic IS NOT NULL THEN '-' || l.letraext_ubic ELSE '' END,
            CASE WHEN l.colonia_ubic IS NOT NULL THEN ', ' || l.colonia_ubic ELSE '' END
        ) as direccion,
        CASE
            WHEN l.zona IS NOT NULL THEN CAST(l.zona AS TEXT)
            ELSE 'N/A'
        END as zona,
        CASE
            WHEN l.vigente = 'V' THEN 'VIGENTE'
            WHEN l.vigente = 'S' THEN 'SUSPENDIDA'
            WHEN l.vigente = 'T' THEN 'TEMPORAL'
            WHEN l.vigente = 'C' THEN 'CANCELADA'
            WHEN l.vigente = 'B' THEN 'BAJA'
            ELSE 'DESCONOCIDO'
        END as estado,
        TO_CHAR(l.fecha_otorgamiento, 'DD/MM/YYYY') as fecha_otorgamiento,
        CASE
            WHEN l.fecha_baja IS NOT NULL THEN TO_CHAR(l.fecha_baja, 'DD/MM/YYYY')
            ELSE 'VIGENTE'
        END as vigencia_hasta
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia > 0
        -- Filtro por giro
        AND (p_giro IS NULL OR g.descripcion ILIKE '%' || p_giro || '%')
        -- Filtro por zona
        AND (p_zona IS NULL OR CAST(l.zona AS TEXT) = p_zona)
        -- Filtro por estado
        AND (p_estado IS NULL OR
            CASE
                WHEN p_estado = 'VIGENTE' THEN l.vigente = 'V'
                WHEN p_estado = 'SUSPENDIDA' THEN l.vigente = 'S'
                WHEN p_estado = 'TEMPORAL' THEN l.vigente = 'T'
                WHEN p_estado = 'CANCELADA' THEN l.vigente = 'C'
                WHEN p_estado = 'BAJA' THEN l.vigente = 'B'
                ELSE TRUE
            END
        )
        -- Filtro por fecha desde
        AND (p_fecha_desde IS NULL OR l.fecha_otorgamiento >= p_fecha_desde::date)
        -- Filtro por fecha hasta
        AND (p_fecha_hasta IS NULL OR l.fecha_otorgamiento <= p_fecha_hasta::date)
        -- Filtro por propietario
        AND (p_propietario IS NULL OR l.propietario ILIKE '%' || p_propietario || '%');

    -- Obtener total de registros
    SELECT COUNT(*) INTO v_total_count FROM temp_licencias_vigentes;

    -- Retornar resultados paginados con total_records
    RETURN QUERY
    SELECT
        t.numero,
        t.propietario,
        t.giro,
        t.direccion,
        t.zona,
        t.estado,
        t.fecha_otorgamiento,
        t.vigencia_hasta,
        v_total_count as total_records
    FROM temp_licencias_vigentes t
    ORDER BY t.numero DESC
    LIMIT p_limit
    OFFSET v_offset;

    -- Limpiar tabla temporal
    DROP TABLE IF EXISTS temp_licencias_vigentes;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIO DEL SP
-- =====================================================
COMMENT ON FUNCTION public.licenciasvigentesfrm_sp_licencias_vigentes IS
'Stored Procedure para el módulo de Licencias Vigentes.
Retorna licencias con paginación y filtros opcionales.
Parámetros:
- p_page: Número de página (default 1)
- p_limit: Registros por página (default 25)
- p_giro: Filtro por descripción de giro (búsqueda parcial)
- p_zona: Filtro por zona exacta
- p_estado: Filtro por estado (VIGENTE, SUSPENDIDA, TEMPORAL, CANCELADA, BAJA)
- p_fecha_desde: Filtro de fecha inicial
- p_fecha_hasta: Filtro de fecha final
- p_propietario: Filtro por nombre de propietario (búsqueda parcial)';
