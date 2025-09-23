CREATE OR REPLACE FUNCTION sp_get_cuenta_by_clave(p_clave TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvecatnva, recaud, urbrus, cuenta
    FROM convcta WHERE cvecatnva = p_clave;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(usuario TEXT, nombres TEXT, cvedepto INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT usuario, nombres, cvedepto FROM usuarios WHERE fecbaj IS NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_catalogo_descuentos()
RETURNS TABLE(cvedescuento INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY SELECT cvedescuento, descripcion FROM c_descpred ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_lista_ejecutores(
    p_recaud INTEGER, p_fecha DATE
) RETURNS TABLE(cveejecutor INTEGER, ncompleto TEXT, asignar INTEGER, ultfec_entrega DATE) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, ncompleto, asignados, ultfec_entrega FROM ejecutores WHERE recaud = p_recaud AND (vigencia = 'V' OR (ultfec_entrega = p_fecha));
END;
$$ LANGUAGE plpgsql;