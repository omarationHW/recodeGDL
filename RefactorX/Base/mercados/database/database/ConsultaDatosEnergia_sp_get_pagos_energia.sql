-- Stored Procedure: sp_get_pagos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los pagos de energía para un id_energia
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INT)
RETURNS TABLE (
  id_pago_energia INT,
  id_energia INT,
  axo SMALLINT,
  periodo SMALLINT,
  fecha_pago DATE,
  importe_pago NUMERIC,
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id_pago_energia, p.id_energia, p.axo, p.periodo, p.fecha_pago, p.importe_pago, u.usuario
    FROM ta_11_pago_energia p
    LEFT JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    WHERE p.id_energia = p_id_energia;
END;
$$ LANGUAGE plpgsql;