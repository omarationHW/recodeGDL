-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaPagEnergiaElec
-- Generado: 2025-08-26 22:53:19
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_buscar_adeudos_energia_elec
-- Tipo: CRUD
-- Descripción: Busca los adeudos de energía eléctrica para un rango de locales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_adeudos_energia_elec(
    p_oficina integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local_desde integer,
    p_local_hasta integer
) RETURNS TABLE(
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    cve_consumo varchar,
    cantidad numeric,
    axo integer,
    periodo integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_energia, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           d.cve_consumo, d.cantidad, a.axo, a.periodo, a.importe
    FROM public.ta_11_adeudo_energ a
    JOIN public.ta_11_locales c ON c.id_local = d.id_local
    JOIN public.ta_11_energia d ON d.id_energia = a.id_energia
    WHERE c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND c.categoria = p_categoria
      AND c.seccion = p_seccion
      AND c.local BETWEEN p_local_desde AND p_local_hasta
      AND d.vigencia = 'A'
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cargar_pago_energia_elec
-- Tipo: CRUD
-- Descripción: Carga un pago de energía eléctrica y elimina el adeudo correspondiente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cargar_pago_energia_elec(
    p_id_energia integer,
    p_axo integer,
    p_periodo integer,
    p_fecha_pago date,
    p_oficina_pago integer,
    p_caja_pago varchar,
    p_operacion_pago integer,
    p_importe_pago numeric,
    p_cve_consumo varchar,
    p_cantidad numeric,
    p_folio varchar,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    INSERT INTO public.ta_11_pago_energia (
        id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_cve_consumo, p_cantidad, p_folio, NOW(), p_id_usuario
    );
    DELETE FROM public.ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_consultar_pagos_energia_elec
-- Tipo: Report
-- Descripción: Consulta los pagos realizados para un id_energia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_pagos_energia_elec(
    p_id_energia integer
) RETURNS TABLE(
    id_pago_energia integer,
    id_energia integer,
    axo integer,
    periodo integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    cve_consumo varchar,
    cantidad numeric,
    folio varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio
    FROM public.ta_11_pago_energia
    WHERE id_energia = p_id_energia
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_consultar_cajas
-- Tipo: Catalog
-- Descripción: Devuelve las cajas disponibles para una oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_cajas(
    p_oficina integer
) RETURNS TABLE(
    caja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT caja FROM public.ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_consultar_mercados
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_mercados(
    p_oficina integer
) RETURNS TABLE(
    id integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT num_mercado_nvo, descripcion FROM public.ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================