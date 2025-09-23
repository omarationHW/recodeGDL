-- Stored Procedure: get_locales_sin_adeudo_con_accesorios
-- Tipo: Report
-- Descripción: Obtiene locales sin adeudo pero con accesorios (multas/gastos) para un mercado, año y mes.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 18:41:59

CREATE OR REPLACE FUNCTION get_locales_sin_adeudo_con_accesorios(
    p_mercado integer,
    p_anio integer,
    p_mes integer
)
RETURNS TABLE (
    id_local integer,
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
    gastos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre,
        COALESCE(SUM(b.importe),0) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM ta_12_recargos WHERE (axo=b.axo AND mes>=b.periodo) OR (axo>b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(importe_multa) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND vigencia='1' AND clave_practicado='P'),0) AS multas,
        COALESCE((SELECT SUM(importe_gastos) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND vigencia='1' AND clave_practicado='P'),0) AS gastos
    FROM ta_11_locales a
    LEFT JOIN ta_11_adeudo_local b ON a.id_local = b.id_local AND ((b.axo = p_anio AND b.periodo <= p_mes) OR (b.axo < p_anio))
    JOIN ta_15_apremios c ON c.modulo=11 AND c.control_otr=a.id_local AND c.vigencia='1' AND c.clave_practicado='P'
    WHERE a.num_mercado = p_mercado
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre
    HAVING COUNT(b.id_adeudo_local) = 0;
END;
$$ LANGUAGE plpgsql;