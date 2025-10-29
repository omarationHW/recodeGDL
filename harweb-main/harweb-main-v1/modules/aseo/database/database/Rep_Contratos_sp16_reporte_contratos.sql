-- Stored Procedure: sp16_reporte_contratos
-- Tipo: Report
-- Descripción: Reporte de solo contratos, con filtros y orden.
-- Generado para formulario: Rep_Contratos
-- Fecha: 2025-08-27 15:07:54

CREATE OR REPLACE FUNCTION sp16_reporte_contratos(
  p_empresa_id INTEGER,
  p_tipo_aseo_id INTEGER,
  p_vigencia TEXT,
  p_recaudadora_id INTEGER,
  p_orden TEXT
)
RETURNS TABLE(
  num_contrato INTEGER, ctrol_aseo INTEGER, tipo_aseo TEXT, des_aseo TEXT, ctrol_recolec INTEGER, cve_recolec TEXT, des_recolec TEXT,
  cantidad_recolec SMALLINT, domicilio TEXT, sector TEXT, ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, des_zona TEXT,
  id_rec SMALLINT, recaudadora TEXT, fecha_hora_alta TIMESTAMP, status_vigencia TEXT, aso_mes_oblig DATE, cve TEXT, usuario INTEGER, fecha_hora_baja TIMESTAMP,
  num_empresa INTEGER, ctrol_emp INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, C.ctrol_recolec, E.cve_recolec, E.descripcion,
         C.cantidad_recolec, C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
         C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja,
         C.num_empresa, C.ctrol_emp
  FROM ta_16_contratos C
  JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE (p_empresa_id IS NULL OR C.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR C.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR C.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR C.id_rec = p_recaudadora_id)
  ORDER BY CASE WHEN p_orden = 'ctrol_aseo,num_contrato' THEN C.ctrol_aseo END, CASE WHEN p_orden = 'num_contrato,ctrol_aseo' THEN C.num_contrato END;
END;
$$ LANGUAGE plpgsql;