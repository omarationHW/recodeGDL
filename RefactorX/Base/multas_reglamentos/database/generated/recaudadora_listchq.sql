-- ================================================================
-- SP: recaudadora_listchq
-- Módulo: multas_reglamentos
-- Descripción: Listado de cheques registrados en el sistema
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tabla: comun.ta_12_cheques (262,236 registros)
-- ================================================================

DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_listchq(VARCHAR);

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_listchq(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    fecha DATE,
    id_rec SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    id_banco INTEGER,
    banco VARCHAR,
    cheque VARCHAR,
    cuenta VARCHAR,
    importe NUMERIC(16,2),
    tipo_pag VARCHAR,
    folio_completo VARCHAR,
    importe_formato VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Consultar cheques registrados
    RETURN QUERY
    SELECT
        c.fecha::DATE,
        COALESCE(c.id_rec, 0)::SMALLINT AS id_rec,
        COALESCE(TRIM(c.caja), 'N/A')::VARCHAR AS caja,
        COALESCE(c.operacion, 0)::INTEGER AS operacion,
        COALESCE(c.id_banco, 0)::INTEGER AS id_banco,
        COALESCE(
            CASE c.id_banco
                WHEN 1 THEN 'BANAMEX'
                WHEN 2 THEN 'BANCOMER'
                WHEN 3 THEN 'SANTANDER'
                WHEN 4 THEN 'HSBC'
                WHEN 5 THEN 'BANORTE'
                WHEN 6 THEN 'SCOTIABANK'
                WHEN 7 THEN 'BBVA'
                ELSE 'BANCO ' || COALESCE(c.id_banco::TEXT, 'N/A')
            END, 'NO ESPECIFICADO'
        )::VARCHAR AS banco,
        COALESCE(c.cheque::TEXT, 'N/A')::VARCHAR AS cheque,
        COALESCE(TRIM(c.cuenta), 'N/A')::VARCHAR AS cuenta,
        COALESCE(c.importe, 0)::NUMERIC(16,2) AS importe,
        COALESCE(
            CASE c.tipo_pag
                WHEN 1 THEN 'Efectivo'
                WHEN 2 THEN 'Cheque'
                WHEN 3 THEN 'Tarjeta'
                WHEN 4 THEN 'Transferencia'
                ELSE 'Tipo ' || COALESCE(c.tipo_pag::TEXT, 'N/A')
            END, 'NO ESPECIFICADO'
        )::VARCHAR AS tipo_pag,
        (
            'REC-' ||
            COALESCE(c.id_rec::TEXT, '0') || '-' ||
            COALESCE(TRIM(c.caja), 'N/A') || '-' ||
            COALESCE(c.operacion::TEXT, '0')
        )::VARCHAR AS folio_completo,
        ('$' || TO_CHAR(COALESCE(c.importe, 0), 'FM999,999,999.00'))::VARCHAR AS importe_formato
    FROM comun.ta_12_cheques c
    WHERE
        c.importe > 0
        AND (
            v_filtro = ''
            OR UPPER(COALESCE(c.cheque::TEXT, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(c.cuenta, '')) LIKE '%' || v_filtro || '%'
            OR c.id_banco::TEXT LIKE '%' || v_filtro || '%'
            OR c.id_rec::TEXT LIKE '%' || v_filtro || '%'
            OR c.operacion::TEXT LIKE '%' || v_filtro || '%'
            OR TO_CHAR(c.fecha, 'YYYY-MM-DD') LIKE '%' || v_filtro || '%'
        )
    ORDER BY
        c.fecha DESC,
        c.id_rec DESC,
        c.operacion DESC
    LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_listchq(VARCHAR) IS
'Listado de cheques registrados en el sistema.
Tabla origen: comun.ta_12_cheques (262,236 registros).
Parámetro:
  - p_filtro: Término de búsqueda (cheque, cuenta, banco, folio, fecha) - opcional
Retorna: Máximo 100 cheques ordenados por fecha descendente.
Búsqueda en: número de cheque, cuenta, banco, recaudadora, operación, fecha.';
