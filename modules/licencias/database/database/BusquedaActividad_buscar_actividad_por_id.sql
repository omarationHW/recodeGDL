-- Stored Procedure: buscar_actividad_por_id
-- Tipo: Catalog
-- Descripción: Obtiene una actividad específica por id_giro, incluyendo costo y refrendo del año actual.
-- Generado para formulario: BusquedaActividadFrm
-- Fecha: 2025-08-27 16:30:39

CREATE OR REPLACE FUNCTION buscar_actividad_por_id(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    vigente CHAR(1),
    axo INTEGER,
    costo NUMERIC,
    refrendo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cg.id_giro, cg.cod_giro, cg.descripcion, cg.vigente,
           cvl.axo, cvl.costo, cvl.refrendo
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = EXTRACT(YEAR FROM CURRENT_DATE)
    WHERE cg.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;