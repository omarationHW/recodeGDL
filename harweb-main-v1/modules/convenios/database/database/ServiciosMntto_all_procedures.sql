-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ServiciosMntto
-- Generado: 2025-08-27 15:54:34
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_servicios_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en ta_17_servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicios_insert(p_servicio integer, p_descripcion text, p_serv_obra94 integer)
RETURNS TABLE(servicio integer, descripcion text, serv_obra94 integer) AS $$
BEGIN
    INSERT INTO ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (p_servicio, p_descripcion, p_serv_obra94);
    RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_servicios_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_17_servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicios_update(p_servicio integer, p_descripcion text, p_serv_obra94 integer)
RETURNS TABLE(servicio integer, descripcion text, serv_obra94 integer) AS $$
BEGIN
    UPDATE ta_17_servicios
    SET descripcion = p_descripcion,
        serv_obra94 = p_serv_obra94
    WHERE servicio = p_servicio;
    RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_servicios_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicios_delete(p_servicio integer)
RETURNS TABLE(success boolean) AS $$
BEGIN
    DELETE FROM ta_17_servicios WHERE servicio = p_servicio;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

