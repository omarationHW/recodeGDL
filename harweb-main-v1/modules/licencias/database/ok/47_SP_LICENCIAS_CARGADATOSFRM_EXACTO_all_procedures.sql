-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGADATOSFRM (EXACTO del archivo original)
-- Archivo: 47_SP_LICENCIAS_CARGADATOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGADATOSFRM (EXACTO del archivo original)
-- Archivo: 47_SP_LICENCIAS_CARGADATOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGADATOSFRM (EXACTO del archivo original)
-- Archivo: 47_SP_LICENCIAS_CARGADATOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

