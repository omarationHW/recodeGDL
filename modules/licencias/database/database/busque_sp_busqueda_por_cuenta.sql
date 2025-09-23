-- Stored Procedure: sp_busqueda_por_cuenta
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por recaudadora, urbano/rústico y número de cuenta.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:21

CREATE OR REPLACE FUNCTION sp_busqueda_por_cuenta(p_recaud INTEGER, p_urbrus TEXT, p_cuenta INTEGER)
RETURNS TABLE(
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    ncompleto TEXT,
    rfc TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, a.cvecatnva, a.subpredio, d.calle, d.noexterior, d.interior, b.nombre_completo, b.rfc
    FROM convcta a
    JOIN regprop c ON c.cvecuenta = a.cvecuenta
    JOIN contrib b ON b.cvecont = c.cvecont
    JOIN ubicacion d ON d.cvecuenta = a.cvecuenta
    WHERE a.recaud = p_recaud
      AND a.urbrus = p_urbrus
      AND a.cuenta = p_cuenta
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;