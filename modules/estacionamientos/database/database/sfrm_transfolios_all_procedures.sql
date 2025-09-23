-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_transfolios
-- Generado: 2025-08-27 14:33:28
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_altas_folios
-- Tipo: CRUD
-- Descripción: Inserta un folio de multa de estacionómetro en ta14_folios_adeudo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_altas_folios(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR,
    p_fec DATE,
    p_clave SMALLINT,
    p_estado SMALLINT,
    p_agente INTEGER,
    p_captura SMALLINT
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    INSERT INTO ta14_folios_adeudo (
        axo, folio, fecha_folio, placa, infraccion, estado, vigilante, fec_cap, usu_inicial
    ) VALUES (
        p_axo, p_folio, p_fec, p_placa, p_clave, p_estado, p_agente, CURRENT_DATE, p_captura
    );
    RETURN QUERY SELECT 1 AS result, 'Insertado correctamente' AS msg;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_bajas_folios
-- Tipo: CRUD
-- Descripción: Realiza la baja de folios de multas de estacionómetros (simula lógica de spd_delesta01).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bajas_folios(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR,
    p_fecha DATE,
    p_convenio INTEGER,
    p_reca SMALLINT,
    p_caja VARCHAR,
    p_oper INTEGER,
    p_opc SMALLINT,
    p_usuauto INTEGER
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
DECLARE
    v_updated INTEGER := 0;
BEGIN
    -- Simulación: actualiza estado de folio a 'baja' (ejemplo: estado=99)
    UPDATE ta14_folios_adeudo
    SET estado = CASE WHEN p_opc = 6 THEN 99 ELSE 98 END,
        fec_baja = p_fecha,
        usu_baja = p_usuauto
    WHERE axo = p_axo AND folio = p_folio AND placa = p_placa;
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated > 0 THEN
        RETURN QUERY SELECT 1 AS result, 'Baja realizada' AS msg;
    ELSE
        RETURN QUERY SELECT 0 AS result, 'No se encontró el folio' AS msg;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_altas_calcomanias
-- Tipo: CRUD
-- Descripción: Inserta una calcomanía sin propietario en ta14_calco.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_altas_calcomanias(
    p_axo SMALLINT,
    p_calco INTEGER,
    p_status VARCHAR,
    p_turno VARCHAR,
    p_fecini DATE,
    p_fecfin DATE,
    p_placa VARCHAR,
    p_propie INTEGER,
    p_usu INTEGER
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    INSERT INTO ta14_calco(
        axo, num_calco, tipo, turno, fecha_inicial, fecha_fin, placa, propietario, fec_cap, usu_inicial
    ) VALUES (
        p_axo, p_calco, p_status, p_turno, p_fecini, p_fecfin, p_placa, p_propie, CURRENT_DATE, p_usu
    );
    RETURN QUERY SELECT 1 AS result, 'Insertado correctamente' AS msg;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

