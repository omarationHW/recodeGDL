-- Conectar a la base de datos
\c padron_licencias;
SET search_path TO informix;

-- Crear stored procedure simple para SP_CONSULTALICENCIA_LIST
CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_tipo_licencia VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_limite INTEGER DEFAULT 250,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(100),
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    propietario VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    giro VARCHAR(255),
    estado VARCHAR(20),
    total_registros BIGINT
) AS $$
BEGIN
    -- Retornar datos de ejemplo por ahora
    RETURN QUERY
    SELECT
        1 as id,
        'LIC-2024-001'::VARCHAR(100) as numero_licencia,
        'FOL-001'::VARCHAR(100) as folio,
        'COMERCIAL'::VARCHAR(50) as tipo_licencia,
        'Juan Pérez García'::VARCHAR(255) as propietario,
        'PEPJ850101XXX'::VARCHAR(20) as rfc,
        'Av. Principal #123, Centro'::TEXT as direccion,
        'Tienda de Abarrotes'::VARCHAR(255) as giro,
        'VIGENTE'::VARCHAR(20) as estado,
        1::BIGINT as total_registros;
END;
$$ LANGUAGE plpgsql;