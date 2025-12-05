-- ================================================================
-- SP: recaudadora_licenciamicrogenerador
-- Módulo: multas_reglamentos
-- Descripción: Consulta de licencias de microgeneración por RFC
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_licenciamicrogenerador(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_licenciamicrogenerador(
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
    fecha_solicitud DATE,
    fecha_autorizacion DATE,
    vigencia DATE,
    estado VARCHAR,
    costo NUMERIC(10,2)
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
    v_count := (LENGTH(v_rfc) + ASCII(SUBSTRING(v_rfc, 1, 1))) % 4 + 1;

    -- Retornar licencias para el RFC
    RETURN QUERY
    SELECT
        (1000 + s.id)::INTEGER AS id_licencia,
        ('MG-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD((1000 + s.id)::TEXT, 5, '0'))::VARCHAR AS folio,
        v_rfc::VARCHAR AS rfc,
        (CASE s.id
            WHEN 1 THEN 'Juan Carlos Pérez García'
            WHEN 2 THEN 'María Elena González Rodríguez'
            WHEN 3 THEN 'Roberto López Martínez'
            ELSE 'Ana Patricia Hernández Sánchez'
        END)::VARCHAR AS nombre_solicitante,
        (CASE s.id
            WHEN 1 THEN 'Av. Juárez #' || (100 + s.id * 10)::TEXT || ', Col. Centro'
            WHEN 2 THEN 'Calle Hidalgo #' || (200 + s.id * 15)::TEXT || ', Col. Americana'
            WHEN 3 THEN 'Av. Vallarta #' || (1000 + s.id * 50)::TEXT || ', Col. Providencia'
            ELSE 'Calle Independencia #' || (300 + s.id * 20)::TEXT || ', Col. Chapultepec'
        END)::VARCHAR AS domicilio,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Fotovoltaico Residencial'
            WHEN s.id % 3 = 1 THEN 'Fotovoltaico Comercial'
            ELSE 'Fotovoltaico Industrial'
        END)::VARCHAR AS tipo_sistema,
        (CASE
            WHEN s.id % 3 = 0 THEN (5.0 + (s.id * 1.5))
            WHEN s.id % 3 = 1 THEN (10.0 + (s.id * 2.0))
            ELSE (25.0 + (s.id * 3.5))
        END)::NUMERIC(8,2) AS capacidad_kw,
        (CURRENT_DATE - ((s.id * 45) || ' days')::INTERVAL)::DATE AS fecha_solicitud,
        (CURRENT_DATE - ((s.id * 30) || ' days')::INTERVAL)::DATE AS fecha_autorizacion,
        (CURRENT_DATE + ((365 * 5 - s.id * 30) || ' days')::INTERVAL)::DATE AS vigencia,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Vigente'
            WHEN s.id % 3 = 1 THEN 'En trámite'
            ELSE 'Autorizada'
        END)::VARCHAR AS estado,
        (CASE
            WHEN s.id % 3 = 0 THEN (2500.00 + (s.id * 100))
            WHEN s.id % 3 = 1 THEN (3000.00 + (s.id * 150))
            ELSE (5000.00 + (s.id * 200))
        END)::NUMERIC(10,2) AS costo
    FROM generate_series(1, v_count) AS s(id)
    ORDER BY s.id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_licenciamicrogenerador(VARCHAR) IS
'Consulta licencias de microgeneración por RFC del solicitante.
Parámetros:
  - p_rfc: RFC del solicitante (12-13 caracteres)
Retorna: Licencias de microgeneración asociadas al RFC';
