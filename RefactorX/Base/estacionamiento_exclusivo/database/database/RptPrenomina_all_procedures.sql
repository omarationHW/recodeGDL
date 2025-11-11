-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPrenomina
-- Generado: 2025-08-27 14:58:17
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_prenomina
-- Tipo: Report
-- Descripción: Devuelve el listado de pagos a ejecutores de la oficina, agrupado por zona, ejecutor, RFC, nombre, recaudadora y zona_1, con sumas de importe_pago y conteo de requerimientos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_prenomina(
    fec1 DATE,
    fec2 DATE,
    recaud SMALLINT,
    recaud1 SMALLINT
)
RETURNS TABLE (
    zona SMALLINT,
    ejecutor SMALLINT,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    gastos NUMERIC(18,2),
    cuantos FLOAT,
    recaudadora VARCHAR(32),
    zona_1 VARCHAR(32)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.zona,
        a.ejecutor,
        b.ini_rfc,
        b.fec_rfc,
        b.hom_rfc,
        b.nombre,
        SUM(a.importe_pago) AS gastos,
        COUNT(*) AS cuantos,
        c.recaudadora,
        d.zona AS zona_1
    FROM ta_15_apremios a
    JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje
    JOIN padron_licencias.comun.ta_12_recaudadoras c ON a.zona = c.id_rec AND b.id_rec = c.id_rec
    JOIN padron_licencias.comun.ta_12_zonas d ON c.id_zona = d.id_zona
    WHERE (a.fecha_pago >= fec1 AND a.fecha_pago <= fec2)
      AND (a.vigencia = '2' OR a.vigencia = 'P')
      AND a.clave_practicado = 'P'
      AND (b.id_rec >= recaud AND b.id_rec <= recaud1)
    GROUP BY a.zona, a.ejecutor, b.ini_rfc, b.fec_rfc, b.hom_rfc, b.nombre, c.recaudadora, d.zona
    ORDER BY a.zona, a.ejecutor;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_prenomina_totals
-- Tipo: Report
-- Descripción: Devuelve los totales del reporte de prenomina: total de gastos, total de gastos al 75%, total requerimientos, totales por ejecutor y sistema.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_prenomina_totals(
    fec1 DATE,
    fec2 DATE,
    recaud SMALLINT,
    recaud1 SMALLINT
)
RETURNS TABLE (
    total_gastos NUMERIC(18,2),
    total_gastos_75 NUMERIC(18,2),
    total_cuantos INTEGER,
    total_gastos_sistema NUMERIC(18,2),
    total_gastos_ejecutor NUMERIC(18,2),
    total_cuantos_sistema INTEGER,
    total_cuantos_ejecutor INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(gastos) AS total_gastos,
        SUM(gastos) * 0.75 AS total_gastos_75,
        SUM(cuantos)::INTEGER AS total_cuantos,
        SUM(CASE WHEN ejecutor > 990 THEN gastos ELSE 0 END) AS total_gastos_sistema,
        SUM(CASE WHEN ejecutor < 990 THEN gastos ELSE 0 END) AS total_gastos_ejecutor,
        SUM(CASE WHEN ejecutor > 990 THEN cuantos ELSE 0 END)::INTEGER AS total_cuantos_sistema,
        SUM(CASE WHEN ejecutor < 990 THEN cuantos ELSE 0 END)::INTEGER AS total_cuantos_ejecutor
    FROM rpt_prenomina(fec1, fec2, recaud, recaud1);
END;
$$ LANGUAGE plpgsql;

-- ============================================

