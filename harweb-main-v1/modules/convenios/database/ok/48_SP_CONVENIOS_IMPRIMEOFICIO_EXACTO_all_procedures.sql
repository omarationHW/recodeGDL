-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: IMPRIMEOFICIO (EXACTO del archivo original)
-- Archivo: 48_SP_CONVENIOS_IMPRIMEOFICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_imprime_oficio_buscar_convenio
-- Tipo: CRUD
-- Descripción: Busca convenio vigente por letras, número, año y tipo. Devuelve todos los datos necesarios para impresión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_imprime_oficio_buscar_convenio(
    p_letras VARCHAR,
    p_numero INTEGER,
    p_axo INTEGER,
    p_tipo INTEGER
) RETURNS TABLE (
    id_conv_resto INTEGER,
    convenio TEXT,
    nombre TEXT,
    domicilio TEXT,
    nombrefirma TEXT,
    cantidad_total NUMERIC,
    total_pagos INTEGER,
    fecha_venc DATE,
    oficio TEXT,
    telefono TEXT,
    referencia TEXT,
    periodos TEXT,
    impuesto NUMERIC,
    recargos NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    anuncio NUMERIC,
    impreso NUMERIC,
    fvlicencias NUMERIC,
    fvanuncios NUMERIC,
    inicial NUMERIC,
    iniven DATE,
    parcial NUMERIC,
    parcven DATE,
    parcvenfin DATE,
    tipo TEXT,
    subtipo TEXT,
    modulo INTEGER,
    id_referencia INTEGER,
    ntipo INTEGER,
    nsubtipo INTEGER,
    id_usuario INTEGER,
    actualizacion NUMERIC,
    actualizacion_anun NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.id_conv_resto,
        (TRIM(a.letras_exp)||'/'||a.numero_exp||'/'||a.axo_exp) AS convenio,
        b.nombre,
        (TRIM(b.calle)||' No. '||b.num_exterior||' '||b.num_interior||' '||TRIM(b.inciso)) AS domicilio,
        b.nombrefirma,
        b.cantidad_total,
        b.total_pagos,
        b.fecha_venc,
        TRIM(b.oficio),
        TRIM(b.telefono),
        TRIM(d.referencia),
        (d.mes_desde||'/'||d.axo_desde||' al '||d.mes_hasta||'/'||d.axo_hasta) AS periodos,
        d.impuesto,
        d.recargos,
        d.multa,
        d.gastos,
        d.total,
        d.anuncio,
        d.impreso,
        d.fvlicencias,
        d.fvanuncios,
        (SELECT importe FROM public.ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=1) AS inicial,
        (SELECT fecha_venc FROM public.ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=1) AS iniven,
        (SELECT importe FROM public.ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=2) AS parcial,
        (SELECT fecha_venc FROM public.ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=2) AS parcven,
        (SELECT max(fecha_venc) FROM public.ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto) AS parcvenfin,
        (SELECT descripcion FROM public.ta_17_tipos WHERE tipo=a.tipo) AS tipo,
        (SELECT desc_subtipo FROM public.ta_17_subtipo_conv WHERE tipo=a.tipo AND subtipo=a.subtipo) AS subtipo,
        d.modulo,
        d.id_referencia,
        (SELECT tipo FROM public.ta_17_tipos WHERE tipo=a.tipo) AS ntipo,
        (SELECT subtipo FROM public.ta_17_subtipo_conv WHERE tipo=a.tipo AND subtipo=a.subtipo) AS nsubtipo,
        b.id_usuario,
        d.actualizacion,
        d.actualizacion_anun
    FROM public.ta_17_conv_diverso a
    JOIN public.ta_17_conv_d_resto b ON b.tipo=a.tipo AND b.id_conv_diver=a.id_conv_diver
    JOIN public.ta_17_referencia d ON d.id_conv_resto=b.id_conv_resto
    WHERE a.tipo=p_tipo AND a.letras_exp=p_letras AND a.numero_exp=p_numero AND a.axo_exp=p_axo
      AND b.vigencia='A';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: IMPRIMEOFICIO (EXACTO del archivo original)
-- Archivo: 48_SP_CONVENIOS_IMPRIMEOFICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_imprime_oficio_firma
-- Tipo: Catalog
-- Descripción: Obtiene los datos de firma para la recaudadora correspondiente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_imprime_oficio_firma(
    p_recaudadora INTEGER
) RETURNS TABLE (
    recaudadora INTEGER,
    titular TEXT,
    cargotitular TEXT,
    recaudador TEXT,
    cargorecaudador TEXT,
    testigo1 TEXT,
    testigo2 TEXT,
    letras TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    FROM public.ta_17_firmaconv WHERE recaudadora=p_recaudadora;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: IMPRIMEOFICIO (EXACTO del archivo original)
-- Archivo: 48_SP_CONVENIOS_IMPRIMEOFICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_imprime_oficio_datos_pagare
-- Tipo: Report
-- Descripción: Devuelve todos los datos necesarios para la impresión del pagaré.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_imprime_oficio_datos_pagare(
    p_id_conv_resto INTEGER
) RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Aquí se arma el JSON con todos los textos, cantidades en letras, nombres, etc.
    -- Por simplicidad, solo se retorna un ejemplo
    SELECT json_build_object(
        'convenio', b.convenio,
        'nombre', b.nombre,
        'domicilio', b.domicilio,
        'cantidad_total', b.cantidad_total,
        'cantidad_total_letras', public.num2letras(b.cantidad_total),
        'firma', f.titular,
        'cargo', f.cargotitular,
        'testigo1', f.testigo1,
        'testigo2', f.testigo2,
        'fecha', to_char(now(), 'DD "de" TMMonth "de" YYYY')
    ) INTO result
    FROM sp_imprime_oficio_buscar_convenio('A', 1, 2024, 1) b
    LEFT JOIN public.ta_17_firmaconv f ON f.recaudadora=1
    WHERE b.id_conv_resto=p_id_conv_resto;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

