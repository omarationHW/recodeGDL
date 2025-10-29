-- Stored Procedure: sp_get_pagos_energia
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de energía eléctrica para un id_energia
-- Generado para formulario: ConsCapturaEnergia
-- Fecha: 2025-08-26 23:12:09

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INTEGER)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(10),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    cve_consumo VARCHAR(2),
    cantidad NUMERIC(12,2),
    folio VARCHAR(20),
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR(50),
    datoslocal TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_pago_energia,
        p.id_energia,
        p.axo,
        p.periodo,
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.operacion_pago,
        p.importe_pago,
        p.cve_consumo,
        p.cantidad,
        p.folio,
        p.fecha_modificacion,
        u.usuario,
        CONCAT(l.oficina, ' ', l.num_mercado, ' ', l.categoria, ' ', l.seccion, ' ', l.local, ' ', l.letra_local, ' ', l.bloque) AS datoslocal
    FROM ta_11_pago_energia p
    JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    JOIN ta_11_energia e ON p.id_energia = e.id_energia
    JOIN ta_11_locales l ON e.id_local = l.id_local
    WHERE p.id_energia = p_id_energia
    ORDER BY p.axo, p.periodo;
END;
$$ LANGUAGE plpgsql;