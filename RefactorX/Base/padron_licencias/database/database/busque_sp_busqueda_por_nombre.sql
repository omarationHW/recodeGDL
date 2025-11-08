-- Stored Procedure: sp_busqueda_por_nombre
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por nombre completo del propietario.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:21

CREATE OR REPLACE FUNCTION sp_busqueda_por_nombre(p_nombre TEXT)
RETURNS TABLE(
    cvecont INTEGER,
    ncompleto TEXT,
    vive_ext TEXT,
    vive_int TEXT,
    calle_vive TEXT,
    clave_cat TEXT,
    cuenta INTEGER,
    ur TEXT,
    reca SMALLINT,
    subpredio SMALLINT,
    vigente TEXT,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    cveregp INTEGER,
    cvectacat INTEGER,
    cveubic INTEGER,
    encabeza TEXT,
    descripcion TEXT,
    porcentaje FLOAT,
    rfc TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cvecont, b.nombre_completo, b.noexterior, b.interior, b.calle, c.cvecatnva, c.cuenta, c.urbrus, c.recaud, c.subpredio, c.vigente,
           d.calle, d.noexterior, d.interior, g.cveregprop, g.cvecuenta, g.cveubic, a.encabeza, h.descripcion, a.porcentaje, b.rfc
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cveubic = c.cveubic
    JOIN catastro g ON g.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.nombre_completo ILIKE '%' || p_nombre || '%'
      AND a.encabeza = 'S'
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;