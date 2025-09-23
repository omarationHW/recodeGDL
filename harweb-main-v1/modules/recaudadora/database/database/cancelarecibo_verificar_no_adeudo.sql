-- Stored Procedure: verificar_no_adeudo
-- Tipo: Report
-- Descripción: Verifica si existe un certificado de no adeudo posterior al pago dado.
-- Generado para formulario: cancelarecibo
-- Fecha: 2025-08-26 23:05:38

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