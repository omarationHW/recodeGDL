-- Stored Procedure: sp_prueba_query
-- Tipo: Report
-- Descripción: Consulta contratos y tipo de aseo según parámetro de control.
-- Generado para formulario: Prueba
-- Fecha: 2025-08-27 15:03:39

-- PostgreSQL version of Query1
CREATE OR REPLACE FUNCTION sp_prueba_query(parCtrol INTEGER)
RETURNS TABLE(tipo_aseo VARCHAR, num_contrato INTEGER)
LANGUAGE sql AS $$
  SELECT b.tipo_aseo, a.num_contrato
  FROM ta_16_contratos a
  JOIN ta_16_tipo_aseo b ON b.ctrol_aseo = a.ctrol_aseo
  WHERE a.num_contrato >= 2120
    AND a.ctrol_aseo = parCtrol
  ORDER BY num_contrato;
$$;