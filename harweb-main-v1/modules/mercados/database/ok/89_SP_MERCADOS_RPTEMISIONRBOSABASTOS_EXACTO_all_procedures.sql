-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEmisionRbosAbastos
-- Generado: 2025-08-27 00:59:26
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_rpt_emision_rbos_abastos
-- Tipo: Report
-- Descripción: Obtiene el reporte de emisión de recibos de abastos para una oficina, mercado, año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_rbos_abastos(
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
    cad text;
    rentaaxos numeric;
BEGIN
    FOR r IN
        SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, a.descripcion_local,
               c.axo AS axo_1, c.categoria AS categoria_1, c.seccion AS seccion_1, c.clave_cuota, c.importe_cuota,
               0::numeric AS renta, 0::numeric AS rentaaxos, ''::text AS meses,
               COALESCE(SUM(d.importe),0) AS adeudo,
               COALESCE(SUM(ROUND((d.importe * (
                   SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos WHERE (axo = d.axo AND mes >= d.periodo) OR (axo > d.axo)
               ))/100,2)),0) AS recargos,
               0::numeric AS subtotal,
               0::numeric AS multa
        FROM public.ta_11_locales a
        JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
        LEFT JOIN public.ta_11_adeudo_local d ON a.id_local = d.id_local
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND a.vigencia = 'A'
          AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
          AND a.id_local NOT IN (
              SELECT id_local FROM public.ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo
          )
        GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, a.descripcion_local,
                 c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Calcular renta
        IF r.seccion = 'PS' THEN
            r.renta := (r.importe_cuota * COALESCE((SELECT superficie FROM public.ta_11_locales WHERE id_local = r.id_local),1)) * 30;
        ELSE
            r.renta := COALESCE((SELECT superficie FROM public.ta_11_locales WHERE id_local = r.id_local),1) * r.importe_cuota;
        END IF;
        -- Calcular rentaaxos y meses adeudados
        cad := '';
        rentaaxos := 0;
        FOR m IN SELECT periodo, importe, axo FROM public.ta_11_adeudo_local WHERE id_local = r.id_local AND axo = r.axo_1 LOOP
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

-- ============================================

-- SP 2/3: sp_get_requerimientos_abastos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos (apremios) asociados a un local para abastos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_abastos(
    p_id_local integer
) RETURNS TABLE (
    id_control integer,
    modulo integer,
    control_otr integer,
    folio integer,
    diligencia text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado text,
    vigencia text,
    fecha_actualiz date,
    usuario integer,
    observaciones text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
           fecha_emision, clave_practicado, vigencia, fecha_actualiz, usuario, observaciones
    FROM public.ta_15_apremios
    WHERE modulo = 11 AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P'
    ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_recargos_mes_abastos
-- Tipo: Report
-- Descripción: Obtiene los recargos del mes para abastos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos_mes_abastos(
    p_axo integer,
    p_mes integer
) RETURNS TABLE (
    axo integer,
    mes integer,
    porcentaje_mes numeric,
    acumulado_uno numeric,
    acumulado_dos numeric,
    acumulado_tres numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, mes, porcentaje_mes, acumulado_uno, acumulado_dos, acumulado_tres
    FROM public.ta_12_recargos
    WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

