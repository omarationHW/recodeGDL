-- Stored Procedure: spd_17_est_periodo
-- Tipo: Report
-- Descripción: Obtiene la estadística de adeudos por periodo, agrupando por plazo y año de firma, filtrando por año de obra y adeudo mínimo.
-- Generado para formulario: RptEstadisticasPeriodos
-- Fecha: 2025-08-27 15:40:20

-- PostgreSQL version of spd_17_est_periodo
CREATE OR REPLACE FUNCTION spd_17_est_periodo(parm_alo integer, parm_adeudo numeric)
RETURNS TABLE (
    plazo smallint,
    cve_plazo varchar(1),
    axo_obra smallint,
    axo_firma smallint,
    saldo_real numeric,
    desc_plazo varchar(20),
    num_cve_pzo smallint,
    plazocorte integer,
    costo numeric,
    parc_pagos smallint,
    estado varchar(20),
    colonia smallint,
    calle smallint,
    folio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.plazo,
        c.clave_plazo,
        c.axo_obra,
        c.axo_firma,
        (c.saldo_real) as saldo_real,
        CASE c.clave_plazo
            WHEN 'Q' THEN 'QUINCENAL'
            WHEN 'M' THEN 'MENSUAL'
            WHEN 'S' THEN 'SEMANAL'
            ELSE 'OTRO'
        END as desc_plazo,
        CASE c.clave_plazo
            WHEN 'Q' THEN 1
            WHEN 'M' THEN 2
            WHEN 'S' THEN 3
            ELSE 0
        END as num_cve_pzo,
        (c.plazo::text ||
         CASE c.clave_plazo
            WHEN 'Q' THEN '1'
            WHEN 'M' THEN '2'
            WHEN 'S' THEN '3'
            ELSE '0'
         END)::integer as plazocorte,
        c.costo,
        c.parc_pagos,
        CASE WHEN c.vigencia = 'A' THEN 'VIGENTE' ELSE 'CANCELADO' END as estado,
        c.colonia,
        c.calle,
        c.folio
    FROM ta_17_convenios c
    WHERE c.axo_obra = parm_alo
      AND c.saldo_real >= parm_adeudo
    ORDER BY plazocorte, axo_firma;
END;
$$ LANGUAGE plpgsql;