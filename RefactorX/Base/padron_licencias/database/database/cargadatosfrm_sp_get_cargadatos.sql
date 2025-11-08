-- Stored Procedure: sp_get_cargadatos
-- Tipo: Report
-- Descripción: Obtiene los datos principales del predio y su avaluo por clave catastral.
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-26 15:06:43

CREATE OR REPLACE FUNCTION sp_get_cargadatos(p_cvecatnva TEXT)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    propietario TEXT,
    rfc TEXT,
    colonia TEXT,
    codpos TEXT,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    observacion TEXT,
    cveavaluo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.calle,
        u.noexterior,
        u.interior,
        c.nombre_completo AS propietario,
        c.rfc,
        u.colonia,
        u.codpos,
        a.supterr,
        a.supconst,
        a.valorterr,
        a.valorconst,
        a.valfiscal,
        a.observacion,
        a.cveavaluo
    FROM convcta v
    LEFT JOIN ubicacion u ON u.cvecuenta = v.cvecuenta
    LEFT JOIN contrib c ON c.cvecont = (SELECT cvecont FROM regprop WHERE cvecuenta = v.cvecuenta AND encabeza = 'S' LIMIT 1)
    LEFT JOIN avaluos a ON a.cvecuenta = v.cvecuenta AND a.vigencia = 'V'
    WHERE v.cvecatnva = p_cvecatnva
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;