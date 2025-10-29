-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ElaboraConvenios (EXACTO del archivo original)
-- Archivo: 20_SP_CONVENIOS_ELABORACONVENIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_elabora_convenios_list
-- Tipo: Catalog
-- Descripción: Lista todos los registros de quienes elaboran convenios, incluyendo recaudador y nombre de quien elabora.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elabora_convenios_list()
RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10),
    recaudador VARCHAR(50),
    elaboro VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.id_rec, a.id_usu_titular, a.iniciales_titular, a.id_usu_elaboro, a.iniciales_elaboro,
           b.nombre AS recaudador,
           (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario=a.id_usu_elaboro) AS elaboro
    FROM public.ta_17_elaboroficio a
    JOIN public.ta_12_passwords b ON b.id_usuario=a.id_usu_titular
    ORDER BY a.id_rec, a.id_usu_titular;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_elabora_convenios_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de quien elabora public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elabora_convenios_create(
    p_id_rec INTEGER,
    p_id_usu_titular INTEGER,
    p_iniciales_titular VARCHAR(10),
    p_id_usu_elaboro INTEGER,
    p_iniciales_elaboro VARCHAR(10),
    p_id_usuario INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10)
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO public.ta_17_elaboroficio (id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro)
    VALUES (p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro)
    RETURNING id_control INTO new_id;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM public.ta_17_elaboroficio WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_elabora_convenios_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de quien elabora public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elabora_convenios_update(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_id_usu_titular INTEGER,
    p_iniciales_titular VARCHAR(10),
    p_id_usu_elaboro INTEGER,
    p_iniciales_elaboro VARCHAR(10),
    p_id_usuario INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10)
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

-- SP 4/5: sp_elabora_convenios_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de quien elabora public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elabora_convenios_delete(
    p_id_control INTEGER,
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM public.ta_17_elaboroficio WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_elabora_convenios_get
-- Tipo: Catalog
-- Descripción: Obtiene un registro específico de quien elabora public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elabora_convenios_get(
    p_id_control INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM public.ta_17_elaboroficio WHERE id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================