-- Stored Procedure: sp_get_ingreso_zonificado
-- Tipo: Report
-- Descripción: Obtiene el ingreso global por zonas en un rango de fechas
-- Generado para formulario: ListadosLocales
-- Fecha: 2025-08-27 00:08:33

CREATE OR REPLACE FUNCTION sp_get_ingreso_zonificado(p_fecha_desde DATE, p_fecha_hasta DATE)
RETURNS TABLE(
    id_zona INT,
    zona VARCHAR(50),
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_zona, z.zona, SUM(i.importe_cta) AS pagado
    FROM ta_12_ingreso a
    JOIN ta_12_importes i ON a.fecing = i.fecing AND a.recing = i.recing AND a.cajing = i.cajing AND a.opcaja = i.opcaja
    JOIN ta_11_mercados m ON i.cta_aplicacion = m.cuenta_ingreso
    JOIN ta_12_zonas z ON m.id_zona = z.id_zona
    WHERE a.fecing BETWEEN p_fecha_desde AND p_fecha_hasta
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
    GROUP BY m.id_zona, z.zona
    ORDER BY m.id_zona;
END;
$$ LANGUAGE plpgsql;