-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: InteresesMtto
-- Generado: 2025-08-27 14:49:07
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_interesesmtto_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de interés de mantenimiento. Si ya existe para el año y mes, retorna error.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_interesesmtto_create(p_axo integer, p_mes integer, p_porc numeric, p_id_usuario integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'Ya existe un registro para ese año y mes'::text;
        RETURN;
    END IF;
    INSERT INTO ta_12_intereses(axo, mes, porcentaje, id_usuario, fecha_actual)
    VALUES (p_axo, p_mes, p_porc, p_id_usuario, NOW());
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_interesesmtto_update
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de interés de mantenimiento para un año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_interesesmtto_update(p_axo integer, p_mes integer, p_porc numeric, p_id_usuario integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'No existe el registro para ese año y mes'::text;
        RETURN;
    END IF;
    UPDATE ta_12_intereses
    SET porcentaje = p_porc,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_interesesmtto_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de interés de mantenimiento por año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_interesesmtto_delete(p_axo integer, p_mes integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'No existe el registro para ese año y mes'::text;
        RETURN;
    END IF;
    DELETE FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

