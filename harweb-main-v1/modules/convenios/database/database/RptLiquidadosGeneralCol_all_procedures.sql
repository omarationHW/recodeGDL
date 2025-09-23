-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptLiquidadosGeneralCol
-- Generado: 2025-08-27 15:41:49
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_liquidados_general_col
-- Tipo: Report
-- Descripción: Reporte de contratos vigentes liquidados con saldo menor o igual a un importe dado por colonia.
-- --------------------------------------------

-- DROP FUNCTION IF EXISTS rpt_liquidados_general_col(integer, numeric);
CREATE OR REPLACE FUNCTION rpt_liquidados_general_col(p_colonia integer, p_importe numeric)
RETURNS TABLE (
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    pago_total numeric,
    pagos numeric,
    descripcion varchar,
    devolucion numeric,
    pagosreal numeric,
    concepto varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_convenio,
        a.colonia,
        a.calle,
        a.folio,
        a.nombre,
        a.pago_total,
        COALESCE(SUM(b.importe), 0) AS pagos,
        d.descripcion,
        (
            SELECT COALESCE(SUM(importe), 0)
            FROM ta_17_devoluciones
            WHERE id_convenio = a.id_convenio
        ) AS devolucion,
        (COALESCE(SUM(b.importe), 0) - (
            SELECT COALESCE(SUM(importe), 0)
            FROM ta_17_devoluciones
            WHERE id_convenio = a.id_convenio
        )) AS pagosreal,
        CASE
            WHEN (a.pago_total - (COALESCE(SUM(b.importe), 0) - (
                SELECT COALESCE(SUM(importe), 0)
                FROM ta_17_devoluciones
                WHERE id_convenio = a.id_convenio
            ))) > 0 THEN 'ADE'
            WHEN (a.pago_total - (COALESCE(SUM(b.importe), 0) - (
                SELECT COALESCE(SUM(importe), 0)
                FROM ta_17_devoluciones
                WHERE id_convenio = a.id_convenio
            ))) = 0 THEN 'LIQ'
            ELSE 'SAF'
        END AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia
      AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, d.descripcion
    HAVING (
        a.pago_total - (
            COALESCE(SUM(b.importe), 0)
            + (
                SELECT COALESCE(SUM(g.importe), 0)
                FROM ta_17_convenios h
                JOIN ta_17_pagos f ON h.id_convenio = a.id_convenio AND f.id_convenio = h.id_convenio AND h.clave_historia = 2
                JOIN ta_12_recibosdet g ON g.fecha = f.fecha_pago AND g.id_rec = f.oficina_pago AND g.caja = f.caja_pago AND g.operacion = f.operacion_pago AND g.cuenta IN (46210, 570200000)
            )
            - (
                SELECT COALESCE(SUM(importe), 0)
                FROM ta_17_devoluciones
                WHERE id_convenio = a.id_convenio
            )
        )
    ) <= p_importe
    ORDER BY a.colonia, a.calle, a.folio;
END;
$$ LANGUAGE plpgsql;


-- ============================================

