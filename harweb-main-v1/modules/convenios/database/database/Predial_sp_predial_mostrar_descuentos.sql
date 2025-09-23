-- Stored Procedure: sp_predial_mostrar_descuentos
-- Tipo: Report
-- Descripción: Obtiene los descuentos aplicados a la cuenta predial en el periodo
-- Generado para formulario: Predial
-- Fecha: 2025-08-27 15:16:35

CREATE OR REPLACE FUNCTION sp_predial_mostrar_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE (
    cvedescuento INTEGER,
    descripcion VARCHAR,
    impdescto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedescuento, c.descripcion, sum(d.impvir)
    FROM detsaldos d
    LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal)) AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
      AND d.cvedescuento IS NOT NULL
    GROUP BY d.cvedescuento, c.descripcion;
END;
$$ LANGUAGE plpgsql;