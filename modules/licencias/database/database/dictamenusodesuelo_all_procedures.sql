-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: dictamenusodesuelo
-- Generado: 2025-08-27 17:38:15
-- Total SPs: 7
-- ============================================

-- SP 1/7: dictamenusodesuelo_list
-- Tipo: Catalog
-- Descripción: Obtiene el listado de dictámenes de uso de suelo (constancias)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_list()
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: dictamenusodesuelo_search
-- Tipo: Catalog
-- Descripción: Búsqueda avanzada de dictámenes por año, folio, licencia o rango de fechas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_search(
  p_axo INTEGER DEFAULT NULL,
  p_folio INTEGER DEFAULT NULL,
  p_licencia INTEGER DEFAULT NULL,
  p_fecha_ini DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_licencia IS NULL OR id_licencia = p_licencia)
      AND (p_fecha_ini IS NULL OR feccap >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR feccap <= p_fecha_fin)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: dictamenusodesuelo_create
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia/dictamen de uso de suelo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_create(
  p_solicita VARCHAR,
  p_partidapago VARCHAR,
  p_observacion VARCHAR,
  p_domicilio VARCHAR,
  p_id_licencia INTEGER,
  p_capturista VARCHAR,
  p_tipo INTEGER,
  p_recaud INTEGER DEFAULT NULL,
  p_actividad VARCHAR DEFAULT NULL,
  p_propietario VARCHAR DEFAULT NULL,
  p_ubicacion VARCHAR DEFAULT NULL,
  p_numext_ubic VARCHAR DEFAULT NULL,
  p_letraext_ubic VARCHAR DEFAULT NULL,
  p_numint_ubic VARCHAR DEFAULT NULL,
  p_letraint_ubic VARCHAR DEFAULT NULL,
  p_sup_construida NUMERIC DEFAULT NULL,
  p_sup_autorizada NUMERIC DEFAULT NULL,
  p_num_cajones INTEGER DEFAULT NULL,
  p_num_empleados INTEGER DEFAULT NULL,
  p_vigente VARCHAR DEFAULT 'V',
  p_feccap DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(axo INTEGER, folio INTEGER) AS $$
DECLARE
  nvo_folio INTEGER;
  nvo_axo INTEGER;
BEGIN
  nvo_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
  -- Obtener folio actual
  SELECT constancia + 1 INTO nvo_folio FROM parametros LIMIT 1;
  -- Actualizar folio en parametros
  UPDATE parametros SET constancia = nvo_folio;
  -- Insertar constancia
  INSERT INTO constancias (
    axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, tipo
  ) VALUES (
    nvo_axo, nvo_folio, p_id_licencia, p_solicita, p_partidapago, p_observacion, p_domicilio, p_vigente, p_feccap, p_capturista, p_tipo
  );
  RETURN QUERY SELECT nvo_axo, nvo_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: dictamenusodesuelo_update
-- Tipo: CRUD
-- Descripción: Actualiza una constancia existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_update(
  p_axo INTEGER,
  p_folio INTEGER,
  p_solicita VARCHAR,
  p_partidapago VARCHAR,
  p_observacion VARCHAR,
  p_domicilio VARCHAR,
  p_id_licencia INTEGER,
  p_capturista VARCHAR,
  p_tipo INTEGER,
  p_recaud INTEGER DEFAULT NULL,
  p_actividad VARCHAR DEFAULT NULL,
  p_propietario VARCHAR DEFAULT NULL,
  p_ubicacion VARCHAR DEFAULT NULL,
  p_numext_ubic VARCHAR DEFAULT NULL,
  p_letraext_ubic VARCHAR DEFAULT NULL,
  p_numint_ubic VARCHAR DEFAULT NULL,
  p_letraint_ubic VARCHAR DEFAULT NULL,
  p_sup_construida NUMERIC DEFAULT NULL,
  p_sup_autorizada NUMERIC DEFAULT NULL,
  p_num_cajones INTEGER DEFAULT NULL,
  p_num_empleados INTEGER DEFAULT NULL,
  p_vigente VARCHAR DEFAULT 'V'
)
RETURNS VOID AS $$
BEGIN
  UPDATE constancias SET
    solicita = p_solicita,
    partidapago = p_partidapago,
    observacion = p_observacion,
    domicilio = p_domicilio,
    id_licencia = p_id_licencia,
    capturista = p_capturista,
    tipo = p_tipo,
    vigente = p_vigente
  WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: dictamenusodesuelo_cancel
-- Tipo: CRUD
-- Descripción: Cancela una constancia (vigente = 'C') y registra motivo
-- --------------------------------------------

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

-- ============================================

-- SP 6/7: dictamenusodesuelo_print
-- Tipo: Report
-- Descripción: Genera el PDF de la constancia (devuelve URL o base64)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_print(
  p_axo INTEGER,
  p_folio INTEGER
)
RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
  url TEXT;
BEGIN
  -- Aquí se debe implementar la generación del PDF y devolver la URL o base64
  url := '/storage/constancias/' || p_axo || '-' || p_folio || '.pdf';
  RETURN QUERY SELECT url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: dictamenusodesuelo_listado
-- Tipo: Report
-- Descripción: Listado filtrado de constancias para impresión masiva
-- --------------------------------------------

CREATE OR REPLACE FUNCTION dictamenusodesuelo_listado(
  p_axo INTEGER DEFAULT NULL,
  p_folio INTEGER DEFAULT NULL,
  p_licencia INTEGER DEFAULT NULL,
  p_fecha_ini DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_licencia IS NULL OR id_licencia = p_licencia)
      AND (p_fecha_ini IS NULL OR feccap >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR feccap <= p_fecha_fin)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

