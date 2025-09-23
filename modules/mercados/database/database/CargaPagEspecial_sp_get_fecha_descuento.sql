-- Stored Procedure: sp_get_fecha_descuento
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de descuento para el mes dado.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 19:00:41

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes SMALLINT)
RETURNS TABLE (
    mes SMALLINT,
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