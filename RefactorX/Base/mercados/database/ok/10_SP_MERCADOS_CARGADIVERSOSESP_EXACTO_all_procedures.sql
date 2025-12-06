-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public, comun;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaDiversosEsp
-- Generado: 2025-08-26 22:49:31
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_adeudos_diversos_esp
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos pendientes para la fecha de pago seleccionada, excluyendo los ya pagados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_diversos_esp(p_fecha_pago DATE)
RETURNS TABLE(
    FECHA DATE,
    REC SMALLINT,
    CAJA VARCHAR,
    OPER INTEGER,
    "AÑO" SMALLINT,
    MES SMALLINT,
    RENTA NUMERIC,
    OFN SMALLINT,
    MER SMALLINT,
    CAT SMALLINT,
    SEC VARCHAR,
    LOCAL INTEGER,
    LET VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.fecing AS FECHA,
        a.recing AS REC,
        a.cajing AS CAJA,
        a.opcaja AS OPER,
        b.axo_desde AS "AÑO",
        b.mes_desde AS MES,
        SUM(b.importe_cta) AS RENTA,
        CASE WHEN b.cta_aplicacion=44514 THEN 5 ELSE 5 END AS OFN,
        CASE WHEN b.cta_aplicacion=44514 THEN 14 ELSE 15 END AS MER,
        CASE WHEN b.cta_aplicacion=44514 THEN 2 ELSE 3 END AS CAT,
        'SS' AS SEC,
        a.colonia AS LOCAL,
        a.letras AS LET
    FROM comun.ta_12_ingreso a
    JOIN public.ta_12_importes b ON a.fecing=b.fecing AND a.recing=b.recing AND a.cajing=b.cajing AND a.opcaja=b.opcaja
    WHERE a.fecing = p_fecha_pago
      AND a.tipo_rbo=12
      AND (b.cta_aplicacion = 44514 OR b.cta_aplicacion=44515)
      AND NOT EXISTS (
        SELECT 1 FROM comun.ta_11_pagos_local pl
        WHERE pl.fecha_pago=a.fecing AND pl.oficina_pago=a.recing AND pl.caja_pago=a.cajing AND pl.operacion_pago=a.opcaja
      )
    GROUP BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.letras, b.cta_aplicacion, b.mes_desde, b.axo_desde
    ORDER BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, b.mes_desde, b.axo_desde;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_locales_diversos_esp
-- Tipo: Catalog
-- Descripción: Obtiene información de un local específico para validación de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales_diversos_esp(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque
    FROM comun.ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local = p_letra_local OR (p_letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = p_bloque OR (p_bloque IS NULL AND bloque IS NULL));
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_cargar_pagos_diversos_esp
-- Tipo: CRUD
-- Descripción: Carga los pagos realizados por diversos, graba en pagos_local y elimina el adeudo correspondiente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cargar_pagos_diversos_esp(
    p_pagos_json JSON,
    p_usuario INTEGER,
    p_fecha_pago DATE
) RETURNS JSON AS $$
DECLARE
    pago RECORD;
    pagos_arr JSON[];
    result JSON := '[]'::JSON;
    local_id INTEGER;
    local_row RECORD;
    inserted_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    pagos_arr := ARRAY(SELECT json_array_elements(p_pagos_json));
    FOREACH pago IN ARRAY pagos_arr LOOP
        -- Buscar local
        SELECT * INTO local_row FROM comun.ta_11_locales
        WHERE oficina=5 AND num_mercado=(pago->>'MER')::INTEGER
          AND categoria=(pago->>'CAT')::INTEGER
          AND seccion='SS'
          AND local=(pago->>'LOCAL')::INTEGER
          AND (letra_local = NULLIF(pago->>'LET','') OR (pago->>'LET' = '' AND letra_local IS NULL))
          AND bloque IS NULL;
        IF NOT FOUND THEN
            error_count := error_count + 1;
            CONTINUE;
        END IF;
        -- Insertar pago
        INSERT INTO comun.ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT,
            local_row.id_local,
            (pago->>'AÑO')::INTEGER,
            (pago->>'MES')::INTEGER,
            p_fecha_pago,
            5,
            (pago->>'REC'),
            (pago->>'OPER')::INTEGER,
            (pago->>'RENTA')::NUMERIC,
            (pago->>'PARTIDA'),
            NOW(),
            p_usuario
        );
        -- Eliminar adeudo
        DELETE FROM comun.ta_11_adeudo_local
        WHERE id_local=local_row.id_local
          AND axo=(pago->>'AÑO')::INTEGER
          AND periodo=(pago->>'MES')::INTEGER;
        inserted_count := inserted_count + 1;
    END LOOP;
    RETURN json_build_object('inserted', inserted_count, 'errors', error_count);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_fecha_descuento
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de descuento para un mes dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes INTEGER)
RETURNS TABLE(
    mes INTEGER,
    fecha_descuento DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_descuento, fecha_alta, id_usuario
    FROM comun.ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================