-- Stored Procedure: sp_busqueda_por_rfc
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por RFC del propietario.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:21

CREATE OR REPLACE FUNCTION sp_busqueda_por_rfc(p_rfc TEXT)
RETURNS TABLE(
    rfc TEXT,
    ncompleto TEXT,
    recaud SMALLINT,
    ur TEXT,
    cuenta INTEGER,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    clave_cat TEXT,
    subpredio SMALLINT,
    calle_vive TEXT,
    vive_ext TEXT,
    vive_int TEXT,
    descripcion TEXT,
    porcentaje FLOAT,
    encabeza TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.rfc, b.nombre_completo, c.recaud, c.urbrus, c.cuenta, d.calle, d.noexterior, d.interior, c.cvecatnva, c.subpredio,
           b.calle, b.noexterior, b.interior, h.descripcion, a.porcentaje, a.encabeza
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.rfc ILIKE '%' || p_rfc || '%'
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;