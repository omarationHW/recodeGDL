-- ============================================================
-- Stored Procedure: sfrm_chgpass_sp_update
-- ============================================================
-- Tipo de Operación: UPDATE
-- Usado en: sfrm_chgpass
-- Frecuencia de uso: 1 veces
-- Prioridad: IMPORTANTE
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_usuario: [Descripción del parámetro]
  -- @param p_p_password_nueva: [Descripción del parámetro]
--
-- Retorna:
--   INTEGER (número de filas afectadas)

--
-- Ejemplo de uso:
--   SELECT * FROM sfrm_chgpass_sp_update('valor_p_usuario', 'valor_p_password_nueva');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sfrm_chgpass_sp_update(
    p_p_usuario VARCHAR,
    p_p_password_nueva VARCHAR
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
-- WHERE routine_name = 'sfrm_chgpass_sp_update' AND routine_schema = 'public';
