-- Stored Procedure: sp_get_condonaciones_energia
-- Tipo: Catalog
-- Descripción: Obtiene las condonaciones de energía para un id_energia
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_condonaciones_energia(p_id_energia INT)
RETURNS TABLE (
  id_cancelacion INT,
  id_energia INT,
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  observacion VARCHAR(255),
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT c.id_cancelacion, c.id_energia, c.axo, c.periodo, c.importe, c.observacion, u.usuario
    FROM ta_11_ade_ene_canc c
    LEFT JOIN ta_12_passwords u ON c.id_usuario = u.id_usuario
    WHERE c.id_energia = p_id_energia;
END;
$$ LANGUAGE plpgsql;