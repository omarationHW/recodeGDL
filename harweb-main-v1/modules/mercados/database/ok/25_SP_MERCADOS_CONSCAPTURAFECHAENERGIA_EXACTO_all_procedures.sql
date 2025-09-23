-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsCapturaFechaEnergia
-- Generado: 2025-08-26 23:14:48
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_pagos_energia_fecha
-- Tipo: Report
-- Descripción: Obtiene los pagos de energía eléctrica por fecha/oficina/caja/operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_energia_fecha(
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    nivel SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    datoslocal VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_pago_energia, a.id_energia, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.cve_consumo, a.cantidad, a.folio, a.fecha_modificacion,
        b.usuario, b.nombre, b.estado, b.id_rec, b.nivel,
        c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
        CONCAT(c.oficina, '-', c.num_mercado, '-', c.categoria, '-', c.seccion, '-', c.local, '-', COALESCE(c.letra_local,''), '-', COALESCE(c.bloque,'')) AS datoslocal
    FROM public.ta_11_pago_energia a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN public.ta_11_energia d ON a.id_energia = d.id_energia
    JOIN public.ta_11_locales c ON d.id_local = c.id_local
    WHERE a.fecha_pago = p_fecha_pago
      AND a.oficina_pago = p_oficina_pago
      AND a.caja_pago = p_caja_pago
      AND a.operacion_pago = p_operacion_pago
    ORDER BY a.id_energia ASC, a.axo ASC, a.periodo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_delete_pagos_energia
-- Tipo: CRUD
-- Descripción: Elimina pagos de energía seleccionados y regenera adeudos si corresponde.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_pagos_energia(
    p_pagos_ids INTEGER[],
    p_user_id INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_operacion_pago INTEGER
) RETURNS JSON AS $$
DECLARE
    v_id_pago INTEGER;
    v_id_energia INTEGER;
    v_axo SMALLINT;
    v_periodo SMALLINT;
    v_cve_consumo VARCHAR;
    v_cantidad NUMERIC;
    v_importe_pago NUMERIC;
    v_result JSON := '[]'::JSON;
BEGIN
    FOREACH v_id_pago IN ARRAY p_pagos_ids LOOP
        SELECT id_energia, axo, periodo, cve_consumo, cantidad, importe_pago
        INTO v_id_energia, v_axo, v_periodo, v_cve_consumo, v_cantidad, v_importe_pago
        FROM public.ta_11_pago_energia WHERE id_pago_energia = v_id_pago;

        -- Verifica si existe adeudo
        IF NOT EXISTS (SELECT 1 FROM public.ta_11_adeudo_energ WHERE id_energia = v_id_energia AND axo = v_axo AND periodo = v_periodo) THEN
            -- Regenera adeudo
            INSERT INTO public.ta_11_adeudo_energ (id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, v_id_energia, v_axo, v_periodo, v_cve_consumo, v_cantidad, v_importe_pago, NOW(), p_user_id);
        END IF;
        -- Borra el pago
        DELETE FROM public.ta_11_pago_energia WHERE id_pago_energia = v_id_pago;
        v_result = v_result || to_jsonb(v_id_pago);
    END LOOP;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

