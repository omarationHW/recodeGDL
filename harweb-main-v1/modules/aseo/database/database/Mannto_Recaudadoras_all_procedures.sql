-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Recaudadoras
-- Generado: 2025-08-27 14:49:12
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_recaudadoras_create
-- Tipo: CRUD
-- Descripción: Crea una nueva recaudadora si no existe el número.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_create(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'YA EXISTE o EL CAMPO DE NUMERO ES NULO, INTENTA CON OTRO.';
    END IF;
    INSERT INTO ta_16_recaudadoras (num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
END;
$$;

-- ============================================

-- SP 2/3: sp_recaudadoras_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una recaudadora.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_update(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;

-- ============================================

-- SP 3/3: sp_recaudadoras_delete
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_delete(p_num_rec SMALLINT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_contratos WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;

-- ============================================

