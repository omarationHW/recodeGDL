-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPagosLocales
-- Generado: 2025-08-27 01:28:57
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_rpt_pagos_locales
-- Tipo: Report
-- Descripción: Devuelve el listado de pagos locales entre fechas y por oficina, con todos los datos requeridos para el reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_pagos_locales(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_oficina INT
)
RETURNS TABLE (
    id_pago_local INT,
    id_local INT,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(10),
    operacion_pago INT,
    importe_pago NUMERIC(12,2),
    folio VARCHAR(20),
    fecha_modificacion TIMESTAMP,
    id_usuario INT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(10),
    local INT,
    letra_local VARCHAR(5),
    bloque VARCHAR(5),
    usuario VARCHAR(50),
    nombre VARCHAR(100),
    recaudadora VARCHAR(100),
    datoslocal VARCHAR(255),
    axoper VARCHAR(20)
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
        a.id_usuario,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        c.usuario,
        c.nombre,
        d.recaudadora,
        -- datoslocal: oficina num_mercado categoria seccion local letra_local bloque
        CONCAT(b.oficina, ' ', b.num_mercado, ' ', b.categoria, ' ', b.seccion, ' ', b.local, ' ', COALESCE(b.letra_local, ''), ' ', COALESCE(b.bloque, '')) AS datoslocal,
        -- axoper: axo-periodo
        CONCAT(a.axo, '-', a.periodo) AS axoper
    FROM ta_11_pagos_local a
    JOIN ta_11_locales b ON b.id_local = a.id_local
    JOIN ta_12_passwords c ON c.id_usuario = a.id_usuario
    JOIN ta_12_recaudadoras d ON d.id_rec = a.oficina_pago
    WHERE a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
      AND b.oficina = p_oficina
    ORDER BY a.oficina_pago, a.fecha_pago, a.caja_pago, a.operacion_pago, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve la lista de recaudadoras para combos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE (
    id_rec INT,
    recaudadora VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora
    FROM ta_12_recaudadoras
    ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

