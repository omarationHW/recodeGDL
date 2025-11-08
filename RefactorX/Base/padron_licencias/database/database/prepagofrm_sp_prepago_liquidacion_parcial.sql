-- Stored Procedure: sp_prepago_liquidacion_parcial
-- Tipo: CRUD
-- Descripción: Calcula la liquidación parcial de adeudo predial para una cuenta hasta un año/bimestre dado.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-27 18:51:25

CREATE OR REPLACE FUNCTION sp_prepago_liquidacion_parcial(
    p_cvecuenta INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS JSON AS $$
DECLARE
    v_detalle JSON;
    v_totales JSON;
BEGIN
    -- Detalle de bimestres
    SELECT json_agg(row_to_json(t)) INTO v_detalle FROM (
        SELECT v.axoefec, v.valfiscal, v.tasa, v.axosobre,
               SUM(d.recvir) AS recvir, SUM(d.impade+d.impvir) AS impfac,
               SUM(d.impvir) AS impvir, SUM(d.impade) AS impade,
               SUM(d.recfac-d.recpag-d.recvir) AS total,
               MIN(v.bimefec) AS bimini, MAX(v.bimefec) AS bimfin,
               MIN(v.bimefec)::TEXT || '/' || v.axoefec AS inicio,
               MAX(v.bimefec)::TEXT || '/' || v.axoefec AS fin
        FROM detsaldos d
        JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
        ORDER BY v.axoefec, bimini
    ) t;
    -- Totales
    SELECT row_to_json(t) INTO v_totales FROM (
        SELECT SUM(d.recfac-d.recpag-d.recvir) AS recppag,
               SUM(d.impfac-d.imppag-d.impvir) AS impppag,
               (s.multa-s.multavir) AS multa,
               s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        FROM detsaldos d
        JOIN saldos s ON s.cvecuenta = d.cvecuenta
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY s.multa, s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        LIMIT 1
    ) t;
    RETURN json_build_object('detalle', v_detalle, 'totales', v_totales);
END;
$$ LANGUAGE plpgsql;