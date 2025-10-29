-- Stored Procedure: sp_list_presc_multas
-- Tipo: Catalog
-- Descripción: Lista todas las prescripciones de multas.
-- Generado para formulario: consmulpresc
-- Fecha: 2025-08-26 23:33:22

CREATE OR REPLACE FUNCTION sp_list_presc_multas()
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
    FROM presc_multas
    ORDER BY id_prescri DESC;
END;
$$ LANGUAGE plpgsql;