-- Stored Procedure: sp_register_folio
-- Tipo: CRUD
-- Descripción: Registra un nuevo folio de multa.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-27 13:19:38

CREATE OR REPLACE FUNCTION sp_register_folio(
  p_year INT,
  p_folio INT,
  p_placa TEXT,
  p_fecha_folio DATE,
  p_clave INT,
  p_estado INT,
  p_agente INT,
  p_captura INT,
  p_zona INT,
  p_espacio INT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_exists INT;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta14_folios_adeudo WHERE axo = p_year AND folio = p_folio;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT FALSE, 'Folio ya existe para el año';
    RETURN;
  END IF;
  INSERT INTO ta14_folios_adeudo(axo, folio, placa, fecha_folio, infraccion, estado, vigilante, num_acuerdo, fec_cap, usu_inicial, zona, espacio)
  VALUES (p_year, p_folio, p_placa, p_fecha_folio, p_clave, p_estado, p_agente, 0, NOW(), p_captura, p_zona, p_espacio);
  RETURN QUERY SELECT TRUE, 'Folio registrado correctamente';
END;
$$ LANGUAGE plpgsql;