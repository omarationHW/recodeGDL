-- =====================================================
-- SCRIPT DE RENOMBRE DE STORED PROCEDURES - APREMIOS SVN
-- Fecha: 2025-12-05
-- Base: estacionamiento_exclusivo
-- Propósito: Estandarizar nombres de SPs a formato apremiossvn_*
-- =====================================================

-- 1. Renombrar sp_fases_list a apremiossvn_fases_list
DROP FUNCTION IF EXISTS apremiossvn_fases_list();
ALTER FUNCTION sp_fases_list() RENAME TO apremiossvn_fases_list;

-- 2. Renombrar sp_actuaciones_list a apremiossvn_actuaciones_list
DROP FUNCTION IF EXISTS apremiossvn_actuaciones_list(VARCHAR, DATE, DATE);
ALTER FUNCTION sp_actuaciones_list(VARCHAR, DATE, DATE) RENAME TO apremiossvn_actuaciones_list;

-- 3. Renombrar sp_estadisticas_generales a apremiossvn_estadisticas_generales
DROP FUNCTION IF EXISTS apremiossvn_estadisticas_generales(DATE, DATE);
ALTER FUNCTION sp_estadisticas_generales(DATE, DATE) RENAME TO apremiossvn_estadisticas_generales;

-- 4. Crear SP faltante: apremiossvn_cambiar_fase
CREATE OR REPLACE FUNCTION apremiossvn_cambiar_fase(
    p_expediente VARCHAR(50),
    p_fase VARCHAR(50)
)
RETURNS TABLE (
    resultado VARCHAR(100),
    mensaje TEXT
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar que el expediente existe
    SELECT COUNT(*) INTO v_count
    FROM ta_15_apremios
    WHERE expediente = p_expediente;

    IF v_count = 0 THEN
        RETURN QUERY
        SELECT 'ERROR'::VARCHAR(100), 'Expediente no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Actualizar fase
    UPDATE ta_15_apremios
    SET fase = p_fase,
        fase_anterior = fase,
        fecha_fase = CURRENT_DATE,
        usuario_modificacion = CURRENT_USER
    WHERE expediente = p_expediente;

    RETURN QUERY
    SELECT 'SUCCESS'::VARCHAR(100), ('Fase actualizada a: ' || p_fase)::TEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Verificación
-- =====================================================
SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name ILIKE '%apremiossvn%'
ORDER BY routine_name;

-- =====================================================
-- NOTA: Ejecutar este script SOLO UNA VEZ
-- =====================================================
