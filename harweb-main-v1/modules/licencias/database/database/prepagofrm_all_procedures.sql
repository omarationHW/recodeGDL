-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: prepagofrm
-- Generado: 2025-08-27 18:51:25
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_prepago_get_data
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contribuyente y cuenta catastral para el formulario de prepago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_get_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_completo, c.calle, c.noexterior, c.interior, ca.ultcomp, ca.axoultcomp
    FROM catastro ca
    JOIN regprop rp ON rp.cvecuenta = ca.cvecuenta AND rp.cveregprop = ca.cveregprop AND rp.encabeza = 'S'
    JOIN contrib c ON c.cvecont = rp.cvecont
    WHERE ca.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_prepago_liquidacion_parcial
-- Tipo: CRUD
-- Descripción: Calcula la liquidación parcial de adeudo predial para una cuenta hasta un año/bimestre dado.
-- --------------------------------------------

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

-- ============================================

-- SP 3/7: sp_prepago_get_descuentos
-- Tipo: Catalog
-- Descripción: Obtiene los descuentos aplicados a la cuenta en el periodo seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_get_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion TEXT,
    impdescto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedescuento, c.descripcion, SUM(d.impvir) AS impdescto
    FROM detsaldos d
    JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
    LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
           AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
      AND d.cvedescuento IS NOT NULL
    GROUP BY d.cvedescuento, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_prepago_get_ultimo_requerimiento
-- Tipo: Catalog
-- Descripción: Obtiene el último requerimiento practicado para la cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_get_ultimo_requerimiento(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvereq INTEGER,
    cveejecut SMALLINT,
    folioreq INTEGER,
    axoreq SMALLINT,
    cvecuenta INTEGER,
    cvepago INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    fecemi DATE,
    fecent DATE,
    cvecancr TEXT,
    axoini SMALLINT,
    bimini SMALLINT,
    axofin SMALLINT,
    bimfin SMALLINT,
    secuencia SMALLINT,
    vigencia TEXT,
    feccap DATE,
    capturista TEXT,
    iniper TEXT,
    finper TEXT,
    diastrans INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT *, bimini::TEXT||'/'||axoini AS iniper, bimfin::TEXT||'/'||axofin AS finper, (CURRENT_DATE - fecent) AS diastrans
    FROM reqpredial
    WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND fecent IS NOT NULL
    ORDER BY axoreq DESC, folioreq DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_prepago_recalcular_dpp
-- Tipo: CRUD
-- Descripción: Ejecuta la lógica de recálculo de descuento pronto pago para la cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_recalcular_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de recálculo (actualiza tablas, etc)
    -- Por ejemplo, llamar otro SP o actualizar campos
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_prepago_eliminar_dpp
-- Tipo: CRUD
-- Descripción: Elimina el descuento pronto pago para la cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_eliminar_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de eliminación (actualiza tablas, etc)
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_prepago_calcular_descpred
-- Tipo: CRUD
-- Descripción: Calcula el descuento predial para la cuenta (aplica reglas de pronto pago, etc).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_calcular_descpred(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de cálculo de descuento predial
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

