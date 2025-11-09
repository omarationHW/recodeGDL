-- ============================================================
-- Stored Procedure: carga_imagen_sp_get_document_image
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: carga_imagen
-- Frecuencia de uso: 2 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_document_id: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM carga_imagen_sp_get_document_image('valor_p_document_id');
--
-- ============================================================

CREATE OR REPLACE FUNCTION carga_imagen_sp_get_document_image(
    p_p_document_id VARCHAR
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
-- WHERE routine_name = 'carga_imagen_sp_get_document_image' AND routine_schema = 'public';
