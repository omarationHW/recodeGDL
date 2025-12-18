-- Actualización del Stored Procedure para DrecgoTrans
-- NOTA: No existen tablas de tránsito/vehículos en la BD
-- Este SP devuelve un conjunto vacío con la estructura esperada

DROP FUNCTION IF EXISTS publico.recaudadora_drecgo_trans(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_drecgo_trans(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE (
    id_transito INTEGER,
    clave_cuenta VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    tipo_vehiculo VARCHAR,
    marca VARCHAR,
    modelo VARCHAR,
    placas VARCHAR,
    numero_serie VARCHAR,
    fecha_registro DATE,
    monto_anual NUMERIC,
    status VARCHAR,
    zona VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- NOTA: No existen tablas de tránsito/vehículos en la base de datos multas_reglamentos
    -- Este stored procedure devuelve un conjunto vacío para evitar errores en el frontend
    -- Si en el futuro se agrega una tabla de vehículos, este SP deberá actualizarse

    RETURN QUERY
    SELECT
        NULL::INTEGER AS id_transito,
        NULL::VARCHAR AS clave_cuenta,
        NULL::VARCHAR AS propietario,
        NULL::VARCHAR AS domicilio,
        NULL::VARCHAR AS tipo_vehiculo,
        NULL::VARCHAR AS marca,
        NULL::VARCHAR AS modelo,
        NULL::VARCHAR AS placas,
        NULL::VARCHAR AS numero_serie,
        NULL::DATE AS fecha_registro,
        NULL::NUMERIC AS monto_anual,
        NULL::VARCHAR AS status,
        NULL::VARCHAR AS zona
    WHERE FALSE;  -- Esta condición asegura que no se devuelva ninguna fila
END;
$$;

-- IMPORTANTE: Este SP está configurado para devolver siempre un conjunto vacío
-- porque no existe una tabla de tránsito/vehículos en la base de datos.
--
-- Las tablas encontradas están relacionadas con:
-- - Transmisión patrimonial (transm_400, pagotransm_400, etc.)
-- - Multas municipales
-- - Licencias comerciales
-- - Cementerios/fosas
-- - Pero NO con control vehicular o tránsito
--
-- Cuando se implemente una tabla de vehículos/tránsito, este SP deberá modificarse
-- para consultar dicha tabla.
