-- Stored Procedure: sp_detpagos
-- Tipo: CRUD
-- Descripción: Genera el detalle de pagos para un contrato y periodo dado
-- Generado para formulario: Adeudos_EdoCta
-- Fecha: 2025-08-27 13:42:14

CREATE OR REPLACE PROCEDURE sp_detpagos(
  IN p_control_contrato INTEGER,
  IN p_ejercicio INTEGER,
  IN p_per1 VARCHAR,
  IN p_per2 VARCHAR,
  IN p_per3 VARCHAR,
  IN p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Elimina registros previos del contrato
  DELETE FROM det_pagos WHERE control_contrato = p_control_contrato;
  -- Inserta los nuevos detalles (ejemplo, sumariza pagos por periodo)
  INSERT INTO det_pagos (control_contrato, ejercicio, detalle, importe_adeudos, importe_recargos, importe_multas, importe_gastos)
  SELECT
    p_control_contrato,
    p_ejercicio,
    CONCAT('Periodo ', p_per1, ' a ', p_per2),
    SUM(CASE WHEN status_vigencia = p_status THEN importe ELSE 0 END) AS importe_adeudos,
    SUM(CASE WHEN status_vigencia = p_status THEN recargos ELSE 0 END) AS importe_recargos,
    SUM(CASE WHEN status_vigencia = p_status THEN multa ELSE 0 END) AS importe_multas,
    SUM(CASE WHEN status_vigencia = p_status THEN gastos ELSE 0 END) AS importe_gastos
  FROM ta_16_pagos
  WHERE control_contrato = p_control_contrato
    AND aso_mes_pago BETWEEN p_per1 AND p_per2
  GROUP BY p_control_contrato, p_ejercicio;
END;
$$;