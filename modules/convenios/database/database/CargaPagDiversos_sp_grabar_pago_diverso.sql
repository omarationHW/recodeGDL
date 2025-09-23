-- Stored Procedure: sp_grabar_pago_diverso
-- Tipo: CRUD
-- Descripción: Graba un pago diverso en la tabla de pagos, validando la existencia del contrato.
-- Generado para formulario: CargaPagDiversos
-- Fecha: 2025-08-27 14:03:24

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