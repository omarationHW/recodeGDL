-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PadronConvenios
-- Generado: 2025-08-27 15:06:39
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_padron_convenios
-- Tipo: Report
-- Descripción: Obtiene el padrón de convenios filtrado por tipo, subtipo, vigencia, recaudadora y rango de años.
-- --------------------------------------------

-- PostgreSQL stored procedure
CREATE OR REPLACE FUNCTION sp_padron_convenios(
    p_tipo integer,
    p_subtipo integer,
    p_vigencia varchar,
    p_recaudadora integer,
    p_anio_desde integer,
    p_anio_hasta integer
)
RETURNS TABLE (
    id_conv_resto integer,
    tipo integer,
    subtipo integer,
    letras_exp varchar,
    numero_exp integer,
    axo_exp integer,
    fecha_inicio date,
    fecha_venc date,
    costo numeric,
    descripcion varchar,
    desc_subtipo varchar,
    vigencia varchar,
    pago_parcial integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    referencia varchar,
    impuesto numeric,
    recargos numeric,
    anuncios numeric,
    impreso numeric,
    gastos numeric,
    multa numeric,
    folios varchar,
    id_referencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id_conv_resto, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp, b.fecha_inicio, b.fecha_venc,
        b.cantidad_total as costo, i.descripcion, d.desc_subtipo,
        CASE b.vigencia WHEN 'A' THEN 'VIGENTE' WHEN 'B' THEN 'BAJA' WHEN 'P' THEN 'PAGADO' ELSE b.vigencia END as vigencia,
        e.pago_parcial, e.fecha_pago, e.oficina_pago, e.caja_pago, e.operacion_pago, e.importe_pago,
        COALESCE(r.referencia, '') as referencia,
        COALESCE(r.impuesto, 0), COALESCE(r.recargos, 0), COALESCE(r.anuncio, 0), COALESCE(r.impreso, 0), COALESCE(r.gastos, 0), COALESCE(r.multa, 0),
        '' as folios, -- Puede llenarse con otro SP si se requiere
        COALESCE(r.id_referencia, 0)
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    JOIN ta_17_tipos i ON a.tipo = i.tipo
    LEFT JOIN ta_17_conv_pagos e ON e.id_conv_resto = b.id_conv_resto
    LEFT JOIN LATERAL (
        SELECT * FROM ta_17_referencia r WHERE r.id_conv_resto = b.id_conv_resto ORDER BY r.modulo LIMIT 1
    ) r ON TRUE
    WHERE (p_tipo IS NULL OR a.tipo = p_tipo)
      AND (p_subtipo IS NULL OR a.subtipo = p_subtipo)
      AND (p_vigencia IS NULL OR b.vigencia = p_vigencia OR p_vigencia = '0')
      AND (p_recaudadora IS NULL OR a.letras_exp = (
            CASE p_recaudadora
                WHEN 1 THEN 'ZC1'
                WHEN 2 THEN 'ZO2'
                WHEN 3 THEN 'ZO3'
                WHEN 4 THEN 'ZM4'
                WHEN 5 THEN 'ZC5'
                ELSE a.letras_exp
            END
        ))
      AND (a.axo_exp BETWEEN COALESCE(p_anio_desde, a.axo_exp) AND COALESCE(p_anio_hasta, a.axo_exp))
    ORDER BY a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp, b.fecha_inicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_padron_convenios_folios
-- Tipo: Report
-- Descripción: Obtiene los folios (parcialidades) de un convenio dado.
-- --------------------------------------------

-- PostgreSQL stored procedure
CREATE OR REPLACE FUNCTION sp_padron_convenios_folios(
    p_modulo integer,
    p_id_referencia integer,
    p_fecha_inicio date,
    p_fecha_venc date,
    p_id_conv_resto integer
)
RETURNS TABLE (
    idconvenio integer,
    folio integer,
    fecprac date,
    vigencia varchar,
    axodsd integer,
    mesdsd integer,
    axohst integer,
    meshst integer,
    FPago varchar,
    ejecutor integer
) AS $$
BEGIN
    -- Simula llamada a stored procedure de folios (debe adaptarse a la lógica real)
    RETURN QUERY
    SELECT 
        p_id_conv_resto as idconvenio,
        f.folio,
        f.fecprac,
        CASE f.vigencia WHEN 'V' THEN 'VIGENTE' WHEN 'P' THEN 'PAGADO' ELSE 'CANCELADO' END as vigencia,
        f.axodsd, f.mesdsd, f.axohst, f.meshst,
        COALESCE(TO_CHAR(f.fecpag, 'YYYY-MM-DD'), '') as FPago,
        f.ejecutor
    FROM ta_17_folios f
    WHERE f.modulo = p_modulo
      AND f.id_referencia = p_id_referencia
      AND f.fecprac BETWEEN p_fecha_inicio AND p_fecha_venc
      AND f.id_conv_resto = p_id_conv_resto
    ORDER BY f.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

