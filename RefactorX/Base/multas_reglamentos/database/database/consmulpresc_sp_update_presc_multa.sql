-- Stored Procedure: sp_update_presc_multa
-- Tipo: CRUD
-- Descripción: Actualiza una prescripción de multa existente.
-- Generado para formulario: consmulpresc
-- Fecha: 2025-08-26 23:33:22

CREATE OR REPLACE FUNCTION sp_update_presc_multa(
    p_id_prescri INTEGER,
    p_fecaut DATE,
    p_fecha_prescri DATE,
    p_oficio VARCHAR,
    p_capturista VARCHAR,
    p_dependencia VARCHAR,
    p_observaciones TEXT
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
BEGIN
    UPDATE presc_multas SET
        fecaut = p_fecaut,
        fecha_prescri = p_fecha_prescri,
        oficio = p_oficio,
        capturista = p_capturista,
        dependencia = p_dependencia,
        observaciones = p_observaciones
    WHERE id_prescri = p_id_prescri;
    RETURN QUERY SELECT id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa
    FROM presc_multas WHERE id_prescri = p_id_prescri;
END;
$$ LANGUAGE plpgsql;