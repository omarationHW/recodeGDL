-- Stored Procedure: fecha_aletras
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato de letras en español (ejemplo: '5 de Junio de 2024').
-- Generado para formulario: RptRecup_Merc
-- Fecha: 2025-08-27 15:03:18

CREATE OR REPLACE FUNCTION fecha_aletras(p_fecha DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    y INT;
    m INT;
    d INT;
BEGIN
    y := EXTRACT(YEAR FROM p_fecha)::INT;
    m := EXTRACT(MONTH FROM p_fecha)::INT;
    d := EXTRACT(DAY FROM p_fecha)::INT;
    RETURN d::TEXT || ' de ' || meses[m] || ' de ' || y::TEXT;
END;
$$ LANGUAGE plpgsql;