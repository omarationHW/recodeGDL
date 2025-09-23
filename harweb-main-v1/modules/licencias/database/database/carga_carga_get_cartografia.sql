-- Stored Procedure: carga_get_cartografia
-- Tipo: CRUD
-- Descripción: Obtiene la información cartográfica de un predio (simulación, ya que MapObjects no aplica en web).
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_get_cartografia(p_cvecatnva VARCHAR, p_subpredio INTEGER)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Simulación: Devuelve la geometría y capas asociadas
    SELECT json_build_object(
        'cvecatnva', p_cvecatnva,
        'subpredio', p_subpredio,
        'layers', ARRAY['predios', 'construcciones', 'calles', 'numeros_oficiales'],
        'geometry', '{"type": "Polygon", "coordinates": [[[0,0],[1,0],[1,1],[0,1],[0,0]]]}'
    ) INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;