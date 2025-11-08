-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptCaratulaEnergia
-- Generado: 2025-08-27 00:46:24
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_energia_caratula
-- Tipo: Report
-- Descripción: Obtiene la carátula de energía para un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_energia_caratula(p_id_local INTEGER)
RETURNS TABLE (
    id_energia INTEGER,
    id_local INTEGER,
    cve_consumo VARCHAR,
    local_adicional VARCHAR,
    cantidad NUMERIC,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR,
    usuario VARCHAR,
    vigdescripcion VARCHAR,
    consumodescr VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo,
        e.local_adicional,
        e.cantidad,
        e.vigencia,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        m.descripcion,
        u.usuario,
        CASE e.vigencia
            WHEN 'B' THEN 'BAJA'
            WHEN 'E' THEN 'VIGENTE / PARA EMISION'
            ELSE 'VIGENTE'
        END AS vigdescripcion,
        CASE e.cve_consumo
            WHEN 'F' THEN 'Precio Fijo / Servicio Normal'
            WHEN 'K' THEN 'Precio Kilowhatts / Servicio Medido'
            ELSE ''
        END AS consumodescr
    FROM ta_11_energia e
    JOIN ta_11_locales l ON l.id_local = e.id_local
    JOIN ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    JOIN ta_12_passwords u ON u.id_usuario = e.id_usuario
    WHERE e.id_local = p_id_local
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene los adeudos de energía para un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(p_id_local INTEGER)
RETURNS TABLE (
    id_adeudo_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo_energia,
        a.id_energia,
        a.axo,
        a.periodo,
        a.importe,
        sp_calcular_recargos_energia(a.id_adeudo_energia) AS recargos
    FROM ta_11_adeudo_energ a
    JOIN ta_11_energia e ON e.id_energia = a.id_energia
    WHERE e.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_requerimientos_energia
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de energía para un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_energia(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_gastos NUMERIC,
    fecha_emision DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_control,
        r.modulo,
        r.control_otr,
        r.folio,
        r.importe_global,
        r.importe_multa,
        r.importe_gastos,
        r.fecha_emision
    FROM ta_15_apremios r
    WHERE r.modulo = 33 AND r.control_otr = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para recargos según el mes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_mes SMALLINT)
RETURNS TABLE (dia SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_limite)::SMALLINT
    FROM ta_12_diaslimite
    WHERE EXTRACT(MONTH FROM fecha_limite) = p_mes
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_calcular_recargos_energia
-- Tipo: CRUD
-- Descripción: Calcula los recargos de energía para un adeudo específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_calcular_recargos_energia(p_id_adeudo INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_axo SMALLINT;
    v_periodo SMALLINT;
    v_importe NUMERIC;
    v_recargos NUMERIC := 0;
    v_mes_actual SMALLINT;
    v_alo SMALLINT;
    v_dia_actual SMALLINT;
    v_dia_venc SMALLINT;
    v_porcentaje NUMERIC;
    v_mes_calc SMALLINT;
    v_meses INTEGER := 1;
    v_impmescalc NUMERIC;
    v_cont INTEGER;
    v_id_energia INTEGER;
    v_id_local INTEGER;
    v_mercado SMALLINT;
    v_req_count INTEGER;
BEGIN
    SELECT a.axo, a.periodo, a.importe, a.id_energia INTO v_axo, v_periodo, v_importe, v_id_energia
    FROM ta_11_adeudo_energ a WHERE a.id_adeudo_energia = p_id_adeudo;
    SELECT e.id_local INTO v_id_local FROM ta_11_energia e WHERE e.id_energia = v_id_energia;
    SELECT l.num_mercado INTO v_mercado FROM ta_11_locales l WHERE l.id_local = v_id_local;
    SELECT EXTRACT(MONTH FROM CURRENT_DATE)::SMALLINT, EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT, EXTRACT(DAY FROM CURRENT_DATE)::SMALLINT INTO v_mes_actual, v_alo, v_dia_actual;
    SELECT dia INTO v_dia_venc FROM sp_get_dia_vencimiento(v_mes_actual);
    IF v_mercado = 1 THEN
        RETURN 0;
    END IF;
    IF v_axo <= 2002 THEN
        v_meses := 2;
        v_impmescalc := v_importe / 2;
        IF v_periodo = 1 THEN v_mes_calc := 1;
        ELSIF v_periodo = 2 THEN v_mes_calc := 3;
        ELSIF v_periodo = 3 THEN v_mes_calc := 5;
        ELSIF v_periodo = 4 THEN v_mes_calc := 7;
        ELSIF v_periodo = 5 THEN v_mes_calc := 9;
        ELSE v_mes_calc := 11;
        END IF;
    ELSE
        v_meses := 1;
        v_impmescalc := v_importe;
        v_mes_calc := v_periodo;
    END IF;
    FOR v_cont IN 1..v_meses LOOP
        SELECT COALESCE(SUM(porcentaje_mes),0) INTO v_porcentaje
        FROM ta_12_recargos
        WHERE (axo = v_axo AND mes >= v_mes_calc)
           OR (axo = v_alo AND mes <= (CASE WHEN v_dia_actual < v_dia_venc THEN v_mes_actual-1 ELSE v_mes_actual END))
           OR (axo > v_axo AND axo < v_alo);
        SELECT COUNT(*) INTO v_req_count FROM ta_15_apremios WHERE modulo=33 AND control_otr=v_id_local;
        IF v_axo = v_alo THEN
            IF v_periodo = v_mes_actual THEN
                IF v_dia_actual > v_dia_venc THEN
                    IF v_req_count = 0 THEN
                        IF v_porcentaje > 100 THEN
                            v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                        ELSE
                            v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                        END IF;
                    ELSE
                        IF v_porcentaje > 250 THEN
                            v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                        ELSE
                            v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                        END IF;
                    END IF;
                END IF;
            ELSE
                IF v_req_count = 0 THEN
                    IF v_porcentaje > 100 THEN
                        v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                    ELSE
                        v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                    END IF;
                ELSE
                    IF v_porcentaje > 250 THEN
                        v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                    ELSE
                        v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                    END IF;
                END IF;
            END IF;
        ELSE
            IF v_req_count = 0 THEN
                IF v_porcentaje > 100 THEN
                    v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                ELSE
                    v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                END IF;
            ELSE
                IF v_porcentaje > 250 THEN
                    v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                ELSE
                    v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                END IF;
            END IF;
        END IF;
        v_mes_calc := v_mes_calc + 1;
    END LOOP;
    RETURN v_recargos;
END;
$$ LANGUAGE plpgsql;

-- ============================================

