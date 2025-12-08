-- ============================================
-- DEPLOY BATCH 1 - PRIMEROS 5 COMPONENTES
-- Modulo: multas_reglamentos [Recaudadora]
-- Esquema: multas_reglamentos
-- Fecha: 2025-11-24
-- Componentes: ActualizaFechaEmpresas, AplicaSdosFavor, autdescto, bloqctasreqfrm, BloqueoMulta
-- ============================================

SET search_path TO multas_reglamentos, public;

-- ============================================
-- 1. ACTUALIZAFECHAEMPRESAS
-- ============================================

-- SP: Obtener ejecutores/empresas
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_get_ejecutores()
RETURNS TABLE(
    cveejecutor INTEGER,
    empresa VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.cveejecutor, e.empresa::VARCHAR(100)
    FROM ejecutor e
    WHERE e.vigente = 'V'
    ORDER BY e.empresa;
END;
$$ LANGUAGE plpgsql;

-- SP: Buscar folio en requerimientos
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_buscar_folio(
    p_clave_cuenta INTEGER,
    p_folio INTEGER,
    p_anio INTEGER
)
RETURNS TABLE(
    cvereq INTEGER,
    folioreq INTEGER,
    axoreq SMALLINT,
    cveejecut SMALLINT,
    fecent DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.cvereq, r.folioreq, r.axoreq, r.cveejecut, r.fecent
    FROM reqpredial r
    WHERE r.cvecuenta = p_clave_cuenta
      AND r.folioreq = p_folio
      AND r.axoreq = p_anio;
END;
$$ LANGUAGE plpgsql;

-- SP: Actualizar fecha practica individual
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_actualizar_fecha(
    p_clave_cuenta INTEGER,
    p_folio INTEGER,
    p_anio INTEGER,
    p_fecha_practica DATE
)
RETURNS TABLE(
    aplicados INTEGER,
    mensaje TEXT
) AS $$
DECLARE
    v_cvereq INTEGER;
BEGIN
    -- Buscar el cvereq
    SELECT r.cvereq INTO v_cvereq
    FROM reqpredial r
    WHERE r.cvecuenta = p_clave_cuenta
      AND r.folioreq = p_folio
      AND r.axoreq = p_anio;

    IF v_cvereq IS NULL THEN
        RETURN QUERY SELECT 0, 'Folio no encontrado';
        RETURN;
    END IF;

    -- Actualizar
    UPDATE reqpredial
    SET fecent = p_fecha_practica
    WHERE cvereq = v_cvereq;

    RETURN QUERY SELECT 1, 'Actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- SP: Actualizar fechas masivas (batch)
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_actualizar_batch(
    p_fecha_practica DATE,
    p_ejecutor INTEGER,
    p_folios_json JSONB
)
RETURNS TABLE(
    aplicados INTEGER,
    errores JSONB,
    mensaje TEXT
) AS $$
DECLARE
    v_aplicados INTEGER := 0;
    v_errores JSONB := '[]'::JSONB;
    v_folio JSONB;
    v_cvereq INTEGER;
BEGIN
    FOR v_folio IN SELECT * FROM jsonb_array_elements(p_folios_json)
    LOOP
        SELECT r.cvereq INTO v_cvereq
        FROM reqpredial r
        WHERE r.cvecuenta = (v_folio->>'clave_cuenta')::INTEGER
          AND r.folioreq = (v_folio->>'folio')::INTEGER
          AND r.axoreq = (v_folio->>'anio_folio')::INTEGER;

        IF v_cvereq IS NOT NULL THEN
            UPDATE reqpredial
            SET fecent = p_fecha_practica
            WHERE cvereq = v_cvereq;
            v_aplicados := v_aplicados + 1;
        ELSE
            v_errores := v_errores || jsonb_build_object(
                'folio', v_folio->>'folio',
                'clave_cuenta', v_folio->>'clave_cuenta',
                'anio_folio', v_folio->>'anio_folio',
                'error', 'Folio no encontrado'
            );
        END IF;
    END LOOP;

    RETURN QUERY SELECT v_aplicados, v_errores, 'Proceso completado';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2. APLICASDOSFAVOR
-- ============================================

-- SP: Buscar solicitud por folio y anio
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_busca_solicitud(
    p_folio INTEGER,
    p_axofol INTEGER
)
RETURNS TABLE(
    id_solic INTEGER,
    cvecuenta INTEGER,
    folio INTEGER,
    axofol SMALLINT,
    status VARCHAR(1),
    fecha_termino DATE,
    saldo_favor NUMERIC(12,2),
    importe NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id_solic, s.cvecuenta, s.folio, s.axofol, s.status, s.fecha_termino,
           COALESCE(sf.saldo_favor, 0)::NUMERIC(12,2),
           COALESCE((SELECT SUM(p.importe) FROM pagos_sdosfavor p WHERE p.id_solic = s.id_solic), 0)::NUMERIC(12,2)
    FROM solicitudes s
    LEFT JOIN sdosfavor sf ON sf.id_solic = s.id_solic
    WHERE s.folio = p_folio AND s.axofol = p_axofol;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener datos conversion cuenta
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_convcta(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    urbrus VARCHAR(1),
    recaud SMALLINT,
    cuenta INTEGER,
    vigente VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.urbrus, c.recaud, c.cuenta, c.vigente
    FROM comun.convcta c
    WHERE c.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener datos contribuyente
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_contrib(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto VARCHAR(200),
    calle VARCHAR(100),
    noexterior VARCHAR(20),
    interior VARCHAR(20),
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT ct.nombre_completo, ct.calle, ct.noexterior, ct.interior,
           cta.ultcomp, cta.axoultcomp
    FROM comun.contrib ct
    JOIN comun.convcta cta ON cta.cvecont = ct.cvecont
    WHERE cta.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener saldos a favor
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_saldos(p_id_solic INTEGER)
RETURNS TABLE(
    id_sdofavor INTEGER,
    cvecuenta INTEGER,
    id_solic INTEGER,
    imp_inconform NUMERIC(12,2),
    saldo_favor NUMERIC(12,2),
    fecha_pago DATE,
    capturista VARCHAR(20),
    tipo_apl VARCHAR(1),
    concepto INTEGER,
    numpago SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT sf.id_sdofavor, sf.cvecuenta, sf.id_solic, sf.imp_inconform,
           sf.saldo_favor, sf.fecha_pago, sf.capturista, sf.tipo_apl,
           sf.concepto, sf.numpago
    FROM sdosfavor sf
    WHERE sf.id_solic = p_id_solic;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener detalle saldos
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_detsaldos(
    p_cvecuenta INTEGER,
    p_bimi INTEGER DEFAULT NULL,
    p_axoi INTEGER DEFAULT NULL,
    p_bimf INTEGER DEFAULT NULL,
    p_axof INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    bimsal SMALLINT,
    axosal SMALLINT,
    impade NUMERIC(12,2),
    recfac NUMERIC(12,2),
    recvir NUMERIC(12,2),
    recpag NUMERIC(12,2),
    imppag NUMERIC(12,2),
    saldo NUMERIC(12,2),
    totalrec NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ds.cvecuenta, ds.bimsal, ds.axosal, ds.impade, ds.recfac, ds.recvir, ds.recpag, ds.imppag,
           (ds.impade - ds.imppag + ds.recfac - ds.recvir - ds.recpag)::NUMERIC(12,2) AS saldo,
           (ds.recfac - ds.recvir - ds.recpag)::NUMERIC(12,2) AS totalrec
    FROM comun.detsaldos ds
    WHERE ds.cvecuenta = p_cvecuenta
      AND (p_bimi IS NULL OR ds.bimsal >= p_bimi)
      AND (p_axoi IS NULL OR ds.axosal >= p_axoi)
      AND (p_bimf IS NULL OR ds.bimsal <= p_bimf)
      AND (p_axof IS NULL OR ds.axosal <= p_axof)
    ORDER BY ds.axosal, ds.bimsal;
END;
$$ LANGUAGE plpgsql;

-- SP: Aplicar saldo a favor
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_aplica_saldo(
    p_id_solic INTEGER,
    p_cvecuenta INTEGER,
    p_importe NUMERIC(12,2),
    p_tipo_apl VARCHAR(1),
    p_concepto INTEGER,
    p_usuario VARCHAR(20)
)
RETURNS TABLE(
    id_sdofavor INTEGER,
    mensaje TEXT
) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    -- Verificar si ya existe
    SELECT sf.id_sdofavor INTO v_id FROM sdosfavor sf WHERE sf.id_solic = p_id_solic;

    IF v_id IS NULL THEN
        INSERT INTO sdosfavor (cvecuenta, id_solic, imp_inconform, saldo_favor, fecha_pago, capturista, tipo_apl, concepto, numpago)
        VALUES (p_cvecuenta, p_id_solic, p_importe, p_importe, CURRENT_DATE, p_usuario, p_tipo_apl, p_concepto, 0)
        RETURNING id_sdofavor INTO v_id;
    ELSE
        UPDATE sdosfavor
        SET saldo_favor = p_importe,
            tipo_apl = p_tipo_apl,
            concepto = p_concepto,
            capturista = p_usuario
        WHERE id_sdofavor = v_id;
    END IF;

    RETURN QUERY SELECT v_id, 'Saldo aplicado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. AUTDESCTO (ya existen en autdescto_all_procedures.sql)
-- ============================================

-- Incluido desde archivo existente
-- sp_autdescto_list, sp_autdescto_create, sp_autdescto_update, sp_autdescto_cancel, sp_autdescto_reactivate

-- SP adicional: Listar tipos de descuento
CREATE OR REPLACE FUNCTION autdescto_sp_get_tipos_descuento()
RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion VARCHAR(100),
    axodescto SMALLINT,
    porcentaje SMALLINT,
    tasasvalidas VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cd.cvedescuento, cd.descripcion::VARCHAR(100), cd.axodescto, cd.porcentaje, cd.tasasvalidas
    FROM c_descpred cd
    WHERE cd.axodescto >= EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT
    ORDER BY cd.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP adicional: Obtener saldo cuenta
CREATE OR REPLACE FUNCTION autdescto_sp_get_saldo_cuenta(p_cvecuenta INTEGER, p_axosal INTEGER)
RETURNS TABLE(
    bimini SMALLINT,
    bimfin SMALLINT,
    adeudo NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT MIN(ds.bimsal)::SMALLINT AS bimini,
           MAX(ds.bimsal)::SMALLINT AS bimfin,
           SUM(ds.impade - ds.imppag + ds.recfac - ds.recvir - ds.recpag)::NUMERIC(12,2) AS adeudo
    FROM comun.detsaldos ds
    WHERE ds.cvecuenta = p_cvecuenta AND ds.axosal = p_axosal
    GROUP BY ds.cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. BLOQCTASREQFRM (ya existen en bloqctasreqfrm_all_procedures.sql)
-- ============================================

-- Incluido desde archivo existente
-- sp_grabainconf, spd_norequeribles, sp_bloquear_cuenta, sp_desbloquear_cuenta

-- SP adicional: Listar bloqueos por cuenta
CREATE OR REPLACE FUNCTION bloqctasreqfrm_sp_list(p_cvecuenta INTEGER DEFAULT NULL, p_cuenta INTEGER DEFAULT NULL)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cuenta INTEGER,
    urbrus VARCHAR(1),
    recaud SMALLINT,
    feccap DATE,
    capturista VARCHAR(20),
    observacion TEXT,
    fecbaja DATE,
    user_baja VARCHAR(20),
    tipo_bloq INTEGER,
    fecha_envio DATE,
    lote_envio INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT n.id, n.cvecuenta, n.cuenta, n.urbrus, n.recaud, n.feccap, n.capturista,
           n.observacion, n.fecbaja, n.user_baja, n.tipo_bloq, n.fecha_envio, n.lote_envio
    FROM norequeribles n
    WHERE (p_cvecuenta IS NULL OR n.cvecuenta = p_cvecuenta)
      AND (p_cuenta IS NULL OR n.cuenta = p_cuenta)
    ORDER BY n.feccap DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. BLOQUEOMULTA
-- ============================================

-- SP: Listar bloqueos de multa paginado
CREATE OR REPLACE FUNCTION bloqueomulta_sp_list(
    p_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    clave_cuenta VARCHAR(20),
    folio INTEGER,
    ejercicio SMALLINT,
    estatus VARCHAR(20),
    fecha_bloqueo DATE,
    usuario_bloqueo VARCHAR(20),
    motivo TEXT,
    fecha_desbloqueo DATE,
    usuario_desbloqueo VARCHAR(20),
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT bm.id_bloqueo, bm.clave_cuenta::VARCHAR(20), bm.folio, bm.ejercicio,
           CASE WHEN bm.fecha_desbloqueo IS NULL THEN 'BLOQUEADO' ELSE 'DESBLOQUEADO' END::VARCHAR(20) AS estatus,
           bm.fecha_bloqueo, bm.usuario_bloqueo, bm.motivo,
           bm.fecha_desbloqueo, bm.usuario_desbloqueo,
           COUNT(*) OVER()
    FROM bloqueo_multa bm
    WHERE (p_cuenta IS NULL OR bm.clave_cuenta LIKE '%' || p_cuenta || '%')
      AND (p_ejercicio IS NULL OR bm.ejercicio = p_ejercicio)
    ORDER BY bm.fecha_bloqueo DESC
    OFFSET p_offset LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- SP: Crear bloqueo de multa
CREATE OR REPLACE FUNCTION bloqueomulta_sp_crear_bloqueo(
    p_clave_cuenta VARCHAR,
    p_folio INTEGER,
    p_ejercicio INTEGER,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    mensaje TEXT
) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    -- Verificar si ya existe bloqueo activo
    IF EXISTS (SELECT 1 FROM bloqueo_multa WHERE clave_cuenta = p_clave_cuenta AND folio = p_folio AND ejercicio = p_ejercicio AND fecha_desbloqueo IS NULL) THEN
        RETURN QUERY SELECT 0, 'Ya existe un bloqueo activo para este folio';
        RETURN;
    END IF;

    INSERT INTO bloqueo_multa (clave_cuenta, folio, ejercicio, fecha_bloqueo, usuario_bloqueo, motivo)
    VALUES (p_clave_cuenta, p_folio, p_ejercicio, CURRENT_DATE, p_usuario, p_motivo)
    RETURNING bloqueo_multa.id_bloqueo INTO v_id;

    RETURN QUERY SELECT v_id, 'Bloqueo creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- SP: Quitar bloqueo de multa
CREATE OR REPLACE FUNCTION bloqueomulta_sp_quitar_bloqueo(
    p_id_bloqueo INTEGER,
    p_usuario VARCHAR,
    p_motivo_desbloqueo TEXT DEFAULT NULL
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    mensaje TEXT
) AS $$
BEGIN
    UPDATE bloqueo_multa
    SET fecha_desbloqueo = CURRENT_DATE,
        usuario_desbloqueo = p_usuario,
        motivo = COALESCE(motivo, '') || COALESCE(E'\nDesbloqueo: ' || p_motivo_desbloqueo, '')
    WHERE bloqueo_multa.id_bloqueo = p_id_bloqueo AND fecha_desbloqueo IS NULL;

    IF NOT FOUND THEN
        RETURN QUERY SELECT p_id_bloqueo, 'Bloqueo no encontrado o ya desbloqueado';
        RETURN;
    END IF;

    RETURN QUERY SELECT p_id_bloqueo, 'Bloqueo removido correctamente';
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener detalle bloqueo
CREATE OR REPLACE FUNCTION bloqueomulta_sp_get_detalle(p_id_bloqueo INTEGER)
RETURNS TABLE(
    id_bloqueo INTEGER,
    clave_cuenta VARCHAR(20),
    folio INTEGER,
    ejercicio SMALLINT,
    fecha_bloqueo DATE,
    usuario_bloqueo VARCHAR(20),
    motivo TEXT,
    fecha_desbloqueo DATE,
    usuario_desbloqueo VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT bm.id_bloqueo, bm.clave_cuenta::VARCHAR(20), bm.folio, bm.ejercicio,
           bm.fecha_bloqueo, bm.usuario_bloqueo, bm.motivo,
           bm.fecha_desbloqueo, bm.usuario_desbloqueo
    FROM bloqueo_multa bm
    WHERE bm.id_bloqueo = p_id_bloqueo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TABLA AUXILIAR: bloqueo_multa (crear si no existe)
-- ============================================

CREATE TABLE IF NOT EXISTS bloqueo_multa (
    id_bloqueo SERIAL PRIMARY KEY,
    clave_cuenta VARCHAR(20) NOT NULL,
    folio INTEGER NOT NULL,
    ejercicio SMALLINT NOT NULL,
    fecha_bloqueo DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_bloqueo VARCHAR(20) NOT NULL,
    motivo TEXT,
    fecha_desbloqueo DATE,
    usuario_desbloqueo VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bloqueo_multa_cuenta ON bloqueo_multa(clave_cuenta);
CREATE INDEX IF NOT EXISTS idx_bloqueo_multa_folio ON bloqueo_multa(folio, ejercicio);

-- ============================================
-- FIN DEPLOY BATCH 1
-- ============================================
