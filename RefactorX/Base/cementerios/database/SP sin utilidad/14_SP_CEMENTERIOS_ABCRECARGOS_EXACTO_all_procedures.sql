-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: ABCRecargos (EXACTO del archivo original)
-- Archivo: 14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un mes, ordenados por año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list(p_mes integer)
RETURNS TABLE(
    axo integer,
    mes smallint,
    porcentaje_parcial float,
    porcentaje_global float,
    usuario integer,
    fecha_mov date
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov
    FROM public.ta_13_recargosrcm
    WHERE mes = p_mes
    ORDER BY axo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_recargos_get
-- Tipo: Catalog
-- Descripción: Obtiene un registro de recargo por año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_get(p_axo integer, p_mes integer)
RETURNS TABLE(
    axo integer,
    mes smallint,
    porcentaje_parcial float,
    porcentaje_global float,
    usuario integer,
    fecha_mov date
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov
    FROM public.ta_13_recargosrcm
    WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_create(
    p_axo integer,
    p_mes integer,
    p_porcentaje_parcial float,
    p_usuario integer
) RETURNS TABLE(result text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_13_recargosrcm WHERE axo = p_axo AND mes = p_mes;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'Ya existe el registro';
        RETURN;
    END IF;
    INSERT INTO public.ta_13_recargosrcm(axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov)
    VALUES (p_axo, p_mes, p_porcentaje_parcial, 0, p_usuario, CURRENT_DATE);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(
    p_axo integer,
    p_mes integer,
    p_porcentaje_parcial float,
    p_usuario integer
) RETURNS TABLE(result text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_13_recargosrcm WHERE axo = p_axo AND mes = p_mes;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'No existe el registro';
        RETURN;
    END IF;
    UPDATE public.ta_13_recargosrcm
    SET porcentaje_parcial = p_porcentaje_parcial,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_recargos_acumulado
-- Tipo: CRUD
-- Descripción: Recalcula el porcentaje_global acumulado para todos los años y meses posteriores al registro modificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_acumulado(p_axo integer, p_mes integer)
RETURNS TABLE(result text) AS $$
DECLARE
    v_year integer;
    v_month integer;
    v_now_year integer;
    v_now_month integer;
    v_global float;
    v_axo integer;
    v_axo2 integer;
    vmes integer;
    vmes2 integer;
BEGIN
    SELECT EXTRACT(YEAR FROM CURRENT_DATE)::integer INTO v_now_year;
    SELECT EXTRACT(MONTH FROM CURRENT_DATE)::integer INTO v_now_month;
    v_axo := 1994;
    v_axo2 := p_axo;
    IF p_axo < v_now_year THEN
        v_axo2 := p_axo;
    ELSE
        v_axo2 := v_now_year;
    END IF;
    vmes := p_mes;
    vmes2 := 12;
    -- Recalcular para cada año desde 1994 hasta v_axo2
    FOR v_year IN v_axo..v_axo2 LOOP
        IF v_year < v_axo2 THEN
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM public.ta_13_recargosrcm
            WHERE (axo = v_year AND mes >= 3) OR (axo > v_year AND axo < v_axo2) OR (axo = v_axo2 AND mes <= p_mes);
        ELSE
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM public.ta_13_recargosrcm
            WHERE axo = v_year AND mes <= p_mes;
        END IF;
        IF v_global > 100 THEN
            v_global := 100;
        END IF;
        UPDATE public.ta_13_recargosrcm
        SET porcentaje_global = v_global
        WHERE axo = v_year AND mes = p_mes;
    END LOOP;
    -- Si es el año actual y mes actual, actualizar meses siguientes
    IF (p_axo = v_now_year) AND (p_mes = v_now_month) THEN
        FOR v_month IN p_mes+1..vmes2 LOOP
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM public.ta_13_recargosrcm
            WHERE axo = v_now_year AND mes <= v_month;
            UPDATE public.ta_13_recargosrcm
            SET porcentaje_global = v_global
            WHERE axo = v_now_year AND mes = v_month;
        END LOOP;
    END IF;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================