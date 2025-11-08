-- Stored Procedure: sp_buscagiro_detalle
-- Tipo: Catalog
-- Descripción: Devuelve el detalle de un giro por ID.
-- Generado para formulario: buscagirofrm
-- Fecha: 2025-08-26 14:50:28

CREATE OR REPLACE FUNCTION sp_buscagiro_detalle(
    p_id_giro INTEGER
) RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente TEXT,
    tipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente, a.tipo
    FROM c_giros a
    LEFT JOIN c_valoreslic b ON a.id_giro = b.id_giro
    WHERE a.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;