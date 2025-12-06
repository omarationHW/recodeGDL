-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaPagMercado
-- Generado: 2025-08-26 22:58:28
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene los mercados de una recaudadora/oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados(p_oficina integer)
RETURNS TABLE(
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso
    FROM padron_licencias.comun.ta_11_mercados
    WHERE oficina = p_oficina
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_get_adeudos_local
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos de un local específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(
    p_oficina integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer
) RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           a.axo, a.periodo, a.importe, a.fecha_alta, b.usuario
    FROM padron_licencias.comun.ta_11_adeudo_local a
    JOIN padron_licencias.comun.ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN padron_licencias.comun.ta_11_locales c ON a.id_local = c.id_local
    WHERE c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND c.categoria = p_categoria
      AND c.seccion = p_seccion
      AND c.local = p_local
      AND c.vigencia = 'A'
      AND c.bloqueo < 4
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_get_ingreso_operacion
-- Tipo: CRUD
-- Descripción: Obtiene el ingreso de una operación de caja para validación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ingreso_operacion(
    p_fecha_ingreso date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_oficina_mercado integer,
    p_mercado integer
) RETURNS TABLE(
    num_mercado_nvo smallint,
    cuenta_ingreso integer,
    cta_aplicacion integer,
    ingreso numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.num_mercado_nvo, b.cuenta_ingreso, a.cta_aplicacion, COALESCE(SUM(a.importe_cta),0) ingreso
    FROM padron_licencias.comun.ta_12_importes a
    JOIN padron_licencias.comun.ta_11_mercados b ON b.oficina = p_oficina_mercado AND b.num_mercado_nvo = p_mercado
    WHERE a.fecing = p_fecha_ingreso
      AND a.recing = p_oficina
      AND a.cajing = p_caja
      AND a.opcaja = p_operacion
      AND (a.cta_aplicacion BETWEEN 44501 AND 44588 OR a.cta_aplicacion=44119 OR a.cta_aplicacion=44214)
    GROUP BY b.num_mercado_nvo, b.cuenta_ingreso, a.cta_aplicacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_get_captura_operacion
-- Tipo: CRUD
-- Descripción: Obtiene el total capturado de una operación de caja para validación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_captura_operacion(
    p_fecha_pago date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_mercado integer
) RETURNS TABLE(
    capturado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(a.importe_pago),0) capturado
    FROM padron_licencias.comun.ta_11_pagos_local a
    JOIN padron_licencias.comun.ta_11_locales b ON a.id_local = b.id_local
    WHERE EXTRACT(MONTH FROM a.fecha_pago) = EXTRACT(MONTH FROM p_fecha_pago)
      AND a.oficina_pago = p_oficina
      AND a.caja_pago = p_caja
      AND a.operacion_pago = p_operacion
      AND b.num_mercado = p_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_insert_pagos_mercado
-- Tipo: CRUD
-- Descripción: Carga pagos de mercado y elimina adeudos correspondientes (transaccional)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_pagos_mercado(
    p_fecha_pago date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_usuario integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_pagos json
) RETURNS TABLE(
    status text,
    message text
) AS $$
DECLARE
    pago json;
    v_id_local integer;
    v_axo smallint;
    v_periodo smallint;
    v_importe numeric;
    v_partida varchar;
BEGIN
    FOR pago IN SELECT * FROM json_array_elements(p_pagos)
    LOOP
        v_id_local := (pago->>'id_local')::integer;
        v_axo := (pago->>'axo')::smallint;
        v_periodo := (pago->>'periodo')::smallint;
        v_importe := (pago->>'importe')::numeric;
        v_partida := (pago->>'partida');
        IF v_partida IS NULL OR v_partida = '' OR v_partida = '0' THEN
            CONTINUE;
        END IF;
        INSERT INTO padron_licencias.comun.ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, v_id_local, v_axo, v_periodo, p_fecha_pago, p_oficina, p_caja, p_operacion, v_importe, v_partida, NOW(), p_usuario
        );
        DELETE FROM padron_licencias.comun.ta_11_adeudo_local WHERE id_local = v_id_local AND axo = v_axo AND periodo = v_periodo;
    END LOOP;
    RETURN QUERY SELECT 'OK', 'Pagos cargados correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_delete_adeudo_local
-- Tipo: CRUD
-- Descripción: Elimina un adeudo local específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_adeudo_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint
) RETURNS TABLE(status text, message text) AS $$
BEGIN
    DELETE FROM padron_licencias.comun.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT 'OK', 'Adeudo eliminado';
END;
$$ LANGUAGE plpgsql;

-- ============================================