-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FORMABUSCOLONIA (EXACTO del archivo original)
-- Archivo: 66_SP_LICENCIAS_FORMABUSCOLONIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_buscar_colonias
-- Tipo: Catalog
-- Descripción: Busca colonias por municipio (c_mnpio=39) y filtro de nombre (LIKE, insensible a mayúsculas/minúsculas). Devuelve colonia, d_codigopostal, d_tipo_asenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_colonias(p_c_mnpio integer, p_filtro text)
RETURNS TABLE (
    colonia text,
    d_codigopostal integer,
    d_tipo_asenta text
) AS $$
BEGIN
    RETURN QUERY
    SELECT colonia, d_codigopostal, d_tipo_asenta
    FROM cp_correos
    WHERE c_mnpio = p_c_mnpio
      AND (
        p_filtro IS NULL OR trim(p_filtro) = '' OR
        UPPER(colonia) LIKE '%' || UPPER(p_filtro) || '%'
      )
    ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FORMABUSCOLONIA (EXACTO del archivo original)
-- Archivo: 66_SP_LICENCIAS_FORMABUSCOLONIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

