-- Stored Procedure: sqrp_publicos_report
-- Tipo: Report
-- Descripción: Genera el reporte de estacionamientos públicos con clasificaciones y totales.
-- Tabla: pubmain (961 registros) con pubcategoria
-- Fecha: 2025-12-06
-- Fix: Usar pubmain en lugar de ta_15_publicos (vacía)

DROP FUNCTION IF EXISTS sqrp_publicos_report(text);

CREATE OR REPLACE FUNCTION sqrp_publicos_report(p_order_by text)
RETURNS TABLE (
    cve_sector character(1),
    cve_categ varchar(10),
    cve_numero integer,
    nombre varchar(100),
    cupo integer
) AS $$
DECLARE
    v_sql text;
    v_order text;
BEGIN
    -- Validar y mapear el orden
    v_order := CASE
        WHEN p_order_by ILIKE '%categ%' THEN 'c.categoria, p.sector, p.numesta'
        WHEN p_order_by ILIKE '%nombre%' THEN 'p.nombre'
        ELSE 'p.sector, c.categoria, p.numesta'
    END;

    v_sql := '
    SELECT
        p.sector AS cve_sector,
        TRIM(c.categoria)::varchar(10) AS cve_categ,
        p.numesta AS cve_numero,
        TRIM(p.nombre)::varchar(100) AS nombre,
        COALESCE(p.cupo, 0) AS cupo
    FROM pubmain p
    LEFT JOIN pubcategoria c ON c.id = p.pubcategoria_id
    WHERE p.folio_baja IS NULL OR p.folio_baja = 0
    ORDER BY ' || v_order;

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;
