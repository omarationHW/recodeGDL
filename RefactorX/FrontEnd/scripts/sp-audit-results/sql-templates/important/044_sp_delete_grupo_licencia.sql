-- ============================================================
-- Stored Procedure: sp_delete_grupo_licencia
-- ============================================================
-- Tipo de Operación: DELETE
-- Usado en: GruposLicenciasAbcfrm
-- Frecuencia de uso: 1 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_id: [Descripción del parámetro]
--
-- Retorna:
--   INTEGER (número de filas afectadas)

--
-- Ejemplo de uso:
--   SELECT * FROM sp_delete_grupo_licencia('valor_p_id');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(
    p_p_id VARCHAR
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
-- WHERE routine_name = 'sp_delete_grupo_licencia' AND routine_schema = 'public';
