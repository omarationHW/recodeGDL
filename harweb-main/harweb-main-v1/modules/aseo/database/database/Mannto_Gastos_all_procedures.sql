-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Gastos
-- Generado: 2025-08-27 14:44:22
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_gastos_insert
-- Tipo: CRUD
-- Descripción: Inserta un registro de gastos en ta_16_gastos
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);
END;
$$;

-- ============================================

-- SP 2/2: sp_gastos_delete_all
-- Tipo: CRUD
-- Descripción: Elimina todos los registros de ta_16_gastos (solo debe haber uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_16_gastos;
END;
$$;

-- ============================================

