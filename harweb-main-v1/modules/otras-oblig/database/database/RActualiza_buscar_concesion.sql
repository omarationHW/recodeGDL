-- Stored Procedure: buscar_concesion
-- Tipo: Catalog
-- Descripción: Busca un local/concesión por su control (número-letra)
-- Generado para formulario: RActualiza
-- Fecha: 2025-08-28 13:26:50

CREATE OR REPLACE FUNCTION buscar_concesion(control TEXT)
RETURNS TABLE (
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    status TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nom_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT A.id_34_datos, A.control, A.concesionario, A.ubicacion, A.superficie, A.fecha_inicio, A.fecha_fin, A.id_recaudadora,
           A.sector, A.id_zona, A.licencia, Z.descripcion AS status, F.descripcion AS unidades,
           B.categoria, B.seccion, B.bloque, C.concepto AS nom_comercial, D.concepto AS lugar, E.concepto AS obs
    FROM t34_datos A
    LEFT JOIN t34_adicionales B ON B.id_datos = A.id_34_datos
    LEFT JOIN t34_conceptos C ON C.id_datos = A.id_34_datos AND C.tipo = 'N'
    LEFT JOIN t34_conceptos D ON D.id_datos = A.id_34_datos AND D.tipo = 'L'
    LEFT JOIN t34_conceptos E ON E.id_datos = A.id_34_datos AND E.tipo = 'O'
    JOIN t34_status Z ON Z.id_34_stat = A.id_stat
    JOIN t34_unidades F ON F.id_34_unidad = A.id_unidad
    WHERE A.control = control;
END;
$$ LANGUAGE plpgsql;