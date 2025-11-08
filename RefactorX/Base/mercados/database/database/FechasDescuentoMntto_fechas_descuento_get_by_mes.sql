-- Stored Procedure: fechas_descuento_get_by_mes
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de descuento y recargos para un mes específico.
-- Generado para formulario: FechasDescuentoMntto
-- Fecha: 2025-08-27 00:04:11

CREATE OR REPLACE FUNCTION fechas_descuento_get_by_mes(p_mes smallint)
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
    WHERE f.mes = p_mes;
END;
$$ LANGUAGE plpgsql;