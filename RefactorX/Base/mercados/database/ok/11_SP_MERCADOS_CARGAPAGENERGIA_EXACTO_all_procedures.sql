-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaPagEnergia
-- Generado: 2025-08-26 22:51:22
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_buscar_adeudos_energia
-- Tipo: CRUD
-- Descripción: Busca los adeudos de energía eléctrica para un local específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_adeudos_energia(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER
) RETURNS TABLE (
    id_adeudo_energia INTEGER,
    id_energia INTEGER,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    axo INTEGER,
    periodo INTEGER,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    importe NUMERIC,
    fecha_alta TIMESTAMP,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_adeudo_energia, a.id_energia, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, a.axo, a.periodo, a.cve_consumo, a.cantidad, a.importe, a.fecha_alta, u.usuario
    FROM mercados.public.ta_11_adeudo_energ a
    JOIN mercados.public.ta_11_energia d ON a.id_energia = d.id_energia
    JOIN padron_licencias.comun.ta_11_locales b ON d.id_local = b.id_local
    JOIN padron_licencias.comun.ta_12_passwords u ON a.id_usuario = u.id_usuario
    WHERE b.oficina = p_oficina
      AND b.num_mercado = p_mercado
      AND b.categoria = p_categoria
      AND b.seccion = p_seccion
      AND b.local = p_local
      AND NOT EXISTS (
        SELECT 1 FROM mercados.public.ta_11_pago_energia pe
        WHERE pe.id_energia = a.id_energia AND pe.axo = a.axo AND pe.periodo = a.periodo
      )
    ORDER BY a.id_energia, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_cargar_pago_energia
-- Tipo: CRUD
-- Descripción: Carga un pago de energía eléctrica y elimina el adeudo correspondiente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cargar_pago_energia(
    p_id_energia INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_importe NUMERIC,
    p_cve_consumo VARCHAR,
    p_cantidad NUMERIC,
    p_folio VARCHAR,
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO mercados.public.ta_11_pago_energia (
        id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe, p_cve_consumo, p_cantidad, p_folio, NOW(), p_id_usuario
    );
    DELETE FROM mercados.public.ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_consultar_pagos_energia
-- Tipo: Report
-- Descripción: Consulta los pagos realizados para un id_energia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_pagos_energia(
    p_id_energia INTEGER
) RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo INTEGER,
    periodo INTEGER,
    fecha_pago DATE,
    oficina_pago INTEGER,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    FROM mercados.public.ta_11_pago_energia
    WHERE id_energia = p_id_energia
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================