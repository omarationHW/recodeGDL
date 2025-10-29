-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SubTipo
-- Generado: 2025-08-27 15:59:10
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_subtipo_list
-- Tipo: Catalog
-- Descripción: Lista todos los subtipos de convenio con información de usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_list()
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.tipo, a.subtipo, a.desc_subtipo, a.cuenta_ingreso, a.id_usuario, a.fecha_actual,
           b.usuario, b.nombre, b.estado, b.id_rec, b.nivel
    FROM ta_17_subtipo_conv a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.tipo, a.subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_subtipo_get
-- Tipo: Catalog
-- Descripción: Obtiene un subtipo específico por tipo y subtipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_get(p_id integer)
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.tipo, a.subtipo, a.desc_subtipo, a.cuenta_ingreso, a.id_usuario, a.fecha_actual,
           b.usuario, b.nombre, b.estado, b.id_rec, b.nivel
    FROM ta_17_subtipo_conv a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.tipo = (p_id/10000)::smallint AND a.subtipo = (p_id%10000)::smallint;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_subtipo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo subtipo de convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_create(
    p_tipo smallint,
    p_subtipo smallint,
    p_desc_subtipo varchar,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    INSERT INTO ta_17_subtipo_conv (tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual)
    VALUES (p_tipo, p_subtipo, p_desc_subtipo, p_cuenta_ingreso, p_id_usuario, now());
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM ta_17_subtipo_conv
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_subtipo_update
-- Tipo: CRUD
-- Descripción: Actualiza un subtipo de convenio existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_update(
    p_tipo smallint,
    p_subtipo smallint,
    p_desc_subtipo varchar,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    UPDATE ta_17_subtipo_conv
    SET desc_subtipo = p_desc_subtipo,
        cuenta_ingreso = p_cuenta_ingreso,
        id_usuario = p_id_usuario,
        fecha_actual = now()
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM ta_17_subtipo_conv
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_subtipo_delete
-- Tipo: CRUD
-- Descripción: Elimina un subtipo de convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_delete(
    p_tipo smallint,
    p_subtipo smallint
) RETURNS TABLE (
    tipo smallint,
    subtipo smallint
) AS $$
BEGIN
    DELETE FROM ta_17_subtipo_conv WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY SELECT p_tipo, p_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_subtipo_last_by_tipo
-- Tipo: Catalog
-- Descripción: Obtiene el último subtipo registrado para un tipo dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_subtipo_last_by_tipo(p_tipo smallint)
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM ta_17_subtipo_conv
    WHERE tipo = p_tipo
    ORDER BY subtipo DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

