-- ============================================================
-- Stored Procedure: unidadimg_set_unidad_img
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: UnidadImg
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_unidad: [Descripción del parámetro]
  -- @param p_p_directorio_base: [Descripción del parámetro]
  -- @param p_p_directorio_licencias: [Descripción del parámetro]
  -- @param p_p_directorio_tramites: [Descripción del parámetro]
  -- @param p_p_directorio_anuncios: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM unidadimg_set_unidad_img('valor_p_unidad', 'valor_p_directorio_base', 'valor_p_directorio_licencias', 'valor_p_directorio_tramites', 'valor_p_directorio_anuncios');
--
-- ============================================================

CREATE OR REPLACE FUNCTION unidadimg_set_unidad_img(
    p_p_unidad VARCHAR,
    p_p_directorio_base VARCHAR,
    p_p_directorio_licencias VARCHAR,
    p_p_directorio_tramites VARCHAR,
    p_p_directorio_anuncios VARCHAR
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
-- WHERE routine_name = 'unidadimg_set_unidad_img' AND routine_schema = 'public';
