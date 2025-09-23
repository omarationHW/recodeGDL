-- Stored Procedure: contar_folios_remesa
-- Tipo: Report
-- Descripción: Cuenta los folios de alta asociados a una remesa.
-- Generado para formulario: Gen_ArcAltas
-- Fecha: 2025-08-27 13:40:51

-- PostgreSQL function to count folios
CREATE OR REPLACE FUNCTION contar_folios_remesa(p_remesa text)
RETURNS integer AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta14_datos_mpio WHERE remesa = p_remesa;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;