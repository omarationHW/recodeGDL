-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsPagos
-- Generado: 2025-08-27 16:01:41
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_cons_pagos_get_by_local
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de un local específico, incluyendo datos relacionados.
-- --------------------------------------------

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
    FROM public.ta_11_pagos_local a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN public.ta_11_locales c ON a.id_local = c.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_cons_pagos_add
-- Tipo: CRUD
-- Descripción: Agrega un pago a un local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_pagos_add(
    p_id_local INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR(10),
    p_operacion_pago INTEGER,
    p_importe_pago NUMERIC(12,2),
    p_folio VARCHAR(50),
    p_id_usuario INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_id_pago_local INTEGER;
BEGIN
    INSERT INTO public.ta_11_pagos_local (
        id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
    ) VALUES (
        p_id_local, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_folio, NOW(), p_id_usuario
    ) RETURNING id_pago_local INTO v_id_pago_local;
    RETURN v_id_pago_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_cons_pagos_delete
-- Tipo: CRUD
-- Descripción: Elimina un pago por su id_pago_local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_pagos_delete(p_id_pago_local INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM public.ta_11_pagos_local WHERE id_pago_local = p_id_pago_local;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

