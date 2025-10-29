-- Stored Procedure: sp_abcf_get_adicional
-- Tipo: CRUD
-- Descripción: Obtiene los datos adicionales de un folio.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE FUNCTION sp_abcf_get_adicional(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    rfc VARCHAR,
    curp VARCHAR,
    telefono VARCHAR,
    clave_ife VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT control_rcm, rfc, curp, telefono, clave_ife FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;