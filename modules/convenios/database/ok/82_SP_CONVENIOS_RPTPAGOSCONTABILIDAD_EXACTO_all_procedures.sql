-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSCONTABILIDAD (EXACTO del archivo original)
-- Archivo: 82_SP_CONVENIOS_RPTPAGOSCONTABILIDAD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_rpt_pagos_contabilidad
-- Tipo: Report
-- Descripción: Reporte de pagos de contabilidad agrupado por tipo, año de obra y cuenta de ingreso, con descripción del fondo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_pagos_contabilidad(p_fecdesde DATE, p_fechasta DATE)
RETURNS TABLE (
    tipo SMALLINT,
    axo_obra SMALLINT,
    cuenta_ingreso INTEGER,
    ingreso NUMERIC(18,2),
    descripcion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.tipo,
        c.axo_obra,
        c.cuenta_ingreso,
        SUM(p.importe) AS ingreso,
        t.descripcion
    FROM public.ta_17_calles c
    JOIN public.ta_17_convenios v ON c.colonia = v.colonia AND c.calle = v.calle
    JOIN public.ta_17_pagos p ON v.id_convenio = p.id_convenio
    JOIN public.ta_17_tipos t ON c.tipo = t.tipo
    WHERE p.fecha_pago BETWEEN p_fecdesde AND p_fechasta
      AND c.tipo >= 15
    GROUP BY c.tipo, c.axo_obra, c.cuenta_ingreso, t.descripcion
    ORDER BY c.tipo, c.axo_obra, c.cuenta_ingreso;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSCONTABILIDAD (EXACTO del archivo original)
-- Archivo: 82_SP_CONVENIOS_RPTPAGOSCONTABILIDAD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

