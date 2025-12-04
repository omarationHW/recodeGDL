-- Stored Procedure: sp_insertar_adeudo_local
-- Tipo: CRUD
-- Descripción: Inserta un registro de adeudo local para el tianguis (Mercado 214)
-- Generado para formulario: PasoAdeudos
-- Fecha: 2025-08-27 00:27:26
-- Actualizado: 2025-12-04 - Corregir schema y cambiar a FUNCTION con retorno

DROP FUNCTION IF EXISTS sp_insertar_adeudo_local(INTEGER, INTEGER, INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION sp_insertar_adeudo_local(
    p_id_local INTEGER,
    p_ano INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Verificar si ya existe el adeudo
    SELECT COUNT(*) INTO v_existe
    FROM comun.ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_ano
      AND periodo = p_periodo;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un adeudo para este local en el periodo especificado';
        RETURN;
    END IF;

    -- Insertar el adeudo
    INSERT INTO comun.ta_11_adeudo_local (
        id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        p_id_local, p_ano, p_periodo, p_importe, NOW(), p_id_usuario
    );

    RETURN QUERY SELECT true, 'Adeudo insertado correctamente';
END;
$$;

COMMENT ON FUNCTION sp_insertar_adeudo_local(INTEGER, INTEGER, INTEGER, NUMERIC, INTEGER) IS
'Inserta un registro de adeudo local para el tianguis (Mercado 214)';