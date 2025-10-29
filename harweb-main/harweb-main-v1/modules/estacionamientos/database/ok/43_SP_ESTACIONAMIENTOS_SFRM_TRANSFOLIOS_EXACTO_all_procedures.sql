-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TRANSFOLIOS (EXACTO del archivo original)
-- Archivo: 43_SP_ESTACIONAMIENTOS_SFRM_TRANSFOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TRANSFOLIOS (EXACTO del archivo original)
-- Archivo: 43_SP_ESTACIONAMIENTOS_SFRM_TRANSFOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

