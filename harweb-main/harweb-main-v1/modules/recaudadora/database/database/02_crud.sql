CREATE OR REPLACE FUNCTION sp_insert_descuento_predial(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_fecalta DATE,
    p_captalta TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_recaud INTEGER,
    p_foliodesc INTEGER,
    p_status TEXT,
    p_identificacion TEXT DEFAULT NULL,
    p_fecnac DATE DEFAULT NULL,
    p_institucion INTEGER DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descpred (cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta, solicitante, observaciones, recaud, foliodesc, status, identificacion, fecnac, institucion)
    VALUES (p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_fecalta, p_captalta, p_solicitante, p_observaciones, p_recaud, p_foliodesc, p_status, p_identificacion, p_fecnac, p_institucion)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_predial(p_id INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE descpred SET status = 'C', fecbaja = NOW(), captbaja = p_usuario WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_get(p_id INTEGER)
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
    WHERE d.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_create(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_identificacion TEXT,
    p_fecnac DATE,
    p_institucion INTEGER,
    p_observaciones TEXT,
    p_porcentaje INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descpred (
        cvecuenta, cvedescuento, bimini, bimfin, solicitante, identificacion, fecnac, institucion, observaciones, porcentaje, fecalta, captalta, status
    ) VALUES (
        p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_solicitante, p_identificacion, p_fecnac, p_institucion, p_observaciones, p_porcentaje, NOW(), p_user, 'V'
    ) RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_update(
    p_id INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_identificacion TEXT,
    p_fecnac DATE,
    p_institucion INTEGER,
    p_observaciones TEXT,
    p_porcentaje INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        bimini = p_bimini,
        bimfin = p_bimfin,
        solicitante = p_solicitante,
        identificacion = p_identificacion,
        fecnac = p_fecnac,
        institucion = p_institucion,
        observaciones = p_observaciones,
        porcentaje = p_porcentaje,
        captbaja = NULL,
        fecbaja = NULL
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_delete(
    p_id INTEGER,
    p_motivo TEXT,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        status = 'C',
        fecbaja = NOW(),
        captbaja = p_user,
        observaciones = COALESCE(observaciones, '') || '\nBAJA: ' || p_motivo
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_descpred_reactivate(
    p_id INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        status = 'V',
        fecbaja = NULL,
        captbaja = NULL
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eje_create(
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(cveejecutor INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ejecutores (paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, capturista, vigente, feccap)
    VALUES (p_paterno, p_materno, p_nombres, p_rfc, p_recaud, p_oficio, p_fecing, p_fecinic, p_fecterm, p_capturista, 'V', NOW())
    RETURNING cveejecutor INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eje_update(
    p_id INTEGER,
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(updated BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET
        paterno = p_paterno,
        materno = p_materno,
        nombres = p_nombres,
        rfc = p_rfc,
        recaud = p_recaud,
        oficio = p_oficio,
        fecing = p_fecing,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        capturista = p_capturista,
        feccap = NOW()
    WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eje_delete(p_id INTEGER) RETURNS TABLE(deleted BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET vigente = 'C', fecbaj = NOW() WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_asignar_requerimientos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_ejecutor INTEGER, p_fecha DATE
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_ejecutor, fecejec = p_fecha
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'asignado' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_marcar_impresos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_usuario TEXT
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET impreso = 'S', feccap = NOW(), capturista = p_usuario
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'impreso' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_max_impresiones(
    p_recaud INTEGER
) RETURNS TABLE(max INTEGER) AS $$
DECLARE
    tEjec INTEGER;
    tReq INTEGER;
    sZona INTEGER;
    maxImp INTEGER;
BEGIN
    SELECT COUNT(*) INTO tEjec FROM ejecutores WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO tReq FROM reqpredial WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO sZona FROM reqpredial WHERE recaud = p_recaud AND (zona_subzona = '0' OR zona_subzona IS NULL) AND vigencia = 'V';
    maxImp := tReq - sZona;
    IF tEjec > 0 THEN
        maxImp := LEAST(maxImp, tEjec);
    END IF;
    RETURN QUERY SELECT maxImp;
END;
$$ LANGUAGE plpgsql;