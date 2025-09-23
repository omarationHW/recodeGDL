-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: cancelarecibo
-- Generado: 2025-08-26 23:05:38
-- Total SPs: 3
-- ============================================

-- SP 1/3: buscar_recibo_pago
-- Tipo: Report
-- Descripción: Busca un recibo de pago por recaudadora, caja, folio, importe y fecha (opcional). Devuelve los datos del recibo y sus relaciones.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_recibo_pago(
    p_recaud INTEGER,
    p_caja TEXT,
    p_folio INTEGER,
    p_importe NUMERIC,
    p_fecha DATE,
    p_user_name TEXT
) RETURNS TABLE(
    cvepago INTEGER,
    cvecuenta INTEGER,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cvecanc INTEGER,
    gaspag NUMERIC,
    mulpag NUMERIC,
    cveconcepto INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    IF p_user_name = 'proceso' AND p_fecha IS NOT NULL THEN
        RETURN QUERY
        SELECT p.cvepago, p.cvecuenta, p.fecha, p.hora, p.importe, p.cvecanc,
               g.gaspag, g.mulpag, p.cveconcepto, tp.impuesto, tp.recargos
        FROM pagos p
        LEFT JOIN gastmult g ON g.cvepago = p.cvepago
        LEFT JOIN imprectp tp ON tp.cvepago = p.cvepago
        WHERE p.recaud = p_recaud
          AND p.caja = p_caja
          AND p.folio = p_folio
          AND p.fecha = p_fecha
          AND p.importe = p_importe;
    ELSE
        RETURN QUERY
        SELECT p.cvepago, p.cvecuenta, p.fecha, p.hora, p.importe, p.cvecanc,
               g.gaspag, g.mulpag, p.cveconcepto, tp.impuesto, tp.recargos
        FROM pagos p
        LEFT JOIN gastmult g ON g.cvepago = p.cvepago
        LEFT JOIN imprectp tp ON tp.cvepago = p.cvepago
        WHERE p.recaud = p_recaud
          AND p.caja = p_caja
          AND p.folio = p_folio
          AND p.fecha = CURRENT_DATE
          AND p.importe = p_importe;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: verificar_no_adeudo
-- Tipo: Report
-- Descripción: Verifica si existe un certificado de no adeudo posterior al pago dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION verificar_no_adeudo(
    p_cvecuenta INTEGER,
    p_cvepago INTEGER
) RETURNS SETOF noadeudo AS $$
BEGIN
    RETURN QUERY
    SELECT a.*
    FROM noadeudo a
    JOIN pagos p ON a.cvecuenta = p.cvecuenta
    JOIN imprecpre i ON i.cvepago = p.cvepago
    WHERE p.cvecuenta = p_cvecuenta
      AND p.cvepago = p_cvepago
      AND a.cvecuenta = p.cvecuenta
      AND i.cvepago = p.cvepago
      AND a.axo = i.axopago
      AND a.bimestre <= i.bimfin
      AND a.cvepago > p.cvepago
      AND a.cvepago NOT IN (
        SELECT cvepago FROM pagos
        WHERE cvecuenta = p_cvecuenta
          AND cvepago > p_cvepago
          AND cveconcepto = 3
          AND cvecanc IS NOT NULL
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: cancelar_recibo_pago
-- Tipo: CRUD
-- Descripción: Cancela un recibo de pago, ejecutando la lógica de negocio según el tipo de concepto y registrando la cancelación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cancelar_recibo_pago(
    p_cvepago INTEGER,
    p_cvecuenta INTEGER,
    p_cveconcepto INTEGER,
    p_user_name TEXT,
    p_fecha_cancelacion DATE
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Si concepto = 6 o 7 (multas), actualizar reqmultas
    IF p_cveconcepto = 6 OR p_cveconcepto = 7 THEN
        UPDATE reqmultas SET vigencia = 'V', cvepago = NULL WHERE cvepago = p_cvepago;
    END IF;
    -- Si concepto = 8 (licencias), ejecutar procedimiento de cancelación de licencia
    IF p_cveconcepto = 8 THEN
        -- Suponiendo que existe un procedimiento similar en PostgreSQL
        PERFORM canc_plicencia(p_cvepago, p_cvecuenta);
    END IF;
    -- Registrar la cancelación en pagoscan
    INSERT INTO pagoscan (cvepago, autorizo, fechacan)
    VALUES (p_cvepago, p_user_name, p_fecha_cancelacion);
    -- Marcar el pago como cancelado (si aplica en la tabla pagos)
    UPDATE pagos SET cvecanc = (SELECT currval(pg_get_serial_sequence('pagoscan','cvecanc'))) WHERE cvepago = p_cvepago;
    RETURN QUERY SELECT TRUE, 'Recibo cancelado correctamente.';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al cancelar el recibo: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

