-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTCALLES (EXACTO del archivo original)
-- Archivo: 74_SP_CONVENIOS_RPTCALLES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_calles_get_by_axo
-- Tipo: Report
-- Descripción: Obtiene el catálogo de calles y colonias para un año de obra específico, incluyendo estado calculado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_calles_get_by_axo(p_axo smallint)
RETURNS TABLE (
    colonia smallint,
    calle smallint,
    desc_calle varchar(50),
    vigencia_obra char(1),
    axo_obra smallint,
    descripcion varchar(50),
    descripcion_1 varchar(50),
    descripcion_2 varchar(50),
    estado varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.colonia,
        a.calle,
        a.desc_calle,
        a.vigencia_obra,
        a.axo_obra,
        b.descripcion,
        c.descripcion as descripcion_1,
        d.descripcion as descripcion_2,
        CASE WHEN a.vigencia_obra = 'A' THEN 'VIGENTE' ELSE 'CANCELADA' END as estado
    FROM public.ta_17_calles a
    JOIN public.ta_17_servicios b ON a.servicio = b.servicio
    JOIN public.ta_17_colonias c ON a.colonia = c.colonia
    JOIN public.ta_17_tipos d ON a.tipo = d.tipo
    WHERE a.axo_obra = p_axo
    GROUP BY a.colonia, a.calle, a.desc_calle, a.vigencia_obra, a.axo_obra, b.descripcion, c.descripcion, d.descripcion
    ORDER BY a.colonia, a.calle, a.desc_calle, a.vigencia_obra, a.axo_obra, b.descripcion, c.descripcion, d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

