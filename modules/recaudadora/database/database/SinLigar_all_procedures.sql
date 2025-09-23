-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SinLigarFrm
-- Generado: 2025-08-27 15:49:03
-- Total SPs: 1
-- ============================================

-- SP 1/1: report_sinligar_pagos
-- Tipo: Report
-- Descripción: Reporte de pagos de transmisiones sin ligar a cuenta predial, entre dos fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_sinligar_pagos(fecha1 DATE, fecha2 DATE)
RETURNS TABLE (
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    caja VARCHAR(2),
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    importe NUMERIC,
    cajero VARCHAR(10),
    cvecanc INTEGER,
    cveconcepto INTEGER,
    cvepago_1 INTEGER,
    contribuyente VARCHAR(100),
    domicilio VARCHAR(50),
    concepto TEXT,
    referencia INTEGER,
    bimini INTEGER,
    axoini INTEGER,
    bimfin INTEGER,
    axofin INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cvepago,
        p.cvecuenta,
        p.recaud,
        p.caja,
        p.folio,
        p.fecha,
        p.hora,
        p.importe,
        p.cajero,
        p.cvecanc,
        p.cveconcepto,
        d.cvepago AS cvepago_1,
        d.contribuyente,
        d.domicilio,
        d.concepto,
        d.referencia,
        d.bimini,
        d.axoini,
        d.bimfin,
        d.axofin
    FROM pagos p
    JOIN auditoria a ON p.cvepago = a.cvepago
    LEFT JOIN pago_diversos d ON p.cvepago = d.cvepago
    WHERE p.cveconcepto = 4
      AND a.cvectaapl = 120100000
      AND p.cvecuenta = 0
      AND p.cvecanc IS NULL
      AND p.fecha >= fecha1
      AND p.fecha <= fecha2
    ORDER BY p.fecha, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

