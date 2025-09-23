-- Stored Procedure: sp_insert_predio_virtual
-- Tipo: CRUD
-- Descripción: Inserta o actualiza los registros de predio_virtual a partir de un JSON de predios.
-- Generado para formulario: sdmWebService
-- Fecha: 2025-08-27 13:58:58

CREATE OR REPLACE FUNCTION sp_insert_predio_virtual(json_data json)
RETURNS TABLE (
    cvecuenta integer,
    recaud smallint,
    tipo varchar(20),
    cuenta integer,
    cvecatastral varchar(20),
    subpredio smallint,
    propietario varchar(20),
    calle varchar(20),
    numext varchar(20),
    numint varchar(20),
    colonia varchar(20),
    zona integer,
    subzona integer,
    status smallint,
    mensaje varchar(20)
) AS $$
DECLARE
    predio json;
BEGIN
    -- Limpiar tabla temporal (si aplica)
    DELETE FROM predio_virtual;
    
    FOR predio IN SELECT * FROM json_array_elements(json_data)
    LOOP
        INSERT INTO predio_virtual (
            cvecuenta, recaud, tipo, cuenta, cvecatastral, subpredio, propietario, calle, numext, numint, colonia, zona, subzona, status, mensaje
        ) VALUES (
            (predio->>'cvecuenta')::integer,
            (predio->>'recaud')::smallint,
            predio->>'tipo',
            (predio->>'cuenta')::integer,
            predio->>'cvecatastral',
            (predio->>'subpredio')::smallint,
            predio->>'propietario',
            predio->>'calle',
            predio->>'numext',
            predio->>'numint',
            predio->>'colonia',
            (predio->>'zona')::integer,
            (predio->>'subzona')::integer,
            (predio->>'status')::smallint,
            predio->>'mensaje'
        )
        RETURNING *;
    END LOOP;
END;
$$ LANGUAGE plpgsql;