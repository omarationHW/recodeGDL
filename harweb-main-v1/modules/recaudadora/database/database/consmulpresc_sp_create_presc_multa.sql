-- Stored Procedure: sp_create_presc_multa
-- Tipo: CRUD
-- Descripción: Crea una nueva prescripción de multa.
-- Generado para formulario: consmulpresc
-- Fecha: 2025-08-26 23:33:22

CREATE OR REPLACE FUNCTION sp_create_presc_multa(
    p_fecaut DATE,
    p_fecha_prescri DATE,
    p_oficio VARCHAR,
    p_capturista VARCHAR,
    p_dependencia VARCHAR,
    p_observaciones TEXT,
    p_id_multa INTEGER
) RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio VARCHAR,
    capturista VARCHAR,
    dependencia VARCHAR,
    observaciones TEXT,
    id_multa INTEGER
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO presc_multas (fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa)
    VALUES (p_fecaut, p_fecha_prescri, p_oficio, p_capturista, p_dependencia, p_observaciones, p_id_multa)
    RETURNING id_prescri INTO new_id;
    RETURN QUERY SELECT id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa
    FROM presc_multas WHERE id_prescri = new_id;
END;
$$ LANGUAGE plpgsql;