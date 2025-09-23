-- Stored Procedure: sp_get_pagos_locales
-- Tipo: Report
-- Descripción: Obtiene los pagos de locales en un rango de fechas y recaudadora
-- Generado para formulario: ListadosLocales
-- Fecha: 2025-08-27 00:08:33

CREATE OR REPLACE FUNCTION sp_get_pagos_locales(p_fecha_desde DATE, p_fecha_hasta DATE, p_recaudadora_id INT)
RETURNS TABLE(
    id_pago_local INT,
    id_local INT,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(10),
    operacion_pago INT,
    importe_pago NUMERIC,
    folio VARCHAR(20),
    nombre VARCHAR(30),
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_pago_local, p.id_local, p.axo, p.periodo, p.fecha_pago, p.oficina_pago, p.caja_pago, p.operacion_pago, p.importe_pago, p.folio,
           l.nombre, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque
    FROM ta_11_pagos_local p
    JOIN ta_11_locales l ON l.id_local = p.id_local
    WHERE p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
      AND p.oficina_pago = p_recaudadora_id
    ORDER BY p.fecha_pago, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;