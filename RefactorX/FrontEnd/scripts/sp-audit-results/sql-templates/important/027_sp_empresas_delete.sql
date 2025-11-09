-- ============================================================
-- Stored Procedure: sp_empresas_delete
-- ============================================================
-- Tipo de Operación: DELETE
-- Usado en: empresasfrm
-- Frecuencia de uso: 1 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_empresa: [Descripción del parámetro]
--
-- Retorna:
--   INTEGER (número de filas afectadas)

--
-- Ejemplo de uso:
--   SELECT * FROM sp_empresas_delete('valor_p_empresa');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_empresas_delete(
    p_p_empresa VARCHAR
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
-- WHERE routine_name = 'sp_empresas_delete' AND routine_schema = 'public';
