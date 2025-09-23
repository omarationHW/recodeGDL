-- Stored Procedure: sp_tramite_baja_lic
-- Tipo: CRUD
-- Descripción: Tramita la baja de una licencia, calcula importes y registra el folio
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-26 18:22:43

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic(
  p_licencia integer,
  p_motivo varchar,
  p_usuario varchar,
  p_baja_admva date
) RETURNS TABLE(folio integer, axo integer, licencia integer, total numeric) AS $$
DECLARE
  v_id_licencia integer := p_licencia;
  v_axo integer := EXTRACT(YEAR FROM CURRENT_DATE);
  v_folio integer;
  v_formas numeric := 0;
  v_derechos numeric := 0;
  v_gastos numeric := 0;
  v_multa numeric := 0;
  v_total numeric := 0;
  v_axo_min integer := 0;
  v_axo_max integer := 0;
  v_param_solicitud numeric := 0;
  v_gastoslic numeric := 0;
BEGIN
  -- Conseguir siguiente folio
  SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_tramitebaja WHERE axo = v_axo;
  -- Calcular importes
  SELECT COALESCE(SUM(formas),0), COALESCE(SUM(derechos),0), MIN(axo), MAX(axo)
    INTO v_formas, v_derechos, v_axo_min, v_axo_max
    FROM detsal_lic WHERE id_licencia = v_id_licencia AND cvepago = 0;
  -- Gastos y multa
  SELECT COALESCE(SUM(gastos),0) INTO v_gastos FROM detsal_lic WHERE id_licencia = v_id_licencia AND cvepago = 0;
  IF v_derechos > 0 THEN
    v_multa := 14844.00;
  ELSE
    v_multa := 7422.00;
  END IF;
  -- Costo solicitud
  SELECT costo_solicitud INTO v_param_solicitud FROM parametros_lic LIMIT 1;
  v_total := v_param_solicitud + v_formas + v_gastos + v_multa;
  -- Insertar folio
  INSERT INTO lic_tramitebaja(axo, folio, licencia, anuncio, axo_min, axo_max, motivo, imp_solicitud, imp_formas, imp_gastos, imp_multa, total, cvepago, vigencia, usuario, fecha, baja_admva)
  VALUES (v_axo, v_folio, v_id_licencia, 0, v_axo_min, v_axo_max, p_motivo, v_param_solicitud, v_formas, v_gastos, v_multa, v_total, 0, 'V', p_usuario, NOW(), p_baja_admva)
  RETURNING folio, axo, licencia, total;
END;
$$ LANGUAGE plpgsql;