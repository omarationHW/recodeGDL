-- ============================================================
-- Stored Procedure: sp_frmselcalle_get_calle_by_ids
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: frmselcalle
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_codigo: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_frmselcalle_get_calle_by_ids('valor_p_codigo');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_frmselcalle_get_calle_by_ids(
    p_p_codigo VARCHAR
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
-- WHERE routine_name = 'sp_frmselcalle_get_calle_by_ids' AND routine_schema = 'public';
