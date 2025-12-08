-- FIX: Recrear sp_gactualiza_grales_update con parámetros correctos
-- Fecha: 2025-12-04
-- Problema: SP recibía jsonb pero frontend envía 8 parámetros individuales

-- Eliminar la función anterior que recibe jsonb
DROP FUNCTION IF EXISTS sp_gactualiza_grales_update(jsonb);

-- Crear función con los 8 parámetros que envía el frontend
CREATE OR REPLACE FUNCTION sp_gactualiza_grales_update(
    par_id_34_datos integer,
    par_conces varchar,
    par_ubica varchar,
    par_lic integer,
    par_nomcom varchar,
    par_lugar varchar,
    par_obs varchar,
    par_usuario varchar
)
RETURNS TABLE (
    status integer,
    concepto varchar
) AS $func$
DECLARE
    v_affected integer := 0;
BEGIN
    -- Actualizar datos en t34_datos
    UPDATE t34_datos
    SET
        concesionario = CASE WHEN par_conces IS NOT NULL AND par_conces != '' THEN par_conces ELSE concesionario END,
        ubicacion = CASE WHEN par_ubica IS NOT NULL AND par_ubica != '' THEN par_ubica ELSE ubicacion END,
        licencia = CASE WHEN par_lic IS NOT NULL AND par_lic > 0 THEN par_lic ELSE licencia END,
        usuario = COALESCE(par_usuario, 'SISTEMA'),
        fecha_registro = CURRENT_DATE
    WHERE id_34_datos = par_id_34_datos;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT 0::integer, 'Datos generales actualizados correctamente'::varchar;
    ELSE
        RETURN QUERY SELECT -1::integer, 'No se encontró el registro a actualizar'::varchar;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT -2::integer, ('Error: ' || SQLERRM)::varchar;
END;
$func$ LANGUAGE plpgsql;
