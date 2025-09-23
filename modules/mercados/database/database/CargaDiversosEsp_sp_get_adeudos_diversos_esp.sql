-- Stored Procedure: sp_get_adeudos_diversos_esp
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos pendientes para la fecha de pago seleccionada, excluyendo los ya pagados.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 22:49:31

CREATE OR REPLACE FUNCTION sp_get_adeudos_diversos_esp(p_fecha_pago DATE)
RETURNS TABLE(
    FECHA DATE,
    REC SMALLINT,
    CAJA VARCHAR,
    OPER INTEGER,
    "AÑO" SMALLINT,
    MES SMALLINT,
    RENTA NUMERIC,
    OFN SMALLINT,
    MER SMALLINT,
    CAT SMALLINT,
    SEC VARCHAR,
    LOCAL INTEGER,
    LET VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.fecing AS FECHA,
        a.recing AS REC,
        a.cajing AS CAJA,
        a.opcaja AS OPER,
        b.axo_desde AS "AÑO",
        b.mes_desde AS MES,
        SUM(b.importe_cta) AS RENTA,
        CASE WHEN b.cta_aplicacion=44514 THEN 5 ELSE 5 END AS OFN,
        CASE WHEN b.cta_aplicacion=44514 THEN 14 ELSE 15 END AS MER,
        CASE WHEN b.cta_aplicacion=44514 THEN 2 ELSE 3 END AS CAT,
        'SS' AS SEC,
        a.colonia AS LOCAL,
        a.letras AS LET
    FROM ta_12_ingreso a
    JOIN ta_12_importes b ON a.fecing=b.fecing AND a.recing=b.recing AND a.cajing=b.cajing AND a.opcaja=b.opcaja
    WHERE a.fecing = p_fecha_pago
      AND a.tipo_rbo=12
      AND (b.cta_aplicacion = 44514 OR b.cta_aplicacion=44515)
      AND NOT EXISTS (
        SELECT 1 FROM ta_11_pagos_local pl
        WHERE pl.fecha_pago=a.fecing AND pl.oficina_pago=a.recing AND pl.caja_pago=a.cajing AND pl.operacion_pago=a.opcaja
      )
    GROUP BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.letras, b.cta_aplicacion, b.mes_desde, b.axo_desde
    ORDER BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, b.mes_desde, b.axo_desde;
END;
$$ LANGUAGE plpgsql;