-- Stored Procedure: spd_12_gastoscobxrec
-- Tipo: Report
-- Descripción: Obtiene los pagos de gastos de cobranza por recaudadora en un rango de fechas.
-- Generado para formulario: Lista_GastosCob
-- Fecha: 2025-08-27 20:47:17

CREATE OR REPLACE FUNCTION spd_12_gastoscobxrec(p_fechad DATE, p_fechah DATE, p_rec INTEGER)
RETURNS TABLE (
    r_fecp DATE,
    r_rec INTEGER,
    r_caja VARCHAR(2),
    r_oper INTEGER,
    r_imptecta NUMERIC,
    r_totcert NUMERIC,
    r_folio INTEGER,
    r_ofnaf INTEGER,
    r_fecemi DATE,
    r_fecpra DATE,
    r_fecent DATE,
    r_imptegf NUMERIC,
    r_ejecutor INTEGER,
    r_nomeje VARCHAR(70),
    r_datos VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha AS r_fecp,
        p.id_rec AS r_rec,
        p.caja AS r_caja,
        p.operacion AS r_oper,
        p.impte_gastos AS r_imptecta,
        p.importe AS r_totcert,
        a.folio AS r_folio,
        a.recaudadora AS r_ofnaf,
        a.fecha_emision AS r_fecemi,
        a.fecha_practicado AS r_fecpra,
        a.fecha_entrega1 AS r_fecent,
        a.importe_gastos AS r_imptegf,
        a.ejecutor AS r_ejecutor,
        e.nombre AS r_nomeje,
        CASE WHEN a.modulo=11 THEN CONCAT('MERCADO ', m.num_mercado, '-', m.categoria, '-', m.seccion, '-', m.local, '-', m.letra_local, '-', m.bloque)
             WHEN a.modulo=16 THEN CONCAT('ASEO ', aseo.tipo_aseo, '-', aseo.num_contrato)
             ELSE '' END AS r_datos
    FROM ta_12_recibos p
    JOIN ta_15_apremios a ON a.fecha_pago = p.fecha AND a.recaudadora = p.id_rec AND a.caja = p.caja AND a.operacion = p.operacion
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN ta_11_locales m ON a.control_otr = m.id_local AND a.modulo = 11
    LEFT JOIN ta_16_contratos aseo ON a.control_otr = aseo.control_contrato AND a.modulo = 16
    WHERE p.fecha BETWEEN p_fechad AND p_fechah
      AND p.id_rec = p_rec
      AND p.impte_gastos > 0
    ORDER BY p.fecha, p.id_rec, p.caja, p.operacion;
END;
$$ LANGUAGE plpgsql;