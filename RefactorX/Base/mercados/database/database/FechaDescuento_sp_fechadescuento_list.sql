-- Stored Procedure: sp_fechadescuento_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las filas de fechas de descuento con usuario
-- Generado para formulario: FechaDescuento
-- Fecha: 2025-08-27 00:02:50

DROP FUNCTION IF EXISTS sp_fechadescuento_list();

CREATE OR REPLACE FUNCTION sp_fechadescuento_list()
RETURNS TABLE (
    mes SMALLINT,
    fecha_descuento DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(20),
    fecha_recargos DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.mes, a.fecha_descuento, a.fecha_alta, a.id_usuario, b.usuario, a.fecha_recargos
    FROM publico.ta_11_fecha_desc a
    LEFT JOIN public.usuarios b ON a.id_usuario = b.id
    ORDER BY a.mes;
END;
$$ LANGUAGE plpgsql;