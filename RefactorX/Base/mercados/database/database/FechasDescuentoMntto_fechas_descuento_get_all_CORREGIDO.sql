-- Stored Procedure: fechas_descuento_get_all
-- CORREGIDO: Typo "publico" -> "public" en línea 26
-- Descripción: Obtiene todas las fechas de descuento del año.
-- Usado por: FechasDescuentoMntto.vue
-- Fecha corrección: 2025-12-05

DROP FUNCTION IF EXISTS fechas_descuento_get_all();

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp without time zone,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.mes,
        f.fecha_descuento,
        f.fecha_recargos,
        f.fecha_alta,
        f.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_fecha_desc f
    LEFT JOIN public.usuarios u ON u.id = f.id_usuario
    ORDER BY f.mes;
END;
$$ LANGUAGE plpgsql;

-- Comentarios:
-- ✅ Corregido el typo en línea 26: "publico" -> "public"
-- ✅ Asegura JOIN con tabla usuarios para mostrar nombre de usuario
-- ✅ Ordena por mes ascendente
