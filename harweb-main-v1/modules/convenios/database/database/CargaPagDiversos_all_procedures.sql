-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaPagDiversos
-- Generado: 2025-08-27 14:03:24
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_buscar_pagos_diversos
-- Tipo: Report
-- Descripción: Devuelve los pagos diversos pendientes de cargar a convenios, filtrados por fecha y recaudadora.
-- --------------------------------------------

-- PostgreSQL stored procedure for searching pending diverse payments
CREATE OR REPLACE FUNCTION sp_buscar_pagos_diversos(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora INTEGER
)
RETURNS TABLE(
    fecing DATE,
    recing INTEGER,
    cajing VARCHAR(10),
    opcaja INTEGER,
    colonia INTEGER,
    obra INTEGER,
    numero INTEGER,
    tipo_rbo VARCHAR(10),
    mes_desde INTEGER,
    axo_desde INTEGER,
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo,
           b.mes_desde, b.axo_desde, SUM(b.importe_cta) AS pagado
    FROM cg_12_ingreso a
    JOIN cg_12_importes b ON a.fecing = b.fecing AND a.recing = b.recing AND a.cajing = b.cajing AND a.opcaja = b.opcaja
    WHERE a.fecing BETWEEN p_fecha_desde AND p_fecha_hasta
      AND a.recing = p_recaudadora
      AND b.cta_aplicacion IN (541000000,542000000,543000000,925400010,925400020,925400030)
      AND NOT EXISTS (
        SELECT 1 FROM ta_17_pagos tp
        WHERE tp.fecha_pago = a.fecing AND tp.oficina_pago = a.recing AND tp.caja_pago = a.cajing AND tp.operacion_pago = a.opcaja
      )
    GROUP BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo, b.mes_desde, b.axo_desde
    ORDER BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo, b.mes_desde, b.axo_desde;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_grabar_pago_diverso
-- Tipo: CRUD
-- Descripción: Graba un pago diverso en la tabla de pagos, validando la existencia del contrato.
-- --------------------------------------------

-- PostgreSQL stored procedure for inserting a diverse payment
CREATE OR REPLACE FUNCTION sp_grabar_pago_diverso(
    p_fecing DATE,
    p_recing INTEGER,
    p_cajing VARCHAR,
    p_opcaja INTEGER,
    p_colonia INTEGER,
    p_obra INTEGER,
    p_numero INTEGER,
    p_tipo_rbo VARCHAR,
    p_mes_desde INTEGER,
    p_axo_desde INTEGER,
    p_pagado NUMERIC,
    p_id_usuario INTEGER,
    p_nivel_usuario INTEGER
) RETURNS TABLE(error TEXT) AS $$
DECLARE
    v_id_convenio INTEGER;
BEGIN
    -- Buscar contrato
    SELECT id_convenio INTO v_id_convenio
    FROM ta_17_convenios
    WHERE colonia = p_colonia AND calle = p_obra AND folio = p_numero;
    IF v_id_convenio IS NULL THEN
        RETURN QUERY SELECT 'No existe el contrato para Colonia: '||p_colonia||', Calle: '||p_obra||', Folio: '||p_numero;
        RETURN;
    END IF;
    -- Insertar pago
    INSERT INTO ta_17_pagos (
        id_pago, id_convenio, fecha_pago, oficina_pago, caja_pago, operacion_pago,
        pago_parcial, total_parciales, importe, cve_descuento, cve_bonificacion, id_usuario, fecha_actual
    ) VALUES (
        DEFAULT, v_id_convenio, p_fecing, p_recing, p_cajing, p_opcaja,
        p_mes_desde, p_axo_desde, p_pagado, NULL, NULL, p_id_usuario, NOW()
    );
    RETURN QUERY SELECT NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

