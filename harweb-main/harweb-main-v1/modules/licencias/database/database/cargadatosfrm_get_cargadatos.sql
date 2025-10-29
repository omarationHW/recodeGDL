-- Stored Procedure: get_cargadatos
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales de la cuenta catastral (ubicación, propietario, domicilio, etc.)
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-27 16:39:10

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