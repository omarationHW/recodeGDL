-- Stored Procedure: sp_eje_delete
-- Tipo: CRUD
-- Descripción: Elimina un ejecutor (baja lógica)
-- Generado para formulario: FrmEje
-- Fecha: 2025-08-27 21:17:33

CREATE OR REPLACE FUNCTION sp_eje_delete(p_id INTEGER) RETURNS TABLE(deleted BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET vigente = 'C', fecbaj = NOW() WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;