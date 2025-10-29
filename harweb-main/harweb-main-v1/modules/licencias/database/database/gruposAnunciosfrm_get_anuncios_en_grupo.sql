-- Stored Procedure: get_anuncios_en_grupo
-- Tipo: Catalog
-- Descripción: Obtiene los anuncios vigentes que están en el grupo, filtrados por texto.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION get_anuncios_en_grupo(grupo_id INT, filtro TEXT)
RETURNS TABLE(
  anuncio INT,
  propietario TEXT,
  descripcion TEXT,
  id_giro INT,
  zona SMALLINT,
  subzona SMALLINT,
  fecha_otorgamiento DATE,
  medidas1 FLOAT,
  medidas2 FLOAT,
  area_anuncio FLOAT,
  num_caras SMALLINT,
  ubicacion TEXT,
  numext_ubic INT,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  vigente TEXT,
  espubic TEXT,
  bloqueado SMALLINT,
  licencia INT,
  empresa INT,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.anuncio, l.propietario, a.descripcion, a.id_giro, a.zona, a.subzona, a.fecha_otorgamiento, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.vigente, a.espubic, a.bloqueado, a.licencia, a.empresa,
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) AS propietarionvo
    FROM anuncios a
    INNER JOIN licencias l ON l.id_licencia = a.licencia
    INNER JOIN c_giros c ON c.id_giro = a.id_giro
    WHERE a.anuncio IN (
      SELECT anuncio FROM anuncios_detgrupo WHERE anuncios_grupos_id = grupo_id
    )
    AND a.vigente = 'V'
    AND (
      filtro IS NULL OR filtro = '' OR
      c.descripcion ILIKE '%' || filtro || '%' OR
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) ILIKE '%' || filtro || '%'
    );
END;
$$ LANGUAGE plpgsql;