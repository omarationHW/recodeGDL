-- Stored Procedure: sp16_alta_empresa
-- Tipo: CRUD
-- Descripción: Da de alta una nueva empresa privada con nombre y representante igual.
-- Generado para formulario: Contratos_UpdxCont
-- Fecha: 2025-08-27 14:22:10

CREATE OR REPLACE FUNCTION sp16_alta_empresa(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
DECLARE
    v_max INTEGER;
BEGIN
    SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM ta_16_empresas WHERE ctrol_emp = 9;
    INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max+1, 9, p_nombre, p_nombre);
    RETURN QUERY SELECT v_max+1, 9, p_nombre, p_nombre;
END;
$$ LANGUAGE plpgsql;