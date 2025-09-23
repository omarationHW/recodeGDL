-- Stored Procedure: sp_bloqueo_licencia_search
-- Tipo: CRUD
-- Descripción: Busca una licencia y su estado de bloqueo
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_search(p_licencia INTEGER)
RETURNS TABLE(
  id_licencia INTEGER,
  licencia INTEGER,
  propietario TEXT,
  domicilio TEXT,
  bloqueada BOOLEAN,
  motivo TEXT,
  feccap DATE,
  fecbaja DATE,
  capturista TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.propietario, l.ubicacion AS domicilio,
      CASE WHEN n.id_control IS NOT NULL AND n.fecbaja IS NULL THEN TRUE ELSE FALSE END AS bloqueada,
      n.observacion, n.feccap, n.fecbaja, n.capturista
    FROM licencias l
    LEFT JOIN norequeriblelic n ON n.id_licencia = l.id_licencia AND n.fecbaja IS NULL
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;