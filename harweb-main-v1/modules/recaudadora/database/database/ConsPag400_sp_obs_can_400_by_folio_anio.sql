-- Stored Procedure: sp_obs_can_400_by_folio_anio
-- Tipo: Report
-- Descripción: Obtiene los registros de obs_can_400 filtrando por tofol (folio) y toafol (año).
-- Generado para formulario: ConsPag400
-- Fecha: 2025-08-26 23:38:10

CREATE OR REPLACE FUNCTION sp_obs_can_400_by_folio_anio(
    p_tfol integer,
    p_tafol smallint
)
RETURNS TABLE (
    tofol integer,
    toafol smallint,
    torec smallint,
    tocta integer,
    toncta smallint,
    toimpde float,
    tobser1 varchar,
    tobser2 varchar,
    tobser3 varchar,
    tobser4 varchar,
    tcapt varchar,
    tfech integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM obs_can_400
    WHERE tofol = p_tfol AND toafol = p_tafol;
END;
$$ LANGUAGE plpgsql;