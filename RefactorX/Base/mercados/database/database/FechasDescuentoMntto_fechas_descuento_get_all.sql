-- Stored Procedure: fechas_descuento_get_all
-- Tipo: Catalog
-- Descripción: Obtiene todas las fechas de descuento y recargos para el año actual.
-- Generado para formulario: FechasDescuentoMntto
-- Fecha: 2025-08-27 00:04:11
-- Desplegado: 2025-12-03 (corregido schema publico + JOIN con usuarios)

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
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
    FROM publico.ta_11_fecha_desc f
    LEFT JOIN public.usuarios u ON u.id = f.id_usuario
    ORDER BY f.mes;
END;
$$ LANGUAGE plpgsql;