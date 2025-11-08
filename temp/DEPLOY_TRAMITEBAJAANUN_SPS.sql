-- =====================================================
-- STORED PROCEDURES - TramiteBajaAnun.vue
-- Módulo: Padrón de Licencias
-- Funcionalidad: Trámite de Baja de Anuncios
-- Base de Datos: padron_licencias (192.168.6.146)
-- Esquema: comun
-- Usuario: refact
-- Fecha: 2025-11-08
-- SPs: 3
-- =====================================================

-- SP 1/3: TramiteBajaAnun_sp_tramite_baja_anun_buscar
-- Busca un anuncio, sus saldos y la licencia relacionada

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_sp_tramite_baja_anun_buscar(INTEGER);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio JSONB,
    saldos JSONB,
    licencia JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        row_to_json(a)::jsonb AS anuncio,
        (SELECT json_agg(row_to_json(s))::jsonb FROM comun.detsal_lic s WHERE s.id_anuncio = a.id_anuncio AND s.cvepago = 0) AS saldos,
        row_to_json(l)::jsonb AS licencia
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 2/3: TramiteBajaAnun_sp_tramite_baja_anun_tramitar
-- Tramita la baja de un anuncio, cancela adeudos, recalcula saldo y registra

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_rec INTEGER DEFAULT 0,
    p_imp_solicitud NUMERIC DEFAULT 0,
    p_imp_licencia NUMERIC DEFAULT 0,
    p_importe NUMERIC DEFAULT 0
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_anuncio RECORD;
    v_folio INTEGER;
    v_axo INTEGER := COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
BEGIN
    -- Buscar el anuncio
    SELECT * INTO v_anuncio FROM comun.anuncios a WHERE a.anuncio = p_anuncio FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el anuncio'::TEXT;
        RETURN;
    END IF;

    IF v_anuncio.vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya se encuentra cancelado.'::TEXT;
        RETURN;
    END IF;

    -- Actualizar anuncio
    UPDATE comun.anuncios
    SET vigente = 'C',
        fecha_baja = NOW(),
        axo_baja = v_axo,
        folio_baja = COALESCE(p_folio_baja, 0),
        espubic = p_motivo
    WHERE anuncio = p_anuncio;

    -- Cancelar adeudos
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_anuncio = v_anuncio.id_anuncio
    AND cvepago = 0;

    -- Recalcular saldo de la licencia
    PERFORM comun.TramiteBajaAnun_calc_sdosl(v_anuncio.id_licencia);

    -- Insertar registro en lic_cancel
    SELECT COALESCE(MAX(folio),0)+1 INTO v_folio
    FROM comun.lic_cancel
    WHERE rec = p_rec AND axo = v_axo;

    INSERT INTO comun.lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago)
    VALUES (p_rec, v_axo, v_folio, 0, v_anuncio.anuncio, p_motivo, p_usuario, NOW(), p_imp_solicitud, p_imp_licencia, p_importe, 0);

    RETURN QUERY SELECT TRUE, 'Baja tramitada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 3/3: TramiteBajaAnun_calc_sdosl
-- Recalcula el saldo de la licencia

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_calc_sdosl(INTEGER);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Recalcular el saldo de la licencia
    -- Sumar los saldos pendientes de detsal_lic y actualizar saldos_lic
    -- Esta es una implementación básica - ajustar según lógica de negocio

    UPDATE comun.saldos_lic sl
    SET saldo = (
        SELECT COALESCE(SUM(ds.saldo), 0)
        FROM comun.detsal_lic ds
        WHERE ds.id_licencia = p_id_licencia
        AND ds.cvepago = 0
    )
    WHERE sl.id_licencia = p_id_licencia;

    -- Si no existe registro en saldos_lic, crear uno
    IF NOT FOUND THEN
        INSERT INTO comun.saldos_lic (id_licencia, saldo)
        SELECT p_id_licencia, COALESCE(SUM(ds.saldo), 0)
        FROM comun.detsal_lic ds
        WHERE ds.id_licencia = p_id_licencia
        AND ds.cvepago = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_buscar(INTEGER) IS
'Busca un anuncio, sus saldos pendientes y la licencia relacionada';

COMMENT ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC) IS
'Tramita la baja de un anuncio, cancela adeudos y registra en lic_cancel';

COMMENT ON FUNCTION comun.TramiteBajaAnun_calc_sdosl(INTEGER) IS
'Recalcula el saldo total de una licencia sumando los detsal_lic pendientes';

-- =====================================================
-- PERMISOS
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_buscar(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_buscar(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC) TO refact;
GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_calc_sdosl(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.TramiteBajaAnun_calc_sdosl(INTEGER) TO PUBLIC;
