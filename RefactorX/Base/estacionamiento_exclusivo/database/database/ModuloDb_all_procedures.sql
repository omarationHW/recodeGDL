-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ModuloDb
-- Generado: 2025-08-27 20:58:42
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_user_by_credentials
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es válido y activo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_user_by_credentials(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre, a.estado, a.id_rec, b.id_zona, b.recaudadora, b.domicilio, b.tel, b.recaudador, a.nivel
    FROM padron_licencias.comun.ta_12_passwords a
    JOIN padron_licencias.comun.ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_check_new_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión para un proyecto dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_check_new_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE (
    nueva_version BOOLEAN
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version) THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: date_to_words
-- Tipo: Catalog
-- Descripción: Convierte una fecha a su representación en letras en español.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION date_to_words(p_date DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    dia INT;
    mes INT;
    anio INT;
BEGIN
    dia := EXTRACT(DAY FROM p_date);
    mes := EXTRACT(MONTH FROM p_date);
    anio := EXTRACT(YEAR FROM p_date);
    RETURN dia::TEXT || ' de ' || meses[mes] || ' de ' || anio::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

