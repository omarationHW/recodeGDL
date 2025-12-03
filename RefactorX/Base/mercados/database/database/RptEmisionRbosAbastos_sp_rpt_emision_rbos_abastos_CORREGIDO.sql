-- Stored Procedure: sp_rpt_emision_rbos_abastos
-- Tipo: Report
-- Descripción: Obtiene el reporte de emisión de recibos de abastos para una oficina, mercado, año y periodo.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-08-27 00:59:26
-- CORREGIDO: Esquemas cross-database según postgreok.csv

CREATE OR REPLACE FUNCTION public.sp_rpt_emision_rbos_abastos(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_periodo integer
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    nombre text,
    descripcion text,
    descripcion_local text,
    axo_1 integer,
    categoria_1 integer,
    seccion_1 text,
    clave_cuota integer,
    importe_cuota numeric,
    renta numeric,
    rentaaxos numeric,
    meses text,
    adeudo numeric,
    recargos numeric,
    subtotal numeric,
    multa numeric
) AS $$
DECLARE
    r record;
    m record;
    cad text;
    rentaaxos numeric;
BEGIN
    FOR r IN
        SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, a.descripcion_local,
               c.axo AS axo_1, c.categoria AS categoria_1, c.seccion AS seccion_1, c.clave_cuota, c.importe_cuota,
               0::numeric AS renta, 0::numeric AS rentaaxos, ''::text AS meses,
               COALESCE(SUM(d.importe),0) AS adeudo,
               COALESCE(SUM(ROUND((d.importe * (
                   SELECT SUM(porcentaje_mes) FROM padron_licencias.comun.ta_12_recargos WHERE (axo = d.axo AND mes >= d.periodo) OR (axo > d.axo)
               ))/100,2)),0) AS recargos,
               0::numeric AS subtotal,
               0::numeric AS multa
        FROM padron_licencias.comun.ta_11_locales a
        JOIN padron_licencias.comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN mercados.public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
        LEFT JOIN padron_licencias.comun.ta_11_adeudo_local d ON a.id_local = d.id_local
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND a.vigencia = 'A'
          AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
          AND a.id_local NOT IN (
              SELECT id_local FROM padron_licencias.comun.ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo
          )
        GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, a.descripcion_local,
                 c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Calcular renta
        IF r.seccion = 'PS' THEN
            r.renta := (r.importe_cuota * COALESCE((SELECT superficie FROM padron_licencias.comun.ta_11_locales WHERE id_local = r.id_local),1)) * 30;
        ELSE
            r.renta := COALESCE((SELECT superficie FROM padron_licencias.comun.ta_11_locales WHERE id_local = r.id_local),1) * r.importe_cuota;
        END IF;
        -- Calcular rentaaxos y meses adeudados
        cad := '';
        rentaaxos := 0;
        FOR m IN SELECT periodo, importe, axo FROM padron_licencias.comun.ta_11_adeudo_local WHERE id_local = r.id_local AND axo = r.axo_1 LOOP
            IF m.axo < p_axo THEN
                cad := cad || m.periodo::text || ',';
                rentaaxos := m.importe;
            ELSIF m.axo = p_axo AND m.periodo < p_periodo THEN
                cad := cad || m.periodo::text || ',';
                rentaaxos := m.importe;
            END IF;
        END LOOP;
        r.rentaaxos := rentaaxos;
        r.meses := LEFT(cad, GREATEST(LENGTH(cad)-1,0));
        -- Calcular multa (por ahora 0)
        r.multa := 0;
        -- Calcular subtotal
        r.subtotal := r.adeudo + r.recargos + r.multa;
        RETURN NEXT r;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
