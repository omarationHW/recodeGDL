-- ============================================
-- DEPLOY CONSOLIDADO: Propuestatab
-- Componente 77/95 - BATCH 16
-- Generado: 2025-11-20
-- Total SPs: 10
-- ============================================

-- SP 1/10: sp_propuestatab_get_cuenta_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_cuenta_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cmovto VARCHAR,
    observacion TEXT,
    tasa NUMERIC,
    indiviso NUMERIC,
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    vigencia VARCHAR,
    obsinter TEXT,
    fechaotorg DATE,
    importe NUMERIC,
    valortransm NUMERIC,
    areatitulo NUMERIC,
    notario VARCHAR,
    noescrituras INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.cmovto, c.observacion, v.tasa, c.indiviso,
           u.calle, u.noexterior, u.interior, u.colonia, u.vigencia, u.obsinter,
           a.fechaotorg, p.importe, p.valortransm, h.areatitulo, n.notario, p.noescrituras,
           c.recaud, c.urbrus, c.cuenta
    FROM cuentas c
    LEFT JOIN valores v ON v.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN pagos p ON p.cvecuenta = c.cvecuenta
    LEFT JOIN historico h ON h.cvecuenta = c.cvecuenta
    LEFT JOIN notarios n ON n.idnotaria = p.idnotaria
    WHERE c.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 2/10: sp_propuestatab_get_regimen_propiedad_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_regimen_propiedad_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvereg INTEGER,
    encabeza VARCHAR,
    porcentaje NUMERIC,
    descripcion VARCHAR,
    exento VARCHAR,
    ncompleto VARCHAR,
    rfc VARCHAR,
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.cvereg, r.encabeza, r.porcentaje, r.descripcion, r.exento,
           r.ncompleto, r.rfc, r.calle, r.noexterior, r.interior
    FROM regimen_propiedad r
    WHERE r.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- SP 3/10: sp_propuestatab_get_diferencias_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_diferencias_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    bimini INTEGER,
    axoini INTEGER,
    bimfin INTEGER,
    axofin INTEGER,
    tasaant NUMERIC,
    stasaant NUMERIC,
    valfisant NUMERIC,
    tasa NUMERIC,
    axosobretasa NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.bimini, d.axoini, d.bimfin, d.axofin, d.tasaant, d.stasaant,
           d.valfisant, d.tasa, d.axosobretasa, d.valfiscal
    FROM diferencias d
    WHERE d.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- SP 4/10: sp_propuestatab_get_obsas400_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_obsas400_historico(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    acomp INTEGER,
    observa VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.acomp, o.observa
    FROM observ_400 o
    WHERE o.recaud = p_recaud AND o.urbrus = p_urbrus AND o.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- SP 5/10: sp_propuestatab_get_predial_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_predial_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    axoefec INTEGER,
    bimefec INTEGER,
    valfiscal NUMERIC,
    tasa NUMERIC,
    impuesto NUMERIC,
    recargos NUMERIC,
    total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.axoefec, v.bimefec, v.valfiscal, v.tasa,
           d.impade AS impuesto, d.recfac AS recargos,
           (d.impade + d.recfac) AS total
    FROM valoradeudo v
    JOIN detsaldos d ON d.cvecuenta = v.cvecuenta AND d.axosal = v.axoefec AND d.bimsal = v.bimefec
    WHERE v.cvecuenta = p_cvecuenta
    ORDER BY v.axoefec DESC, v.bimefec DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 6/10: sp_propuestatab_get_ubicacion_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_ubicacion_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    cp VARCHAR,
    vigencia VARCHAR,
    obsinter TEXT,
    fecalt DATE,
    fecmod DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.calle, u.noexterior, u.interior, u.colonia, u.cp, u.vigencia,
           u.obsinter, u.fecalt, u.fecmod
    FROM ubicacion u
    WHERE u.cvecuenta = p_cvecuenta
    ORDER BY u.fecmod DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 7/10: sp_propuestatab_get_valores_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_valores_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    axoefec INTEGER,
    valfiscal NUMERIC,
    valcatastral NUMERIC,
    tasa NUMERIC,
    axosobre INTEGER,
    fecact DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.axoefec, v.valfiscal, v.valcatastral, v.tasa, v.axosobre, v.fecact
    FROM valores v
    WHERE v.cvecuenta = p_cvecuenta
    ORDER BY v.axoefec DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 8/10: sp_propuestatab_get_cfs_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_cfs_historico(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvecatnva VARCHAR,
    nombre VARCHAR,
    tipocond VARCHAR,
    numpred INTEGER,
    escritura INTEGER,
    fecescrit DATE,
    areacomun NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.nombre, c.tipocond, c.numpred, c.escritura, c.fecescrit, c.areacomun
    FROM condominio c
    WHERE c.cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

-- SP 9/10: sp_propuestatab_get_hist_uem
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_hist_uem(p_cvecuenta INTEGER)
RETURNS TABLE(
    cveuem INTEGER,
    descripcion VARCHAR,
    axoinicio INTEGER,
    axofin INTEGER,
    fecalta DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.cveuem, u.descripcion, u.axoinicio, u.axofin, u.fecalta
    FROM hist_uem u
    WHERE u.cvecuenta = p_cvecuenta
    ORDER BY u.axoinicio DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 10/10: sp_propuestatab_get_escrituras_historico
CREATE OR REPLACE FUNCTION public.sp_propuestatab_get_escrituras_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    noescrituras INTEGER,
    fechaotorg DATE,
    notario VARCHAR,
    importe NUMERIC,
    valortransm NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.noescrituras, p.fechaotorg, n.notario, p.importe, p.valortransm
    FROM pagos p
    LEFT JOIN notarios n ON n.idnotaria = p.idnotaria
    WHERE p.cvecuenta = p_cvecuenta
    ORDER BY p.fechaotorg DESC;
END;
$$ LANGUAGE plpgsql;
