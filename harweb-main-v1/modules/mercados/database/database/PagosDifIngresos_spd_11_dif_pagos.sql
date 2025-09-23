-- Stored Procedure: spd_11_dif_pagos
-- Tipo: Report
-- Descripción: Obtiene pagos con datos diferentes en ingresos (pagos con cuenta, caja u operación errónea) en el rango de fechas y recaudadora.
-- Generado para formulario: PagosDifIngresos
-- Fecha: 2025-08-27 00:21:53

CREATE OR REPLACE FUNCTION spd_11_dif_pagos(
    parm_rec integer,
    parm_fpadsd date,
    parm_fpahst date
) RETURNS TABLE (
    id_pago_local integer,
    id_local integer,
    axo smallint,
    periodo smallint,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    folio varchar,
    fecha_modificacion timestamp,
    id_usuario integer,
    usuario varchar,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    cuenta_ingreso integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_pago_local, a.id_local, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.folio, a.fecha_modificacion, a.id_usuario, d.usuario, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, c.cuenta_ingreso
    FROM ta_11_pagos_local a
    JOIN ta_11_locales b ON b.id_local = a.id_local
    JOIN ta_11_mercados c ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
    JOIN ta_12_passwords d ON d.id_usuario = a.id_usuario
    WHERE a.fecha_pago BETWEEN parm_fpadsd AND parm_fpahst
      AND c.oficina = parm_rec
      AND (
        a.oficina_pago NOT IN (SELECT cta_aplicacion FROM ta_12_importes WHERE recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=c.cuenta_ingreso)
        OR a.caja_pago NOT IN (SELECT cajing FROM ta_12_importes WHERE recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=c.cuenta_ingreso)
        OR a.operacion_pago NOT IN (SELECT opcaja FROM ta_12_importes WHERE recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=c.cuenta_ingreso)
        OR c.cuenta_ingreso NOT IN (SELECT cta_aplicacion FROM ta_12_importes WHERE recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=c.cuenta_ingreso)
      )
    ORDER BY a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago;
END;
$$ LANGUAGE plpgsql;