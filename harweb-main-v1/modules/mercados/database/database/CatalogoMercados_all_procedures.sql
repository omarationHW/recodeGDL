-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatalogoMercados
-- Generado: 2025-08-26 23:04:40
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_catalogo_mercados_list
-- Tipo: Catalog
-- Descripción: Lista todos los mercados activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_list()
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar(30),
    cuenta_ingreso integer,
    cuenta_energia integer,
    id_zona smallint,
    tipo_emision char(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    ORDER BY oficina ASC, num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_catalogo_mercados_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_create(
    p_oficina smallint,
    p_num_mercado_nvo smallint,
    p_categoria smallint,
    p_descripcion varchar(30),
    p_cuenta_ingreso integer,
    p_cuenta_energia integer,
    p_id_zona smallint,
    p_tipo_emision char(1)
) RETURNS TABLE (result text) AS $$
BEGIN
    INSERT INTO ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, p_descripcion, p_cuenta_ingreso, p_cuenta_energia, p_id_zona, p_tipo_emision
    );
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_catalogo_mercados_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de mercado existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_update(
    p_oficina smallint,
    p_num_mercado_nvo smallint,
    p_categoria smallint,
    p_descripcion varchar(30),
    p_cuenta_ingreso integer,
    p_cuenta_energia integer,
    p_id_zona smallint,
    p_tipo_emision char(1)
) RETURNS TABLE (result text) AS $$
BEGIN
    UPDATE ta_11_mercados SET
        categoria = p_categoria,
        descripcion = p_descripcion,
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = p_cuenta_energia,
        id_zona = p_id_zona,
        tipo_emision = p_tipo_emision
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_catalogo_mercados_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_delete(
    p_oficina smallint,
    p_num_mercado_nvo smallint
) RETURNS TABLE (result text) AS $$
BEGIN
    DELETE FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_catalogo_mercados_report
-- Tipo: Report
-- Descripción: Reporte de catálogo de mercados (puede filtrar por oficina si se desea)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_report(p_oficina smallint DEFAULT NULL)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar(30),
    cuenta_ingreso integer,
    cuenta_energia integer,
    id_zona smallint,
    tipo_emision char(1)
) AS $$
BEGIN
    IF p_oficina IS NULL THEN
        RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
        FROM ta_11_mercados
        ORDER BY oficina ASC, num_mercado_nvo ASC;
    ELSE
        RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
        FROM ta_11_mercados
        WHERE oficina = p_oficina
        ORDER BY oficina ASC, num_mercado_nvo ASC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

