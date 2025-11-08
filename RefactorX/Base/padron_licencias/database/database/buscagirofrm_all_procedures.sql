-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: buscagirofrm
-- Generado: 2025-08-27 16:26:19
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_buscagiro_list
-- Tipo: Catalog
-- Descripción: Devuelve el listado de giros filtrados por descripción, tipo, autoevaluación, pacto y permisos del usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscagiro_list(
    p_descripcion TEXT,
    p_tipo CHAR(1),
    p_autoev CHAR(1),
    p_pacto CHAR(1),
    p_usuario TEXT,
    p_year INT
)
RETURNS TABLE (
    id_giro INT,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente
    FROM c_giros a
    LEFT JOIN c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = p_year
    WHERE a.tipo = p_tipo
      AND a.id_giro > 500
      AND a.vigente = 'V'
      AND (
        p_descripcion IS NULL OR p_descripcion = '' OR
        UPPER(a.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
      AND (
        (p_autoev = 'S' AND a.id_giro IN (SELECT id_giro FROM c_girosautoev)) OR
        (p_autoev = 'N')
      )
      AND (
        (p_pacto = 'S' AND a.clasificacion IN ('B')) OR
        (p_pacto = 'N')
      )
      AND (
        a.id_giro NOT BETWEEN 5000 AND 99999
      )
      AND (
        (
          SELECT giro_a FROM lic_permisos WHERE usuario = p_usuario AND id_permiso_catalogo = 2
        ) = 'S' OR (a.clasificacion <> 'A' OR a.clasificacion IS NULL)
      )
    ORDER BY a.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_buscagiro_permisos
-- Tipo: Catalog
-- Descripción: Obtiene los permisos de giros del usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscagiro_permisos(
    p_usuario TEXT,
    p_id_permiso_catalogo INT
)
RETURNS TABLE (
    id INT,
    usuario TEXT,
    giro_a CHAR(1),
    giro_b CHAR(1),
    giro_c CHAR(1),
    giro_d CHAR(1),
    id_permiso_catalogo INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, usuario, giro_a, giro_b, giro_c, giro_d, id_permiso_catalogo
    FROM lic_permisos
    WHERE usuario = p_usuario AND id_permiso_catalogo = p_id_permiso_catalogo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

