-- ============================================================
-- Stored Procedure: carga_imagen_sp_delete_document_image
-- ============================================================
-- Tipo de Operación: DELETE
-- Usado en: carga_imagen
-- Frecuencia de uso: 1 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_document_id: [Descripción del parámetro]
--
-- Retorna:
--   INTEGER (número de filas afectadas)

--
-- Ejemplo de uso:
--   SELECT * FROM carga_imagen_sp_delete_document_image('valor_p_document_id');
--
-- ============================================================

CREATE OR REPLACE FUNCTION carga_imagen_sp_delete_document_image(
    p_p_document_id VARCHAR
)
RETURNS INTEGER
AS $$
BEGIN
    -- ============================================================
    -- TODO: Implementar lógica del stored procedure
    -- ============================================================

    RETURN 0; -- TODO: Implementar

END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Verificación de creación
-- ============================================================
-- SELECT routine_name FROM information_schema.routines
-- WHERE routine_name = 'carga_imagen_sp_delete_document_image' AND routine_schema = 'public';
