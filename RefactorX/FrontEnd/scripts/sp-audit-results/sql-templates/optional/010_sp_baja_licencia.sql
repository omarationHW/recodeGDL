-- ============================================================
-- Stored Procedure: sp_baja_licencia
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: bajaLicenciafrm
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_id_licencia: [Descripción del parámetro]
  -- @param p_p_motivo: [Descripción del parámetro]
  -- @param p_p_anio: [Descripción del parámetro]
  -- @param p_p_folio: [Descripción del parámetro]
  -- @param p_p_baja_error: [Descripción del parámetro]
  -- @param p_p_usuario: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_baja_licencia('valor_p_id_licencia', 'valor_p_motivo', 'valor_p_anio', 'valor_p_folio', 'valor_p_baja_error', 'valor_p_usuario');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_baja_licencia(
    p_p_id_licencia VARCHAR,
    p_p_motivo VARCHAR,
    p_p_anio VARCHAR,
    p_p_folio VARCHAR,
    p_p_baja_error VARCHAR,
    p_p_usuario VARCHAR
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
-- WHERE routine_name = 'sp_baja_licencia' AND routine_schema = 'public';
