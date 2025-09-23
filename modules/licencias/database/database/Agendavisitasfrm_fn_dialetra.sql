-- Stored Procedure: fn_dialetra
-- Tipo: Catalog
-- Descripción: Devuelve el nombre del día de la semana en español a partir del número de día (0=domingo, 1=lunes, ...).
-- Generado para formulario: Agendavisitasfrm
-- Fecha: 2025-08-27 15:54:49

CREATE OR REPLACE FUNCTION fn_dialetra(p_dia INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
BEGIN
    IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
        RETURN '';
    END IF;
    RETURN dias[p_dia+1];
END;
$$ LANGUAGE plpgsql IMMUTABLE;