-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RecargosMntto
-- Generado: 2025-08-27 00:34:42
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_insert_recargo
-- Tipo: CRUD
-- Descripción: Inserta un nuevo recargo de mantenimiento para un año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_recargo(p_axo integer, p_periodo integer, p_porcentaje numeric, p_id_usuario integer)
RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM public.ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
    IF existe > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese año y periodo.';
        RETURN;
    END IF;
    INSERT INTO public.ta_11_recargos(axo, periodo, porcentaje, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_porcentaje, NOW(), p_id_usuario);
    RETURN QUERY SELECT true, 'Recargo insertado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_update_recargo
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de un recargo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_recargo(p_axo integer, p_periodo integer, p_porcentaje numeric, p_id_usuario integer)
RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM public.ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
    IF existe = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese año y periodo.';
        RETURN;
    END IF;
    UPDATE public.ta_11_recargos
    SET porcentaje = p_porcentaje, fecha_alta = NOW(), id_usuario = p_id_usuario
    WHERE axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT true, 'Recargo actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_recargo
-- Tipo: Catalog
-- Descripción: Obtiene un recargo específico por año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargo(p_axo integer, p_periodo integer)
RETURNS TABLE(axo integer, periodo integer, porcentaje numeric, fecha_alta timestamp, id_usuario integer, usuario text) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, r.id_usuario, u.usuario
    FROM public.ta_11_recargos r
    LEFT JOIN public.ta_12_passwords u ON r.id_usuario = u.id_usuario
    WHERE r.axo = p_axo AND r.periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_list_recargos
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de mantenimiento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_recargos()
RETURNS TABLE(axo integer, periodo integer, porcentaje numeric, fecha_alta timestamp, id_usuario integer, usuario text) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, r.id_usuario, u.usuario
    FROM public.ta_11_recargos r
    LEFT JOIN public.ta_12_passwords u ON r.id_usuario = u.id_usuario
    ORDER BY r.axo DESC, r.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

