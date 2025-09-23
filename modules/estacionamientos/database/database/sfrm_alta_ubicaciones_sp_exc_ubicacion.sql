-- Stored Procedure: sp_exc_ubicacion
-- Tipo: CRUD
-- Descripción: Alta de ubicaciones para estacionamiento exclusivo. Inserta una nueva ubicación asociada a un contrato.
-- Generado para formulario: sfrm_alta_ubicaciones
-- Fecha: 2025-08-27 14:07:39

-- PostgreSQL stored procedure for alta de ubicaciones
CREATE OR REPLACE FUNCTION sp_exc_ubicacion(
    opc integer,
    id_ubic integer,
    contrato_id integer,
    tipo_esta varchar,
    calle varchar,
    colonia varchar,
    zona integer,
    subzona integer,
    extencion numeric,
    acera varchar,
    inter varchar,
    inter2 varchar,
    apartir integer,
    hacia varchar,
    usuario integer
)
RETURNS TABLE(id integer, mensaje varchar) AS $$
DECLARE
    new_id integer;
BEGIN
    IF opc = 1 THEN -- Alta
        INSERT INTO ubicaciones (
            contrato_id, tipo_esta, calle, colonia, zona, subzona, extencion, acera, inter, inter2, apartir, hacia, usuario_alta, fecha_alta
        ) VALUES (
            contrato_id, tipo_esta, calle, colonia, zona, subzona, extencion, acera, inter, inter2, apartir, hacia, usuario, NOW()
        ) RETURNING id INTO new_id;
        RETURN QUERY SELECT new_id, 'Alta de Ubicación realizada correctamente.';
    ELSE
        RETURN QUERY SELECT NULL::integer, 'Operación no soportada.';
    END IF;
END;
$$ LANGUAGE plpgsql;
