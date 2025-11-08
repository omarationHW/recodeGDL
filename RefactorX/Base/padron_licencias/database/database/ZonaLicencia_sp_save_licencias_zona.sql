-- Stored Procedure: sp_save_licencias_zona
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la zona/subzona/recaudadora de una licencia
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

CREATE OR REPLACE FUNCTION sp_save_licencias_zona(p_licencia INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM licencias_zona WHERE licencia = p_licencia) THEN
    UPDATE licencias_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista WHERE licencia = p_licencia;
  ELSE
    INSERT INTO licencias_zona (licencia, zona, subzona, recaud, feccap, capturista) VALUES (p_licencia, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
  END IF;
END;
$$ LANGUAGE plpgsql;