-- Stored Procedure: spd_17_estadisticas_periodos
-- Tipo: Report
-- Descripción: Obtiene estadísticas de contratos por periodo y adeudo mínimo
-- Generado para formulario: EstadisticasContratos
-- Fecha: 2025-08-27 14:35:30

-- PostgreSQL version of spd_17_estadisticas_periodos
CREATE OR REPLACE FUNCTION spd_17_estadisticas_periodos(parm_alo integer, parm_adeudo numeric, parm_detalle integer)
RETURNS TABLE(
    plazo integer,
    cve_plazo varchar,
    axo_obra integer,
    axo_firma integer,
    saldo_real numeric,
    desc_plazo varchar,
    num_cve_pzo integer,
    costo numeric,
    parc_pagos integer,
    estado varchar,
    colonia integer,
    calle integer,
    folio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.plazo,
        c.clave_plazo,
        c.axo_obra,
        EXTRACT(YEAR FROM c.fecha_firma)::integer AS axo_firma,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo_real,
        CASE c.clave_plazo WHEN 'M' THEN 'MENSUAL' WHEN 'Q' THEN 'QUINCENAL' ELSE 'SEMANAL' END AS desc_plazo,
        CASE c.clave_plazo WHEN 'M' THEN 2 WHEN 'Q' THEN 1 ELSE 3 END AS num_cve_pzo,
        c.pago_total AS costo,
        c.pagos_parciales,
        c.vigencia,
        c.colonia,
        c.calle,
        c.folio
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND (c.pago_total - COALESCE(SUM(p.importe),0)) >= parm_adeudo
    GROUP BY c.plazo, c.clave_plazo, c.axo_obra, c.fecha_firma, c.pago_total, c.pagos_parciales, c.vigencia, c.colonia, c.calle, c.folio;
END;
$$ LANGUAGE plpgsql;