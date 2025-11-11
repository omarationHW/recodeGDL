-- Stored Procedure: rptrecup_merc_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora, nombre y zona para la cabecera del reporte.
-- Generado para formulario: RptRecup_Merc
-- Fecha: 2025-08-27 15:03:18

CREATE OR REPLACE FUNCTION rptrecup_merc_recaudadora(
    p_reca SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(32),
    domicilio VARCHAR(32),
    tel VARCHAR(15),
    recaudador VARCHAR(32),
    sector VARCHAR(1),
    recing SMALLINT,
    nomre VARCHAR(60),
    id_zona_1 INTEGER,
    zona VARCHAR(2)
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