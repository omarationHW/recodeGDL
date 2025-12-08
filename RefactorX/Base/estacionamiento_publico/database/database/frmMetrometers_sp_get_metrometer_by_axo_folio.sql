-- Stored Procedure: sp_get_metrometer_by_axo_folio
-- Tipo: Catalog
-- Descripción: Obtiene un registro de ta14_adicional_mmeters por axo y folio.
-- Generado para formulario: frmMetrometers
-- Fecha: 2025-08-27 13:37:50
-- Fix: Alias para evitar ambiguedad

DROP FUNCTION IF EXISTS sp_get_metrometer_by_axo_folio(integer, integer);

CREATE OR REPLACE FUNCTION sp_get_metrometer_by_axo_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    out_axo smallint,
    out_folio integer,
    direccion varchar(100),
    poslong varchar(30),
    poslat varchar(30),
    marca varchar(30),
    modelo varchar(30),
    linkfoto1 varchar(100),
    linkfoto2 varchar(100),
    motivo varchar(250),
    idmedio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.axo, t.folio, t.direccion, t.poslong, t.poslat, t.marca, t.modelo, t.linkfoto1, t.linkfoto2, t.motivo, t.idmedio
    FROM ta14_adicional_mmeters t
    WHERE t.axo = p_axo AND t.folio = p_folio;
END;
$$ LANGUAGE plpgsql;