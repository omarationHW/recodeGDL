-- Stored Procedure: rptreq_merc_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene la información de la recaudadora y zona asociada.
-- Generado para formulario: RptReq_Merc
-- Fecha: 2025-08-27 15:08:39

CREATE OR REPLACE FUNCTION rptreq_merc_recaudadora(
    p_reca smallint
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar(34),
    domicilio varchar(34),
    tel varchar(15),
    recaudador varchar(34),
    sector varchar(1),
    recing smallint,
    nomre varchar(60),
    id_zona_1 integer,
    zona varchar(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona as id_zona_1, c.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN padron_licencias.comun.ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;