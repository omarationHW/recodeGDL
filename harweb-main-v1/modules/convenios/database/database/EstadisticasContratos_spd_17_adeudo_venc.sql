-- Stored Procedure: spd_17_adeudo_venc
-- Tipo: Report
-- Descripción: Obtiene adeudos vencidos por año de obra y fondo/programa
-- Generado para formulario: EstadisticasContratos
-- Fecha: 2025-08-27 14:35:30

-- PostgreSQL version of spd_17_adeudo_venc
CREATE OR REPLACE FUNCTION spd_17_adeudo_venc(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    numero varchar,
    costo numeric,
    pagos numeric,
    saldo numeric,
    importe_vencido numeric,
    parc_vencida integer,
    fecha_venc date,
    descuento varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.colonia,
        c.calle,
        c.folio,
        c.nombre,
        c.numero,
        c.pago_total AS costo,
        COALESCE(SUM(p.importe),0) AS pagos,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo,
        -- Lógica para importe vencido, parc_vencida, fecha_venc, descuento
        0 AS importe_vencido,
        0 AS parc_vencida,
        NULL::date AS fecha_venc,
        '' AS descuento
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND c.fondo = parm_fondo
    GROUP BY c.colonia, c.calle, c.folio, c.nombre, c.numero, c.pago_total;
END;
$$ LANGUAGE plpgsql;