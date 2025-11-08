-- Stored Procedure: sp_get_area_carto
-- Tipo: Report
-- Descripción: Obtiene el área de construcción cartográfica para una clave catastral.
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-26 15:06:43

CREATE OR REPLACE FUNCTION sp_get_area_carto(p_cvecatnva TEXT)
RETURNS TABLE(supconst NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT SUM(areaconst) FROM construc_carto WHERE cvecatnva = p_cvecatnva AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;