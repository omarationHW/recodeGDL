-- Stored Procedure: sp_prepago_get_data
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contribuyente y cuenta catastral para el formulario de prepago.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-27 18:51:25

CREATE OR REPLACE FUNCTION sp_prepago_get_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_completo, c.calle, c.noexterior, c.interior, ca.ultcomp, ca.axoultcomp
    FROM catastro ca
    JOIN regprop rp ON rp.cvecuenta = ca.cvecuenta AND rp.cveregprop = ca.cveregprop AND rp.encabeza = 'S'
    JOIN contrib c ON c.cvecont = rp.cvecont
    WHERE ca.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;