SET search_path TO pavimentacion, public;

CREATE OR REPLACE FUNCTION pavimentacion.sp_empleados_mantener(
  _operacion INT,            -- 0=Consultar, 1=Insertar/Actualizar, 2=Eliminar
  _id        INT DEFAULT 0,
  _nombre    VARCHAR DEFAULT NULL,
  _correo    VARCHAR DEFAULT NULL
)
RETURNS SETOF pavimentacion.empleados
LANGUAGE plpgsql
AS $$
DECLARE
  v_row pavimentacion.empleados%ROWTYPE;
BEGIN
  -- CONSULTAR
  IF _operacion = 0 THEN
    IF _id = 0 THEN
      RETURN QUERY SELECT * FROM pavimentacion.empleados ORDER BY id;
    ELSE
      RETURN QUERY SELECT * FROM pavimentacion.empleados WHERE id = _id;
    END IF;
    RETURN;
  END IF;

  -- INSERTAR / ACTUALIZAR
  IF _operacion = 1 THEN
    IF _id = 0 THEN
      -- INSERTAR
      IF _nombre IS NULL OR _correo IS NULL THEN
        RAISE EXCEPTION 'Para insertar, nombre y correo son obligatorios' USING ERRCODE = '22023';
      END IF;

      INSERT INTO pavimentacion.empleados (nombre, correo, created_at, updated_at)
      VALUES (trim(_nombre), trim(_correo), NOW(), NOW())
      RETURNING * INTO v_row;

      RETURN QUERY SELECT v_row.*;
      RETURN;

    ELSIF _id > 0 THEN
      -- ACTUALIZAR
      IF _nombre IS NULL OR _correo IS NULL THEN
        RAISE EXCEPTION 'Para actualizar, nombre y correo son obligatorios' USING ERRCODE = '22023';
      END IF;

      UPDATE pavimentacion.empleados
         SET nombre = trim(_nombre),
             correo = trim(_correo),
             updated_at = NOW()
       WHERE id = _id
      RETURNING * INTO v_row;

      IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe empleado con id=%', _id USING ERRCODE = '23503';
      END IF;

      RETURN QUERY SELECT v_row.*;
      RETURN;
    ELSE
      RAISE EXCEPTION 'Id inválido para operación 1 (insert/update)' USING ERRCODE = '22023';
    END IF;
  END IF;

  -- ELIMINAR
  IF _operacion = 2 THEN
    IF _id <= 0 THEN
      RAISE EXCEPTION 'Para eliminar, _id debe ser > 0' USING ERRCODE = '22023';
    END IF;

    DELETE FROM pavimentacion.empleados
     WHERE id = _id
    RETURNING * INTO v_row;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'No existe empleado con id=%', _id USING ERRCODE = '23503';
    END IF;

    RETURN QUERY SELECT v_row.*;
    RETURN;
  END IF;

  -- Operación inválida
  RAISE EXCEPTION 'Operación inválida: use 0=Consultar, 1=Insertar/Actualizar, 2=Eliminar' USING ERRCODE = '22023';

EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'El correo % ya existe', _correo USING ERRCODE = '23505';
END;
$$;