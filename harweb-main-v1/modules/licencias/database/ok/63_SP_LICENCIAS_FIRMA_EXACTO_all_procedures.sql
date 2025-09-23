-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FIRMA (EXACTO del archivo original)
-- Archivo: 63_SP_LICENCIAS_FIRMA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_firma_validate
-- Tipo: CRUD
-- Descripción: Valida si la firma digital ingresada es correcta para el usuario actual (puede ser extendido para validar contra una tabla de usuarios/firma). Retorna is_valid boolean.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firma_validate(p_firma_digital TEXT)
RETURNS TABLE(is_valid BOOLEAN, usuario_id INTEGER, nombre TEXT) AS $$
BEGIN
    -- Ejemplo: Validar contra tabla de usuarios
    RETURN QUERY
    SELECT TRUE AS is_valid, id AS usuario_id, nombre
    FROM usuarios
    WHERE firma_digital = p_firma_digital
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FIRMA (EXACTO del archivo original)
-- Archivo: 63_SP_LICENCIAS_FIRMA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

