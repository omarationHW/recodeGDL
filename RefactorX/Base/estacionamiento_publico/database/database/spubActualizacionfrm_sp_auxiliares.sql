-- =============================================================================
-- STORED PROCEDURES AUXILIARES - ActualizacionPublicos.vue
-- Base: estacionamiento_publico
-- Esquema: public
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SP: sp_get_categorias_publicos
-- Descripción: Obtiene el catálogo de categorías de estacionamientos públicos
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_categorias_publicos();

CREATE OR REPLACE FUNCTION public.sp_get_categorias_publicos()
RETURNS TABLE (
    id integer,
    tipo varchar(1),
    categoria varchar(2),
    descripcion varchar(20)
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        TRIM(c.tipo)::varchar(1) as tipo,
        TRIM(c.categoria)::varchar(2) as categoria,
        TRIM(c.descripcion)::varchar(20) as descripcion
    FROM public.pubcategoria c
    ORDER BY c.descripcion;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP: cajero_pub_detalle
-- Descripción: Obtiene los adeudos de un estacionamiento público
-- Parámetros:
--   p_opc: 1 = Listar todos, 2 = Por año/mes específico
--   p_pubid: ID del estacionamiento
--   p_axo: Año (solo para opción 2)
--   p_mes: Mes (solo para opción 2)
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.cajero_pub_detalle(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.cajero_pub_detalle(
    p_opc integer,
    p_pubid integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE (
    concepto varchar,
    axo smallint,
    mes smallint,
    adeudo numeric,
    recargos numeric
) AS $func$
BEGIN
    IF p_opc = 1 THEN
        -- Opción 1: Listar todos los adeudos del estacionamiento
        RETURN QUERY
        SELECT
            a.concepto::varchar,
            a.axo,
            a.mes,
            COALESCE(a.ade_importe, 0) as adeudo,
            COALESCE(a.ade_descto, 0) as recargos
        FROM public.pubadeudo a
        WHERE a.pubmain_id = p_pubid
        ORDER BY a.axo DESC, a.mes DESC;
    ELSIF p_opc = 2 THEN
        -- Opción 2: Buscar adeudo específico por año y mes
        RETURN QUERY
        SELECT
            a.concepto::varchar,
            a.axo,
            a.mes,
            COALESCE(a.ade_importe, 0) as adeudo,
            COALESCE(a.ade_descto, 0) as recargos
        FROM public.pubadeudo a
        WHERE a.pubmain_id = p_pubid
          AND a.axo = p_axo
          AND a.mes = p_mes;
    END IF;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP: sp_get_recibos_publicos
-- Descripción: Obtiene el historial de pagos/recibos de un estacionamiento
-- Parámetros:
--   p_pubmain_id: ID del estacionamiento
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_recibos_publicos(integer);

CREATE OR REPLACE FUNCTION public.sp_get_recibos_publicos(
    p_pubmain_id integer
) RETURNS TABLE (
    fecha_movto date,
    pag_reca integer,
    pag_caja varchar,
    pag_operacion integer,
    pag_importe numeric,
    count bigint
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        h.fecha_at as fecha_movto,
        COALESCE(h.id_usuario, 0) as pag_reca,
        'A'::varchar as pag_caja,
        h.id as pag_operacion,
        COALESCE(h.ade_importe, 0) as pag_importe,
        COUNT(*)::bigint as count
    FROM public.pubadeudo_histo h
    WHERE h.pubmain_id = p_pubmain_id
    GROUP BY h.fecha_at, h.id_usuario, h.id, h.ade_importe
    ORDER BY h.fecha_at DESC;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP: sp_get_multas_publicos
-- Descripción: Obtiene las multas relacionadas con un estacionamiento
-- Parámetros:
--   p_numesta: ID del estacionamiento (pubmain_id)
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_multas_publicos(integer);

CREATE OR REPLACE FUNCTION public.sp_get_multas_publicos(
    p_numesta integer
) RETURNS TABLE (
    folio integer,
    fecha date,
    concepto varchar,
    importe numeric,
    pagado boolean
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(m.id_multa, 0)::integer as folio,
        COALESCE(m.fecha_acta, CURRENT_DATE) as fecha,
        COALESCE(m.observacion, 'MULTA')::varchar as concepto,
        COALESCE(m.total, 0)::numeric as importe,
        CASE WHEN m.cvepago IS NOT NULL AND m.cvepago > 0 THEN true ELSE false END as pagado
    FROM public.pub_rel_multas r
    LEFT JOIN public.multas m ON m.id_multa = r.id_multa AND m.id_dependencia = r.id_dependencia
    WHERE r.pubmain_id = p_numesta
      AND TRIM(r.vigente) = 'S'
    ORDER BY m.fecha_acta DESC;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP: sp_get_detalle_recibo_publicos
-- Descripción: Obtiene el detalle de un recibo/pago específico
-- Parámetros:
--   p_pubmain_id: ID del estacionamiento
--   p_fecha_movto: Fecha del movimiento
--   p_pag_reca: Recaudadora
--   p_pag_caja: Caja
--   p_pag_operacion: Número de operación
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_detalle_recibo_publicos(integer, date, integer, varchar, integer);

CREATE OR REPLACE FUNCTION public.sp_get_detalle_recibo_publicos(
    p_pubmain_id integer,
    p_fecha_movto date,
    p_pag_reca integer,
    p_pag_caja varchar,
    p_pag_operacion integer
) RETURNS TABLE (
    tipo integer,
    concepto varchar,
    axo smallint,
    mes smallint,
    ade_importe numeric,
    ade_descto numeric,
    ade_recgos numeric,
    total numeric
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        h.tipo,
        h.concepto::varchar,
        h.axo,
        h.mes,
        COALESCE(h.ade_importe, 0) as ade_importe,
        COALESCE(h.ade_descto, 0) as ade_descto,
        0::numeric as ade_recgos,
        COALESCE(h.ade_importe, 0) - COALESCE(h.ade_descto, 0) as total
    FROM public.pubadeudo_histo h
    WHERE h.pubmain_id = p_pubmain_id
      AND h.fecha_at = p_fecha_movto
      AND h.id = p_pag_operacion
    ORDER BY h.axo DESC, h.mes DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURES AUXILIARES
-- =============================================================================
