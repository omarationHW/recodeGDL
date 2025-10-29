-- Stored Procedure: sp_consultar_detalle_tpat400
-- Tipo: Report
-- Descripción: Consulta detalle de transmisión patrimonial en transm_400 según filtros.
-- Generado para formulario: ConsTPat400
-- Fecha: 2025-08-26 23:45:50

CREATE OR REPLACE FUNCTION sp_consultar_detalle_tpat400(
    p_fecha integer,
    p_recaud smallint,
    p_caja varchar,
    p_folio smallint,
    p_lug varchar
)
RETURNS TABLE (
    fecha integer,
    recaud smallint,
    caja varchar,
    folio integer,
    lug varchar,
    importe float,
    imp1 float,
    cta_apli1 integer,
    imp2 float,
    cta_apli2 integer,
    imp3 float,
    cta_apli3 integer,
    imp4 float,
    cta_apli4 integer,
    imp5 float,
    cta_apli5 integer,
    imp6 float,
    cta_apli6 integer,
    imp7 float,
    cta_apli7 integer,
    imp8 float,
    ctaapli8 integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM transm_400
    WHERE fecha = p_fecha
      AND recaud = p_recaud
      AND caja = p_caja
      AND folio = p_folio
      AND lug = p_lug;
END;
$$ LANGUAGE plpgsql;