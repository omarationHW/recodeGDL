-- Stored Procedure: sp_condonacion_borrar_mayores_mes
-- Tipo: CRUD
-- Descripción: Borra los adeudos mayores al mes actual para un local.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 19:19:54

CREATE OR REPLACE PROCEDURE sp_condonacion_borrar_mayores_mes(
    p_id_local integer,
    p_id_usuario integer,
    p_categoria integer,
    p_seccion varchar,
    p_clave_cuota integer,
    p_superficie numeric,
    p_clave varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ano integer := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mes integer := EXTRACT(MONTH FROM CURRENT_DATE);
BEGIN
    DELETE FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND (axo > v_ano OR (axo = v_ano AND periodo > v_mes));
END;
$$;