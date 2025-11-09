-- ============================================================
-- Stored Procedure: sp_cruces_search_calle2
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: Cruces
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_busqueda: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_cruces_search_calle2('valor_p_busqueda');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_cruces_search_calle2(
    p_p_busqueda VARCHAR
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
-- WHERE routine_name = 'sp_cruces_search_calle2' AND routine_schema = 'public';
