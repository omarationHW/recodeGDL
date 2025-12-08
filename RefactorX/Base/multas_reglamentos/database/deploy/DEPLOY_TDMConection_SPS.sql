-- ============================================
-- STORED PROCEDURE PARA TDMConection.vue
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-25
-- Descripcion: SP para prueba de conexion TDM
-- ============================================

-- ============================================
-- SP: tdmconection_sp_test
-- Prueba la conexion con servicios TDM
-- ============================================
DROP FUNCTION IF EXISTS tdmconection_sp_test();

CREATE OR REPLACE FUNCTION tdmconection_sp_test()
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    server_time VARCHAR,
    database_name VARCHAR,
    db_version VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRUE AS success,
        'Conexion exitosa con el servidor de base de datos'::VARCHAR AS message,
        TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')::VARCHAR AS server_time,
        current_database()::VARCHAR AS database_name,
        version()::VARCHAR AS db_version;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION tdmconection_sp_test() IS 'Prueba la conexion con el servidor TDM';

-- ============================================
-- Verificacion
-- ============================================
SELECT 'SP tdmconection_sp_test creado correctamente' AS status;
