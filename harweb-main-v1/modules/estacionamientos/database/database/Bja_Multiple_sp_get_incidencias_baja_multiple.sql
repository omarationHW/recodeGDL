-- Stored Procedure: sp_get_incidencias_baja_multiple
-- Tipo: Report
-- Descripción: Devuelve los registros con error de validación (estatus = 9) para un archivo dado.
-- Generado para formulario: Bja_Multiple
-- Fecha: 2025-08-27 13:24:39

CREATE OR REPLACE FUNCTION sp_get_incidencias_baja_multiple(p_archivo VARCHAR)
RETURNS TABLE (
    placa VARCHAR,
    folio_archivo INTEGER,
    fecha_archivo VARCHAR,
    anomalia VARCHAR,
    referencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT placa, folio_archivo, fecha_archivo, anomalia, referencia
    FROM ta14_folios_baja_esta
    WHERE archivo = p_archivo AND estatus = 9;
END;
$$ LANGUAGE plpgsql;