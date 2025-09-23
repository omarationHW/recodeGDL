-- Stored Procedure: sp_get_tianguis_info
-- Tipo: Catalog
-- Descripción: Obtiene información del folio del Tianguis Cultural desde la tabla cobrotrimestral.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 23:03:00

CREATE OR REPLACE FUNCTION sp_get_tianguis_info(
    p_folio INTEGER
) RETURNS TABLE(
    folio INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    poblacion VARCHAR,
    superficie NUMERIC,
    giro VARCHAR,
    descuento NUMERIC,
    motivo_descuento VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        "Folio", "Nombre", "Domicilio", "Colonia", "Poblacion", "Superficie", "Giro", "Descuento", "MotivoDescuento"
    FROM cobrotrimestral
    WHERE "Folio" = p_folio;
END;
$$ LANGUAGE plpgsql;