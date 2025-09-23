-- Stored Procedure: sp_cons_pagos_get_by_local
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de un local específico, incluyendo datos relacionados.
-- Generado para formulario: ConsPagos
-- Fecha: 2025-08-27 16:01:41

CREATE OR REPLACE FUNCTION sp_cons_pagos_get_by_local(p_id_local INTEGER)
RETURNS TABLE (
    id_pago_local INTEGER,
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(10),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    folio VARCHAR(50),
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR(50),
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(10),
    letra_local VARCHAR(10),
    bloque VARCHAR(10),
    clave_cuota SMALLINT,
    superficie NUMERIC(12,2),
    local INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_pago_local,
        a.id_local,
        a.axo,
        a.periodo,
        a.fecha_pago,
        a.oficina_pago,
        a.caja_pago,
        a.operacion_pago,
        a.importe_pago,
        a.folio,
        a.fecha_modificacion,
        b.usuario,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.letra_local,
        c.bloque,
        c.clave_cuota,
        c.superficie,
        c.local
    FROM ta_11_pagos_local a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON a.id_local = c.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;