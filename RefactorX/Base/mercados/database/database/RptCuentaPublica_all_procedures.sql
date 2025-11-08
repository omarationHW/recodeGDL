-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptCuentaPublica
-- Generado: 2025-08-27 00:49:48
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_cuenta_publica
-- Tipo: Report
-- Descripción: Genera el reporte de cuentas por cobrar para un año fiscal y oficina/recaudadora.
-- --------------------------------------------

-- DROP FUNCTION IF EXISTS rpt_cuenta_publica(integer, integer);
CREATE OR REPLACE FUNCTION rpt_cuenta_publica(p_axo integer, p_oficina integer)
RETURNS TABLE(
    id serial,
    recaudadora text,
    descripcion text,
    saldo_mes_anterior numeric(18,2),
    altas_doctos integer,
    altas_importe numeric(18,2),
    mov_mes_doctos integer,
    mov_mes_importe numeric(18,2),
    bajas_doctos integer,
    bajas_importe numeric(18,2)
) AS $$
BEGIN
    -- Ejemplo: Adaptar a la estructura real de la tabla ta_11_categoria y relaciones
    RETURN QUERY
    SELECT
        row_number() OVER () as id,
        r.recaudadora,
        c.descripcion,
        c.saldo_mes_anterior,
        c.altas_doctos,
        c.altas_importe,
        c.mov_mes_doctos,
        c.mov_mes_importe,
        c.bajas_doctos,
        c.bajas_importe
    FROM ta_11_categoria c
    LEFT JOIN recaudadoras r ON r.id = c.recaudadora_id
    WHERE c.axo = p_axo AND c.recaudadora_id = p_oficina;
END;
$$ LANGUAGE plpgsql;


-- ============================================

