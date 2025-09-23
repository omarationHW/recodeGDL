-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: CGA_ARCEDOEX (EXACTO del archivo original)
-- Archivo: 09_SP_ESTACIONAMIENTOS_CGA_ARCEDOEX_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_insert_ta14_datos_edo
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta14_datos_edo para la carga de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_ta14_datos_edo(
    vMpio integer,
    vTipoAct varchar,
    vFolio numeric,
    vPlaca varchar,
    vFecPago date,
    vImporte numeric,
    vFecAlta date,
    vRemesa varchar,
    vFecRemesa date
) RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    INSERT INTO ta14_datos_edo (
        mpio, tipoact, folio, teso_cve, placa,
        campo6, campo7, fecpago, campo9,
        importe, campo11, fecalta, campo13,
        campo14, campo15, campo16, remesa, fecharemesa, campo19, campo20, campo21
    ) VALUES (
        vMpio, vTipoAct, vFolio, NULL, vPlaca,
        NULL, NULL, vFecPago, NULL,
        vImporte, NULL, vFecAlta, NULL,
        NULL, NULL, NULL, vRemesa, vFecRemesa, NULL, NULL, NULL
    );
    RETURN QUERY SELECT true, 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error en la carga de folios: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: CGA_ARCEDOEX (EXACTO del archivo original)
-- Archivo: 09_SP_ESTACIONAMIENTOS_CGA_ARCEDOEX_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_insert_ta14_bitacora
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta14_bitacora para registrar la carga de una remesa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_ta14_bitacora(
    p_fecha_inicio date,
    p_fecha_fin date,
    p_fecha date,
    p_num_rem integer,
    p_cant_reg integer
) RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    INSERT INTO ta14_bitacora (
        id, tipo, fecha_inicio, fecha_fin, fecha, num_remesa, cant_reg
    ) VALUES (
        0, 'A', p_fecha_inicio, p_fecha_fin, p_fecha, p_num_rem, p_cant_reg
    );
    RETURN QUERY SELECT true, 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al registrar en bitácora: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

