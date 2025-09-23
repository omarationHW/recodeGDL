-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPagosContratosDecsDev
-- Generado: 2025-08-27 15:45:22
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_pagos_contratos_descs_dev
-- Tipo: Report
-- Descripción: Reporte de contratos que pagaron con descuento por colonia. Devuelve los campos requeridos para el reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_pagos_contratos_descs_dev(p_colonia integer)
RETURNS TABLE (
    colonia smallint,
    calle smallint,
    folio integer,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar(1),
    operacion_pago integer,
    pago_parcial smallint,
    total_parciales smallint,
    importe numeric(18,2),
    cve_descuento smallint,
    cve_bonificacion smallint,
    descripcion varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.calle, a.folio, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago,
           b.pago_parcial, b.total_parciales, b.importe, b.cve_descuento, b.cve_bonificacion, c.descripcion
    FROM ta_17_convenios a
    JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio
    JOIN ta_17_colonias c ON a.colonia = c.colonia
    WHERE a.colonia = p_colonia
      AND b.cve_descuento > 0
    ORDER BY a.colonia, a.calle, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

