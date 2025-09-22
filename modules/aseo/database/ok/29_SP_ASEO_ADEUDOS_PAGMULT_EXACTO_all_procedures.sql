-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: Adeudos_PagMult (EXACTO del archivo original)
-- Archivo: 29_SP_ASEO_ADEUDOS_PAGMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_adeudos_pagmult_listar_catalogos
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipos de aseo, recaudadoras y cajas para el formulario de pagos múltiples.
-- --------------------------------------------

-- No es necesario un SP, pero si se requiere:
CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_catalogos()
RETURNS TABLE(
    ctrol_aseo integer, tipo_aseo varchar, descripcion varchar,
    id_rec integer, recaudadora varchar,
    caja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.ctrol_aseo, t.tipo_aseo, t.descripcion, NULL::integer, NULL::varchar, NULL::varchar FROM public.ta_16_tipo_aseo t
    UNION ALL
    SELECT NULL, NULL, NULL, r.id_rec, r.recaudadora, NULL FROM public.ta_12_recaudadoras r
    UNION ALL
    SELECT NULL, NULL, NULL, NULL, NULL, o.caja FROM public.ta_12_operaciones o;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_adeudos_pagmult_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_buscar_contrato(p_num_contrato integer, p_ctrol_aseo integer)
RETURNS TABLE(control_contrato integer, num_contrato integer, ctrol_aseo integer) AS $$
BEGIN
    RETURN QUERY
    SELECT control_contrato, num_contrato, ctrol_aseo
    FROM public.ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_adeudos_pagmult_listar_adeudos
-- Tipo: CRUD
-- Descripción: Lista los adeudos vigentes de un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_adeudos(p_control_contrato integer)
RETURNS TABLE(
    control_contrato integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar,
    descripcion varchar,
    exedencias smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.cve_operacion, b.descripcion, a.exedencias, a.importe
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V'
    ORDER BY a.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_adeudos_pagmult_pagar_adeudos
-- Tipo: CRUD
-- Descripción: Marca como pagados los adeudos seleccionados, actualizando los campos de pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_pagar_adeudos(
    p_adeudos jsonb,
    p_fecha_pagado timestamp,
    p_id_rec integer,
    p_caja varchar,
    p_consec_operacion integer,
    p_folio_rcbo varchar,
    p_usuario integer
) RETURNS void AS $$
DECLARE
    ad jsonb;
    r record;
BEGIN
    FOR ad IN SELECT * FROM jsonb_array_elements(p_adeudos) LOOP
        SELECT control_contrato, aso_mes_pago, ctrol_operacion INTO r
        FROM jsonb_to_record(ad) AS x(control_contrato integer, aso_mes_pago date, ctrol_operacion integer);
        UPDATE public.ta_16_pagos
        SET status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_operacion,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario
        WHERE control_contrato = r.control_contrato
          AND aso_mes_pago = r.aso_mes_pago
          AND ctrol_operacion = r.ctrol_operacion
          AND status_vigencia = 'V';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================