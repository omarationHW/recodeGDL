-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_ASPECTO (EXACTO del archivo original)
-- Archivo: 34_SP_ESTACIONAMIENTOS_SFRM_ASPECTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: get_aspectos
-- Tipo: Catalog
-- Descripción: Devuelve la lista de aspectos visuales disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_aspectos()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla o directorio
    RETURN QUERY SELECT unnest(ARRAY['Directorio de Aspectos...', 'SkinBlue', 'SkinDark', 'SkinClassic']) AS nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_ASPECTO (EXACTO del archivo original)
-- Archivo: 34_SP_ESTACIONAMIENTOS_SFRM_ASPECTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: get_current_aspecto
-- Tipo: Catalog
-- Descripción: Devuelve el aspecto visual actualmente seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_current_aspecto()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla de configuración
    RETURN QUERY SELECT 'SkinBlue'::TEXT AS nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

