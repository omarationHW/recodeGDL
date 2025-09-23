-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuotasEnergia
-- Generado: 2025-08-26 23:31:39
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cuotas_energia_list
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de energía eléctrica con usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotas_energia_list()
RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_kilowhatts, a.axo, a.periodo, a.importe, a.fecha_alta, a.id_usuario, b.usuario
    FROM public.ta_11_kilowhatts a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.axo DESC, a.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cuotas_energia_create
-- Tipo: CRUD
-- Descripción: Crea una nueva cuota de energía eléctrica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotas_energia_create(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
) RETURNS TABLE (id_kilowhatts INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, NOW(), p_id_usuario)
    RETURNING id_kilowhatts INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_cuotas_energia_update
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotas_energia_update(
    p_id_kilowhatts INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_11_kilowhatts
    SET axo = p_axo,
        periodo = p_periodo,
        importe = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_cuotas_energia_delete
-- Tipo: CRUD
-- Descripción: Elimina una cuota de energía eléctrica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotas_energia_delete(
    p_id_kilowhatts INTEGER
) RETURNS VOID AS $$
BEGIN
    DELETE FROM public.ta_11_kilowhatts WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_cuotas_energia_get
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotas_energia_get(
    p_id_kilowhatts INTEGER
) RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_kilowhatts, a.axo, a.periodo, a.importe, a.fecha_alta, a.id_usuario, b.usuario
    FROM public.ta_11_kilowhatts a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;

-- ============================================

