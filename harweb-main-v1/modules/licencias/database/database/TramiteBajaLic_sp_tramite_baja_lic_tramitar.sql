-- Stored Procedure: sp_tramite_baja_lic_tramitar
-- Tipo: CRUD
-- Descripción: Realiza el trámite de baja de licencia, calcula importes, inserta registro en lic_tramitebaja y retorna los datos del trámite.
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-27 19:47:43

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