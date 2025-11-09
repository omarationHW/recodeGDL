-- ============================================================
-- Stored Procedure: unidadimg_get_ruta_dir
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: UnidadImg
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_ruta: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM unidadimg_get_ruta_dir('valor_p_ruta');
--
-- ============================================================

CREATE OR REPLACE FUNCTION unidadimg_get_ruta_dir(
    p_p_ruta VARCHAR
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
-- WHERE routine_name = 'unidadimg_get_ruta_dir' AND routine_schema = 'public';
