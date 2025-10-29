-- Stored Procedure: sp_imprime_oficio_buscar_convenio
-- Tipo: CRUD
-- Descripción: Busca convenio vigente por letras, número, año y tipo. Devuelve todos los datos necesarios para impresión.
-- Generado para formulario: ImprimeOficio
-- Fecha: 2025-08-27 14:41:11

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
        (SELECT importe FROM ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=1) AS inicial,
        (SELECT fecha_venc FROM ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=1) AS iniven,
        (SELECT importe FROM ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=2) AS parcial,
        (SELECT fecha_venc FROM ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto AND pago_parcial=2) AS parcven,
        (SELECT max(fecha_venc) FROM ta_17_adeudos_div WHERE id_conv_resto=b.id_conv_resto) AS parcvenfin,
        (SELECT descripcion FROM ta_17_tipos WHERE tipo=a.tipo) AS tipo,
        (SELECT desc_subtipo FROM ta_17_subtipo_conv WHERE tipo=a.tipo AND subtipo=a.subtipo) AS subtipo,
        d.modulo,
        d.id_referencia,
        (SELECT tipo FROM ta_17_tipos WHERE tipo=a.tipo) AS ntipo,
        (SELECT subtipo FROM ta_17_subtipo_conv WHERE tipo=a.tipo AND subtipo=a.subtipo) AS nsubtipo,
        b.id_usuario,
        d.actualizacion,
        d.actualizacion_anun
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON b.tipo=a.tipo AND b.id_conv_diver=a.id_conv_diver
    JOIN ta_17_referencia d ON d.id_conv_resto=b.id_conv_resto
    WHERE a.tipo=p_tipo AND a.letras_exp=p_letras AND a.numero_exp=p_numero AND a.axo_exp=p_axo
      AND b.vigencia='A';
END;
$$ LANGUAGE plpgsql;