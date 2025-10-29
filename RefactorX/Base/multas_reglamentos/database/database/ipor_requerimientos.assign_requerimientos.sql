-- Stored Procedure: requerimientos.assign_requerimientos
-- Tipo: CRUD
-- Descripción: Asigna requerimientos a ejecutores según tipo, ejecutor, fecha, recaudadora y rango de folios.
-- Generado para formulario: ipor
-- Fecha: 2025-08-27 12:29:04

CREATE OR REPLACE FUNCTION requerimientos.assign_requerimientos(tipo text, ejecutor_id integer, fecha date, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    asignados integer,
    mensaje text
) AS $$
DECLARE
    n_asignados integer := 0;
BEGIN
    IF tipo = 'predial' THEN
        UPDATE reqpredial
        SET cveejecut = ejecutor_id, fecejec = fecha
        WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND cveejecut IS NULL;
        GET DIAGNOSTICS n_asignados = ROW_COUNT;
        RETURN QUERY SELECT n_asignados, 'Asignados a ejecutor ' || ejecutor_id;
    ELSIF tipo = 'multas' THEN
        UPDATE reqmultas
        SET cveejecut = ejecutor_id, fecejec = fecha
        WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND cveejecut IS NULL;
        GET DIAGNOSTICS n_asignados = ROW_COUNT;
        RETURN QUERY SELECT n_asignados, 'Asignados a ejecutor ' || ejecutor_id;
    -- Agregar lógica para licencias, anuncios, diferencias si aplica
    ELSE
        RETURN QUERY SELECT 0, 'Tipo no soportado';
    END IF;
END;
$$ LANGUAGE plpgsql;