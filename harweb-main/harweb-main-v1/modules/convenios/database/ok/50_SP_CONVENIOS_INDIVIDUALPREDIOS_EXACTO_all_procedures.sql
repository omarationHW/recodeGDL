-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALPREDIOS (EXACTO del archivo original)
-- Archivo: 50_SP_CONVENIOS_INDIVIDUALPREDIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_get_predio_by_id
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos del predio/convenio por id_conv_predio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_predio_by_id(p_id_conv_predio INTEGER)
RETURNS TABLE (
    id_conv_predio INTEGER,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana VARCHAR,
    lote INTEGER,
    letra VARCHAR,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    id_conv_resto INTEGER,
    tipo_1 SMALLINT,
    id_conv_diver INTEGER,
    id_referencia INTEGER,
    id_rec SMALLINT,
    id_zona INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso VARCHAR,
    fecha_inicio DATE,
    fecha_venc DATE,
    cantidad_total NUMERIC,
    cantidad_inicio NUMERIC,
    pago_parcial NUMERIC,
    pago_final NUMERIC,
    total_pagos SMALLINT,
    metros FLOAT,
    tipo_pago VARCHAR,
    observaciones VARCHAR,
    vigencia VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, a.id_usuario, a.fecha_actual,
           b.id_conv_resto, b.tipo AS tipo_1, b.id_conv_diver, b.id_referencia, b.id_rec, b.id_zona, b.nombre, b.calle,
           b.num_exterior, b.num_interior, b.inciso, b.fecha_inicio, b.fecha_venc, b.cantidad_total, b.cantidad_inicio,
           b.pago_parcial, b.pago_final, b.total_pagos, b.metros, b.tipo_pago, b.observaciones, b.vigencia, e.usuario
    FROM public.ta_17_con_reg_pred a
    JOIN public.ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    JOIN public.ta_12_passwords e ON b.id_usuario = e.id_usuario
    WHERE a.id_conv_predio = p_id_conv_predio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALPREDIOS (EXACTO del archivo original)
-- Archivo: 50_SP_CONVENIOS_INDIVIDUALPREDIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_get_tot_pagado_by_predio
-- Tipo: Report
-- Descripción: Obtiene el total pagado por un predio/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tot_pagado_by_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    importe_pago NUMERIC,
    cve_descuento SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe_pago, cve_descuento
    FROM public.ta_17_conv_pagos
    WHERE id_conv_resto = p_id_conv_resto
      AND cve_bonificacion IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALPREDIOS (EXACTO del archivo original)
-- Archivo: 50_SP_CONVENIOS_INDIVIDUALPREDIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para un predio/convenio en un año y mes dados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_id_conv_resto INTEGER, p_anio INTEGER, p_mes INTEGER)
RETURNS TABLE (dia_venc SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_venc)::SMALLINT AS dia_venc
    FROM public.ta_17_adeudos_div
    WHERE id_conv_resto = p_id_conv_resto
      AND EXTRACT(YEAR FROM fecha_venc) = p_anio
      AND EXTRACT(MONTH FROM fecha_venc) = p_mes
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALPREDIOS (EXACTO del archivo original)
-- Archivo: 50_SP_CONVENIOS_INDIVIDUALPREDIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

