-- Stored Procedure: sp_mantpagoscontratos_agregar_pago
-- Tipo: CRUD
-- Descripción: Agrega un nuevo pago de contrato, validando existencia de contrato.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_agregar_pago(
    p_colonia SMALLINT,
    p_calle SMALLINT,
    p_folio INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_pago_parcial SMALLINT,
    p_total_parciales SMALLINT,
    p_importe NUMERIC,
    p_cve_descuento SMALLINT,
    p_cve_bonificacion SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
    v_id_convenio INTEGER;
BEGIN
    SELECT id_convenio INTO v_id_convenio
      FROM ta_17_convenios
      WHERE colonia = p_colonia AND calle = p_calle AND folio = p_folio;
    IF v_id_convenio IS NULL THEN
        RETURN QUERY SELECT 'error', 'No existe el contrato especificado';
        RETURN;
    END IF;
    INSERT INTO ta_17_pagos (
        id_convenio, fecha_pago, oficina_pago, caja_pago, operacion_pago, pago_parcial, total_parciales, importe, cve_descuento, cve_bonificacion, id_usuario, fecha_actual
    ) VALUES (
        v_id_convenio, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_pago_parcial, p_total_parciales, p_importe,
        NULLIF(p_cve_descuento, 0), NULLIF(p_cve_bonificacion, 0), p_id_usuario, CURRENT_TIMESTAMP
    );
    RETURN QUERY SELECT 'success', 'Pago agregado correctamente';
END;
$$ LANGUAGE plpgsql;