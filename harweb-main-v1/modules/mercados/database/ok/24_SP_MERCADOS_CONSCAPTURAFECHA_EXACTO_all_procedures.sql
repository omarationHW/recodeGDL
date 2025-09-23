-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsCapturaFecha
-- Generado: 2025-08-26 23:13:33
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_pagos_by_fecha
-- Tipo: Report
-- Descripción: Obtiene los pagos capturados por fecha, oficina, caja y operación.
-- --------------------------------------------

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
    FROM public.ta_11_pagos_local a
    JOIN public.ta_12_passwords b ON b.id_usuario = a.id_usuario
    JOIN public.ta_11_locales c ON c.id_local = a.id_local
    WHERE a.fecha_pago = p_fecha
      AND a.oficina_pago = p_oficina
      AND a.caja_pago = p_caja
      AND a.operacion_pago = p_operacion
    ORDER BY a.id_local, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_delete_pago_local
-- Tipo: CRUD
-- Descripción: Elimina un pago local y regenera el adeudo si corresponde.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_pago_local(
    p_id_local INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_usuario INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
    v_categoria SMALLINT;
    v_seccion VARCHAR;
    v_clave_cuota SMALLINT;
    v_superficie NUMERIC;
    v_importe_pago NUMERIC;
    v_renta NUMERIC;
BEGIN
    -- Verifica si existe adeudo
    SELECT COUNT(*) INTO v_count FROM public.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_count = 0 THEN
        -- Obtener datos del local y pago
        SELECT categoria, seccion, clave_cuota, superficie INTO v_categoria, v_seccion, v_clave_cuota, v_superficie FROM public.ta_11_locales WHERE id_local = p_id_local;
        SELECT importe_pago INTO v_importe_pago FROM public.ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        IF p_axo >= 2003 THEN
            SELECT importe_cuota INTO v_renta FROM public.ta_11_cuo_locales WHERE axo = p_axo AND categoria = v_categoria AND seccion = v_seccion AND clave_cuota = v_clave_cuota;
            IF v_seccion = 'PS' AND v_clave_cuota = 4 THEN
                v_renta := v_superficie * v_renta;
            ELSIF v_seccion = 'PS' THEN
                v_renta := (v_renta * v_superficie) * 30;
            ELSE
                v_renta := v_superficie * v_renta;
            END IF;
        ELSE
            v_renta := v_importe_pago;
        END IF;
        INSERT INTO public.ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
        VALUES (DEFAULT, p_id_local, p_axo, p_periodo, v_renta, CURRENT_TIMESTAMP, p_usuario);
    END IF;
    -- Borra el pago
    DELETE FROM public.ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_oficinas
-- Tipo: Catalog
-- Descripción: Obtiene la lista de oficinas recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_oficinas()
RETURNS TABLE (id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_cajas_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene las cajas de una oficina public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cajas_by_oficina(p_oficina INTEGER)
RETURNS TABLE (caja VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT caja FROM public.ta_12_cajas WHERE id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;

-- ============================================

