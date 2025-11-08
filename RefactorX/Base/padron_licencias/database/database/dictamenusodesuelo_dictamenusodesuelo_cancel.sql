-- Stored Procedure: dictamenusodesuelo_cancel
-- Tipo: CRUD
-- Descripción: Cancela una constancia (vigente = 'C') y registra motivo
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_cancel(
  p_axo INTEGER,
  p_folio INTEGER,
  p_motivo VARCHAR
)
RETURNS VOID AS $$
BEGIN
  UPDATE constancias SET
    vigente = 'C',
    observacion = p_motivo
  WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;