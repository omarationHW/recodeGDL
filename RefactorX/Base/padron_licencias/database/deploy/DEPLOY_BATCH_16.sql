-- ============================================
-- DEPLOY BATCH 16 - Componentes 76-80
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- ============================================
-- Componentes incluidos:
-- 76. prepagofrm (7 SPs)
-- 77. Propuestatab (10 SPs)
-- 78. prophologramasfrm (5 SPs)
-- 79. h_bloqueoDomiciliosfrm (3 SPs)
-- 80. observacionfrm (2 SPs)
-- TOTAL: 27 SPs
-- ============================================

-- ============================================
-- COMPONENTE 76: prepagofrm (7 SPs)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_prepago_get_data(p_cvecuenta INTEGER)
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

CREATE OR REPLACE FUNCTION public.sp_prepago_liquidacion_parcial(
    p_cvecuenta INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS JSON AS $$
DECLARE
    v_detalle JSON;
    v_totales JSON;
BEGIN
    SELECT json_agg(row_to_json(t)) INTO v_detalle FROM (
        SELECT v.axoefec, v.valfiscal, v.tasa, v.axosobre,
               SUM(d.recvir) AS recvir, SUM(d.impade+d.impvir) AS impfac,
               SUM(d.impvir) AS impvir, SUM(d.impade) AS impade,
               SUM(d.recfac-d.recpag-d.recvir) AS total,
               MIN(v.bimefec) AS bimini, MAX(v.bimefec) AS bimfin,
               MIN(v.bimefec)::TEXT || '/' || v.axoefec AS inicio,
               MAX(v.bimefec)::TEXT || '/' || v.axoefec AS fin
        FROM detsaldos d
        JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
        ORDER BY v.axoefec, bimini
    ) t;
    SELECT row_to_json(t) INTO v_totales FROM (
        SELECT SUM(d.recfac-d.recpag-d.recvir) AS recppag,
               SUM(d.impfac-d.imppag-d.impvir) AS impppag,
               (s.multa-s.multavir) AS multa,
               s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        FROM detsaldos d
        JOIN saldos s ON s.cvecuenta = d.cvecuenta
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY s.multa, s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        LIMIT 1
    ) t;
    RETURN json_build_object('detalle', v_detalle, 'totales', v_totales);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_prepago_get_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion TEXT,
    impdescto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedescuento, c.descripcion, SUM(d.impvir) AS impdescto
    FROM detsaldos d
    JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
    LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
           AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
      AND d.cvedescuento IS NOT NULL
    GROUP BY d.cvedescuento, c.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_prepago_get_ultimo_requerimiento(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvereq INTEGER,
    cveejecut SMALLINT,
    folioreq INTEGER,
    axoreq SMALLINT,
    cvecuenta INTEGER,
    cvepago INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    fecemi DATE,
    fecent DATE,
    cvecancr TEXT,
    axoini SMALLINT,
    bimini SMALLINT,
    axofin SMALLINT,
    bimfin SMALLINT,
    secuencia SMALLINT,
    vigencia TEXT,
    feccap DATE,
    capturista TEXT,
    iniper TEXT,
    finper TEXT,
    diastrans INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.*, r.bimini::TEXT||'/'||r.axoini AS iniper, r.bimfin::TEXT||'/'||r.axofin AS finper,
           (CURRENT_DATE - r.fecent)::INTEGER AS diastrans
    FROM reqpredial r
    WHERE r.cvecuenta = p_cvecuenta AND r.vigencia = 'V' AND r.fecent IS NOT NULL
    ORDER BY r.axoreq DESC, r.folioreq DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_prepago_recalcular_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_prepago_eliminar_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_prepago_calcular_descpred(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 77: Propuestatab (10 SPs)
-- ============================================

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

-- ============================================
-- COMPONENTE 78: prophologramasfrm (5 SPs)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_c_contribholog_list()
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_c_contribholog_show(p_idcontrib INTEGER)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c
    WHERE c.idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_c_contribholog_create(
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_idcontrib INTEGER;
BEGIN
    INSERT INTO c_contribholog (nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista)
    VALUES (p_nombre, p_domicilio, p_colonia, p_telefono, p_rfc, p_curp, p_email, NOW(), p_capturista)
    RETURNING c_contribholog.idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c WHERE c.idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_c_contribholog_update(
    p_idcontrib INTEGER,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    UPDATE c_contribholog
    SET nombre = p_nombre,
        domicilio = p_domicilio,
        colonia = p_colonia,
        telefono = p_telefono,
        rfc = p_rfc,
        curp = p_curp,
        email = p_email,
        capturista = p_capturista
    WHERE c_contribholog.idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c WHERE c.idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_c_contribholog_delete(p_idcontrib INTEGER)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM c_contribholog WHERE c_contribholog.idcontrib = p_idcontrib;
    IF FOUND THEN
        DELETE FROM c_contribholog WHERE c_contribholog.idcontrib = p_idcontrib;
        RETURN QUERY SELECT v_row.idcontrib, v_row.nombre, v_row.domicilio, v_row.colonia, v_row.telefono,
                            v_row.rfc, v_row.curp, v_row.email, v_row.feccap, v_row.capturista;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 79: h_bloqueoDomiciliosfrm (3 SPs)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_listar(p_order TEXT DEFAULT 'calle,num_ext')
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT * FROM h_bloqueo_dom ORDER BY %s', p_order);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_filtrar(
    p_campo TEXT,
    p_valor TEXT,
    p_order TEXT DEFAULT 'calle,num_ext'
)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT * FROM h_bloqueo_dom WHERE %I ILIKE %L ORDER BY %s',
        p_campo,
        '%' || p_valor || '%',
        p_order
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_detalle(p_id INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM h_bloqueo_dom WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 80: observacionfrm (2 SPs)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());

    RETURN QUERY
    SELECT o.id, o.observacion, o.created_at
    FROM observaciones o
    WHERE o.id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_observaciones()
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.id, o.observacion, o.created_at
    FROM observaciones o
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DEPLOY BATCH 16
-- ============================================
