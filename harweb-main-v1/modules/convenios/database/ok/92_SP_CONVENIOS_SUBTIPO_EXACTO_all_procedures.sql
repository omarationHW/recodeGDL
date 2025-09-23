-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SUBTIPO (EXACTO del archivo original)
-- Archivo: 92_SP_CONVENIOS_SUBTIPO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
    FROM public.ta_17_subtipo_conv a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.tipo, a.subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SUBTIPO (EXACTO del archivo original)
-- Archivo: 92_SP_CONVENIOS_SUBTIPO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
    INSERT INTO public.ta_17_subtipo_conv (tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual)
    VALUES (p_tipo, p_subtipo, p_desc_subtipo, p_cuenta_ingreso, p_id_usuario, now());
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM public.ta_17_subtipo_conv
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SUBTIPO (EXACTO del archivo original)
-- Archivo: 92_SP_CONVENIOS_SUBTIPO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
    DELETE FROM public.ta_17_subtipo_conv WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY SELECT p_tipo, p_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SUBTIPO (EXACTO del archivo original)
-- Archivo: 92_SP_CONVENIOS_SUBTIPO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

