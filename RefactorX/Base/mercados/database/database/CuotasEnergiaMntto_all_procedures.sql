-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuotasEnergiaMntto
-- Generado: 2025-08-26 23:33:06
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_insert_cuota_energia
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de energía eléctrica en ta_11_kilowhatts.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
DECLARE
BEGIN
    INSERT INTO ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_update_cuota_energia
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
DECLARE
BEGIN
    UPDATE ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts
      AND axo = p_axo
      AND periodo = p_periodo
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_cuota_energia
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    FROM ta_11_kilowhatts
    WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_list_cuotas_energia
-- Tipo: Catalog
-- Descripción: Lista cuotas de energía eléctrica, opcionalmente filtrando por año y/o periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo integer DEFAULT NULL, p_periodo integer DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    FROM ta_11_kilowhatts
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_periodo IS NULL OR periodo = p_periodo)
    ORDER BY axo DESC, periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

