-- ============================================
-- DEPLOY BATCH 2 - MULTAS Y REGLAMENTOS
-- 3 Componentes: CatastroDM, ConsReq400, ReqTrans
-- Fecha: 2025-11-24
-- ============================================

-- ============================================
-- COMPONENTE 1: CatastroDM
-- Gestion de descuentos prediales
-- ============================================

-- SP: Buscar cuenta por clave catastral
CREATE OR REPLACE FUNCTION catastrodm_sp_get_cuenta_by_clave(p_clave TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.recaud, c.urbrus, c.cuenta
    FROM convcta c
    WHERE c.cvecatnva = p_clave
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener adeudos por cuenta
CREATE OR REPLACE FUNCTION catastrodm_sp_get_adeudos_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    axosal INTEGER,
    bimsal INTEGER,
    impfac NUMERIC,
    recfac NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.axosal, s.bimsal, s.impfac, s.recfac,
           COALESCE(s.impfac, 0) + COALESCE(s.recfac, 0) as saldo
    FROM saldo s
    WHERE s.cvecuenta = p_cvecuenta
    ORDER BY s.axosal DESC, s.bimsal DESC;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener descuentos prediales por cuenta
CREATE OR REPLACE FUNCTION catastrodm_sp_get_descuentos_predial(p_cvecuenta INTEGER)
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
    RETURN QUERY
    SELECT d.id, d.cvedescuento, d.bimini, d.bimfin,
           d.solicitante, d.observaciones, d.fecalta, d.status
    FROM descpred d
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener catalogo de tipos de descuento
CREATE OR REPLACE FUNCTION catastrodm_sp_get_catalogo_descuentos()
RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvedescuento, c.descripcion
    FROM c_descpred c
    ORDER BY c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP: Insertar descuento predial
CREATE OR REPLACE FUNCTION catastrodm_sp_insert_descuento_predial(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_recaud INTEGER,
    p_status TEXT
) RETURNS JSON AS $$
DECLARE
    v_id INTEGER;
    v_foliodesc INTEGER;
BEGIN
    -- Generar folio
    SELECT COALESCE(MAX(foliodesc), 0) + 1 INTO v_foliodesc FROM descpred WHERE recaud = p_recaud;

    INSERT INTO descpred (
        cvecuenta, cvedescuento, bimini, bimfin,
        fecalta, captalta, solicitante, observaciones,
        recaud, foliodesc, status
    ) VALUES (
        p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin,
        CURRENT_DATE, 'WEB', p_solicitante, p_observaciones,
        p_recaud, v_foliodesc, p_status
    ) RETURNING id INTO v_id;

    RETURN json_build_object('id', v_id, 'foliodesc', v_foliodesc, 'ok', true);
END;
$$ LANGUAGE plpgsql;

-- SP: Cancelar descuento predial
CREATE OR REPLACE FUNCTION catastrodm_sp_cancelar_descuento_predial(
    p_id INTEGER,
    p_usuario TEXT
) RETURNS JSON AS $$
BEGIN
    UPDATE descpred
    SET status = 'C',
        fecbaja = CURRENT_DATE,
        captbaja = p_usuario
    WHERE id = p_id;

    RETURN json_build_object('ok', true, 'mensaje', 'Descuento cancelado');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 2: ConsReq400
-- Consulta de requerimientos AS-400
-- ============================================

-- SP: Buscar requerimientos AS-400
CREATE OR REPLACE FUNCTION consreq400_sp_get_requerimientos(
    p_ofnar TEXT,
    p_tpr TEXT,
    p_ctarfc TEXT
) RETURNS TABLE(
    ofnar TEXT,
    tpr TEXT,
    ctarfc TEXT,
    folio INTEGER,
    tipo TEXT,
    fecha DATE,
    importe NUMERIC,
    estatus TEXT,
    recargos NUMERIC,
    multas NUMERIC,
    gastos NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    -- Busca en tabla de requerimientos historicos AS-400
    RETURN QUERY
    SELECT
        r.ofnar::TEXT,
        r.tpr::TEXT,
        r.ctarfc::TEXT,
        r.folio,
        r.tipo,
        r.fecha,
        r.importe,
        r.estatus,
        r.recargos,
        r.multas,
        r.gastos,
        r.observaciones
    FROM req400 r
    WHERE (p_ofnar IS NULL OR r.ofnar = p_ofnar)
      AND (p_tpr IS NULL OR r.tpr = p_tpr)
      AND (p_ctarfc IS NULL OR r.ctarfc = p_ctarfc)
    ORDER BY r.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 3: ReqTrans
-- Requerimientos de Transmisiones Patrimoniales
-- ============================================

-- SP: Obtener catalogo de ejecutores
CREATE OR REPLACE FUNCTION reqtrans_sp_get_ejecutores()
RETURNS TABLE(
    cveejecutor INTEGER,
    nombres TEXT,
    paterno TEXT,
    materno TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.cveejecutor, e.nombres, e.paterno, e.materno
    FROM ejecutor e
    WHERE COALESCE(e.status, 'A') = 'A'
    ORDER BY e.nombres, e.paterno;
END;
$$ LANGUAGE plpgsql;

-- SP: Listar requerimientos de transmisiones
CREATE OR REPLACE FUNCTION reqtrans_sp_list(
    p_folioreq INTEGER DEFAULT NULL,
    p_cvecta INTEGER DEFAULT NULL,
    p_cveejec INTEGER DEFAULT NULL
) RETURNS TABLE(
    folioreq INTEGER,
    tipo TEXT,
    cvecta INTEGER,
    cveejec INTEGER,
    fecemi DATE,
    importe NUMERIC,
    recargos NUMERIC,
    multas_ex NUMERIC,
    multas_otr NUMERIC,
    gastos NUMERIC,
    gastos_req NUMERIC,
    total NUMERIC,
    observ TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.folioreq,
        r.tipo,
        r.cvecta,
        r.cveejec,
        r.fecemi,
        r.importe,
        r.recargos,
        r.multas_ex,
        r.multas_otr,
        r.gastos,
        r.gastos_req,
        r.total,
        r.observ
    FROM reqtrans r
    WHERE (p_folioreq IS NULL OR r.folioreq = p_folioreq)
      AND (p_cvecta IS NULL OR r.cvecta = p_cvecta)
      AND (p_cveejec IS NULL OR r.cveejec = p_cveejec)
    ORDER BY r.fecemi DESC, r.folioreq DESC
    LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- SP: Crear requerimiento de transmision
CREATE OR REPLACE FUNCTION reqtrans_sp_create(
    p_folioreq INTEGER,
    p_tipo TEXT,
    p_cvecta INTEGER,
    p_cveejec INTEGER,
    p_fecemi DATE,
    p_importe NUMERIC,
    p_recargos NUMERIC,
    p_multas_ex NUMERIC,
    p_multas_otr NUMERIC,
    p_gastos NUMERIC,
    p_gastos_req NUMERIC,
    p_total NUMERIC,
    p_observ TEXT
) RETURNS JSON AS $$
BEGIN
    INSERT INTO reqtrans (
        folioreq, tipo, cvecta, cveejec, fecemi,
        importe, recargos, multas_ex, multas_otr,
        gastos, gastos_req, total, observ, usu_act, fec_act
    ) VALUES (
        p_folioreq, p_tipo, p_cvecta, p_cveejec, p_fecemi,
        p_importe, p_recargos, p_multas_ex, p_multas_otr,
        p_gastos, p_gastos_req, p_total, p_observ, 'WEB', CURRENT_TIMESTAMP
    );

    RETURN json_build_object('ok', true, 'folioreq', p_folioreq);
END;
$$ LANGUAGE plpgsql;

-- SP: Actualizar requerimiento de transmision
CREATE OR REPLACE FUNCTION reqtrans_sp_update(
    p_folioreq INTEGER,
    p_tipo TEXT,
    p_cvecta INTEGER,
    p_cveejec INTEGER,
    p_fecemi DATE,
    p_importe NUMERIC,
    p_recargos NUMERIC,
    p_multas_ex NUMERIC,
    p_multas_otr NUMERIC,
    p_gastos NUMERIC,
    p_gastos_req NUMERIC,
    p_total NUMERIC,
    p_observ TEXT
) RETURNS JSON AS $$
BEGIN
    UPDATE reqtrans SET
        tipo = p_tipo,
        cvecta = p_cvecta,
        cveejec = p_cveejec,
        fecemi = p_fecemi,
        importe = p_importe,
        recargos = p_recargos,
        multas_ex = p_multas_ex,
        multas_otr = p_multas_otr,
        gastos = p_gastos,
        gastos_req = p_gastos_req,
        total = p_total,
        observ = p_observ,
        usu_act = 'WEB',
        fec_act = CURRENT_TIMESTAMP
    WHERE folioreq = p_folioreq;

    RETURN json_build_object('ok', true, 'folioreq', p_folioreq);
END;
$$ LANGUAGE plpgsql;

-- SP: Eliminar requerimiento de transmision
CREATE OR REPLACE FUNCTION reqtrans_sp_delete(p_folioreq INTEGER)
RETURNS JSON AS $$
BEGIN
    DELETE FROM reqtrans WHERE folioreq = p_folioreq;
    RETURN json_build_object('ok', true, 'mensaje', 'Requerimiento eliminado');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DEPLOY BATCH 2
-- ============================================

-- Verificacion rapida
DO $$
BEGIN
    RAISE NOTICE '=== DEPLOY BATCH 2 COMPLETADO ===';
    RAISE NOTICE 'Componentes desplegados:';
    RAISE NOTICE '1. CatastroDM - 6 SPs';
    RAISE NOTICE '2. ConsReq400 - 1 SP';
    RAISE NOTICE '3. ReqTrans - 5 SPs';
    RAISE NOTICE 'Total: 12 SPs';
END $$;
