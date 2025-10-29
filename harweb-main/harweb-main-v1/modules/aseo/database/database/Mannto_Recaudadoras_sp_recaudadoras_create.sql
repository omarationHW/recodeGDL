-- Stored Procedure: sp_recaudadoras_create
-- Tipo: CRUD
-- Descripción: Crea una nueva recaudadora si no existe el número.
-- Generado para formulario: Mannto_Recaudadoras
-- Fecha: 2025-08-27 14:49:12

CREATE OR REPLACE PROCEDURE sp_recaudadoras_create(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'YA EXISTE o EL CAMPO DE NUMERO ES NULO, INTENTA CON OTRO.';
    END IF;
    INSERT INTO ta_16_recaudadoras (num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
END;
$$;