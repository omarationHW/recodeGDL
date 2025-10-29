-- Stored Procedure: sp_get_remesas
-- Tipo: Report
-- Descripción: Obtiene la lista de remesas filtradas por tipo (A, B, C, D), ordenadas por num_remesa descendente.
-- Generado para formulario: ConsRemesas
-- Fecha: 2025-08-27 13:30:41

CREATE OR REPLACE FUNCTION sp_get_remesas(tipo_param character varying)
RETURNS TABLE (
    control integer,
    tipo character varying,
    fecha_inicio date,
    fecha_fin date,
    fecha_hoy date,
    num_remesa integer,
    cant_reg integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg
    FROM ta14_bitacora
    WHERE tipo = tipo_param
    ORDER BY num_remesa DESC;
END;
$$ LANGUAGE plpgsql;