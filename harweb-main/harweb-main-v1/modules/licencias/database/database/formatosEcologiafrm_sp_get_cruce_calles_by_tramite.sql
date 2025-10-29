-- Stored Procedure: sp_get_cruce_calles_by_tramite
-- Tipo: Report
-- Descripción: Obtiene los nombres de las calles cruzadas para un trámite dado.
-- Generado para formulario: formatosEcologiafrm
-- Fecha: 2025-08-26 16:29:50

CREATE OR REPLACE FUNCTION sp_get_cruce_calles_by_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    calle VARCHAR,
    calle_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.calle, c.calle AS calle_1
    FROM crucecalles a
    JOIN c_calles b ON b.cvecalle = a.cvecalle1
    JOIN c_calles c ON c.cvecalle = a.cvecalle2
    WHERE a.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;