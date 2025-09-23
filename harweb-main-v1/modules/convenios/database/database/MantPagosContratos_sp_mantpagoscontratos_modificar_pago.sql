-- Stored Procedure: sp_mantpagoscontratos_modificar_pago
-- Tipo: CRUD
-- Descripción: Modifica un pago de contrato existente.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_modificar_pago(
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
    v_affected INTEGER;
BEGIN
    SELECT id_convenio INTO v_id_convenio
      FROM ta_17_convenios
      WHERE colonia = p_colonia AND calle = p_calle AND folio = p_folio;
    IF v_id_convenio IS NULL THEN
        RETURN QUERY SELECT 'error', 'No existe el contrato especificado';
        RETURN;
    END IF;
    UPDATE ta_17_pagos SET
        id_convenio = v_id_convenio,
        pago_parcial = p_pago_parcial,
        total_parciales = p_total_parciales,
        importe = p_importe,
        cve_descuento = NULLIF(p_cve_descuento, 0),
        cve_bonificacion = NULLIF(p_cve_bonificacion, 0),
        id_usuario = p_id_usuario,
        fecha_actual = CURRENT_TIMESTAMP
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    IF v_affected = 0 THEN
        RETURN QUERY SELECT 'error', 'No se encontró el pago para modificar';
    ELSE
        RETURN QUERY SELECT 'success', 'Pago modificado correctamente';
    END IF;
END;
$$ LANGUAGE plpgsql;