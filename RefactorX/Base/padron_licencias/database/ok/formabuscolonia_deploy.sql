-- ============================================
-- DEPLOY: formabuscolonia.vue
-- Módulo: padron_licencias
-- Componente: Formulario de Búsqueda de Colonias
-- Total SPs: 2
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'DESPLEGANDO: formabuscolonia (2 SPs)'
\echo '================================================'
\echo ''

-- SP 1/2: sp_buscar_colonias
CREATE OR REPLACE FUNCTION public.sp_buscar_colonias(p_c_mnpio INTEGER, p_filtro TEXT)
RETURNS TABLE (
    colonia TEXT,
    d_codigopostal INTEGER,
    d_tipo_asenta TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.colonia, c.d_codigopostal, c.d_tipo_asenta
    FROM public.cp_correos c
    WHERE c.c_mnpio = p_c_mnpio
      AND (
        p_filtro IS NULL OR trim(p_filtro) = '' OR
        UPPER(c.colonia) LIKE '%' || UPPER(p_filtro) || '%'
      )
    ORDER BY c.colonia
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 1/2: sp_buscar_colonias creado exitosamente'

-- SP 2/2: sp_obtener_colonia_seleccionada
CREATE OR REPLACE FUNCTION public.sp_obtener_colonia_seleccionada(p_c_mnpio INTEGER, p_colonia TEXT)
RETURNS TABLE (
    colonia TEXT,
    d_codigopostal INTEGER,
    d_tipo_asenta TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.colonia, c.d_codigopostal, c.d_tipo_asenta
    FROM public.cp_correos c
    WHERE c.c_mnpio = p_c_mnpio
      AND c.colonia = p_colonia
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 2/2: sp_obtener_colonia_seleccionada creado exitosamente'
\echo ''
\echo 'DEPLOY COMPLETADO: formabuscolonia'
\echo ''
