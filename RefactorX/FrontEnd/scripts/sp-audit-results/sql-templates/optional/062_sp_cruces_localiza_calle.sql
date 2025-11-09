-- ============================================================
-- Stored Procedure: sp_cruces_localiza_calle
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: Cruces
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_clave_calle1: [Descripción del parámetro]
  -- @param p_p_clave_calle2: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_cruces_localiza_calle('valor_p_clave_calle1', 'valor_p_clave_calle2');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_cruces_localiza_calle(
    p_p_clave_calle1 VARCHAR,
    p_p_clave_calle2 VARCHAR
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
-- WHERE routine_name = 'sp_cruces_localiza_calle' AND routine_schema = 'public';
