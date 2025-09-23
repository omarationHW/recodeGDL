-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BUSQUEDASCIANFRM (EXACTO del archivo original)
-- Archivo: 10_SP_LICENCIAS_BUSQUEDASCIANFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: catalogo_scian_busqueda
-- Tipo: Catalog
-- Descripción: Devuelve los registros de c_scian vigentes filtrados por descripción o código_scian. Si el parámetro es vacío, devuelve todos los vigentes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_scian_busqueda(p_descripcion TEXT)
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
    RETURN QUERY
    SELECT 
        codigo_scian,
        descripcion,
        vigente,
        es_microgenerador,
        microgenerador_a,
        microgenerador_b,
        microgenerador_c,
        microgenerador_d,
        fecha_alta,
        usuario_alta,
        fecha_baja,
        usuario_baja,
        tipo
    FROM c_scian
    WHERE vigente = 'V'
      AND (
        p_descripcion IS NULL OR p_descripcion = ''
        OR (
          UPPER(descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
          OR CAST(codigo_scian AS VARCHAR) LIKE '%' || p_descripcion || '%'
        )
      )
    ORDER BY descripcion ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

