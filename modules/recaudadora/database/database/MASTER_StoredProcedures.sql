-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: Recaudadora
-- Generado: 2025-08-27 21:29:49
-- Total SPs: 22
-- ============================================

-- NOTA: Ejecutar este script en PostgreSQL para crear todos los stored procedures
-- del módulo. Se recomienda ejecutar en el siguiente orden:
-- 1. CATALOG procedures (consultas básicas)
-- 2. CRUD procedures (operaciones de datos)
-- 3. PROCESS procedures (procesos de negocio)
-- 4. REPORT procedures (reportes y análisis)

-- ============================================
-- STORED PROCEDURES TIPO: Catalog
-- ============================================

-- SP 1/4 del tipo Catalog
-- Nombre: sp_get_catalogo_descuentos
-- Descripción: Obtiene el catálogo de tipos de descuentos predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_catalogo_descuentos()
RETURNS TABLE(cvedescuento INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY SELECT cvedescuento, descripcion FROM c_descpred ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/4 del tipo Catalog
-- Nombre: sp_get_cuenta_by_clave
-- Descripción: Obtiene la cuenta catastral por clave catastral
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 3/4 del tipo Catalog
-- Nombre: sp_get_usuarios
-- Descripción: Obtiene los usuarios activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(usuario TEXT, nombres TEXT, cvedepto INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT usuario, nombres, cvedepto FROM usuarios WHERE fecbaj IS NULL;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/4 del tipo Catalog
-- Nombre: sp_lista_ejecutores
-- Descripción: Lista ejecutores disponibles para una recaudadora y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_lista_ejecutores(
    p_recaud INTEGER, p_fecha DATE
) RETURNS TABLE(cveejecutor INTEGER, ncompleto TEXT, asignar INTEGER, ultfec_entrega DATE) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, ncompleto, asignados, ultfec_entrega FROM ejecutores WHERE recaud = p_recaud AND (vigencia = 'V' OR (ultfec_entrega = p_fecha));
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: CRUD
-- ============================================

-- SP 1/13 del tipo CRUD
-- Nombre: sp_asignar_requerimientos
-- Descripción: Asigna requerimientos a un ejecutor en un rango de folios
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 2/13 del tipo CRUD
-- Nombre: sp_cancelar_descuento_predial
-- Descripción: Cancela un descuento predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_predial(p_id INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE descpred SET status = 'C', fecbaja = NOW(), captbaja = p_usuario WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/13 del tipo CRUD
-- Nombre: sp_descpred_create
-- Descripción: Crea un nuevo descuento de predial
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 4/13 del tipo CRUD
-- Nombre: sp_descpred_delete
-- Descripción: Da de baja (cancela) un descuento de predial
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 5/13 del tipo CRUD
-- Nombre: sp_descpred_get
-- Descripción: Obtiene un descuento de predial por ID
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 6/13 del tipo CRUD
-- Nombre: sp_descpred_reactivate
-- Descripción: Reactiva un descuento de predial dado de baja
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 7/13 del tipo CRUD
-- Nombre: sp_descpred_update
-- Descripción: Actualiza un descuento de predial existente
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 8/13 del tipo CRUD
-- Nombre: sp_eje_create
-- Descripción: Crea un nuevo ejecutor
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 9/13 del tipo CRUD
-- Nombre: sp_eje_delete
-- Descripción: Elimina un ejecutor (baja lógica)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_delete(p_id INTEGER) RETURNS TABLE(deleted BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET vigente = 'C', fecbaj = NOW() WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 10/13 del tipo CRUD
-- Nombre: sp_eje_update
-- Descripción: Actualiza un ejecutor existente
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 11/13 del tipo CRUD
-- Nombre: sp_insert_descuento_predial
-- Descripción: Inserta un nuevo descuento predial
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 12/13 del tipo CRUD
-- Nombre: sp_marcar_impresos
-- Descripción: Marca como impresos los requerimientos seleccionados
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 13/13 del tipo CRUD
-- Nombre: sp_max_impresiones
-- Descripción: Calcula el máximo de impresiones posibles para una recaudadora
-- --------------------------------------------

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

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: Report
-- ============================================

-- SP 1/5 del tipo Report
-- Nombre: sp_descpred_list
-- Descripción: Lista todos los descuentos de predial para una cuenta
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 2/5 del tipo Report
-- Nombre: sp_eje_report
-- Descripción: Reporte de ejecutores por rango de fechas y recaudadora
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 3/5 del tipo Report
-- Nombre: sp_get_adeudos_by_cuenta
-- Descripción: Obtiene los adeudos de una cuenta catastral
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 4/5 del tipo Report
-- Nombre: sp_get_descuentos_predial
-- Descripción: Obtiene los descuentos predial de una cuenta
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 5/5 del tipo Report
-- Nombre: sp_listanotificaciones_report
-- Descripción: Genera el listado de notificaciones/requerimientos/secuestros de multas según los filtros y orden seleccionados.
-- --------------------------------------------

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

-- --------------------------------------------

-- ============================================
-- FIN DEL SCRIPT MAESTRO
-- Total de 22 stored procedures incluidos
-- ============================================
