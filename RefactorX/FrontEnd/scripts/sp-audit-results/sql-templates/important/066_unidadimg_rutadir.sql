-- ============================================================
-- Stored Procedure: unidadimg_rutadir
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: UnidadImg
-- Frecuencia de uso: 3 veces
-- Prioridad: IMPORTANTE
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
--   SELECT * FROM unidadimg_rutadir('valor_p_ruta');
--
-- ============================================================

CREATE OR REPLACE FUNCTION unidadimg_rutadir(
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
-- WHERE routine_name = 'unidadimg_rutadir' AND routine_schema = 'public';
