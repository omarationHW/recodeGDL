-- ============================================================
-- Stored Procedure: carga_search_predio
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: carga
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_clavecatastral: [Descripción del parámetro]
  -- @param p_p_cuenta: [Descripción del parámetro]
  -- @param p_p_propietario: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM carga_search_predio('valor_p_clavecatastral', 'valor_p_cuenta', 'valor_p_propietario');
--
-- ============================================================

CREATE OR REPLACE FUNCTION carga_search_predio(
    p_p_clavecatastral VARCHAR,
    p_p_cuenta VARCHAR,
    p_p_propietario VARCHAR
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
-- WHERE routine_name = 'carga_search_predio' AND routine_schema = 'public';
