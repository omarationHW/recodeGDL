-- ========================================================================
-- SPs CORREGIDOS PARA PAGOSLOC GRL - REPORTE DE PAGOS POR MERCADO
-- Base de datos: padron_licencias
-- Fecha: 2025-12-04
-- ========================================================================

-- ========================================================================
-- SP 1: sp_get_recaudadoras
-- Obtiene el catálogo de oficinas recaudadoras
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE (
    id_rec SMALLINT,
    recaudadora VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.recaudadora
    FROM padron_licencias.comun.ta_12_recaudadoras r
    WHERE r.id_rec > 0
    ORDER BY r.id_rec;
END;
$$;

-- ========================================================================
-- SP 2: sp_get_mercados_by_recaudadora
-- Obtiene mercados filtrados por oficina recaudadora
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
    p_recaudadora_id SMALLINT
)
RETURNS TABLE (
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo,
        m.descripcion
    FROM padron_licencias.comun.ta_11_mercados m
    WHERE m.id_rec = p_recaudadora_id
    ORDER BY m.num_mercado_nvo;
END;
$$;

-- ========================================================================
-- SP 3: sp_get_pagos_loc_grl (PRINCIPAL)
-- Obtiene reporte de pagos por mercado con rango de fechas
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_get_pagos_loc_grl(
    p_rec_id SMALLINT,
    p_mercado_id SMALLINT,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE (
    num_mercado SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque SMALLINT,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago SMALLINT,
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    folio INTEGER,
    fecha_modificacion TEXT,
    usuario VARCHAR(15),
    fecha_emision DATE,
    folio_1 INTEGER,
    requerimientos TEXT,
    id_local INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.num_mercado,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        b.axo,
        b.periodo,
        b.fecha_pago,
        b.oficina_pago,
        b.caja_pago,
        b.operacion_pago,
        b.importe_pago,
        b.folio,
        to_char(b.fecha_modificacion, 'YYYY-MM-DD HH24:MI:SS') as fecha_modificacion,
        c.usuario,
        d.fecha_emision,
        d.folio as folio_1,
        (
            SELECT string_agg('(' || p.ayo || '-' || p.periodo || ')', ' ')
            FROM padron_licencias.comun.ta_15_periodos p
            WHERE p.control_otr = a.id_local
        ) as requerimientos,
        a.id_local
    FROM padron_licencias.comun.ta_11_locales a
    INNER JOIN padron_licencias.comun.ta_11_pagos_local b
        ON b.id_local = a.id_local
    INNER JOIN padron_licencias.comun.ta_12_passwords c
        ON c.id_usuario = b.id_usuario
    LEFT JOIN padron_licencias.comun.ta_15_apremios d
        ON d.modulo = 11
        AND d.control_otr = b.id_local
        AND d.vigencia = '2'
        AND d.fecha_pago = b.fecha_pago
        AND d.recaudadora = b.oficina_pago
        AND d.caja = b.caja_pago
        AND d.operacion = b.operacion_pago
    WHERE a.oficina = p_rec_id
        AND a.num_mercado = p_mercado_id
        AND b.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    ORDER BY
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        b.fecha_pago,
        b.axo,
        b.periodo,
        d.fecha_emision,
        d.folio;
END;
$$;

-- ========================================================================
-- COMENTARIOS Y NOTAS:
-- ========================================================================
-- 1. Todos los SPs usan schemas totalmente calificados: padron_licencias.comun
-- 2. sp_get_pagos_loc_grl incluye:
--    - JOIN con ta_11_pagos_local (pagos realizados)
--    - JOIN con ta_12_passwords (usuario que registró el pago)
--    - LEFT JOIN con ta_15_apremios (requerimientos asociados al pago)
--    - Subconsulta para agregar periodos requeridos en formato (AÑO-PERIODO)
-- 3. Filtros principales:
--    - Por oficina recaudadora (oficina)
--    - Por mercado (num_mercado)
--    - Por rango de fechas de pago (fecha_desde a fecha_hasta)
-- 4. Ordenamiento jerárquico:
--    - Primero por ubicación del local (sección, local, letra, bloque)
--    - Luego por fecha y periodo de pago
--    - Finalmente por datos del requerimiento
-- ========================================================================
