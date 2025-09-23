CREATE OR REPLACE FUNCTION sp_get_adeudos_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    axosal INTEGER,
    bimsal INTEGER,
    impfac NUMERIC,
    recfac NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY SELECT axosal, bimsal, impfac, recfac, saldo
    FROM detsaldos WHERE cvecuenta = p_cvecuenta ORDER BY axosal, bimsal;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_descuentos_predial(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    solicitante TEXT,
    observaciones TEXT,
    fecalta DATE,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id, cvedescuento, bimini, bimfin, solicitante, observaciones, fecalta, status
    FROM descpred WHERE cvecuenta = p_cvecuenta ORDER BY fecalta DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion INTEGER,
    porcentaje INTEGER,
    descripcion TEXT,
    institucion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, d.captalta, d.fecbaja, d.captbaja, d.propie, d.solicitante, d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, d.fecnac, d.institucion, d.porcentaje, c.descripcion, i.institucion
    FROM descpred d
    JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    LEFT JOIN c_instituciones i ON d.institucion = i.cveinst
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eje_report(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_recaud INTEGER
) RETURNS TABLE(
    cveejecutor INTEGER,
    paterno TEXT,
    materno TEXT,
    nombres TEXT,
    rfc TEXT,
    recaud INTEGER,
    oficio TEXT,
    fecing DATE,
    fecinic DATE,
    fecterm DATE,
    vigente TEXT,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveejecutor, paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, vigente, feccap
    FROM ejecutores
    WHERE (p_fecha_inicio IS NULL OR fecing >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR fecing <= p_fecha_fin)
      AND (p_recaud IS NULL OR recaud = p_recaud)
    ORDER BY cveejecutor;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listanotificaciones_report(
    p_axo integer,
    p_reca integer,
    p_inicio integer,
    p_final integer,
    p_tipo character varying,
    p_orden character varying
)
RETURNS TABLE (
    abrevia text,
    axo_acta integer,
    num_acta integer,
    num_lote integer,
    folioreq integer
) AS $$
BEGIN
    IF p_orden = 'lote' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
        ORDER BY m.num_lote, m.num_acta;
    ELSIF p_orden = 'vigentes' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY r.folioreq;
    ELSIF p_orden = 'dependencia' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY d.abrevia, m.axo_acta, m.num_acta;
    ELSE
        RAISE EXCEPTION 'Orden no válido: %', p_orden;
    END IF;
END;
$$ LANGUAGE plpgsql;