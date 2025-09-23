-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTCOLONIAS (EXACTO del archivo original)
-- Archivo: 76_SP_CONVENIOS_RPTCOLONIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_colonias_list
-- Tipo: Report
-- Descripción: Devuelve el catálogo de colonias con su zona asociada, para reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_colonias_list()
RETURNS TABLE (
    colonia smallint,
    descripcion varchar(50),
    id_rec smallint,
    id_zona integer,
    col_obra94 smallint,
    id_usuario integer,
    fecha_actual timestamp,
    zona varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.descripcion, a.id_rec, a.id_zona, a.col_obra94, a.id_usuario, a.fecha_actual, UPPER(b.zona) AS zona
    FROM public.ta_17_colonias a
    JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona
    ORDER BY a.colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

