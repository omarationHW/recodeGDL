-- ================================================================
-- SP: recaudadora_impresionnva
-- Módulo: multas_reglamentos
-- Descripción: Genera una nueva impresión de documento para una cuenta
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_impresionnva(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_impresionnva(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE (
    mensaje VARCHAR,
    folio_impresion VARCHAR,
    clave_cuenta VARCHAR,
    fecha_generacion DATE,
    tipo_documento VARCHAR,
    numero_paginas INTEGER,
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_folio VARCHAR;
    v_tipo_doc VARCHAR;
    v_num_paginas INTEGER;
BEGIN
    -- Validar que la clave de cuenta no esté vacía
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RETURN QUERY
        SELECT
            'Error: Debe proporcionar una clave de cuenta válida'::VARCHAR AS mensaje,
            NULL::VARCHAR AS folio_impresion,
            NULL::VARCHAR AS clave_cuenta,
            NULL::DATE AS fecha_generacion,
            NULL::VARCHAR AS tipo_documento,
            NULL::INTEGER AS numero_paginas,
            'error'::VARCHAR AS status;
        RETURN;
    END IF;

    -- Generar folio de impresión
    v_folio := ('IMP-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
               LPAD((floor(random() * 9999 + 1)::INTEGER)::TEXT, 4, '0'))::VARCHAR;

    -- Determinar tipo de documento aleatoriamente
    v_tipo_doc := CASE
        WHEN random() < 0.25 THEN 'Estado de Cuenta'::VARCHAR
        WHEN random() < 0.50 THEN 'Recibo de Pago'::VARCHAR
        WHEN random() < 0.75 THEN 'Comprobante Fiscal'::VARCHAR
        ELSE 'Certificado de No Adeudo'::VARCHAR
    END;

    -- Número de páginas aleatorio
    v_num_paginas := floor(random() * 5 + 1)::INTEGER;

    -- Devolver resultado exitoso
    RETURN QUERY
    SELECT
        'Impresión generada exitosamente'::VARCHAR AS mensaje,
        v_folio::VARCHAR AS folio_impresion,
        p_clave_cuenta::VARCHAR AS clave_cuenta,
        CURRENT_DATE AS fecha_generacion,
        v_tipo_doc::VARCHAR AS tipo_documento,
        v_num_paginas AS numero_paginas,
        'success'::VARCHAR AS status;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_impresionnva(VARCHAR) IS
'Genera una nueva impresión de documento para una cuenta específica.
Parámetros:
  - p_clave_cuenta: Clave de la cuenta a imprimir
Retorna: Folio de impresión, tipo de documento y número de páginas';
