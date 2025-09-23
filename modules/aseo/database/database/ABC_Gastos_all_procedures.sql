-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Gastos
-- Generado: 2025-08-27 13:24:08
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_gastos_insert
-- Tipo: Catalog
-- Descripción: Inserta un nuevo registro de gastos (solo debe existir uno)
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
-- Tipo: Catalog
-- Descripción: Elimina todos los registros de gastos (solo debe haber uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_16_gastos;
END;
$$;

-- ============================================

