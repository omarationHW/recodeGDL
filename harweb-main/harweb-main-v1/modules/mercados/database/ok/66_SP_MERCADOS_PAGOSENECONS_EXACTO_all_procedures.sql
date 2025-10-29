-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PagosEneCons
-- Generado: 2025-08-27 00:23:09
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_pagos_energia
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de energía eléctrica para un id_energia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INTEGER)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(1),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    cve_consumo VARCHAR(1),
    cantidad NUMERIC(12,2),
    folio VARCHAR(18),
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_pago_energia, a.id_energia, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.cve_consumo, a.cantidad, a.folio, a.fecha_modificacion, a.id_usuario, b.usuario
    FROM public.ta_11_pago_energia a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.id_energia = p_id_energia
    ORDER BY a.id_energia ASC, a.axo ASC, a.periodo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_add_pago_energia
-- Tipo: CRUD
-- Descripción: Agrega un pago de energía eléctrica y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_pago_energia(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR(1),
    p_operacion_pago INTEGER,
    p_importe_pago NUMERIC(12,2),
    p_cve_consumo VARCHAR(1),
    p_cantidad NUMERIC(12,2),
    p_folio VARCHAR(18),
    p_id_usuario INTEGER
) RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(1),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    cve_consumo VARCHAR(1),
    cantidad NUMERIC(12,2),
    folio VARCHAR(18),
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
DECLARE
    v_id_pago_energia INTEGER;
BEGIN
    INSERT INTO public.ta_11_pago_energia (
        id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        p_id_energia, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_cve_consumo, p_cantidad, p_folio, NOW(), p_id_usuario
    ) RETURNING id_pago_energia INTO v_id_pago_energia;
    RETURN QUERY
    SELECT a.id_pago_energia, a.id_energia, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.cve_consumo, a.cantidad, a.folio, a.fecha_modificacion, a.id_usuario, b.usuario
    FROM public.ta_11_pago_energia a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.id_pago_energia = v_id_pago_energia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_delete_pago_energia
-- Tipo: CRUD
-- Descripción: Elimina un pago de energía eléctrica por id_pago_energia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_pago_energia(
    p_id_pago_energia INTEGER,
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM public.ta_11_pago_energia WHERE id_pago_energia = p_id_pago_energia;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

