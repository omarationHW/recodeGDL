-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPagosDesarrollo
-- Generado: 2025-08-27 15:46:39
-- Total SPs: 2
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
    FROM ta_17_calles a
    JOIN ta_17_convenios b ON a.colonia = b.colonia AND a.calle = b.calle
    JOIN ta_17_pagos c ON b.id_convenio = c.id_convenio
    JOIN ta_17_tipos t ON a.tipo = t.tipo
    WHERE c.fecha_pago BETWEEN fecdesde AND fechasta
      AND (a.tipo = 11 OR a.tipo >= 15)
    GROUP BY a.tipo, a.axo_obra, t.descripcion
    ORDER BY a.tipo, a.axo_obra;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: cat_fondos
-- Tipo: Catalog
-- Descripción: Catálogo de fondos (tipos de obra pública) para combos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cat_fondos()
RETURNS TABLE (
    tipo SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

