-- Stored Procedure: sp_predial_calcular_liquidacion
-- Tipo: CRUD
-- Descripción: Calcula la liquidación de adeudos de predial para una cuenta y periodo
-- Generado para formulario: Predial
-- Fecha: 2025-08-27 15:16:35

CREATE OR REPLACE FUNCTION sp_predial_calcular_liquidacion(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE (
    axoefec INTEGER,
    valfiscal NUMERIC,
    tasa NUMERIC,
    axosobre INTEGER,
    recvir NUMERIC,
    impfac NUMERIC,
    impvir NUMERIC,
    impade NUMERIC,
    total NUMERIC,
    bimini INTEGER,
    bimfin INTEGER,
    inicio VARCHAR,
    fin VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.axoefec, v.valfiscal, v.tasa, v.axosobre, sum(d.recvir), sum(d.impade+d.impvir), sum(d.impvir), sum(d.impade), sum(d.recfac-d.recpag-d.recvir), min(v.bimefec), max(v.bimefec), min(v.bimefec)::text || '/' || v.axoefec::text, max(v.bimefec)::text || '/' || v.axoefec::text
    FROM detsaldos d
    JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal)) AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
    GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
    ORDER BY v.axoefec, min(v.bimefec);
END;
$$ LANGUAGE plpgsql;