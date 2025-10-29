-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_ABC_PROPIETARIO (EXACTO del archivo original)
-- Archivo: 32_SP_ESTACIONAMIENTOS_SFRM_ABC_PROPIETARIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: check_rfc_exists
-- Tipo: Catalog
-- Descripción: Verifica si un RFC ya existe en la tabla ta14_personas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE (exists BOOLEAN)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT EXISTS(SELECT 1 FROM ta14_personas WHERE rfc = UPPER(TRIM(p_rfc)));
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_ABC_PROPIETARIO (EXACTO del archivo original)
-- Archivo: 32_SP_ESTACIONAMIENTOS_SFRM_ABC_PROPIETARIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

