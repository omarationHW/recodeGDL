-- ============================================================
-- Stored Procedure: reghfrm_sp_get_historic_record
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: regHfrm
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_id: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM reghfrm_sp_get_historic_record('valor_p_id');
--
-- ============================================================

CREATE OR REPLACE FUNCTION reghfrm_sp_get_historic_record(
    p_p_id VARCHAR
)
RETURNS TABLE (
    -- TODO: Definir columnas
    id INTEGER,
    nombre VARCHAR
)
AS $$
BEGIN
    -- ============================================================
    -- TODO: Implementar lógica del stored procedure
    -- ============================================================

    RETURN QUERY
    SELECT 
        1 as id,
        'Ejemplo' as nombre;
    -- TODO: Reemplazar con query real

END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Verificación de creación
-- ============================================================
-- SELECT routine_name FROM information_schema.routines
-- WHERE routine_name = 'reghfrm_sp_get_historic_record' AND routine_schema = 'public';
