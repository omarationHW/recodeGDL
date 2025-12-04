-- Stored Procedure: spd_11_ade_axo
-- Tipo: Report
-- Descripción: Obtiene el desglose de adeudos vencidos por local, agrupado por año y filtrado por importe mínimo, año y periodo.
-- Generado para formulario: RptDesgloceAdeporImporte
-- Fecha: 2025-08-27 00:51:52

DROP FUNCTION IF EXISTS spd_11_ade_axo(SMALLINT, SMALLINT, NUMERIC);

CREATE OR REPLACE FUNCTION spd_11_ade_axo(parm_axo SMALLINT, parm_mes SMALLINT, parm_cuota NUMERIC)
RETURNS TABLE (
    spd_id_local INTEGER,
    spd_oficina SMALLINT,
    spd_mercado SMALLINT,
    spd_categoria SMALLINT,
    spd_seccion CHAR(2),
    spd_local INTEGER,
    spd_letra CHAR(1),
    spd_bloque CHAR(1),
    spd_nombre VARCHAR(60),
    spd_descripcion CHAR(20),
    spd_adeant NUMERIC(16,2),
    spd_ade2004 NUMERIC(16,2),
    spd_ade2005 NUMERIC(16,2),
    spd_ade2006 NUMERIC(16,2),
    spd_ade2007 NUMERIC(16,2),
    spd_ade2008 NUMERIC(16,2),
    spd_totade NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local AS spd_id_local,
        l.oficina AS spd_oficina,
        l.num_mercado AS spd_mercado,
        l.categoria AS spd_categoria,
        l.seccion AS spd_seccion,
        l.local AS spd_local,
        l.letra_local::CHAR(1) AS spd_letra,
        l.bloque::CHAR(1) AS spd_bloque,
        l.nombre AS spd_nombre,
        l.descripcion_local AS spd_descripcion,
        COALESCE(SUM(CASE WHEN a.axo < 2004 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_adeant,
        COALESCE(SUM(CASE WHEN a.axo = 2004 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_ade2004,
        COALESCE(SUM(CASE WHEN a.axo = 2005 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_ade2005,
        COALESCE(SUM(CASE WHEN a.axo = 2006 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_ade2006,
        COALESCE(SUM(CASE WHEN a.axo = 2007 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_ade2007,
        COALESCE(SUM(CASE WHEN a.axo = 2008 THEN a.importe ELSE 0 END), 0)::NUMERIC(16,2) AS spd_ade2008,
        COALESCE(SUM(a.importe), 0)::NUMERIC(16,2) AS spd_totade
    FROM
        publico.ta_11_locales l
        INNER JOIN publico.ta_11_adeudo_local a ON a.id_local = l.id_local
    WHERE
        a.axo <= parm_axo
        AND a.periodo <= parm_mes
    GROUP BY
        l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.descripcion_local
    HAVING
        COALESCE(SUM(a.importe), 0) >= parm_cuota
    ORDER BY
        l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local;
END;
$$ LANGUAGE plpgsql;
