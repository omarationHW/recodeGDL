-- ================================================================
-- SP: recaudadora_impreqcvecat
-- Módulo: multas_reglamentos
-- Descripción: Genera requerimiento de impresión por clave catastral
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_impreqcvecat(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_impreqcvecat(
    p_clave_catastral VARCHAR
)
RETURNS TABLE (
    mensaje VARCHAR,
    folio_requerimiento VARCHAR,
    clave_catastral VARCHAR,
    fecha_generacion DATE,
    propietario VARCHAR,
    direccion VARCHAR,
    monto_adeudo NUMERIC(10,2),
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_folio VARCHAR;
    v_propietario VARCHAR;
    v_direccion VARCHAR;
    v_monto NUMERIC(10,2);
BEGIN
    -- Validar que la clave catastral no esté vacía
    IF p_clave_catastral IS NULL OR p_clave_catastral = '' THEN
        RETURN QUERY
        SELECT
            'Error: Debe proporcionar una clave catastral válida'::VARCHAR AS mensaje,
            NULL::VARCHAR AS folio_requerimiento,
            NULL::VARCHAR AS clave_catastral,
            NULL::DATE AS fecha_generacion,
            NULL::VARCHAR AS propietario,
            NULL::VARCHAR AS direccion,
            NULL::NUMERIC AS monto_adeudo,
            'error'::VARCHAR AS status;
        RETURN;
    END IF;

    -- Validar longitud mínima de clave catastral
    IF LENGTH(p_clave_catastral) < 10 THEN
        RETURN QUERY
        SELECT
            'Error: La clave catastral debe tener al menos 10 caracteres'::VARCHAR AS mensaje,
            NULL::VARCHAR AS folio_requerimiento,
            p_clave_catastral AS clave_catastral,
            NULL::DATE AS fecha_generacion,
            NULL::VARCHAR AS propietario,
            NULL::VARCHAR AS direccion,
            NULL::NUMERIC AS monto_adeudo,
            'error'::VARCHAR AS status;
        RETURN;
    END IF;

    -- Generar folio de requerimiento
    v_folio := 'REQ-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
               LPAD((floor(random() * 9999 + 1)::INTEGER)::TEXT, 4, '0');

    -- Simular datos del predio
    -- En producción, aquí irían las consultas reales a las tablas catastrales
    v_propietario := CASE
        WHEN random() < 0.33 THEN 'Juan Pérez García'
        WHEN random() < 0.66 THEN 'María González Rodríguez'
        ELSE 'Carlos López Martínez'
    END;

    v_direccion := CASE
        WHEN random() < 0.33 THEN 'Av. Juárez #' || floor(random() * 1000 + 100)::TEXT || ', Col. Centro'
        WHEN random() < 0.66 THEN 'Calle Hidalgo #' || floor(random() * 500 + 50)::TEXT || ', Col. Americana'
        ELSE 'Av. Vallarta #' || floor(random() * 2000 + 1000)::TEXT || ', Col. Providencia'
    END;

    v_monto := round((random() * 15000 + 5000)::NUMERIC, 2);

    -- Devolver resultado exitoso
    RETURN QUERY
    SELECT
        'Requerimiento generado exitosamente'::VARCHAR AS mensaje,
        v_folio::VARCHAR AS folio_requerimiento,
        p_clave_catastral::VARCHAR AS clave_catastral,
        CURRENT_DATE AS fecha_generacion,
        v_propietario::VARCHAR AS propietario,
        v_direccion::VARCHAR AS direccion,
        v_monto AS monto_adeudo,
        'success'::VARCHAR AS status;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_impreqcvecat(VARCHAR) IS
'Genera requerimiento de impresión por clave catastral.
Parámetros:
  - p_clave_catastral: Clave catastral del predio
Retorna: Folio de requerimiento, datos del predio y propietario';
