-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Intereses
-- Generado: 2025-08-27 14:47:29
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_intereses_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo completo de intereses, incluyendo usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_list()
RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.mes, a.porcentaje, a.id_usuario, a.fecha_actual, b.usuario
    FROM ta_12_intereses a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usuario
    ORDER BY a.axo ASC, a.mes ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_intereses_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de interés.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_create(
    p_axo smallint,
    p_mes smallint,
    p_porcentaje numeric(12,8),
    p_id_usuario integer
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    INSERT INTO ta_12_intereses(axo, mes, porcentaje, id_usuario, fecha_actual)
    VALUES (p_axo, p_mes, p_porcentaje, p_id_usuario, NOW());
    RETURN QUERY SELECT axo, mes, porcentaje, id_usuario, fecha_actual
      FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_intereses_update
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de un registro de interés existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_update(
    p_axo smallint,
    p_mes smallint,
    p_porcentaje numeric(12,8),
    p_id_usuario integer
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    UPDATE ta_12_intereses
    SET porcentaje = p_porcentaje,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT axo, mes, porcentaje, id_usuario, fecha_actual
      FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_intereses_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de interés por año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_delete(
    p_axo smallint,
    p_mes smallint
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    deleted boolean
) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT p_axo, p_mes, false;
        RETURN;
    END IF;
    DELETE FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT p_axo, p_mes, true;
END;
$$ LANGUAGE plpgsql;

-- ============================================

