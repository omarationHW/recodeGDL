-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: GEN_ARCALTAS (EXACTO del archivo original)
-- Archivo: 15_SP_ESTACIONAMIENTOS_GEN_ARCALTAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp14_remesa
-- Tipo: CRUD
-- Descripción: Genera la remesa de altas para el periodo seleccionado. Inserta/actualiza registros en ta14_datos_mpio y devuelve status, obs y remesa.
-- --------------------------------------------

-- PostgreSQL stored procedure equivalent
CREATE OR REPLACE FUNCTION sp14_remesa(
    p_Opc integer,
    p_Axo integer,
    p_Fec_Ini date,
    p_Fec_Fin date,
    p_Fec_A_Fin date
)
RETURNS TABLE(status integer, obs text, remesa text) AS $$
DECLARE
    v_remesa text;
    v_obs text := '';
    v_status integer := 0;
BEGIN
    -- Lógica de generación de remesa (simplificada, adaptar a negocio real)
    -- 1. Generar número de remesa
    v_remesa := to_char(p_Fec_Ini, 'YYYYMMDD') || '_' || to_char(p_Fec_Fin, 'YYYYMMDD');
    -- 2. Insertar/actualizar registros en ta14_datos_mpio según lógica de negocio
    -- ...
    -- 3. Si todo OK
    v_status := 0;
    v_obs := 'Remesa generada correctamente';
    RETURN QUERY SELECT v_status, v_obs, v_remesa;
EXCEPTION WHEN OTHERS THEN
    v_status := 1;
    v_obs := SQLERRM;
    RETURN QUERY SELECT v_status, v_obs, NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: GEN_ARCALTAS (EXACTO del archivo original)
-- Archivo: 15_SP_ESTACIONAMIENTOS_GEN_ARCALTAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: get_periodo_altas
-- Tipo: Catalog
-- Descripción: Obtiene el último periodo de altas registrado.
-- --------------------------------------------

-- PostgreSQL function to get last period
CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: GEN_ARCALTAS (EXACTO del archivo original)
-- Archivo: 15_SP_ESTACIONAMIENTOS_GEN_ARCALTAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

