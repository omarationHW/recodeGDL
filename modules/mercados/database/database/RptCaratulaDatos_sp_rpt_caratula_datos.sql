-- Stored Procedure: sp_rpt_caratula_datos
-- Tipo: Report
-- Descripción: Devuelve toda la información de la carátula de datos de un local, incluyendo adeudos y recargos calculados
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 00:44:44

CREATE OR REPLACE FUNCTION sp_rpt_caratula_datos(
  p_id_local INTEGER,
  p_renta NUMERIC,
  p_adeudo NUMERIC,
  p_recargos NUMERIC,
  p_gastos NUMERIC,
  p_multa NUMERIC,
  p_total NUMERIC,
  p_folios TEXT,
  p_leyenda TEXT
) RETURNS JSON AS $$
DECLARE
  local_row RECORD;
  adeudos_rows JSON;
BEGIN
  SELECT * INTO local_row FROM sp_get_locales_by_id(p_id_local) LIMIT 1;
  SELECT json_agg(row_to_json(a)) INTO adeudos_rows FROM sp_get_adeudos_by_local(p_id_local) a;
  RETURN json_build_object(
    'id_local', local_row.id_local,
    'nombre', local_row.nombre,
    'domicilio', local_row.domicilio,
    'sector', local_row.sector,
    'zona', local_row.zona,
    'descripcion_local', local_row.descripcion_local,
    'superficie', local_row.superficie,
    'giro', local_row.giro,
    'fecha_alta', local_row.fecha_alta,
    'vigdescripcion', local_row.vigdescripcion,
    'usuario', local_row.usuario,
    'renta', p_renta,
    'adeudo', p_adeudo,
    'recargos', p_recargos,
    'gastos', p_gastos,
    'multa', p_multa,
    'total', p_total,
    'folios', p_folios,
    'leyenda', p_leyenda,
    'adeudos', adeudos_rows
  );
END;
$$ LANGUAGE plpgsql;