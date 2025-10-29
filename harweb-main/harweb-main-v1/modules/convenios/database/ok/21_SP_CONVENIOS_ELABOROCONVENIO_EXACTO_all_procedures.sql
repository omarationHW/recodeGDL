-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ElaboroConvenio (EXACTO del archivo original)
-- Archivo: 21_SP_CONVENIOS_ELABOROCONVENIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_elaboro_convenio_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de registros de quien elaboró convenio, incluyendo nombres de usuarios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_list()
RETURNS TABLE (
    id_control integer,
    id_rec integer,
    id_usu_titular integer,
    iniciales_titular varchar(10),
    id_usu_elaboro integer,
    iniciales_elaboro varchar(10),
    titular varchar(50),
    elaboro varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.id_rec, a.id_usu_titular, a.iniciales_titular, a.id_usu_elaboro, a.iniciales_elaboro,
           b.nombre AS titular,
           (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario=a.id_usu_elaboro) AS elaboro
    FROM public.ta_17_elaboroficio a
    JOIN public.ta_12_passwords b ON b.id_usuario = a.id_usu_titular;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_elaboro_convenio_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de quien elaboró convenio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_create(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar(10),
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar(10)
) RETURNS TABLE (
    id_control integer,
    id_rec integer,
    id_usu_titular integer,
    iniciales_titular varchar(10),
    id_usu_elaboro integer,
    iniciales_elaboro varchar(10)
) AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO public.ta_17_elaboroficio (id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro)
    VALUES (p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro)
    RETURNING id_control INTO new_id;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM public.ta_17_elaboroficio WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_elaboro_convenio_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de quien elaboró convenio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_update(
    p_id_control integer,
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar(10),
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar(10)
) RETURNS TABLE (
    id_control integer,
    id_rec integer,
    id_usu_titular integer,
    iniciales_titular varchar(10),
    id_usu_elaboro integer,
    iniciales_elaboro varchar(10)
) AS $$
BEGIN
    UPDATE public.ta_17_elaboroficio
    SET id_rec = p_id_rec,
        id_usu_titular = p_id_usu_titular,
        iniciales_titular = p_iniciales_titular,
        id_usu_elaboro = p_id_usu_elaboro,
        iniciales_elaboro = p_iniciales_elaboro
    WHERE id_control = p_id_control;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM public.ta_17_elaboroficio WHERE id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_elaboro_convenio_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de quien elaboró convenio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_delete(
    p_id_control integer
) RETURNS TABLE (
    id_control integer
) AS $$
BEGIN
    DELETE FROM public.ta_17_elaboroficio WHERE id_control = p_id_control RETURNING id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================