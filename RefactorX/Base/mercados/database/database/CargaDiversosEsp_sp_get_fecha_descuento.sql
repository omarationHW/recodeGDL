-- Stored Procedure: sp_get_fecha_descuento
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de descuento para un mes dado.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 22:49:31

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes INTEGER)
RETURNS TABLE(
    mes INTEGER,
    fecha_descuento DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_descuento, fecha_alta, id_usuario
    FROM ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;