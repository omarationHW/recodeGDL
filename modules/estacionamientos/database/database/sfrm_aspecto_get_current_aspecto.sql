-- Stored Procedure: get_current_aspecto
-- Tipo: Catalog
-- Descripción: Devuelve el aspecto visual actualmente seleccionado.
-- Generado para formulario: sfrm_aspecto
-- Fecha: 2025-08-27 14:09:01

CREATE OR REPLACE FUNCTION get_current_aspecto()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla de configuración
    RETURN QUERY SELECT 'SkinBlue'::TEXT AS nombre;
END;
$$ LANGUAGE plpgsql;