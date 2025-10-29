-- Stored Procedure: buscar_folios_remesa
-- Tipo: Report
-- Descripción: Cuenta los folios de una remesa por tipoact
-- Generado para formulario: Gen_ArcDiario
-- Fecha: 2025-08-27 20:40:42

CREATE OR REPLACE FUNCTION buscar_folios_remesa(p_remesa text, p_tipoact text)
RETURNS integer AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = p_tipoact;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;