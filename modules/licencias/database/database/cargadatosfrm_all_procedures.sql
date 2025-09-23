-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: cargadatosfrm
-- Generado: 2025-08-27 16:39:10
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_cargadatos
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales de la cuenta catastral (ubicación, propietario, domicilio, etc.)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_cargadatos(p_cvecatnva TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT row_to_json(t)
  INTO result
  FROM (
    SELECT
      u.calle,
      u.noexterior,
      u.interior,
      u.colonia,
      c.nombre_completo,
      c.rfc,
      c.domicilio,
      r.poblacion,
      c.codpos,
      a.observacion,
      -- Otros campos relevantes
      ARRAY(
        SELECT json_build_object('uso', us.uso, 'descripcion', us.descripcion)
        FROM usos_suelo us WHERE us.cvecatnva = p_cvecatnva
      ) AS usos
    FROM ubicacion u
    JOIN contribuyente c ON c.cvecatnva = u.cvecatnva
    JOIN regprop r ON r.cvecatnva = u.cvecatnva
    LEFT JOIN avaluos a ON a.cvecatnva = u.cvecatnva
    WHERE u.cvecatnva = p_cvecatnva
    LIMIT 1
  ) t;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_avaluos
-- Tipo: Catalog
-- Descripción: Obtiene los avalúos de una cuenta catastral y subpredio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_avaluos(p_cvecatnva TEXT, p_subpredio INT)
RETURNS TABLE(
  cveavaluo INT,
  supterr NUMERIC,
  supconst NUMERIC,
  valorterr NUMERIC,
  valorconst NUMERIC,
  valfiscal NUMERIC,
  feccap DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT cveavaluo, supterr, supconst, valorterr, valorconst, valfiscal, feccap
  FROM avaluos
  WHERE cvecatnva = p_cvecatnva AND (subpredio = p_subpredio OR p_subpredio = 0)
  ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: get_construcciones
-- Tipo: Catalog
-- Descripción: Obtiene las construcciones asociadas a un avalúo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_construcciones(p_cveavaluo INT)
RETURNS TABLE(
  cvebloque INT,
  cveclasif INT,
  descripcion TEXT,
  areaconst NUMERIC,
  importe NUMERIC,
  numpisos INT,
  estructura TEXT,
  factorajus NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cvebloque, a.cveclasif, b.descripcion, a.areaconst, a.importe, a.numpisos, a.estructura, a.factorajus
  FROM construc a
  LEFT JOIN c_bloqcon b ON b.axovig = a.axovig AND b.cveclasif = a.cveclasif
  WHERE a.cveavaluo = p_cveavaluo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: get_area_carto
-- Tipo: Catalog
-- Descripción: Obtiene el área de construcción cartográfica para una clave catastral
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_area_carto(p_cvecatnva TEXT)
RETURNS TABLE(supconst NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT SUM(areaconst) AS supconst
  FROM construc_carto
  WHERE cvecatnva = p_cvecatnva AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: save_cargadatos
-- Tipo: CRUD
-- Descripción: Guarda o actualiza los datos principales de la cuenta catastral
-- --------------------------------------------

CREATE OR REPLACE FUNCTION save_cargadatos(p_cvecatnva TEXT, p_data JSON)
RETURNS JSON AS $$
DECLARE
  -- Aquí se haría el upsert de los datos principales
  result JSON;
BEGIN
  -- Ejemplo: actualizar propietario
  UPDATE contribuyente SET nombre_completo = p_data->>'nombre_completo', rfc = p_data->>'rfc'
  WHERE cvecatnva = p_cvecatnva;
  -- Otros updates según la estructura de p_data
  result := json_build_object('updated', true);
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

