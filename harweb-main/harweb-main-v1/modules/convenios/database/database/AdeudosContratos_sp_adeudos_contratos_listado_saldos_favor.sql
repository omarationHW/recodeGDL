-- Stored Procedure: sp_adeudos_contratos_listado_saldos_favor
-- Tipo: Report
-- Descripción: Listado de contratos vigentes con saldos a favor
-- Generado para formulario: AdeudosContratos
-- Fecha: 2025-08-27 13:38:13

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_saldos_favor(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'SAF' AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) < 0;
END;
$$ LANGUAGE plpgsql;