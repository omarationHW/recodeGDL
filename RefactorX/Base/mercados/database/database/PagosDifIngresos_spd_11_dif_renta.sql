-- Stored Procedure: spd_11_dif_renta
-- Tipo: Report
-- Descripción: Obtiene pagos con renta errónea (pagos con importe diferente al esperado) en el rango de fechas y recaudadora.
-- Generado para formulario: PagosDifIngresos
-- Fecha: 2025-08-27 00:21:53

DROP FUNCTION IF EXISTS spd_11_dif_renta(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION spd_11_dif_renta(
    parm_rec INTEGER,
    parm_fpadsd DATE,
    parm_fpahst DATE
) RETURNS TABLE (
    id_pago_local INTEGER,
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER,
    importe_pago NUMERIC(16,2),
    folio CHAR(10),
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(20),
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(2),
    renta_esperada NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_pago_local, a.id_local, a.axo, a.periodo, a.fecha_pago,
        a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago,
        a.folio, a.fecha_modificacion, a.id_usuario, d.usuario,
        b.oficina, b.num_mercado, b.categoria, b.seccion, b.local,
        b.letra_local, b.bloque,
        (CASE
            WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
            WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
            ELSE b.superficie * cu.importe_cuota
        END)::NUMERIC(16,2) AS renta_esperada
    FROM publico.ta_11_pagos_local a
    JOIN publico.ta_11_locales b ON b.id_local = a.id_local
    JOIN public.ta_11_mercados c ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
    LEFT JOIN public.usuarios d ON d.id = a.id_usuario
    JOIN publico.ta_11_cuo_locales cu ON cu.axo = a.axo AND cu.categoria = b.categoria AND cu.seccion = b.seccion AND cu.clave_cuota = b.clave_cuota
    WHERE a.fecha_pago BETWEEN parm_fpadsd AND parm_fpahst
      AND c.oficina = parm_rec
      AND (
        a.importe_pago <> (CASE
            WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
            WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
            ELSE b.superficie * cu.importe_cuota
        END)
      )
    ORDER BY a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago;
END;
$$ LANGUAGE plpgsql;