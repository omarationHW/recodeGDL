-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptDesgloceAdeporImporte
-- Generado: 2025-08-27 00:51:52
-- Total SPs: 1
-- ============================================

-- SP 1/1: spd_11_ade_axo
-- Tipo: Report
-- Descripción: Obtiene el desglose de adeudos vencidos por local, agrupado por año y filtrado por importe mínimo, año y periodo.
-- --------------------------------------------

-- PostgreSQL stored procedure/function for report
CREATE OR REPLACE FUNCTION spd_11_ade_axo(parm_axo SMALLINT, parm_mes SMALLINT, parm_cuota NUMERIC)
RETURNS TABLE (
    spd_id_local INTEGER,
    spd_oficina SMALLINT,
    spd_mercado SMALLINT,
    spd_categoria SMALLINT,
    spd_seccion VARCHAR(2),
    spd_local INTEGER,
    spd_letra VARCHAR(1),
    spd_bloque VARCHAR(1),
    spd_nombre VARCHAR(60),
    spd_descripcion VARCHAR(30),
    spd_adeant NUMERIC,
    spd_ade2004 NUMERIC,
    spd_ade2005 NUMERIC,
    spd_ade2006 NUMERIC,
    spd_ade2007 NUMERIC,
    spd_ade2008 NUMERIC,
    spd_totade NUMERIC
) AS $$
BEGIN
    -- NOTA: Debe adaptarse la consulta interna a la estructura real de la base de datos BasePHP
    RETURN QUERY
    SELECT
        l.id_local AS spd_id_local,
        l.oficina AS spd_oficina,
        l.mercado AS spd_mercado,
        l.categoria AS spd_categoria,
        l.seccion AS spd_seccion,
        l.local AS spd_local,
        l.letra AS spd_letra,
        l.bloque AS spd_bloque,
        l.nombre AS spd_nombre,
        l.descripcion AS spd_descripcion,
        COALESCE(a.ade_ant, 0) AS spd_adeant,
        COALESCE(a.ade_2004, 0) AS spd_ade2004,
        COALESCE(a.ade_2005, 0) AS spd_ade2005,
        COALESCE(a.ade_2006, 0) AS spd_ade2006,
        COALESCE(a.ade_2007, 0) AS spd_ade2007,
        COALESCE(a.ade_2008, 0) AS spd_ade2008,
        (COALESCE(a.ade_ant, 0) + COALESCE(a.ade_2004, 0) + COALESCE(a.ade_2005, 0) + COALESCE(a.ade_2006, 0) + COALESCE(a.ade_2007, 0) + COALESCE(a.ade_2008, 0)) AS spd_totade
    FROM
        locales l
        INNER JOIN adeudos a ON a.id_local = l.id_local
    WHERE
        a.anio <= parm_axo
        AND a.mes <= parm_mes
        AND (COALESCE(a.ade_ant, 0) + COALESCE(a.ade_2004, 0) + COALESCE(a.ade_2005, 0) + COALESCE(a.ade_2006, 0) + COALESCE(a.ade_2007, 0) + COALESCE(a.ade_2008, 0)) >= parm_cuota
    ORDER BY
        l.oficina, l.mercado, l.categoria, l.seccion, l.local, l.letra;
END;
$$ LANGUAGE plpgsql;


-- ============================================

