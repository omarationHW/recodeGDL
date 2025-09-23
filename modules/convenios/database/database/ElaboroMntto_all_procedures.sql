-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ElaboroMntto
-- Generado: 2025-08-27 14:33:12
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_elaboro_mntto_create
-- Tipo: CRUD
-- Descripción: Crea un registro en ta_17_elaboroficio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_create(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar,
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_17_elaboroficio (
        id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    ) VALUES (
        p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro
    ) RETURNING id_control INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_elaboro_mntto_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro en ta_17_elaboroficio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_update(
    p_id_control integer,
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar,
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar
) RETURNS integer AS $$
BEGIN
    UPDATE ta_17_elaboroficio SET
        id_rec = p_id_rec,
        id_usu_titular = p_id_usu_titular,
        iniciales_titular = p_iniciales_titular,
        id_usu_elaboro = p_id_usu_elaboro,
        iniciales_elaboro = p_iniciales_elaboro
    WHERE id_control = p_id_control;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_elaboro_mntto_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_elaboroficio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_delete(
    p_id_control integer
) RETURNS integer AS $$
BEGIN
    DELETE FROM ta_17_elaboroficio WHERE id_control = p_id_control;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_elaboro_mntto_titular_info
-- Tipo: Catalog
-- Descripción: Obtiene información de titular y elabora para mostrar en el formulario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_titular_info(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_id_usu_elaboro integer
) RETURNS TABLE(
    recaudadora varchar,
    usutitular varchar,
    titular varchar,
    usuelabora varchar,
    elabora varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.recaudadora,
        t.usuario as usutitular,
        t.nombre as titular,
        e.usuario as usuelabora,
        e.nombre as elabora
    FROM ta_12_passwords t
    JOIN ta_12_recaudadoras r ON r.id_rec = t.id_rec
    JOIN ta_12_passwords e ON e.id_usuario = p_id_usu_elaboro AND e.id_rec = t.id_rec AND e.estado = t.estado
    WHERE t.id_usuario = p_id_usu_titular AND t.id_rec = p_id_rec AND t.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- ============================================

