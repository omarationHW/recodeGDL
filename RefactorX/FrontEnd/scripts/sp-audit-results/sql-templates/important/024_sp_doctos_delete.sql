-- ============================================================
-- Stored Procedure: sp_doctos_delete
-- ============================================================
-- Tipo de Operación: DELETE
-- Usado en: doctosfrm
-- Frecuencia de uso: 1 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_cvedocto: [Descripción del parámetro]
--
-- Retorna:
--   INTEGER (número de filas afectadas)

--
-- Ejemplo de uso:
--   SELECT * FROM sp_doctos_delete('valor_p_cvedocto');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_doctos_delete(
    p_p_cvedocto VARCHAR
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
-- WHERE routine_name = 'sp_doctos_delete' AND routine_schema = 'public';
