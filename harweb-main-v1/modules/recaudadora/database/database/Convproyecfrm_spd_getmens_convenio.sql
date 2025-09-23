-- Stored Procedure: spd_getmens_convenio
-- Tipo: CRUD
-- Descripción: Calcula la proyección de pagos de convenio predial con porcentaje inicial.
-- Generado para formulario: Convproyecfrm
-- Fecha: 2025-08-26 23:54:52

-- PostgreSQL stored procedure for convenio proyección con porcentaje inicial
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
    v_inicial := p_importe * (p_porcentaje::NUMERIC / 100);
    v_mensualidad := (p_importe - v_inicial) / (p_mensualidades - 1);
    -- Parcialidad inicial
    v_deaxo := EXTRACT(YEAR FROM v_fecha);
    v_debim := CEIL(EXTRACT(MONTH FROM v_fecha) / 2);
    v_haaxo := v_deaxo;
    v_habim := v_debim;
    v_tbim := 1;
    v_impuesto := v_inicial * 0.7;
    v_recargos := v_inicial * 0.2;
    v_gastos := v_inicial * 0.05;
    v_multa := v_inicial * 0.05;
    fec_venc := v_fecha;
    RETURN NEXT;
    v_fecha := v_fecha + INTERVAL '1 month';
    -- Resto de parcialidades
    FOR v_idx IN 2..p_mensualidades LOOP
        v_deaxo := EXTRACT(YEAR FROM v_fecha);
        v_debim := CEIL(EXTRACT(MONTH FROM v_fecha) / 2);
        v_haaxo := v_deaxo;
        v_habim := v_debim;
        v_tbim := 1;
        v_impuesto := v_mensualidad * 0.7;
        v_recargos := v_mensualidad * 0.2;
        v_gastos := v_mensualidad * 0.05;
        v_multa := v_mensualidad * 0.05;
        fec_venc := v_fecha;
        RETURN NEXT;
        v_fecha := v_fecha + INTERVAL '1 month';
    END LOOP;
END;
$$ LANGUAGE plpgsql;