-- Stored Procedure: get_aspectos
-- Tipo: Catalog
-- Descripción: Devuelve la lista de aspectos visuales disponibles.
-- Generado para formulario: sfrm_aspecto
-- Fecha: 2025-08-27 14:09:01

CREATE OR REPLACE FUNCTION get_aspectos()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla o directorio
    RETURN QUERY SELECT unnest(ARRAY['Directorio de Aspectos...', 'SkinBlue', 'SkinDark', 'SkinClassic']) AS nombre;
END;
$$ LANGUAGE plpgsql;