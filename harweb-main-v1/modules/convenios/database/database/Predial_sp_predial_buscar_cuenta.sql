-- Stored Procedure: sp_predial_buscar_cuenta
-- Tipo: Catalog
-- Descripción: Busca los datos del contribuyente y cuenta predial
-- Generado para formulario: Predial
-- Fecha: 2025-08-27 15:16:35

CREATE OR REPLACE FUNCTION sp_predial_buscar_cuenta(
    p_recaud INTEGER,
    p_urbrus VARCHAR,
    p_cuenta INTEGER
) RETURNS TABLE (
    cvecuenta INTEGER,
    ncompleto VARCHAR,
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    telefono VARCHAR,
    cvereg INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, contrib.nombre_completo, contrib.calle, contrib.noexterior, contrib.interior, contrib.telefono, reg.cvereg, cal.descripcion
    FROM convcta c
    JOIN catastro ON catastro.cvecuenta = c.cvecuenta
    JOIN regprop reg ON reg.cvecuenta = catastro.cvecuenta AND reg.cveregprop = catastro.cveregprop AND reg.encabeza = 'S'
    JOIN contrib ON contrib.cvecont = reg.cvecont
    LEFT JOIN c_calidpro cal ON cal.cvereg = reg.cvereg
    WHERE c.recaud = p_recaud AND c.urbrus = p_urbrus AND c.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;