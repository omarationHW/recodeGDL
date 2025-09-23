-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: RNuevos (EXACTO del archivo original)
-- Archivo: 23_SP_OTRASOBLIG_RNUEVOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_ins34_rastro_01
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de local/concesión en t34_datos para el Rastro. Valida unicidad de control.
-- --------------------------------------------

-- PostgreSQL stored procedure for inserting new local/concession
CREATE OR REPLACE FUNCTION sp_ins34_rastro_01(
    par_tabla INTEGER,
    par_control VARCHAR,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector VARCHAR,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip VARCHAR
) RETURNS TABLE(expression INTEGER, expression_1 VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
    v_id_unidad INTEGER;
    v_id_stat INTEGER := 1; -- VIGENTE
BEGIN
    SELECT COUNT(*) INTO v_exists FROM otrasoblig.t34_datos WHERE control = par_control;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1 AS expression, 'Ya existe LOCAL con este dato, intentalo de nuevo' AS expression_1;
        RETURN;
    END IF;
    -- Buscar id_unidad por descripcion
    SELECT id_34_unidad INTO v_id_unidad FROM otrasoblig.t34_unidades WHERE descripcion = par_Descrip AND cve_tab = par_tabla LIMIT 1;
    IF v_id_unidad IS NULL THEN
        v_id_unidad := 1; -- fallback
    END IF;
    INSERT INTO otrasoblig.t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, id_unidad, id_stat
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, v_id_unidad, v_id_stat
    );
    RETURN QUERY SELECT 0 AS expression, 'Se ejecutó correctamente la creación del Local/Concesión' AS expression_1;
END;
$$ LANGUAGE plpgsql;

-- ============================================