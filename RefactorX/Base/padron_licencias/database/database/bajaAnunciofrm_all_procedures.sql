-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: bajaAnunciofrm
-- Generado: 2025-08-27 15:56:52
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_baja_anuncio_buscar
-- Tipo: CRUD
-- Descripción: Busca el anuncio y sus adeudos, licencia relacionada y propietario.
-- --------------------------------------------

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

-- ============================================

-- SP 2/3: sp_baja_anuncio_verificar_permisos
-- Tipo: CRUD
-- Descripción: Verifica los permisos del usuario para dar de baja anuncios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_anuncio_verificar_permisos(p_usuario TEXT)
RETURNS TABLE (
  nivel SMALLINT,
  cvedependencia INTEGER,
  cvedepto INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT u.nivel, d.cvedependencia, u.cvedepto
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_baja_anuncio_procesar
-- Tipo: CRUD
-- Descripción: Realiza la baja del anuncio, cancela adeudos y recalcula saldos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_anuncio_procesar(
  p_anuncio INTEGER,
  p_motivo TEXT,
  p_axo_baja INTEGER,
  p_folio_baja INTEGER,
  p_usuario TEXT,
  p_baja_error BOOLEAN,
  p_baja_tiempo BOOLEAN,
  p_fecha TIMESTAMP
) RETURNS TABLE (result TEXT, status TEXT) AS $$
DECLARE
  v_vigente TEXT;
  v_id_licencia INTEGER;
BEGIN
  SELECT vigente, id_licencia INTO v_vigente, v_id_licencia FROM anuncios WHERE anuncio = p_anuncio;
  IF v_vigente IS NULL OR v_vigente <> 'V' THEN
    RETURN QUERY SELECT 'El anuncio ya se encuentra cancelado.', 'error';
    RETURN;
  END IF;
  -- Cancelar el anuncio
  UPDATE anuncios SET
    vigente = 'C',
    fecha_baja = p_fecha,
    axo_baja = p_axo_baja,
    folio_baja = p_folio_baja,
    espubic = p_motivo
  WHERE anuncio = p_anuncio;
  -- Cancelar adeudos
  UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = p_anuncio AND cvepago = 0;
  -- Recalcular saldo de la licencia
  PERFORM calc_sdosl(v_id_licencia);
  RETURN QUERY SELECT 'Baja realizada correctamente', 'ok';
END;
$$ LANGUAGE plpgsql;

-- ============================================

