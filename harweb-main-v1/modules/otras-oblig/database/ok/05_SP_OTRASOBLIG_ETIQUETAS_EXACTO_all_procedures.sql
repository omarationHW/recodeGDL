-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: Etiquetas (EXACTO del archivo original)
-- Archivo: 05_SP_OTRASOBLIG_ETIQUETAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_update_t34_etiq
-- Tipo: CRUD
-- Descripción: Actualiza los campos de la tabla t34_etiq para una clave de tabla específica.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_update_t34_etiq(
    p_abreviatura VARCHAR(4),
    p_etiq_control VARCHAR(20),
    p_concesionario VARCHAR(100),
    p_ubicacion VARCHAR(100),
    p_superficie VARCHAR(100),
    p_fecha_inicio VARCHAR(20),
    p_fecha_fin VARCHAR(20),
    p_recaudadora VARCHAR(100),
    p_sector VARCHAR(100),
    p_zona VARCHAR(100),
    p_licencia VARCHAR(100),
    p_fecha_cancelacion VARCHAR(20),
    p_unidad VARCHAR(100),
    p_categoria VARCHAR(100),
    p_seccion VARCHAR(100),
    p_bloque VARCHAR(100),
    p_nombre_comercial VARCHAR(100),
    p_lugar VARCHAR(100),
    p_obs VARCHAR(100),
    p_cve_tab VARCHAR(2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE otrasoblig.t34_etiq SET
        abreviatura = p_abreviatura,
        etiq_control = p_etiq_control,
        concesionario = p_concesionario,
        ubicacion = p_ubicacion,
        superficie = p_superficie,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        recaudadora = p_recaudadora,
        sector = p_sector,
        zona = p_zona,
        licencia = p_licencia,
        fecha_cancelacion = p_fecha_cancelacion,
        unidad = p_unidad,
        categoria = p_categoria,
        seccion = p_seccion,
        bloque = p_bloque,
        nombre_comercial = p_nombre_comercial,
        lugar = p_lugar,
        obs = p_obs
    WHERE cve_tab = p_cve_tab;
END;
$$;

-- ============================================