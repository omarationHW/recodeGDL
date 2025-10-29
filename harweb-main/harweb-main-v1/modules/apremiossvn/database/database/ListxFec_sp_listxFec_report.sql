-- Stored Procedure: sp_listxFec_report
-- Tipo: Report
-- Descripción: Reporte principal de ListxFec por fechas, modulo, vigencia y ejecutor
-- Generado para formulario: ListxFec
-- Fecha: 2025-08-27 20:48:46

CREATE OR REPLACE FUNCTION sp_listxFec_report(
  p_rec INT,
  p_modulo INT,
  p_tipo_fecha INT, -- 1: actualiz, 2: practicado, 3: citado, 4: pago, 5: emision, 6: entrega
  p_fecha1 DATE,
  p_fecha2 DATE,
  p_vigencia VARCHAR,
  p_ejecutor VARCHAR
)
RETURNS TABLE(
  folio INT,
  fecha DATE,
  ejecutor_nombre VARCHAR,
  vigencia VARCHAR,
  importe_global NUMERIC,
  datos VARCHAR
) AS $$
DECLARE
  v_sql TEXT;
BEGIN
  v_sql := 'SELECT a.folio, ';
  CASE p_tipo_fecha
    WHEN 1 THEN v_sql := v_sql || 'a.fecha_actualiz AS fecha, '
    WHEN 2 THEN v_sql := v_sql || 'a.fecha_practicado AS fecha, '
    WHEN 3 THEN v_sql := v_sql || 'a.fecha_citatorio AS fecha, '
    WHEN 4 THEN v_sql := v_sql || 'a.fecha_pago AS fecha, '
    WHEN 5 THEN v_sql := v_sql || 'a.fecha_emision AS fecha, '
    WHEN 6 THEN v_sql := v_sql || 'a.fecha_entrega1 AS fecha, '
    ELSE v_sql := v_sql || 'a.fecha_actualiz AS fecha, '
  END CASE;
  v_sql := v_sql || 'b.nombre AS ejecutor_nombre, a.vigencia, a.importe_global, '
    || 'COALESCE(a.datos, '''') AS datos '
    || 'FROM ta_15_apremios a '
    || 'LEFT JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec '
    || 'WHERE a.zona = $1 ';
  IF p_modulo IS NOT NULL AND p_modulo <> 99 THEN
    v_sql := v_sql || 'AND a.modulo = $2 ';
  END IF;
  IF p_vigencia IS NOT NULL AND p_vigencia <> 'todas' THEN
    IF p_vigencia = '2' THEN
      v_sql := v_sql || 'AND (a.vigencia = ''2'' OR a.vigencia = ''P'') ';
    ELSE
      v_sql := v_sql || 'AND a.vigencia = $3 ';
    END IF;
  END IF;
  IF p_ejecutor IS NOT NULL AND p_ejecutor <> 'todos' AND p_ejecutor <> 'ninguno' THEN
    v_sql := v_sql || 'AND a.ejecutor = $4 ';
  END IF;
  -- Fecha filtro
  CASE p_tipo_fecha
    WHEN 1 THEN v_sql := v_sql || 'AND a.fecha_actualiz BETWEEN $5 AND $6 ';
    WHEN 2 THEN v_sql := v_sql || 'AND a.fecha_practicado BETWEEN $5 AND $6 ';
    WHEN 3 THEN v_sql := v_sql || 'AND a.fecha_citatorio BETWEEN $5 AND $6 ';
    WHEN 4 THEN v_sql := v_sql || 'AND a.fecha_pago BETWEEN $5 AND $6 ';
    WHEN 5 THEN v_sql := v_sql || 'AND a.fecha_emision BETWEEN $5 AND $6 ';
    WHEN 6 THEN v_sql := v_sql || 'AND a.fecha_entrega1 BETWEEN $5 AND $6 ';
    ELSE v_sql := v_sql || 'AND a.fecha_actualiz BETWEEN $5 AND $6 ';
  END CASE;
  v_sql := v_sql || 'ORDER BY a.folio';
  RETURN QUERY EXECUTE v_sql
    USING p_rec, p_modulo, p_vigencia, p_ejecutor, p_fecha1, p_fecha2;
END;
$$ LANGUAGE plpgsql;