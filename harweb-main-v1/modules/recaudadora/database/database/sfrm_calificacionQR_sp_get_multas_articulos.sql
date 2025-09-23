-- Stored Procedure: sp_get_multas_articulos
-- Tipo: Report
-- Descripción: Obtiene los artículos relacionados a una multa
-- Generado para formulario: sfrm_calificacionQR
-- Fecha: 2025-08-27 15:42:11

CREATE OR REPLACE FUNCTION sp_get_multas_articulos(p_id_multa integer)
RETURNS TABLE (
    id_ley smallint,
    art_reg varchar,
    fracc_reg varchar,
    num_reg varchar,
    inciso_reg varchar,
    art_ley varchar,
    fracc_ley varchar,
    num_ley varchar,
    inciso_ley varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ley, art_reg, fracc_reg, num_reg, inciso_reg, art_ley, fracc_ley, num_ley, inciso_ley
    FROM multas_articulos
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;