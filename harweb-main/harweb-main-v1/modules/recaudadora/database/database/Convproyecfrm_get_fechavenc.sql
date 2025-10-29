-- Stored Procedure: get_fechavenc
-- Tipo: CRUD
-- Descripción: Obtiene la fecha de vencimiento para una parcialidad dada una fecha base.
-- Generado para formulario: Convproyecfrm
-- Fecha: 2025-08-26 23:54:52

-- PostgreSQL stored procedure para obtener fecha de vencimiento
CREATE OR REPLACE FUNCTION get_fechavenc(p_fec DATE)
RETURNS DATE AS $$
BEGIN
    -- Simulación: sumar 30 días
    RETURN p_fec + INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;