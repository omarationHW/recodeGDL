-- Stored Procedure: sp_empresas_folios
-- Tipo: CRUD
-- Descripción: Obtiene o actualiza folios para empresas externas según parámetros.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_empresas_folios(
  prec INTEGER,
  paxo INTEGER,
  pfdsd INTEGER,
  pfhst INTEGER,
  pfecha DATE,
  pejecutor INTEGER,
  pmod INTEGER,
  popc TEXT
) RETURNS SETOF empresas_folios AS $$
-- empresas_folios debe ser un tipo compuesto o tabla con los campos requeridos
DECLARE
BEGIN
  IF popc = 'C' THEN
    RETURN QUERY SELECT * FROM empresas_folios WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
  ELSIF popc = 'M' THEN
    -- Aquí se debe realizar la actualización de los folios (practicar)
    UPDATE empresas_folios SET practicado = NOW() WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
    RETURN QUERY SELECT * FROM empresas_folios WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
  END IF;
END;
$$ LANGUAGE plpgsql;