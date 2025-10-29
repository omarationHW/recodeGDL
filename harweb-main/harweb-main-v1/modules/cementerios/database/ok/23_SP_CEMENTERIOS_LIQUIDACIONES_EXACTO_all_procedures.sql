-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: LIQUIDACIONES (EXACTO del archivo original)
-- Archivo: 23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_liquidaciones_calcular
-- Tipo: CRUD
-- Descripción: Calcula la liquidación de mantenimiento y recargos para un cementerio, años y metros dados.
-- --------------------------------------------

-- PostgreSQL stored procedure for liquidation calculation
CREATE OR REPLACE FUNCTION sp_liquidaciones_calcular(
    p_cementerio VARCHAR(1),
    p_anio_desde INTEGER,
    p_anio_hasta INTEGER,
    p_metros NUMERIC,
    p_tipo VARCHAR(1), -- 'F', 'U', 'G'
    p_nuevo BOOLEAN,
    p_mes INTEGER
)
RETURNS TABLE(
    axo_cuota INTEGER,
    manten NUMERIC,
    recargos NUMERIC
) AS $$
DECLARE
    v_cuota_col TEXT;
    v_axo INTEGER;
    v_mant NUMERIC;
    v_rec NUMERIC;
    v_porcentaje NUMERIC;
BEGIN
    -- Determinar columna de cuota
    IF p_tipo = 'F' THEN
        v_cuota_col := 'cuota1';
    ELSIF p_tipo = 'U' THEN
        v_cuota_col := 'cuota_urna';
    ELSIF p_tipo = 'G' THEN
        v_cuota_col := 'cuota_gaveta';
    ELSE
        v_cuota_col := 'cuota2';
    END IF;

    FOR v_axo IN p_anio_desde..p_anio_hasta LOOP
        -- Obtener cuota
        EXECUTE format('SELECT %I FROM public.ta_13_rcmcuotas WHERE cementerio = $1 AND axo_cuota = $2', v_cuota_col)
        INTO v_mant USING p_cementerio, v_axo;
        IF v_mant IS NULL THEN v_mant := 0; END IF;
        v_mant := round(v_mant * p_metros, 2);
        -- Calcular recargos
        IF p_nuevo THEN
            v_rec := 0;
        ELSE
            SELECT porcentaje_global FROM public.ta_13_recargosrcm WHERE axo = v_axo AND mes = p_mes INTO v_porcentaje;
            IF v_porcentaje IS NULL THEN v_porcentaje := 0; END IF;
            v_rec := round(v_mant * (v_porcentaje/100), 2);
        END IF;
        axo_cuota := v_axo;
        manten := v_mant;
        recargos := v_rec;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

