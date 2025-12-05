-- ================================================================
-- SP: recaudadora_consmulpagos
-- Módulo: multas_reglamentos
-- Descripción: Consulta pagos de multas por clave de cuenta (cvepago)
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-28
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_consmulpagos(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvepago INTEGER,
    fecha DATE,
    recaud SMALLINT,
    caja CHAR(2),
    folio INTEGER,
    importe NUMERIC(16),
    cajero CHAR(10),
    cveconcepto INTEGER,
    contribuyente VARCHAR(306),
    domicilio VARCHAR(336),
    num_acta INTEGER,
    axo_acta SMALLINT,
    id_dependencia SMALLINT,
    multa NUMERIC(16),
    calificacion NUMERIC(16),
    total NUMERIC(16),
    observacion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si se proporciona una clave_cuenta específica, buscar ese pago
    IF p_clave_cuenta IS NOT NULL AND p_clave_cuenta != '' THEN
        RETURN QUERY
        SELECT
            p.cvepago,
            p.fecha,
            p.recaud,
            p.caja,
            p.folio,
            p.importe,
            p.cajero,
            p.cveconcepto,
            m.contribuyente,
            m.domicilio,
            m.num_acta,
            m.axo_acta,
            m.id_dependencia,
            m.multa,
            m.calificacion,
            m.total,
            m.observacion
        FROM comun.pagos p
        INNER JOIN comun.multas m ON p.cvepago = m.cvepago
        WHERE p.cvepago = p_clave_cuenta::INTEGER
          AND p.cveconcepto = 6
        ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
    ELSE
        -- Si no se proporciona clave_cuenta, listar todos los pagos de multas
        RETURN QUERY
        SELECT
            p.cvepago,
            p.fecha,
            p.recaud,
            p.caja,
            p.folio,
            p.importe,
            p.cajero,
            p.cveconcepto,
            m.contribuyente,
            m.domicilio,
            m.num_acta,
            m.axo_acta,
            m.id_dependencia,
            m.multa,
            m.calificacion,
            m.total,
            m.observacion
        FROM comun.pagos p
        INNER JOIN comun.multas m ON p.cvepago = m.cvepago
        WHERE p.cveconcepto = 6
        ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio
        LIMIT 100; -- Limitar resultados para evitar sobrecarga
    END IF;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_consmulpagos(VARCHAR) IS 'Consulta pagos de multas por clave de cuenta (cvepago). Si no se proporciona cuenta, devuelve los últimos 100 pagos.';
