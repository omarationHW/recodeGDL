-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Empresas
-- Generado: 2025-08-27 01:35:17
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de ejecutores vigentes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ejecutores()
RETURNS TABLE(cveejecutor SMALLINT, ejecutor TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT cveejecutor, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) AS ejecutor
    FROM ejecutor
    WHERE vigencia = 'V' AND fecinic >= DATE '2022-01-01';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_check_cuenta
-- Tipo: CRUD
-- Descripción: Verifica si existe la cuenta para el ejecutor y fecha dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_check_cuenta(
  vcta INTEGER,
  veje INTEGER,
  vfec DATE
) RETURNS TABLE(cuentas INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) FROM ctaempexterna WHERE cvecuenta = vcta AND cveejecutor = veje AND fecha_trabajo = vfec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_check_empresa_diferente
-- Tipo: CRUD
-- Descripción: Verifica si la cuenta existe para otra empresa (ejecutor) distinta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_check_empresa_diferente(
  ecta INTEGER,
  eeje INTEGER
) RETURNS TABLE(existe INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) FROM ctaempexterna WHERE cvecuenta = ecta AND fecha_trabajo >= DATE '2022-01-01' AND cveejecutor <> eeje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_insert_ctaempexterna
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuenta en ctaempexterna.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_ctaempexterna(
  vcta INTEGER,
  veje INTEGER,
  vfec DATE
) RETURNS TABLE(inserted BOOLEAN) AS $$
BEGIN
  INSERT INTO ctaempexterna (cvecuenta, cveejecutor, fecha_trabajo)
  VALUES (vcta, veje, vfec);
  RETURN QUERY SELECT TRUE;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_empresas_folios
-- Tipo: CRUD
-- Descripción: Obtiene o actualiza folios para empresas externas según parámetros.
-- --------------------------------------------

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

-- ============================================

-- SP 6/7: sp_predial_principal
-- Tipo: Report
-- Descripción: Obtiene los datos principales de predial para un ejecutor y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_predial_principal(
  pejec INTEGER,
  pfecha DATE
) RETURNS SETOF predial_principal AS $$
-- predial_principal debe ser un tipo compuesto o tabla con los campos requeridos
BEGIN
  RETURN QUERY
    SELECT * FROM predial_principal WHERE cveejecutor = pejec AND fecha = pfecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_predial_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de predial para un ejecutor y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_predial_detalle(
  pejec INTEGER,
  pfecha DATE
) RETURNS SETOF predial_detalle AS $$
-- predial_detalle debe ser un tipo compuesto o tabla con los campos requeridos
BEGIN
  RETURN QUERY
    SELECT * FROM predial_detalle WHERE cveejecutor = pejec AND fecha = pfecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

