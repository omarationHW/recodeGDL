-- Stored Procedure: rptrecup_aseo_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora para la oficina/ofna dada.
-- Generado para formulario: RptRecup_Aseo
-- Fecha: 2025-08-27 15:00:57

CREATE OR REPLACE FUNCTION rptrecup_aseo_recaudadora(
    p_ofna integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar,
    domicilio varchar,
    tel varchar,
    recaudador varchar,
    sector varchar,
    recing smallint,
    nomre varchar,
    id_zona_1 integer,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona as id_zona_1, c.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN padron_licencias.comun.ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = p_ofna;
END;
$$ LANGUAGE plpgsql;