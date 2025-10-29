-- Stored Procedure: sp_insertar_adeudo_local
-- Tipo: CRUD
-- Descripción: Inserta un registro de adeudo local para el tianguis (Mercado 214)
-- Generado para formulario: PasoAdeudos
-- Fecha: 2025-08-27 00:27:26

CREATE OR REPLACE PROCEDURE sp_insertar_adeudo_local(
    p_id_local INTEGER,
    p_ano INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC,
    p_actualizacion TIMESTAMP,
    p_id_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_adeudo_local (
        id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_ano, p_periodo, p_importe, p_actualizacion, p_id_usuario
    );
END;
$$;