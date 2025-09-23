-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PasoPagos
-- Generado: 2025-08-27 15:14:09
-- Total SPs: 2
-- ============================================

-- SP 1/2: spd_17_b_p400cont
-- Tipo: CRUD
-- Descripción: Limpia la tabla temporal de paso de pagos de contratos AS/400
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE spd_17_b_p400cont()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE ta_17_paso_p_400 RESTART IDENTITY;
END;
$$;

-- ============================================

-- SP 2/2: spd_17_a_p400_cont
-- Tipo: Report
-- Descripción: Devuelve el conteo de pagos grabados, modificados y totales para usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_17_a_p400_cont(parm_id_usuario integer)
RETURNS TABLE(expression integer, expression_1 integer) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) AS expression, 0 AS expression_1
    FROM ta_17_paso_p_400
    WHERE usuario = parm_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

