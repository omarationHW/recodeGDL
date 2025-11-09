-- ============================================================
-- Stored Procedure: carga_imagen_sp_get_tramite_info
-- ============================================================
-- Tipo de Operación: READ
-- Usado en: carga_imagen
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_numero: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM carga_imagen_sp_get_tramite_info('valor_p_numero');
--
-- ============================================================

CREATE OR REPLACE FUNCTION carga_imagen_sp_get_tramite_info(
    p_p_numero VARCHAR
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
-- WHERE routine_name = 'carga_imagen_sp_get_tramite_info' AND routine_schema = 'public';
