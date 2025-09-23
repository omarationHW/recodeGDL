-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Ejercicios_Ins
-- Generado: 2025-08-27 14:36:01
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_create_ejercicio
-- Tipo: Catalog
-- Descripción: Crea un nuevo ejercicio en la tabla ta_16_ejercicios si no existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_ejercicio(p_ejercicio INTEGER)
RETURNS TEXT AS $$
DECLARE
    existe INTEGER;
BEGIN
    SELECT 1 INTO existe FROM ta_16_ejercicios WHERE ejercicio = p_ejercicio;
    IF existe IS NOT NULL THEN
        RETURN 'YA EXISTE EL EJERCICIO';
    END IF;
    INSERT INTO ta_16_ejercicios (ejercicio, fecha_hora_alta) VALUES (p_ejercicio, NOW());
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

