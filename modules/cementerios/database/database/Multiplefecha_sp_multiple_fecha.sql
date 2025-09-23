-- Stored Procedure: sp_multiple_fecha
-- Tipo: Report
-- Descripción: Devuelve pagos y títulos por fecha, recaudadora y caja (consulta múltiple por fecha de pago)
-- Generado para formulario: Multiplefecha
-- Fecha: 2025-08-27 14:40:23

-- PostgreSQL stored procedure for MultipleFecha
CREATE OR REPLACE FUNCTION sp_multiple_fecha(
    p_fecha DATE,
    p_rec SMALLINT,
    p_caja VARCHAR(10)
)
RETURNS TABLE (
    tipopag VARCHAR(10),
    fecing DATE,
    recing SMALLINT,
    cajing VARCHAR(10),
    opcaja INTEGER,
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC,
    importe_recargos NUMERIC,
    vigencia VARCHAR(2),
    usuario INTEGER,
    fecha_mov DATE,
    obser VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Manten' AS tipopag,
           fecing, recing, cajing, opcaja, control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos, vigencia, usuario, fecha_mov, '' AS obser
      FROM ta_13_pagosrcm
     WHERE fecing = p_fecha AND recing >= p_rec AND cajing >= p_caja
    UNION ALL
    SELECT 'Titulo' AS tipopag,
           fecha AS fecing, id_rec AS recing, caja AS cajing, operacion AS opcaja, 0 AS control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, tipo AS axo_pago_desde, titulo AS axo_pago_hasta, importe, 0, '', 0, CURRENT_DATE, observaciones
      FROM ta_13_titulos
     WHERE fecha = p_fecha AND id_rec >= p_rec AND caja >= p_caja
    ORDER BY fecing, recing, cajing, opcaja;
END;
$$ LANGUAGE plpgsql;