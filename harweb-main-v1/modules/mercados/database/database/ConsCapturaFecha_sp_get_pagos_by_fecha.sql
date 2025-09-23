-- Stored Procedure: sp_get_pagos_by_fecha
-- Tipo: Report
-- Descripción: Obtiene los pagos capturados por fecha, oficina, caja y operación.
-- Generado para formulario: ConsCapturaFecha
-- Fecha: 2025-08-26 23:13:33

CREATE OR REPLACE FUNCTION sp_get_pagos_by_fecha(
    p_fecha DATE,
    p_oficina INTEGER,
    p_caja VARCHAR,
    p_operacion INTEGER
)
RETURNS TABLE (
    id_local INTEGER,
    datoslocal TEXT,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    letra_local VARCHAR,
    bloque VARCHAR,
    clave_cuota SMALLINT,
    superficie NUMERIC,
    local INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_local,
        CONCAT(c.oficina, ' ', c.num_mercado, ' ', c.categoria, ' ', c.seccion, ' ', c.local, ' ', COALESCE(c.letra_local, ''), ' ', COALESCE(c.bloque, '')) AS datoslocal,
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
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usuario
    JOIN ta_11_locales c ON c.id_local = a.id_local
    WHERE a.fecha_pago = p_fecha
      AND a.oficina_pago = p_oficina
      AND a.caja_pago = p_caja
      AND a.operacion_pago = p_operacion
    ORDER BY a.id_local, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;