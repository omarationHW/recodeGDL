-- Stored Procedure: sp_rbaja_buscar_local
-- Tipo: Catalog
-- Descripción: Busca un local/concesión por número y letra, retorna todos los datos relevantes.
-- Generado para formulario: RBaja
-- Fecha: 2025-08-28 13:35:33

CREATE OR REPLACE FUNCTION sp_rbaja_buscar_local(p_numero VARCHAR, p_letra VARCHAR)
RETURNS TABLE (
    id_34_datos INTEGER,
    control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector VARCHAR,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad VARCHAR,
    cve_stat VARCHAR,
    descrip_stat VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad, c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3
      AND a.control = CONCAT(TRIM(p_numero), '-', TRIM(p_letra));
END;
$$ LANGUAGE plpgsql;