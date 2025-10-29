-- Stored Procedure: requerimientos.get_multas_grid
-- Tipo: Report
-- Descripción: Obtiene el grid de multas agrupadas por zona/subzona para asignación.
-- Generado para formulario: ipor
-- Fecha: 2025-08-27 12:29:04

CREATE OR REPLACE FUNCTION requerimientos.get_multas_grid(tipo text, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    zona_sub varchar,
    cantidad integer,
    ejecutor_id integer,
    asignar integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT zona || '/' || subzona as zona_sub, count(*) as cantidad, NULL::integer as ejecutor_id, NULL::integer as asignar
    FROM reqmultas
    WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND tipo = tipo AND vigencia = 'V'
    GROUP BY zona, subzona;
END;
$$ LANGUAGE plpgsql;