-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TRANS_EXCLU (EXACTO del archivo original)
-- Archivo: 28_SP_ESTACIONAMIENTOS_SFRM_TRANS_EXCLU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_insert_ta_18_exclusivo
-- Tipo: CRUD
-- Descripción: Inserta un registro en la tabla ta_18_exclusivo con todos los campos requeridos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_ta_18_exclusivo(
    p_control integer,
    p_cve_sector varchar(1),
    p_cve_zona varchar(1),
    p_cve_metros smallint,
    p_cve_tipo varchar(1),
    p_cve_numero integer,
    p_nombre varchar(30),
    p_telefono varchar(7),
    p_calle varchar(30),
    p_num varchar(4),
    p_domfis varchar(30),
    p_fecha_alta date,
    p_fecha_inic date,
    p_fecha_venci date,
    p_numoft varchar(8),
    p_numofm varchar(4),
    p_numctat smallint,
    p_zopparq smallint,
    p_manz smallint,
    p_estatus varchar(1),
    p_clave varchar(1)
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO public.ta_18_exclusivo (
        control, cve_sector, cve_zona, cve_metros, cve_tipo, cve_numero, nombre, telefono, calle, num, domfis, fecha_alta, fecha_inic, fecha_venci, numoft, numofm, numctat, zopparq, manz, estatus, clave
    ) VALUES (
        DEFAULT, p_cve_sector, p_cve_zona, p_cve_metros, p_cve_tipo, p_cve_numero, p_nombre, p_telefono, p_calle, p_num, p_domfis, p_fecha_alta, p_fecha_inic, p_fecha_venci, p_numoft, p_numofm, p_numctat, p_zopparq, p_manz, p_estatus, p_clave
    ) RETURNING control INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TRANS_EXCLU (EXACTO del archivo original)
-- Archivo: 28_SP_ESTACIONAMIENTOS_SFRM_TRANS_EXCLU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

