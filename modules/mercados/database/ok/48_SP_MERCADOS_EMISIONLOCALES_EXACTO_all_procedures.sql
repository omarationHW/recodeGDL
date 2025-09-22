-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EmisionLocales
-- Generado: 2025-08-26 23:54:25
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_emisionlocales_listar_mercados
-- Tipo: Catalog
-- Descripción: Lista los mercados activos de una recaudadora/oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emisionlocales_listar_mercados(p_oficina INTEGER)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, tipo_emision
    FROM public.ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision <> 'B'
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_emisionlocales_emitir_recibos
-- Tipo: CRUD
-- Descripción: Genera la emisión de recibos para un mercado/oficina/año/periodo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emisionlocales_emitir_recibos(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    local INTEGER,
    nombre VARCHAR,
    descripcion_local VARCHAR,
    superficie FLOAT,
    renta NUMERIC,
    subtotal NUMERIC,
    meses VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.local,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
             WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
             ELSE l.superficie * c.importe_cuota END AS renta,
        0 AS subtotal, -- Calculado en frontend o en otro SP
        '' AS meses
    FROM public.ta_11_locales l
    JOIN public.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    JOIN public.ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_mercado
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
      AND l.id_local NOT IN (
        SELECT id_local FROM public.ta_11_pagos_local WHERE id_local = l.id_local AND axo = p_axo AND periodo = p_periodo
      )
      AND l.id_local NOT IN (
        SELECT id_local FROM public.ta_11_ade_loc_canc WHERE id_local = l.id_local AND axo = p_axo AND periodo = p_periodo
      )
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_emisionlocales_grabar_emision
-- Tipo: CRUD
-- Descripción: Graba la emisión de recibos en la tabla de adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emisionlocales_grabar_emision(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    status TEXT
) AS $$
DECLARE
    r RECORD;
    v_renta NUMERIC;
BEGIN
    FOR r IN
        SELECT l.id_local, l.superficie, l.seccion, c.importe_cuota, c.clave_cuota
        FROM public.ta_11_locales l
        JOIN public.ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
        WHERE l.oficina = p_oficina AND l.num_mercado = p_mercado AND l.vigencia = 'A' AND l.bloqueo < 4
    LOOP
        IF r.seccion = 'PS' AND r.clave_cuota = 4 THEN
            v_renta := r.superficie * r.importe_cuota;
        ELSIF r.seccion = 'PS' THEN
            v_renta := (r.importe_cuota * r.superficie) * 30;
        ELSE
            v_renta := r.superficie * r.importe_cuota;
        END IF;
        -- Solo insertar si no existe adeudo para ese periodo
        IF NOT EXISTS (
            SELECT 1 FROM public.ta_11_adeudo_local WHERE id_local = r.id_local AND axo = p_axo AND periodo = p_periodo
        ) THEN
            INSERT INTO public.ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, r.id_local, p_axo, p_periodo, v_renta, now(), p_usuario_id);
            RETURN NEXT (r.id_local, 'insertado');
        ELSE
            RETURN NEXT (r.id_local, 'ya_existe');
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_emisionlocales_facturacion
-- Tipo: Report
-- Descripción: Genera la facturación de recibos para un mercado/oficina/año/periodo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emisionlocales_facturacion(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_solo_mercado BOOLEAN
) RETURNS TABLE(
    id_local INTEGER,
    nombre VARCHAR,
    descripcion_local VARCHAR,
    superficie FLOAT,
    renta NUMERIC,
    subtotal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
             WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
             ELSE l.superficie * c.importe_cuota END AS renta,
        0 AS subtotal
    FROM public.ta_11_locales l
    JOIN public.ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
    WHERE l.oficina = p_oficina
      AND (p_solo_mercado IS FALSE OR l.num_mercado = p_mercado)
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_emisionlocales_detalle_local
-- Tipo: Report
-- Descripción: Devuelve el detalle completo de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emisionlocales_detalle_local(p_id_local INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    descripcion_local VARCHAR,
    superficie FLOAT,
    clave_cuota SMALLINT,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, descripcion_local, superficie, clave_cuota, vigencia, fecha_alta, fecha_baja
    FROM public.ta_11_locales
    WHERE id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

