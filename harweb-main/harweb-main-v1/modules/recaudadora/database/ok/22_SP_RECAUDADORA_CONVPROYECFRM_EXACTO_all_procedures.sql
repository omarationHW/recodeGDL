-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Convproyecfrm (Convenio Proyección)
-- Generado: 2025-08-26 23:54:52
-- Total SPs: 3
-- ============================================

-- SP 1/3: spd_mens_convenio
-- Tipo: CRUD
-- Descripción: Calcula la proyección de pagos de convenio predial por mensualidades, importe y fecha inicial.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_mens_convenio(
    p_cvecuenta INTEGER,
    p_mensualidades INTEGER,
    p_importe NUMERIC,
    p_fecha DATE
)
RETURNS TABLE(
    s_parcial INTEGER,
    s_deaxo INTEGER,
    s_debim INTEGER,
    s_haaxo INTEGER,
    s_habim INTEGER,
    s_impuesto NUMERIC,
    s_recagos NUMERIC,
    s_gastos NUMERIC,
    s_multa NUMERIC,
    s_tbim INTEGER,
    fec_venc DATE
) AS $$
DECLARE
    v_mensualidad NUMERIC;
    v_fecha DATE := p_fecha;
    v_cuenta INTEGER := p_cvecuenta;
    v_idx INTEGER := 1;
    v_deaxo INTEGER;
    v_debim INTEGER;
    v_haaxo INTEGER;
    v_habim INTEGER;
    v_tbim INTEGER;
    v_impuesto NUMERIC;
    v_recargos NUMERIC;
    v_gastos NUMERIC;
    v_multa NUMERIC;
BEGIN
    -- Calcular mensualidad base
    v_mensualidad := p_importe / p_mensualidades;
    
    -- Generar proyección para cada mensualidad
    FOR v_idx IN 1..p_mensualidades LOOP
        s_parcial := v_idx;
        v_deaxo := EXTRACT(YEAR FROM v_fecha);
        v_debim := CEIL(EXTRACT(MONTH FROM v_fecha) / 2);
        v_haaxo := v_deaxo;
        v_habim := v_debim;
        v_tbim := 1;
        
        -- Distribución simulada de importes
        v_impuesto := v_mensualidad * 0.7;  -- 70% impuesto
        v_recargos := v_mensualidad * 0.2;  -- 20% recargos  
        v_gastos := v_mensualidad * 0.05;   -- 5% gastos
        v_multa := v_mensualidad * 0.05;    -- 5% multa
        
        s_deaxo := v_deaxo;
        s_debim := v_debim;
        s_haaxo := v_haaxo;
        s_habim := v_habim;
        s_impuesto := v_impuesto;
        s_recagos := v_recargos;
        s_gastos := v_gastos;
        s_multa := v_multa;
        s_tbim := v_tbim;
        fec_venc := v_fecha;
        
        RETURN NEXT;
        
        -- Avanzar al siguiente mes
        v_fecha := v_fecha + INTERVAL '1 month';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: spd_getmens_convenio
-- Tipo: CRUD
-- Descripción: Calcula la proyección de pagos de convenio predial con porcentaje inicial.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_getmens_convenio(
    p_cvecuenta INTEGER,
    p_mensualidades INTEGER,
    p_importe NUMERIC,
    p_porcentaje INTEGER,
    p_fecha DATE
)
RETURNS TABLE(
    s_parcial INTEGER,
    s_deaxo INTEGER,
    s_debim INTEGER,
    s_haaxo INTEGER,
    s_habim INTEGER,
    s_impuesto NUMERIC,
    s_recagos NUMERIC,
    s_gastos NUMERIC,
    s_multa NUMERIC,
    s_tbim INTEGER,
    fec_venc DATE
) AS $$
DECLARE
    v_mensualidad NUMERIC;
    v_inicial NUMERIC;
    v_fecha DATE := p_fecha;
    v_cuenta INTEGER := p_cvecuenta;
    v_idx INTEGER := 1;
    v_deaxo INTEGER;
    v_debim INTEGER;
    v_haaxo INTEGER;
    v_habim INTEGER;
    v_tbim INTEGER;
    v_impuesto NUMERIC;
    v_recargos NUMERIC;
    v_gastos NUMERIC;
    v_multa NUMERIC;
BEGIN
    -- Calcular pago inicial y mensualidades restantes
    v_inicial := p_importe * (p_porcentaje::NUMERIC / 100);
    v_mensualidad := (p_importe - v_inicial) / (p_mensualidades - 1);
    
    -- Parcialidad inicial (pago del porcentaje)
    s_parcial := 1;
    v_deaxo := EXTRACT(YEAR FROM v_fecha);
    v_debim := CEIL(EXTRACT(MONTH FROM v_fecha) / 2);
    v_haaxo := v_deaxo;
    v_habim := v_debim;
    v_tbim := 1;
    
    -- Distribución del pago inicial
    v_impuesto := v_inicial * 0.7;
    v_recargos := v_inicial * 0.2;
    v_gastos := v_inicial * 0.05;
    v_multa := v_inicial * 0.05;
    
    s_deaxo := v_deaxo;
    s_debim := v_debim;
    s_haaxo := v_haaxo;
    s_habim := v_habim;
    s_impuesto := v_impuesto;
    s_recagos := v_recargos;
    s_gastos := v_gastos;
    s_multa := v_multa;
    s_tbim := v_tbim;
    fec_venc := v_fecha;
    
    RETURN NEXT;
    
    -- Avanzar al siguiente mes
    v_fecha := v_fecha + INTERVAL '1 month';
    
    -- Resto de parcialidades
    FOR v_idx IN 2..p_mensualidades LOOP
        s_parcial := v_idx;
        v_deaxo := EXTRACT(YEAR FROM v_fecha);
        v_debim := CEIL(EXTRACT(MONTH FROM v_fecha) / 2);
        v_haaxo := v_deaxo;
        v_habim := v_debim;
        v_tbim := 1;
        
        -- Distribución de las mensualidades restantes
        v_impuesto := v_mensualidad * 0.7;
        v_recargos := v_mensualidad * 0.2;
        v_gastos := v_mensualidad * 0.05;
        v_multa := v_mensualidad * 0.05;
        
        s_deaxo := v_deaxo;
        s_debim := v_debim;
        s_haaxo := v_haaxo;
        s_habim := v_habim;
        s_impuesto := v_impuesto;
        s_recagos := v_recargos;
        s_gastos := v_gastos;
        s_multa := v_multa;
        s_tbim := v_tbim;
        fec_venc := v_fecha;
        
        RETURN NEXT;
        
        -- Avanzar al siguiente mes
        v_fecha := v_fecha + INTERVAL '1 month';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: get_fechavenc
-- Tipo: CRUD
-- Descripción: Obtiene la fecha de vencimiento para una parcialidad dada una fecha base.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_fechavenc(p_fec DATE)
RETURNS DATE AS $$
BEGIN
    -- Agregar 30 días a la fecha base para obtener fecha de vencimiento
    RETURN p_fec + INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================