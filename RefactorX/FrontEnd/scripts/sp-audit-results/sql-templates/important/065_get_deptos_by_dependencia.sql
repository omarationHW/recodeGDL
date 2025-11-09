-- ============================================================
-- Stored Procedure: get_deptos_by_dependencia
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: consultausuariosfrm
-- Frecuencia de uso: 3 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_id_dependencia: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM get_deptos_by_dependencia('valor_p_id_dependencia');
--
-- ============================================================

CREATE OR REPLACE FUNCTION get_deptos_by_dependencia(
    p_p_id_dependencia VARCHAR
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
-- WHERE routine_name = 'get_deptos_by_dependencia' AND routine_schema = 'public';
