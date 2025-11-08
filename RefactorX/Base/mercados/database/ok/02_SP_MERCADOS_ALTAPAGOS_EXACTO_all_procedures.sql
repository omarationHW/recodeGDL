-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - MERCADOS
-- Formulario: AltaPagos (EXACTO del archivo original)
-- Archivo: 02_SP_MERCADOS_ALTAPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 1/8: sp_alta_pagos_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local vigente y no bloqueado según los parámetros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_buscar_local(
    p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text, p_local integer, p_letra_local text, p_bloque text
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    superficie numeric,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, superficie, clave_cuota
    FROM public.ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local IS NULL OR letra_local = NULLIF(p_letra_local, ''))
      AND (bloque IS NULL OR bloque = NULLIF(p_bloque, ''))
      AND vigencia = 'A'
      AND bloqueo < 4
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_alta_pagos_consultar_pago
-- Tipo: CRUD
-- Descripción: Consulta si existe un pago para un local, año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_consultar_pago(
    p_id_local integer, p_axo integer, p_periodo integer
) RETURNS TABLE(
    id_pago_local integer,
    id_local integer,
    axo integer,
    periodo integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago text,
    operacion_pago integer,
    importe_pago numeric,
    folio text,
    fecha_modificacion timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
    FROM public.ta_11_pagos_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_alta_pagos_agregar
-- Tipo: CRUD
-- Descripción: Agrega un pago de local y elimina el adeudo correspondiente si existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_agregar(
    p_id_local integer, p_axo integer, p_periodo integer, p_fecha_pago date, p_oficina_pago integer, p_caja_pago text, p_operacion_pago integer, p_importe_pago numeric, p_folio text, p_id_usuario integer, p_fecha_ingreso date
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_adeudo_count integer;
BEGIN
    -- Insertar el pago
    INSERT INTO public.ta_11_pagos_local (id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario)
    VALUES (p_id_local, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_folio, NOW(), p_id_usuario);
    -- Si existe adeudo, eliminarlo
    SELECT COUNT(*) INTO v_adeudo_count FROM public.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_adeudo_count = 1 THEN
        DELETE FROM public.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    END IF;
    RETURN QUERY SELECT true, 'El Pago se dio de Alta Correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al dar de Alta el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_alta_pagos_modificar
-- Tipo: CRUD
-- Descripción: Modifica un pago existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_modificar(
    p_id_local integer, p_axo integer, p_periodo integer, p_fecha_pago date, p_oficina_pago integer, p_caja_pago text, p_operacion_pago integer, p_importe_pago numeric, p_folio text, p_id_usuario integer, p_fecha_ingreso date
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
    UPDATE public.ta_11_pagos_local
    SET fecha_pago = p_fecha_pago,
        oficina_pago = p_oficina_pago,
        caja_pago = p_caja_pago,
        operacion_pago = p_operacion_pago,
        importe_pago = p_importe_pago,
        folio = p_folio,
        fecha_modificacion = NOW(),
        id_usuario = p_id_usuario
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT true, 'El Pago Modificó Correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al Modificar el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_alta_pagos_borrar
-- Tipo: CRUD
-- Descripción: Elimina un pago y regenera el adeudo si corresponde.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_borrar(
    p_id_local integer, p_axo integer, p_periodo integer, p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_pago RECORD;
    v_adeudo_count integer;
BEGIN
    SELECT * INTO v_pago FROM public.ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF FOUND THEN
        -- Regenerar adeudo si no existe
        SELECT COUNT(*) INTO v_adeudo_count FROM public.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        IF v_adeudo_count = 0 THEN
            INSERT INTO public.ta_11_adeudo_local (id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (p_id_local, p_axo, p_periodo, v_pago.importe_pago, NOW(), p_id_usuario);
        END IF;
        DELETE FROM public.ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        RETURN QUERY SELECT true, 'Se Eliminó Correctamente el Pago';
    ELSE
        RETURN QUERY SELECT false, 'No existe el pago a borrar';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al Borrar el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_alta_pagos_consultar_adeudo
-- Tipo: CRUD
-- Descripción: Consulta el adeudo de un local para un periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_pagos_consultar_adeudo(
    p_id_local integer, p_axo integer, p_periodo integer
) RETURNS TABLE(
    id_adeudo_local integer,
    id_local integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    FROM public.ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_catalogo_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_recaudadoras() RETURNS TABLE(
    id_rec integer,
    recaudadora text
) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_catalogo_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones de mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_secciones() RETURNS TABLE(
    seccion text,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM public.ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;

-- ============================================