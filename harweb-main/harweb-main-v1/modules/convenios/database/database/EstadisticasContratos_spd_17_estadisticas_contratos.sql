-- Stored Procedure: spd_17_estadisticas_contratos
-- Tipo: Report
-- Descripción: Obtiene estadísticas de contratos por año de obra y fondo/programa
-- Generado para formulario: EstadisticasContratos
-- Fecha: 2025-08-27 14:35:30

-- PostgreSQL version of spd_17_estadisticas_contratos
CREATE OR REPLACE FUNCTION spd_17_estadisticas_contratos(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    numero varchar,
    costo numeric,
    pagos numeric,
    saldo numeric
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
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND c.fondo = parm_fondo
    GROUP BY c.colonia, c.calle, c.folio, c.nombre, c.numero, c.pago_total;
END;
$$ LANGUAGE plpgsql;