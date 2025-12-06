-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURE: spd_11_ade_axo
-- Formulario: RptDesgloceAdeporImporte
-- Descripción: Obtiene el desglose de adeudos vencidos por local, agrupado por año y filtrado por importe mínimo, año y periodo.
-- ============================================

DROP FUNCTION IF EXISTS public.spd_11_ade_axo(SMALLINT, SMALLINT, NUMERIC);

CREATE OR REPLACE FUNCTION public.spd_11_ade_axo(
    parm_axo SMALLINT,
    parm_mes SMALLINT,
    parm_cuota NUMERIC
)
RETURNS TABLE (
    spd_id_local INTEGER,
    spd_oficina SMALLINT,
    spd_mercado SMALLINT,
    spd_categoria SMALLINT,
    spd_seccion VARCHAR(2),
    spd_local INTEGER,
    spd_letra VARCHAR(3),
    spd_bloque VARCHAR(2),
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
    RETURN QUERY
    SELECT
        a.id_local AS spd_id_local,
        a.oficina AS spd_oficina,
        a.num_mercado AS spd_mercado,
        a.categoria AS spd_categoria,
        a.seccion AS spd_seccion,
        a.local AS spd_local,
        a.letra_local AS spd_letra,
        a.bloque AS spd_bloque,
        a.nombre AS spd_nombre,
        b.descripcion AS spd_descripcion,
        -- Adeudos anteriores a 2004
        COALESCE(SUM(CASE WHEN c.axo <= 2003 THEN c.importe ELSE 0 END), 0) AS spd_adeant,
        -- Adeudos 2004
        COALESCE(SUM(CASE WHEN c.axo = 2004 THEN c.importe ELSE 0 END), 0) AS spd_ade2004,
        -- Adeudos 2005
        COALESCE(SUM(CASE WHEN c.axo = 2005 THEN c.importe ELSE 0 END), 0) AS spd_ade2005,
        -- Adeudos 2006
        COALESCE(SUM(CASE WHEN c.axo = 2006 THEN c.importe ELSE 0 END), 0) AS spd_ade2006,
        -- Adeudos 2007
        COALESCE(SUM(CASE WHEN c.axo = 2007 THEN c.importe ELSE 0 END), 0) AS spd_ade2007,
        -- Adeudos 2008
        COALESCE(SUM(CASE WHEN c.axo = 2008 THEN c.importe ELSE 0 END), 0) AS spd_ade2008,
        -- Total de adeudos
        COALESCE(SUM(c.importe), 0) AS spd_totade
    FROM
        padron_licencias.comun.ta_11_locales a
        INNER JOIN padron_licencias.comun.ta_11_mercados b
            ON a.oficina = b.oficina
            AND a.num_mercado = b.num_mercado_nvo
        INNER JOIN padron_licencias.comun.ta_11_adeudo_local c
            ON a.id_local = c.id_local
    WHERE
        ((c.axo = parm_axo AND c.periodo <= parm_mes) OR (c.axo < parm_axo))
    GROUP BY
        a.id_local,
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        b.descripcion
    HAVING
        SUM(c.importe) >= parm_cuota
    ORDER BY
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Comentarios y permisos
-- ============================================
COMMENT ON FUNCTION public.spd_11_ade_axo(SMALLINT, SMALLINT, NUMERIC) IS
'Reporte de desglose de adeudos vencidos por local, agrupado por año.
Parámetros:
  - parm_axo: Año de corte
  - parm_mes: Mes/periodo de corte
  - parm_cuota: Importe mínimo para filtrar
Retorna locales con adeudos desglosados por año (<=2003, 2004-2008) y total.';

-- ============================================
