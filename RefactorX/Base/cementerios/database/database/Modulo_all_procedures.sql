-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Modulo
-- Generado: 2025-08-27 14:38:06
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_valida_usuario
-- Tipo: CRUD
-- Descripción: Valida usuario y clave, retorna datos del usuario si es válido.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_valida_usuario(p_usuario VARCHAR, p_clave VARCHAR)
RETURNS TABLE(
    valido BOOLEAN,
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TRUE AS valido,
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A'
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_usuario_detalle
-- Tipo: Catalog
-- Descripción: Obtiene detalles del usuario por nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuario_detalle(p_usuario VARCHAR)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_hay_nueva_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión para el proyecto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_hay_nueva_version(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(hay_nueva BOOLEAN) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version;
    IF v_count = 1 THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_version_detalle
-- Tipo: Catalog
-- Descripción: Obtiene detalles de la versión de un proyecto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_version_detalle(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(
    proyecto VARCHAR,
    version VARCHAR,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT proyecto, version, fecha
    FROM ta_versiones
    WHERE proyecto = p_proyecto AND version = p_version;
END;
$$ LANGUAGE plpgsql;

-- ============================================

