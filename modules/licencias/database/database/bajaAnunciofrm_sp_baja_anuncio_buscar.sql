-- Stored Procedure: sp_baja_anuncio_buscar
-- Tipo: CRUD
-- Descripción: Busca el anuncio y sus adeudos, licencia relacionada y propietario.
-- Generado para formulario: bajaAnunciofrm
-- Fecha: 2025-08-27 15:56:52

CREATE OR REPLACE FUNCTION sp_baja_anuncio_buscar(p_anuncio INTEGER)
RETURNS TABLE (
  id_anuncio INTEGER,
  id_licencia INTEGER,
  fecha_otorgamiento DATE,
  propietario TEXT,
  propietarionvo TEXT,
  medidas1 NUMERIC,
  medidas2 NUMERIC,
  area_anuncio NUMERIC,
  ubicacion TEXT,
  numext_ubic TEXT,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  telefono_prop TEXT,
  vigente TEXT,
  adeudos JSONB
) AS $$
DECLARE
  v_adeudos JSONB;
BEGIN
  SELECT a.id_anuncio, a.id_licencia, a.fecha_otorgamiento, l.propietario,
         TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || l.propietario) AS propietarionvo,
         a.medidas1, a.medidas2, a.area_anuncio, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic,
         l.telefono_prop, a.vigente,
         (
           SELECT jsonb_agg(row_to_json(s)) FROM (
             SELECT axo, saldo FROM detsal_lic WHERE id_anuncio = a.id_anuncio AND cvepago = 0
           ) s
         ) AS adeudos
  INTO id_anuncio, id_licencia, fecha_otorgamiento, propietario, propietarionvo, medidas1, medidas2, area_anuncio, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, telefono_prop, vigente, v_adeudos
  FROM anuncios a
  LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
  WHERE a.anuncio = p_anuncio;
  adeudos := COALESCE(v_adeudos, '[]'::jsonb);
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;