-- Stored Procedure: rpt_catal_eje
-- Tipo: Report
-- Descripción: Obtiene el listado de ejecutores con datos de recaudadora y zona, filtrando por id_rec y vigencia.
-- Generado para formulario: RprtCATAL_EJE
-- Fecha: 2025-08-27 14:30:12

CREATE OR REPLACE FUNCTION rpt_catal_eje(p_id_rec integer, p_vigencia varchar)
RETURNS TABLE (
    id_ejecutor integer,
    cve_eje integer,
    ini_rfc varchar,
    fec_rfc date,
    hom_rfc varchar,
    nombre varchar,
    id_rec smallint,
    categoria varchar,
    observacion varchar,
    oficio varchar,
    fecinic date,
    fecterm date,
    vigencia varchar,
    recaudadora_1 varchar,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_ejecutor, a.cve_eje, a.ini_rfc, a.fec_rfc, a.hom_rfc, a.nombre, a.id_rec, a.categoria, a.observacion, a.oficio, a.fecinic, a.fecterm, a.vigencia,
           b.recaudadora_1, d.zona
    FROM ta_15_ejecutores a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    JOIN ta_12_zonas d ON b.id_zona = d.id_zona
    WHERE a.id_rec = p_id_rec
      AND (p_vigencia IS NULL OR p_vigencia = '' OR a.vigencia = p_vigencia)
    ORDER BY a.cve_eje;
END;
$$ LANGUAGE plpgsql;