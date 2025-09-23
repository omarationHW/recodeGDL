-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSDESARROLLO (EXACTO del archivo original)
-- Archivo: 84_SP_CONVENIOS_RPTPAGOSDESARROLLO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: rpt_pagos_desarrollo
-- Tipo: Report
-- Descripción: Obtiene el reporte de pagos de desarrollo por fondo y año de obra en un rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_pagos_desarrollo(fecdesde DATE, fechasta DATE)
RETURNS TABLE (
    tipo SMALLINT,
    axo_obra SMALLINT,
    ingreso NUMERIC,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.tipo,
        a.axo_obra,
        SUM(c.importe) AS ingreso,
        t.descripcion
    FROM public.ta_17_calles a
    JOIN public.ta_17_convenios b ON a.colonia = b.colonia AND a.calle = b.calle
    JOIN public.ta_17_pagos c ON b.id_convenio = c.id_convenio
    JOIN public.ta_17_tipos t ON a.tipo = t.tipo
    WHERE c.fecha_pago BETWEEN fecdesde AND fechasta
      AND (a.tipo = 11 OR a.tipo >= 15)
    GROUP BY a.tipo, a.axo_obra, t.descripcion
    ORDER BY a.tipo, a.axo_obra;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSDESARROLLO (EXACTO del archivo original)
-- Archivo: 84_SP_CONVENIOS_RPTPAGOSDESARROLLO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

