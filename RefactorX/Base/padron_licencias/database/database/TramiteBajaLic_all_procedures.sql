-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TramiteBajaLic
-- Generado: 2025-08-27 19:47:43
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_tramite_baja_lic_consulta
-- Tipo: CRUD
-- Descripción: Consulta todos los datos necesarios para el formulario de baja de licencia, incluyendo adeudos y trámites realizados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_consulta(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
  v_adeudos JSON;
  v_tramites JSON;
BEGIN
  SELECT *,
    TRIM(COALESCE(primer_ap, '') || ' ' || COALESCE(segundo_ap, '') || ' ' || COALESCE(propietario, '')) AS propietarionvo
  INTO v_licencia
  FROM licencias
  WHERE licencia = p_licencia;

  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;

  SELECT json_agg(row_to_json(a))
    INTO v_adeudos
    FROM (
      SELECT axo, formas, derechos, recargos, gastos, multas, saldo
      FROM detsal_lic
      WHERE id_licencia = v_licencia.id_licencia AND (id_anuncio IS NULL OR id_anuncio = 0) AND cvepago = 0
      ORDER BY axo
    ) a;

  SELECT json_agg(row_to_json(t))
    INTO v_tramites
    FROM (
      SELECT axo, folio, motivo, baja_admva, total, usuario, fecha
      FROM lic_tramitebaja
      WHERE licencia = p_licencia
      ORDER BY fecha DESC
    ) t;

  RETURN json_build_object(
    'success', true,
    'propietarionvo', v_licencia.propietarionvo,
    'ubicacion', v_licencia.ubicacion,
    'actividad', v_licencia.actividad,
    'sup_construida', v_licencia.sup_construida,
    'sup_autorizada', v_licencia.sup_autorizada,
    'num_cajones', v_licencia.num_cajones,
    'num_empleados', v_licencia.num_empleados,
    'vigente', v_licencia.vigente,
    'adeudos', COALESCE(v_adeudos, '[]'),
    'tramites', COALESCE(v_tramites, '[]')
  );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_tramite_baja_lic_tramitar
-- Tipo: CRUD
-- Descripción: Realiza el trámite de baja de licencia, calcula importes, inserta registro en lic_tramitebaja y retorna los datos del trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_tramitar(
  p_licencia INTEGER,
  p_motivo TEXT,
  p_baja_admva DATE,
  p_usuario TEXT
) RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
  v_parametros RECORD;
  v_adeudos RECORD;
  v_folio INTEGER;
  v_axo INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
  v_formas NUMERIC := 0;
  v_derechos NUMERIC := 0;
  v_gastos NUMERIC := 0;
  v_multa NUMERIC := 0;
  v_total NUMERIC := 0;
  v_axo_min INTEGER := 0;
  v_axo_max INTEGER := 0;
BEGIN
  SELECT * INTO v_licencia FROM licencias WHERE licencia = p_licencia;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;
  SELECT * INTO v_parametros FROM parametros_lic LIMIT 1;

  -- Sumar adeudos
  FOR v_adeudos IN SELECT * FROM spget_lic_adeudos(v_licencia.id_licencia, 'L') LOOP
    IF v_axo_min = 0 THEN v_axo_min := v_adeudos.axo; END IF;
    v_formas := v_formas + v_adeudos.formas;
    v_derechos := v_derechos + v_adeudos.derechos;
    v_axo_max := v_adeudos.axo;
  END LOOP;

  -- Gastos y multa
  SELECT gastos, multas FROM get_gastoslic(v_licencia.id_licencia) INTO v_gastos, v_multa;
  IF v_derechos > 0 THEN
    v_multa := 14844.00;
  ELSE
    v_multa := 7422.00;
  END IF;
  v_total := COALESCE(v_parametros.costo_solicitud,0) + v_formas + v_gastos + v_multa;

  -- Folio
  SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_tramitebaja WHERE axo = v_axo;

  INSERT INTO lic_tramitebaja(axo, folio, licencia, anuncio, motivo, axo_min, axo_max, imp_solicitud, imp_formas, imp_gastos, imp_multa, total, cvepago, vigencia, usuario, fecha, baja_admva)
  VALUES (v_axo, v_folio, v_licencia.licencia, 0, p_motivo, v_axo_min, v_axo_max, COALESCE(v_parametros.costo_solicitud,0), v_formas, v_gastos, v_multa, v_total, 0, 'V', p_usuario, NOW(), p_baja_admva)
  RETURNING *;

  RETURN json_build_object('success', true, 'folio', v_folio, 'total', v_total);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_tramite_baja_lic_recalcula
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de la licencia y actualiza los importes proporcionales según reglas de negocio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_recalcula(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
BEGIN
  SELECT * INTO v_licencia FROM licencias WHERE licencia = p_licencia;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;
  -- Aquí se puede llamar a un SP que recalcula los saldos proporcionales
  PERFORM calc_sdosl(v_licencia.id_licencia);
  RETURN json_build_object('success', true, 'message', 'Recalculo realizado');
END;
$$ LANGUAGE plpgsql;

-- ============================================

