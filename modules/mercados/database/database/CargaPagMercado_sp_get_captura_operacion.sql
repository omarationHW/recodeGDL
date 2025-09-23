-- Stored Procedure: sp_get_captura_operacion
-- Tipo: CRUD
-- Descripción: Obtiene el total capturado de una operación de caja para validación
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_get_captura_operacion(
    p_fecha_pago date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_mercado integer
) RETURNS TABLE(
    capturado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(a.importe_pago),0) capturado
    FROM ta_11_pagos_local a
    JOIN ta_11_locales b ON a.id_local = b.id_local
    WHERE EXTRACT(MONTH FROM a.fecha_pago) = EXTRACT(MONTH FROM p_fecha_pago)
      AND a.oficina_pago = p_oficina
      AND a.caja_pago = p_caja
      AND a.operacion_pago = p_operacion
      AND b.num_mercado = p_mercado;
END;
$$ LANGUAGE plpgsql;