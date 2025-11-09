-- ============================================================
-- Stored Procedure: sp_busque_search_by_owner
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: busque
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_nombre: [Descripción del parámetro]
  -- @param p_p_apellido_paterno: [Descripción del parámetro]
  -- @param p_p_apellido_materno: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_busque_search_by_owner('valor_p_nombre', 'valor_p_apellido_paterno', 'valor_p_apellido_materno');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_busque_search_by_owner(
    p_p_nombre VARCHAR,
    p_p_apellido_paterno VARCHAR,
    p_p_apellido_materno VARCHAR
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
-- WHERE routine_name = 'sp_busque_search_by_owner' AND routine_schema = 'public';
