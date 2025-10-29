-- Stored Procedure: fechasegfrm_save
-- Tipo: CRUD
-- Descripción: Guarda un registro de fecha y oficio en la tabla fechasegfrm.
-- Generado para formulario: fechasegfrm
-- Fecha: 2025-08-27 17:41:32

CREATE OR REPLACE FUNCTION fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR)
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO fechasegfrm (fecha, oficio, created_at)
    VALUES (p_fecha, p_oficio, NOW())
    RETURNING id, fecha, oficio, created_at INTO new_id, fechasegfrm_save.fecha, fechasegfrm_save.oficio, fechasegfrm_save.created_at;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;