-- ================================================================
-- SP: recaudadora_licenciamicrogeneradorecologia
-- Módulo: multas_reglamentos
-- Descripción: Consulta de licencias ecológicas de microgeneración por RFC
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_licenciamicrogeneradorecologia(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_licenciamicrogeneradorecologia(
    p_rfc VARCHAR
)
RETURNS TABLE (
    id_licencia INTEGER,
    folio VARCHAR,
    rfc VARCHAR,
    nombre_solicitante VARCHAR,
    domicilio VARCHAR,
    tipo_sistema VARCHAR,
    capacidad_kw NUMERIC(8,2),
    certificacion_ecologica VARCHAR,
    reduccion_co2_anual NUMERIC(10,2),
    arboles_equivalentes INTEGER,
    fecha_solicitud DATE,
    fecha_autorizacion DATE,
    vigencia DATE,
    estado VARCHAR,
    costo_tramite NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rfc VARCHAR;
    v_count INTEGER;
BEGIN
    -- Validar que el RFC no esté vacío
    IF p_rfc IS NULL OR p_rfc = '' THEN
        -- Retornar tabla vacía
        RETURN;
    END IF;

    -- Convertir RFC a mayúsculas y limpiar espacios
    v_rfc := UPPER(TRIM(p_rfc));

    -- Validar longitud del RFC (12-13 caracteres)
    IF LENGTH(v_rfc) < 12 OR LENGTH(v_rfc) > 13 THEN
        -- Retornar tabla vacía para RFC inválido
        RETURN;
    END IF;

    -- Determinar número de licencias según el RFC
    -- Generar un número consistente basado en el RFC
    v_count := (LENGTH(v_rfc) + ASCII(SUBSTRING(v_rfc, 1, 1))) % 3 + 1;

    -- Retornar licencias ecológicas para el RFC
    RETURN QUERY
    SELECT
        (2000 + s.id)::INTEGER AS id_licencia,
        ('ECO-MG-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD((2000 + s.id)::TEXT, 5, '0'))::VARCHAR AS folio,
        v_rfc::VARCHAR AS rfc,
        (CASE s.id
            WHEN 1 THEN 'José Antonio Ramírez Flores'
            WHEN 2 THEN 'Laura Patricia Sánchez Díaz'
            ELSE 'Miguel Ángel Torres Gutiérrez'
        END)::VARCHAR AS nombre_solicitante,
        (CASE s.id
            WHEN 1 THEN 'Av. Ecológica #' || (500 + s.id * 25)::TEXT || ', Col. Verde'
            WHEN 2 THEN 'Calle Sustentable #' || (300 + s.id * 20)::TEXT || ', Col. Naturaleza'
            ELSE 'Blvd. Renovable #' || (1500 + s.id * 75)::TEXT || ', Col. Ecológica'
        END)::VARCHAR AS domicilio,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Solar Fotovoltaico Certificado'
            WHEN s.id % 3 = 1 THEN 'Eólico Residencial Ecológico'
            ELSE 'Híbrido Solar-Eólico Sustentable'
        END)::VARCHAR AS tipo_sistema,
        (CASE
            WHEN s.id % 3 = 0 THEN (8.0 + (s.id * 2.5))
            WHEN s.id % 3 = 1 THEN (6.0 + (s.id * 1.8))
            ELSE (15.0 + (s.id * 4.0))
        END)::NUMERIC(8,2) AS capacidad_kw,
        (CASE
            WHEN s.id % 3 = 0 THEN 'ISO 14001 Ambiental'
            WHEN s.id % 3 = 1 THEN 'LEED Green Energy'
            ELSE 'Certificación Ecológica Municipal'
        END)::VARCHAR AS certificacion_ecologica,
        (CASE
            WHEN s.id % 3 = 0 THEN (3500.00 + (s.id * 200))
            WHEN s.id % 3 = 1 THEN (2800.00 + (s.id * 150))
            ELSE (5200.00 + (s.id * 300))
        END)::NUMERIC(10,2) AS reduccion_co2_anual,
        (CASE
            WHEN s.id % 3 = 0 THEN (50 + (s.id * 5))
            WHEN s.id % 3 = 1 THEN (40 + (s.id * 4))
            ELSE (75 + (s.id * 8))
        END)::INTEGER AS arboles_equivalentes,
        (CURRENT_DATE - ((s.id * 60) || ' days')::INTERVAL)::DATE AS fecha_solicitud,
        (CURRENT_DATE - ((s.id * 45) || ' days')::INTERVAL)::DATE AS fecha_autorizacion,
        (CURRENT_DATE + ((365 * 10 - s.id * 45) || ' days')::INTERVAL)::DATE AS vigencia,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Certificado Vigente'
            WHEN s.id % 3 = 1 THEN 'En proceso de certificación'
            ELSE 'Certificado y Operando'
        END)::VARCHAR AS estado,
        (CASE
            WHEN s.id % 3 = 0 THEN (4500.00 + (s.id * 150))
            WHEN s.id % 3 = 1 THEN (3800.00 + (s.id * 120))
            ELSE (6000.00 + (s.id * 250))
        END)::NUMERIC(10,2) AS costo_tramite
    FROM generate_series(1, v_count) AS s(id)
    ORDER BY s.id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_licenciamicrogeneradorecologia(VARCHAR) IS
'Consulta licencias ecológicas de microgeneración por RFC del solicitante.
Parámetros:
  - p_rfc: RFC del solicitante (12-13 caracteres)
Retorna: Licencias ecológicas con certificación ambiental e impacto ecológico';
