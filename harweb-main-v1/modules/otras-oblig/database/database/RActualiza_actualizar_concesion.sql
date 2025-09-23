-- Stored Procedure: actualizar_concesion
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una concesión/local según la opción seleccionada
-- Generado para formulario: RActualiza
-- Fecha: 2025-08-28 13:26:50

CREATE OR REPLACE FUNCTION actualizar_concesion(
    opc INTEGER,
    id_34_datos INTEGER,
    concesionario TEXT,
    ubicacion TEXT,
    licencia INTEGER,
    superficie NUMERIC,
    descrip TEXT,
    aso_ini INTEGER,
    mes_ini INTEGER
) RETURNS TABLE (resultado INTEGER, mensaje TEXT) AS $$
DECLARE
    v_old_concesionario TEXT;
    v_old_ubicacion TEXT;
    v_old_licencia INTEGER;
    v_old_superficie NUMERIC;
    v_old_descrip TEXT;
BEGIN
    SELECT concesionario, ubicacion, licencia, superficie, (SELECT descripcion FROM t34_unidades WHERE id_34_unidad = t34_datos.id_unidad)
    INTO v_old_concesionario, v_old_ubicacion, v_old_licencia, v_old_superficie, v_old_descrip
    FROM t34_datos WHERE id_34_datos = id_34_datos;

    IF opc = 0 THEN
        IF v_old_concesionario = concesionario THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET concesionario = concesionario WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Concesionario actualizado correctamente';
    ELSIF opc = 1 THEN
        IF v_old_ubicacion = ubicacion THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET ubicacion = ubicacion WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Ubicación actualizada correctamente';
    ELSIF opc = 2 THEN
        IF v_old_licencia = licencia THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET licencia = licencia WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Licencia actualizada correctamente';
    ELSIF opc = 3 THEN
        IF v_old_superficie = superficie THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET superficie = superficie WHERE id_34_datos = id_34_datos;
        -- Aquí se puede registrar el cambio de periodo si aplica
        RETURN QUERY SELECT 0, 'Superficie actualizada correctamente';
    ELSIF opc = 4 THEN
        IF v_old_descrip = descrip THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET id_unidad = (SELECT id_34_unidad FROM t34_unidades WHERE descripcion = descrip LIMIT 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Tipo de local actualizado correctamente';
    ELSIF opc = 5 THEN
        -- Inicio de obligación (actualizar fecha_inicio)
        UPDATE t34_datos SET fecha_inicio = make_date(aso_ini, mes_ini, 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Inicio de obligación actualizado correctamente';
    ELSE
        RETURN QUERY SELECT 1, 'Opción no válida';
    END IF;
END;
$$ LANGUAGE plpgsql;