-- Stored Procedure: sp_get_prescripcion
-- Tipo: Report
-- Descripción: Obtiene la prescripción por id_prescri
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

CREATE OR REPLACE FUNCTION sp_get_prescripcion(p_id_prescri INTEGER)
RETURNS TABLE (
    id_prescri INTEGER,
    id_multa INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio TEXT,
    capturista TEXT,
    dependencia TEXT,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id_prescri, id_multa, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones
    FROM presc_multas WHERE id_prescri = p_id_prescri;
END;
$$ LANGUAGE plpgsql;