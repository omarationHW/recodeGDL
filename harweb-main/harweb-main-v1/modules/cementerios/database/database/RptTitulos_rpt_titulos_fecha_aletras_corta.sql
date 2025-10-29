-- Stored Procedure: rpt_titulos_fecha_aletras_corta
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato 'dd-Mes-aaaa' en español abreviado.
-- Generado para formulario: RptTitulos
-- Fecha: 2025-08-27 14:51:51

CREATE OR REPLACE FUNCTION rpt_titulos_fecha_aletras_corta(fecha date)
RETURNS varchar AS $$
DECLARE
    meses text[] := ARRAY['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM fecha);
    m := EXTRACT(MONTH FROM fecha);
    y := EXTRACT(YEAR FROM fecha);
    RETURN d::text || '-' || meses[m] || '-' || y::text;
END;
$$ LANGUAGE plpgsql;