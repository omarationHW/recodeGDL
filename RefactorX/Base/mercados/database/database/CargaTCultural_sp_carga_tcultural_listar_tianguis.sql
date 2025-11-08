-- Stored Procedure: sp_carga_tcultural_listar_tianguis
-- Tipo: Catalog
-- Descripción: Obtiene información de un folio del tianguis cultural.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 19:09:26

CREATE OR REPLACE FUNCTION sp_carga_tcultural_listar_tianguis(folio integer)
RETURNS TABLE(
    Folio integer,
    Nombre text,
    Domicilio text,
    Colonia text,
    Poblacion text,
    Superficie numeric,
    Giro text,
    Descuento numeric,
    MotivoDescuento text
) AS $$
BEGIN
    RETURN QUERY
    SELECT "Folio", "Nombre", "Domicilio", "Colonia", "Poblacion", "Superficie", "Giro", "Descuento", "MotivoDescuento"
    FROM cobrotrimestral
    WHERE "Folio" = folio;
END;
$$ LANGUAGE plpgsql;