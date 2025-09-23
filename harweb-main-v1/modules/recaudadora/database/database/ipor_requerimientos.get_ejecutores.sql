-- Stored Procedure: requerimientos.get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene la lista de ejecutores disponibles para una recaudadora y fecha.
-- Generado para formulario: ipor
-- Fecha: 2025-08-27 12:29:04

CREATE OR REPLACE FUNCTION requerimientos.get_ejecutores(fecha date, recaud integer)
RETURNS TABLE(
    cveejecutor integer,
    ncompleto varchar,
    asignar integer,
    ultfec_entrega date
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveejecutor, (paterno || ' ' || materno || ' ' || nombres) as ncompleto, asignados as asignar, ultfec_entrega
    FROM ejecutor
    WHERE recaud = $2 AND (vigencia = 'V' OR vigencia IS NULL);
END;
$$ LANGUAGE plpgsql;