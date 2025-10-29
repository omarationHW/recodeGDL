-- Stored Procedure: fechas_descuento_get_all
-- Tipo: Catalog
-- Descripción: Obtiene todas las fechas de descuento y recargos para el año actual.
-- Generado para formulario: FechasDescuentoMntto
-- Fecha: 2025-08-27 00:04:11

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario text
) AS $$
BEGIN
    RETURN QUERY
    SELECT f.mes, f.fecha_descuento, f.fecha_recargos, f.fecha_alta, f.id_usuario, u.usuario
    FROM ta_11_fecha_desc f
    LEFT JOIN ta_12_passwords u ON u.id_usuario = f.id_usuario
    ORDER BY f.mes;
END;
$$ LANGUAGE plpgsql;