-- Stored Procedure: sp_get_pagos_energia_fecha
-- Tipo: Report
-- Descripción: Obtiene los pagos de energía eléctrica por fecha/oficina/caja/operación.
-- Generado para formulario: ConsCapturaFechaEnergia
-- Fecha: 2025-08-26 23:14:48

CREATE OR REPLACE FUNCTION sp_get_pagos_energia_fecha(
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    nivel SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    datoslocal VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_pago_energia, a.id_energia, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.cve_consumo, a.cantidad, a.folio, a.fecha_modificacion,
        b.usuario, b.nombre, b.estado, b.id_rec, b.nivel,
        c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
        CONCAT(c.oficina, '-', c.num_mercado, '-', c.categoria, '-', c.seccion, '-', c.local, '-', COALESCE(c.letra_local,''), '-', COALESCE(c.bloque,'')) AS datoslocal
    FROM ta_11_pago_energia a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_energia d ON a.id_energia = d.id_energia
    JOIN ta_11_locales c ON d.id_local = c.id_local
    WHERE a.fecha_pago = p_fecha_pago
      AND a.oficina_pago = p_oficina_pago
      AND a.caja_pago = p_caja_pago
      AND a.operacion_pago = p_operacion_pago
    ORDER BY a.id_energia ASC, a.axo ASC, a.periodo ASC;
END;
$$ LANGUAGE plpgsql;