-- ============================================================
-- Stored Procedure: sfrm_chgfirma_upd_firma
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: sfrm_chgfirma
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_usuario: [Descripción del parámetro]
  -- @param p_p_firma_actual: [Descripción del parámetro]
  -- @param p_p_firma_nueva: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sfrm_chgfirma_upd_firma('valor_p_usuario', 'valor_p_firma_actual', 'valor_p_firma_nueva');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sfrm_chgfirma_upd_firma(
    p_p_usuario VARCHAR,
    p_p_firma_actual VARCHAR,
    p_p_firma_nueva VARCHAR
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
-- WHERE routine_name = 'sfrm_chgfirma_upd_firma' AND routine_schema = 'public';
