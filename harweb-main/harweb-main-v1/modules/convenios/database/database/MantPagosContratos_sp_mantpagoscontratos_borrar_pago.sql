-- Stored Procedure: sp_mantpagoscontratos_borrar_pago
-- Tipo: CRUD
-- Descripción: Elimina un pago de contrato por sus llaves.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_borrar_pago(
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
) RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    DELETE FROM ta_17_pagos
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    IF v_affected = 0 THEN
        RETURN QUERY SELECT 'error', 'No se encontró el pago para borrar';
    ELSE
        RETURN QUERY SELECT 'success', 'Pago eliminado correctamente';
    END IF;
END;
$$ LANGUAGE plpgsql;