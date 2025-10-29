-- Stored Procedure: sp_recaudadoras_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de recaudadoras ordenado según la opción seleccionada (1: id_rec, 2: recaudadora, 3: domicilio, 4: sector, id_rec).
-- Generado para formulario: sQRptRecaudadoras
-- Fecha: 2025-08-27 15:36:40

CREATE OR REPLACE FUNCTION sp_recaudadoras_report(opcion integer)
RETURNS TABLE (
    id_rec integer,
    recaudadora varchar,
    domicilio varchar,
    sector varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora, domicilio, sector
    FROM ta_12_recaudadoras
    ORDER BY
        CASE WHEN opcion = 1 THEN id_rec END ASC,
        CASE WHEN opcion = 2 THEN recaudadora END ASC,
        CASE WHEN opcion = 3 THEN domicilio END ASC,
        CASE WHEN opcion = 4 THEN sector END ASC,
        CASE WHEN opcion = 4 THEN id_rec END ASC;
END;
$$ LANGUAGE plpgsql;