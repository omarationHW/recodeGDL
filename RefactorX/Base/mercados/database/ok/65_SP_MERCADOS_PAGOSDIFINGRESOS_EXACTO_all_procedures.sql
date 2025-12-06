-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PagosDifIngresos
-- Generado: 2025-08-27 00:21:53
-- Actualizado: 2025-12-01
-- Total SPs: 2
-- ============================================

-- SP 1/2: spd_11_dif_pagos
-- Tipo: Report
-- Descripción: Obtiene pagos con datos diferentes en ingresos (pagos con cuenta, caja u operación errónea) en el rango de fechas.
-- --------------------------------------------

DROP FUNCTION IF EXISTS public.spd_11_dif_pagos(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION public.spd_11_dif_pagos(
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
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    cuenta_ingreso INTEGER
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
        d.usuario,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        c.cuenta_ingreso
    FROM padron_licencias.comun.ta_11_pagos_local a
    INNER JOIN padron_licencias.comun.ta_11_locales b
        ON b.id_local = a.id_local
    INNER JOIN padron_licencias.comun.ta_11_mercados c
        ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
    INNER JOIN padron_licencias.comun.ta_12_passwords d
        ON d.id_usuario = a.id_usuario
    WHERE a.fecha_pago BETWEEN parm_fpadsd AND parm_fpahst
      AND c.oficina = parm_rec
      AND (
        a.oficina_pago NOT IN (
            SELECT cta_aplicacion
            FROM public.ta_12_importes
            WHERE recing = a.oficina_pago
              AND cajing = a.caja_pago
              AND opcaja = a.operacion_pago
              AND cta_aplicacion = c.cuenta_ingreso
        )
        OR a.caja_pago NOT IN (
            SELECT cajing
            FROM public.ta_12_importes
            WHERE recing = a.oficina_pago
              AND cajing = a.caja_pago
              AND opcaja = a.operacion_pago
              AND cta_aplicacion = c.cuenta_ingreso
        )
        OR a.operacion_pago NOT IN (
            SELECT opcaja
            FROM public.ta_12_importes
            WHERE recing = a.oficina_pago
              AND cajing = a.caja_pago
              AND opcaja = a.operacion_pago
              AND cta_aplicacion = c.cuenta_ingreso
        )
        OR c.cuenta_ingreso NOT IN (
            SELECT cta_aplicacion
            FROM public.ta_12_importes
            WHERE recing = a.oficina_pago
              AND cajing = a.caja_pago
              AND opcaja = a.operacion_pago
              AND cta_aplicacion = c.cuenta_ingreso
        )
      )
    ORDER BY a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.spd_11_dif_pagos(INTEGER, DATE, DATE) IS
'Reporte de pagos con datos erróneos (cuenta, caja u operación incorrecta).
Parámetros:
  - parm_rec: ID de recaudadora
  - parm_fpadsd: Fecha desde
  - parm_fpahst: Fecha hasta
Retorna pagos que no coinciden con ta_12_importes.';

-- ============================================

-- SP 2/2: spd_11_dif_renta
-- Tipo: Report
-- Descripción: Obtiene pagos con renta errónea (pagos con importe diferente al esperado) en el rango de fechas.
-- --------------------------------------------

DROP FUNCTION IF EXISTS public.spd_11_dif_renta(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION public.spd_11_dif_renta(
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
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    cuenta_ingreso INTEGER,
    renta_esperada NUMERIC
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
        d.usuario,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        c.cuenta_ingreso,
        (CASE
            WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
            WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
            ELSE b.superficie * cu.importe_cuota
        END) AS renta_esperada
    FROM padron_licencias.comun.ta_11_pagos_local a
    INNER JOIN padron_licencias.comun.ta_11_locales b
        ON b.id_local = a.id_local
    INNER JOIN padron_licencias.comun.ta_11_mercados c
        ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
    INNER JOIN padron_licencias.comun.ta_12_passwords d
        ON d.id_usuario = a.id_usuario
    INNER JOIN padron_licencias.comun.ta_11_cuo_locales cu
        ON cu.axo = a.axo
        AND cu.categoria = b.categoria
        AND cu.seccion = b.seccion
        AND cu.clave_cuota = b.clave_cuota
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

COMMENT ON FUNCTION public.spd_11_dif_renta(INTEGER, DATE, DATE) IS
'Reporte de pagos con renta errónea (importe diferente al esperado).
Parámetros:
  - parm_rec: ID de recaudadora
  - parm_fpadsd: Fecha desde
  - parm_fpahst: Fecha hasta
Retorna pagos donde el importe no coincide con el cálculo esperado.';

-- ============================================

