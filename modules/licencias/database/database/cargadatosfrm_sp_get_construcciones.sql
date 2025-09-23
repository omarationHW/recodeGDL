-- Stored Procedure: sp_get_construcciones
-- Tipo: Report
-- Descripción: Obtiene las construcciones asociadas a un avaluo.
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-26 15:06:43

CREATE OR REPLACE FUNCTION sp_get_construcciones(p_cveavaluo INTEGER)
RETURNS TABLE(
    cvebloque INTEGER,
    cveclasif INTEGER,
    descripcion TEXT,
    areaconst NUMERIC,
    importe NUMERIC,
    numpisos INTEGER,
    estructura TEXT,
    factorajus NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cvebloque, c.cveclasif, b.descripcion, c.areaconst, c.importe, c.numpisos, c.estructura, c.factorajus
    FROM construc c
    LEFT JOIN c_bloqcon b ON b.axovig = c.axovig AND b.cveclasif = c.cveclasif
    WHERE c.cveavaluo = p_cveavaluo;
END;
$$ LANGUAGE plpgsql;