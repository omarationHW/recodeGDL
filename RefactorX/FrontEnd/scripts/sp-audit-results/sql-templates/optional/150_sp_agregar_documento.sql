-- ============================================================
-- Stored Procedure: sp_agregar_documento
-- ============================================================
-- Tipo de Operación: QUERY
-- Usado en: RegistroSolicitud
-- Frecuencia de uso: 1 veces
-- Prioridad: OPCIONAL
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
  -- @param p_p_id_tramite: [Descripción del parámetro]
  -- @param p_p_nombre: [Descripción del parámetro]
  -- @param p_p_ruta: [Descripción del parámetro]
  -- @param p_p_usuario: [Descripción del parámetro]
--
-- Retorna:
--   TABLE con las siguientes columnas:
    -- Definir columnas de retorno
--
-- Ejemplo de uso:
--   SELECT * FROM sp_agregar_documento('valor_p_id_tramite', 'valor_p_nombre', 'valor_p_ruta', 'valor_p_usuario');
--
-- ============================================================

CREATE OR REPLACE FUNCTION sp_agregar_documento(
    p_p_id_tramite VARCHAR,
    p_p_nombre VARCHAR,
    p_p_ruta VARCHAR,
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
-- WHERE routine_name = 'sp_agregar_documento' AND routine_schema = 'public';
