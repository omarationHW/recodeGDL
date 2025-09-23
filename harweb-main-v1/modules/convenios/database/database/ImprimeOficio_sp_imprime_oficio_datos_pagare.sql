-- Stored Procedure: sp_imprime_oficio_datos_pagare
-- Tipo: Report
-- Descripción: Devuelve todos los datos necesarios para la impresión del pagaré.
-- Generado para formulario: ImprimeOficio
-- Fecha: 2025-08-27 14:41:11

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
    LEFT JOIN ta_17_firmaconv f ON f.recaudadora=1
    WHERE b.id_conv_resto=p_id_conv_resto;
    RETURN result;
END;
$$ LANGUAGE plpgsql;