-- Stored Procedure: sp_fechadescuento_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las filas de fechas de descuento con usuario
-- Generado para formulario: FechaDescuento
-- Fecha: 2025-08-27 00:02:50

CREATE OR REPLACE FUNCTION sp_fechadescuento_list()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar(50),
    fecha_recargos date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.mes, a.fecha_descuento, a.fecha_alta, a.id_usuario, b.usuario, a.fecha_recargos
    FROM ta_11_fecha_desc a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.mes;
END;
$$ LANGUAGE plpgsql;