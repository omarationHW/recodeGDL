-- Stored Procedure: sp_tramite_baja_lic_consulta
-- Tipo: CRUD
-- Descripción: Consulta todos los datos necesarios para el formulario de baja de licencia, incluyendo adeudos y trámites realizados.
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-27 19:47:43

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