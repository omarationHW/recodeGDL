-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatalogoMntto
-- Generado: 2025-08-26 23:06:58
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_catalogo_mntto_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados (catálogo completo)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_list()
RETURNS TABLE (
    oficina INTEGER,
    num_mercado_nvo INTEGER,
    categoria INTEGER,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona INTEGER,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    WHERE tipo_emision <> 'B'
    ORDER BY oficina ASC, num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_catalogo_mntto_get
-- Tipo: Catalog
-- Descripción: Obtiene un mercado por ID compuesto (oficina, num_mercado_nvo)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_get(p_oficina INTEGER, p_num_mercado_nvo INTEGER)
RETURNS TABLE (
    oficina INTEGER,
    num_mercado_nvo INTEGER,
    categoria INTEGER,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona INTEGER,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_catalogo_mntto_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo mercado en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_insert(
    p_oficina INTEGER,
    p_num_mercado_nvo INTEGER,
    p_categoria INTEGER,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_pregunta VARCHAR,
    p_cuenta_energia INTEGER,
    p_zona INTEGER,
    p_emision VARCHAR
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_tipo_emision CHAR(1);
BEGIN
    IF p_emision = 'MASIVA' THEN
        v_tipo_emision := 'M';
    ELSIF p_emision = 'DISKETTE' THEN
        v_tipo_emision := 'D';
    ELSIF p_emision = 'BAJA' THEN
        v_tipo_emision := 'B';
    ELSE
        v_tipo_emision := 'M';
    END IF;
    IF EXISTS (SELECT 1 FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un mercado con esa clave';
        RETURN;
    END IF;
    INSERT INTO ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, UPPER(p_descripcion), p_cuenta_ingreso,
        CASE WHEN p_pregunta = 'S' THEN p_cuenta_energia ELSE NULL END,
        p_zona, v_tipo_emision
    );
    RETURN QUERY SELECT TRUE, 'Mercado insertado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al insertar: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_catalogo_mntto_update
-- Tipo: CRUD
-- Descripción: Actualiza un mercado existente en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_update(
    p_oficina INTEGER,
    p_num_mercado_nvo INTEGER,
    p_categoria INTEGER,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_pregunta VARCHAR,
    p_cuenta_energia INTEGER,
    p_zona INTEGER,
    p_emision VARCHAR
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_tipo_emision CHAR(1);
BEGIN
    IF p_emision = 'MASIVA' THEN
        v_tipo_emision := 'M';
    ELSIF p_emision = 'DISKETTE' THEN
        v_tipo_emision := 'D';
    ELSIF p_emision = 'BAJA' THEN
        v_tipo_emision := 'B';
    ELSE
        v_tipo_emision := 'M';
    END IF;
    UPDATE ta_11_mercados SET
        categoria = p_categoria,
        descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = CASE WHEN p_pregunta = 'S' THEN p_cuenta_energia ELSE NULL END,
        id_zona = p_zona,
        tipo_emision = v_tipo_emision
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Mercado actualizado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el mercado para actualizar';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al actualizar: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_recaudadoras_list
-- Tipo: Catalog
-- Descripción: Lista de recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recaudadoras_list()
RETURNS TABLE (id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_categorias_list
-- Tipo: Catalog
-- Descripción: Lista de categorías de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_zonas_list
-- Tipo: Catalog
-- Descripción: Lista de zonas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_list()
RETURNS TABLE (id_zona INTEGER, zona VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_cuentas_list
-- Tipo: Catalog
-- Descripción: Lista de cuentas de ingreso
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuentas_list()
RETURNS TABLE (cta_aplicacion INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT cta_aplicacion, descripcion FROM ta_12_cuentas ORDER BY cta_aplicacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

