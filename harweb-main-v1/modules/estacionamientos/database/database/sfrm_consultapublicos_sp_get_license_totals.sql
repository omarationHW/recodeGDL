-- Stored Procedure: sp_get_license_totals
-- Tipo: Report
-- Descripción: Obtiene los totales de una licencia (conceptos e importes).
-- Generado para formulario: sfrm_consultapublicos
-- Fecha: 2025-08-27 16:04:06

CREATE OR REPLACE FUNCTION sp_get_license_totals(id_licencia integer, tipo_l varchar, redon varchar)
RETURNS TABLE (
    cuenta integer,
    obliga varchar(1),
    concepto varchar(150),
    importe numeric(12,2),
    licanun integer
) AS $$
BEGIN
    -- Aquí debe ir la lógica de obtención de totales de licencia
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe, licanun
    FROM vw_licencias_totales
    WHERE id_licencia = id_licencia AND tipo_l = tipo_l AND redon = redon;
END;
$$ LANGUAGE plpgsql;