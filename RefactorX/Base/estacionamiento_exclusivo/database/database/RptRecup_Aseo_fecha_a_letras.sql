-- Stored Procedure: fecha_a_letras
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato 'día de Mes de Año' en español.
-- Generado para formulario: RptRecup_Aseo
-- Fecha: 2025-08-27 15:00:57

CREATE OR REPLACE FUNCTION fecha_a_letras(p_fecha date)
RETURNS text AS $$
DECLARE
    meses text[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM p_fecha);
    m := EXTRACT(MONTH FROM p_fecha);
    y := EXTRACT(YEAR FROM p_fecha);
    RETURN d::text || ' de ' || meses[m] || ' de ' || y::text;
END;
$$ LANGUAGE plpgsql;