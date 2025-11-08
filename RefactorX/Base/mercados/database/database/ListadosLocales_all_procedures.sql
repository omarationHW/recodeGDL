-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ListadosLocales
-- Generado: 2025-08-27 00:08:33
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_padron_locales
-- Tipo: Report
-- Descripción: Obtiene el padrón de locales para una recaudadora y mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_padron_locales(p_recaudadora_id INT, p_mercado_id INT)
RETURNS TABLE(
    id_local INT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie FLOAT,
    renta NUMERIC,
    vigencia VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.superficie,
        CASE 
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
            WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * fd.sabadosacum
            ELSE l.superficie * c.importe_cuota
        END AS renta,
        l.vigencia
    FROM ta_11_locales l
    JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    JOIN ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    LEFT JOIN ta_11_fecha_desc fd ON fd.mes = EXTRACT(MONTH FROM CURRENT_DATE)
    WHERE l.oficina = p_recaudadora_id AND l.num_mercado = p_mercado_id
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_movimientos_locales
-- Tipo: Report
-- Descripción: Obtiene los movimientos de locales en un rango de fechas y recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_movimientos_locales(p_fecha_desde DATE, p_fecha_hasta DATE, p_recaudadora_id INT)
RETURNS TABLE(
    id_movimiento INT,
    fecha TIMESTAMP,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    tipodescripcion VARCHAR(50),
    nombre VARCHAR(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_movimiento, m.fecha, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque,
        CASE m.tipo_movimiento
            WHEN 1 THEN 'ALTA'
            WHEN 2 THEN 'CAMBIO DE GIRO'
            WHEN 3 THEN 'CAMBIO FECHA ALTA'
            WHEN 4 THEN 'CAMBIO NOMBRE LOC.'
            WHEN 5 THEN 'CAMBIO DOMICILIO'
            WHEN 6 THEN 'CAMBIO DE ZONA'
            WHEN 7 THEN 'CAMBIO LOCAL,SUPERF.'
            WHEN 8 THEN 'BAJA TOTAL'
            WHEN 9 THEN 'BAJA ADMINISTRATIVA'
            WHEN 10 THEN 'BAJA POR ACUERDO'
            WHEN 11 THEN 'REACTIVACION'
            WHEN 12 THEN 'BLOQUEADO'
            WHEN 13 THEN 'REACTIVAR BLOQUEO'
            ELSE 'OTRO'
        END AS tipodescripcion,
        l.nombre
    FROM ta_11_movimientos m
    JOIN ta_11_locales l ON l.id_local = m.id_local
    WHERE m.fecha::date BETWEEN p_fecha_desde AND p_fecha_hasta
      AND l.oficina = p_recaudadora_id
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, m.axo_memo, m.numero_memo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_pagos_locales
-- Tipo: Report
-- Descripción: Obtiene los pagos de locales en un rango de fechas y recaudadora
-- --------------------------------------------

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

-- ============================================

-- SP 4/4: sp_get_ingreso_zonificado
-- Tipo: Report
-- Descripción: Obtiene el ingreso global por zonas en un rango de fechas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ingreso_zonificado(p_fecha_desde DATE, p_fecha_hasta DATE)
RETURNS TABLE(
    id_zona INT,
    zona VARCHAR(50),
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_zona, z.zona, SUM(i.importe_cta) AS pagado
    FROM ta_12_ingreso a
    JOIN ta_12_importes i ON a.fecing = i.fecing AND a.recing = i.recing AND a.cajing = i.cajing AND a.opcaja = i.opcaja
    JOIN ta_11_mercados m ON i.cta_aplicacion = m.cuenta_ingreso
    JOIN ta_12_zonas z ON m.id_zona = z.id_zona
    WHERE a.fecing BETWEEN p_fecha_desde AND p_fecha_hasta
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
    GROUP BY m.id_zona, z.zona
    ORDER BY m.id_zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

