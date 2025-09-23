-- Stored Procedure: sp_get_presc_multa
-- Tipo: Catalog
-- Descripción: Obtiene una prescripción de multa por id.
-- Generado para formulario: consmulpresc
-- Fecha: 2025-08-26 23:33:22

CREATE OR REPLACE FUNCTION sp_get_presc_multa(p_id_prescri INTEGER)
RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio VARCHAR,
    capturista VARCHAR,
    dependencia VARCHAR,
    observaciones TEXT,
    id_multa INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa
    FROM presc_multas WHERE id_prescri = p_id_prescri;
END;
$$ LANGUAGE plpgsql;