-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Recargos
-- Generado: 2025-08-27 00:32:58
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos con información de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list()
RETURNS TABLE(
    axo SMALLINT,
    periodo SMALLINT,
    porcentaje NUMERIC(8,2),
    fecha_alta TIMESTAMP,
    usuario TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, u.usuario
    FROM public.ta_11_recargos r
    LEFT JOIN public.ta_passwords u ON r.id_usuario = u.id_usuario
    ORDER BY r.axo DESC, r.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_create(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_porcentaje NUMERIC(8,2),
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.ta_11_recargos(axo, periodo, porcentaje, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_porcentaje, NOW(), p_usuario_id);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_porcentaje NUMERIC(8,2),
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_11_recargos
    SET porcentaje = p_porcentaje,
        fecha_alta = NOW(),
        id_usuario = p_usuario_id
    WHERE axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_delete(
    p_axo SMALLINT,
    p_periodo SMALLINT
) RETURNS VOID AS $$
BEGIN
    DELETE FROM public.ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

