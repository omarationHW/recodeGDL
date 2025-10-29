-- Stored Procedure: sp_buscagiro_search
-- Tipo: Catalog
-- Descripción: Busca giros por descripción, tipo, permisos, autoevaluación y pacto.
-- Generado para formulario: buscagirofrm
-- Fecha: 2025-08-26 14:50:28

CREATE OR REPLACE FUNCTION sp_buscagiro_search(
    p_descripcion TEXT,
    p_tipo TEXT,
    p_usuario TEXT,
    p_autoev TEXT DEFAULT NULL,
    p_pacto TEXT DEFAULT NULL
) RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente TEXT,
    tipo TEXT
) AS $$
DECLARE
    v_giro_a TEXT;
    v_filtroClasificacion TEXT := '';
    v_extraFiltro TEXT := '';
BEGIN
    SELECT giro_a INTO v_giro_a FROM lic_permisos WHERE usuario = p_usuario AND id_permiso_catalogo = 2 LIMIT 1;
    IF v_giro_a IS NULL OR v_giro_a <> 'S' THEN
        v_filtroClasificacion := ' AND (a.clasificacion <> ''A'' OR a.clasificacion IS NULL) ';
    END IF;
    IF p_autoev = 'Autoevaluacion' THEN
        v_extraFiltro := v_extraFiltro || ' AND a.id_giro IN (SELECT id_giro FROM c_girosautoev) ';
    END IF;
    IF p_pacto = 'Pacto para homologar los requisitos' THEN
        v_extraFiltro := v_extraFiltro || ' AND a.clasificacion IN (''B'') ';
    END IF;
    RETURN QUERY EXECUTE format('
        SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente, a.tipo
        FROM c_giros a
        LEFT JOIN c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = $1
        WHERE a.id_giro > 500 AND a.vigente = ''V'' AND a.tipo = $2 AND a.descripcion ILIKE $3 AND a.id_giro NOT BETWEEN 5000 AND 99999 %s %s
        ORDER BY a.descripcion', v_filtroClasificacion, v_extraFiltro)
    USING extract(year from current_date), p_tipo, '%' || p_descripcion || '%';
END;
$$ LANGUAGE plpgsql;