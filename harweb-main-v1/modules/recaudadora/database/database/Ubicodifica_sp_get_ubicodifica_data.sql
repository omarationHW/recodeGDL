-- Stored Procedure: sp_get_ubicodifica_data
-- Tipo: Catalog
-- Descripción: Obtiene los datos de contribuyente y codificación de ubicación para una cuenta.
-- Generado para formulario: Ubicodifica
-- Fecha: 2025-08-27 15:58:02

CREATE OR REPLACE FUNCTION sp_get_ubicodifica_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    cvecalle INTEGER,
    calleu TEXT,
    extu TEXT,
    intu TEXT,
    cvereg INTEGER,
    descripcion TEXT,
    fec_alta DATE,
    usuario_alta TEXT,
    vigencia TEXT,
    fec_mov DATE,
    usuario_mov TEXT,
    fec_baja DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT contrib.nombre_completo, contrib.calle, contrib.noexterior, contrib.interior, catastro.ultcomp, catastro.axoultcomp, c.recaud, c.urbrus, c.cuenta, ub.cvecalle, ub.calle, ub.noexterior, ub.interior, regprop.cvereg, cal.descripcion, ur.fec_alta, ur.usuario_alta, ur.vigencia, ur.fec_mov, ur.usuario_mov, ur.fec_baja
    FROM catastro
    JOIN regprop ON regprop.cvecuenta = catastro.cvecuenta AND regprop.cveregprop = catastro.cveregprop AND regprop.encabeza = 'S'
    JOIN contrib ON contrib.cvecont = regprop.cvecont
    JOIN convcta c ON c.cvecuenta = catastro.cvecuenta
    JOIN ubicacion ub ON ub.cveubic = catastro.cveubic
    LEFT JOIN c_calidpro cal ON cal.cvereg = regprop.cvereg
    LEFT JOIN ubicacion_req ur ON ur.cvecuenta = catastro.cvecuenta
    WHERE catastro.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;