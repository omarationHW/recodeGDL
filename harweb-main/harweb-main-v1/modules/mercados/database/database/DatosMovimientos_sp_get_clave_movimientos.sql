-- Stored Procedure: sp_get_clave_movimientos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de movimiento.
-- Generado para formulario: DatosMovimientos
-- Fecha: 2025-08-26 23:46:08

CREATE OR REPLACE FUNCTION sp_get_clave_movimientos()
RETURNS TABLE (
    clave_movimiento SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT clave_movimiento, descripcion
    FROM ta_11_clave_mov
    ORDER BY clave_movimiento;
END;
$$ LANGUAGE plpgsql;