-- Stored Procedure: sp_ingreso_zonificado
-- Tipo: Report
-- Descripción: Obtiene el ingreso global por zona entre dos fechas, sumando ingresos y ajustes.
-- Generado para formulario: RptIngresoZonificado
-- Fecha: 2025-08-27 01:08:18

CREATE OR REPLACE FUNCTION sp_ingreso_zonificado(fecdesde DATE, fechasta DATE)
RETURNS TABLE(id_zona INT, zona TEXT, pagado NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id_zona, UPPER(d.zona) AS zona, SUM(b.importe_cta) AS pagado
    FROM ta_12_ingreso a
    JOIN ta_12_importes b ON b.fecing = a.fecing AND b.recing = a.recing AND b.cajing = a.cajing AND b.opcaja = a.opcaja
    JOIN ta_11_mercados c ON c.cuenta_ingreso = b.cta_aplicacion
    JOIN ta_12_zonas d ON d.id_zona = c.id_zona
   WHERE a.fecing BETWEEN fecdesde AND fechasta
     AND c.num_mercado_nvo NOT IN (99,214)
     AND ((b.cta_aplicacion BETWEEN 44501 AND 44588) OR (b.cta_aplicacion = 44119))
   GROUP BY c.id_zona, d.zona

  UNION

  SELECT f.id_zona, UPPER(g.zona) AS zona, SUM(e.importe_ajuste) AS pagado
    FROM ta_11_mercados f
    JOIN ta_12_zonas g ON g.id_zona = f.id_zona
    JOIN ta_12_ajustes e ON e.cta_aplicacion = f.cuenta_ingreso
   WHERE e.fecha_ajuste BETWEEN fecdesde AND fechasta
     AND ((e.cta_aplicacion BETWEEN 44501 AND 44588) OR (e.cta_aplicacion = 44119))
   GROUP BY f.id_zona, g.zona;
END;
$$ LANGUAGE plpgsql;