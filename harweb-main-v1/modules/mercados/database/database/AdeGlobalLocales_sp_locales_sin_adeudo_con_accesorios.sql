-- Stored Procedure: sp_locales_sin_adeudo_con_accesorios
-- Tipo: Report
-- Descripción: Obtiene el listado de locales sin adeudo pero con accesorios (multas/gastos) para un mercado, año y mes.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 20:19:25

CREATE OR REPLACE FUNCTION sp_locales_sin_adeudo_con_accesorios(
    p_merc integer,
    p_axo integer,
    p_mes integer
)
RETURNS TABLE(
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local integer,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    adeudo numeric,
    recargos numeric,
    multas numeric,
    gastos numeric,
    id_local integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        COALESCE(SUM(b.importe),0) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM ta_12_recargos WHERE (axo = b.axo AND mes >= b.periodo) OR (axo > b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_multa ELSE 0 END)
                  FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS multas,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_gastos ELSE 0 END)
                  FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS gastos,
        a.id_local
    FROM ta_11_locales a
    LEFT JOIN ta_11_adeudo_local b ON a.id_local = b.id_local AND ((b.axo = p_axo AND b.periodo <= p_mes) OR (b.axo < p_axo))
    JOIN ta_15_apremios c ON c.modulo = 11 AND c.control_otr = a.id_local AND c.vigencia = '1' AND c.clave_practicado = 'P'
    WHERE a.num_mercado = p_merc
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre
    HAVING COUNT(b.id_adeudo_local) = 0
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;