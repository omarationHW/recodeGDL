-- Stored Procedure: sp_get_tianguis
-- Tipo: Catalog
-- Descripción: Obtiene los datos del tianguis para locales con num_mercado=214
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_tianguis(p_folio INTEGER)
RETURNS TABLE (
    Folio INTEGER,
    Nombre VARCHAR(132),
    Domicilio VARCHAR(60),
    Colonia VARCHAR(40),
    Poblacion VARCHAR(11),
    Superficie FLOAT,
    Giro VARCHAR(40),
    Descuento FLOAT,
    MotivoDescuento VARCHAR(13)
) AS $$
BEGIN
    RETURN QUERY
    SELECT Folio, Nombre, Domicilio, Colonia, Poblacion, Superficie, Giro, Descuento, MotivoDescuento
    FROM cobrotrimestral
    WHERE Folio = p_folio;
END;
$$ LANGUAGE plpgsql;