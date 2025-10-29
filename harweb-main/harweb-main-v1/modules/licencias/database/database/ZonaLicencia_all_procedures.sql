-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ZonaLicencia
-- Generado: 2025-08-27 19:54:46
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene las zonas disponibles para una recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_zonas(p_recaud INTEGER)
RETURNS TABLE(cvezona SMALLINT, cvepoblacion INTEGER, zona VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT z.cvezona, z.cvepoblacion, z.zona, z.feccap, z.capturista, z.cvezona || ' - ' || z.zona AS descripcion
  FROM c_zonas z
  WHERE z.cvezona IN (SELECT zona FROM c_zonayrec WHERE rec = p_recaud)
  ORDER BY z.cvezona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_get_subzonas
-- Tipo: Catalog
-- Descripción: Obtiene las subzonas disponibles para una zona y recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_subzonas(p_cvezona INTEGER, p_recaud INTEGER)
RETURNS TABLE(cvezona INTEGER, cvesubzona INTEGER, descsubzon VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT s.cvezona, s.cvesubzona, s.descsubzon, s.feccap, s.capturista, s.cvesubzona || ' - ' || s.descsubzon AS descripcion
  FROM c_subzonas s
  WHERE s.cvezona = p_cvezona
    AND s.cvesubzona IN (SELECT subzona FROM c_zonayrec WHERE rec = p_recaud AND zona = s.cvezona)
  ORDER BY s.cvesubzona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene las recaudadoras activas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(recaud SMALLINT, descripcion VARCHAR, mpio SMALLINT, recaudador VARCHAR, domicilio VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT recaud, descripcion, mpio, recaudador, domicilio, feccap, capturista
  FROM c_recaud
  WHERE recaud <= 5;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_get_licencia
-- Tipo: Catalog
-- Descripción: Obtiene los datos de una licencia por número
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_licencia(p_licencia INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, empresa INTEGER, recaud SMALLINT, id_giro INTEGER, x FLOAT, y FLOAT, zona SMALLINT, subzona SMALLINT, tipo_registro VARCHAR, actividad VARCHAR, cvecuenta INTEGER, fecha_otorgamiento DATE, propietario VARCHAR, rfc VARCHAR, curp VARCHAR, domicilio VARCHAR, numext_prop INTEGER, numint_prop VARCHAR, colonia_prop VARCHAR, telefono_prop VARCHAR, email VARCHAR, cvecalle INTEGER, ubicacion VARCHAR, numext_ubic INTEGER, letraext_ubic VARCHAR, numint_ubic VARCHAR, letrain_ubic VARCHAR, colonia_ubic VARCHAR, sup_construida FLOAT, sup_autorizada FLOAT, num_cajones SMALLINT, num_empleados SMALLINT, aforo SMALLINT, inversion NUMERIC, rhorario VARCHAR, fecha_consejo DATE, bloqueado SMALLINT, asiento SMALLINT, vigente VARCHAR, fecha_baja DATE, axo_baja INTEGER, folio_baja INTEGER, espubic VARCHAR, base_impuesto NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_get_licencias_zona
-- Tipo: Catalog
-- Descripción: Obtiene la zona/subzona/recaudadora de una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_licencias_zona(p_licencia INTEGER)
RETURNS TABLE(licencia INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias_zona WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_save_licencias_zona
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la zona/subzona/recaudadora de una licencia
-- --------------------------------------------

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

-- ============================================

