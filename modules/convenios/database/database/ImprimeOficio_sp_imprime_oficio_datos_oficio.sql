-- Stored Procedure: sp_imprime_oficio_datos_oficio
-- Tipo: Report
-- Descripción: Devuelve todos los datos necesarios para la impresión del oficio (incluye textos legales, cantidades en letras, etc).
-- Generado para formulario: ImprimeOficio
-- Fecha: 2025-08-27 14:41:11

CREATE OR REPLACE FUNCTION sp_imprime_oficio_datos_oficio(
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
        'inicial', b.inicial,
        'inicial_letras', public.num2letras(b.inicial),
        'parcial', b.parcial,
        'parcial_letras', public.num2letras(b.parcial),
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