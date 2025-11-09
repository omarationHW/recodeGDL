-- ============================================================
-- Stored Procedure: sp_frmselcalle_get_calles
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: frmselcalle
-- Frecuencia de uso: 2 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_nombre: [Descripción del parámetro]
  -- @param p_p_limit: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_frmselcalle_get_calles('valor_p_nombre', 'valor_p_limit');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_frmselcalle_get_calles(
    p_p_nombre VARCHAR,
    p_p_limit VARCHAR
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
-- WHERE routine_name = 'sp_frmselcalle_get_calles' AND routine_schema = 'public';
