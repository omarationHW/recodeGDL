-- Stored Procedure: sp16_reporte_empresa_contratos
-- Tipo: Report
-- Descripción: Reporte de empresas y sus contratos (cabecera + detalle).
-- Generado para formulario: Rep_Contratos
-- Fecha: 2025-08-27 15:07:54

CREATE OR REPLACE FUNCTION sp16_reporte_empresa_contratos(
  p_empresa_id INTEGER,
  p_tipo_aseo_id INTEGER,
  p_vigencia TEXT,
  p_recaudadora_id INTEGER,
  p_orden TEXT
)
RETURNS TABLE(
  num_empresa INTEGER, ctrol_emp INTEGER, nom_empresa TEXT, representante TEXT, tipo_empresa TEXT,
  tipo_aseo TEXT, des_aseo TEXT, num_contrato INTEGER, domicilio TEXT, cantidad_recolec SMALLINT, des_recolec TEXT, id_rec SMALLINT, sector TEXT, ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, aso_mes_oblig DATE, fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante, b.descripcion,
         d.tipo_aseo, d.descripcion, c.num_contrato, c.domicilio, c.cantidad_recolec, e.descripcion, c.id_rec, c.sector, c.ctrol_zona, f.zona, f.sub_zona, c.aso_mes_oblig, c.fecha_hora_baja
  FROM ta_16_empresas a
  JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  JOIN ta_16_contratos c ON c.num_empresa = a.num_empresa AND c.ctrol_emp = a.ctrol_emp
  JOIN ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
  JOIN ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
  JOIN ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
  WHERE (p_empresa_id IS NULL OR a.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR c.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR c.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR c.id_rec = p_recaudadora_id)
  ORDER BY CASE WHEN p_orden = 'ctrol_emp,num_empresa' THEN a.ctrol_emp END, CASE WHEN p_orden = 'num_empresa,ctrol_emp' THEN a.num_empresa END, c.num_contrato;
END;
$$ LANGUAGE plpgsql;