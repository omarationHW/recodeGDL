-- Stored Procedure: sp_localesmodif_modificar_local
-- Corregido para trabajar con ta_11_localpaso y 18 parámetros

CREATE OR REPLACE FUNCTION sp_localesmodif_modificar_local(
    p_id_local integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_sector varchar,
    p_zona integer,
    p_descripcion_local varchar,
    p_superficie numeric,
    p_giro integer,
    p_fecha_alta date,
    p_fecha_baja date,
    p_vigencia varchar,
    p_clave_cuota integer,
    p_tipo_movimiento integer,
    p_bloqueo integer,
    p_cve_bloqueo integer,
    p_fecha_inicio_bloqueo date,
    p_fecha_final_bloqueo date,
    p_observacion varchar
) RETURNS TABLE (result text) AS $$
DECLARE
    v_msg text;
    v_id_usuario integer := 1; -- Usuario por defecto
BEGIN
    -- Actualizar local en ta_11_localpaso
    UPDATE public.ta_11_localpaso SET
        nombre = p_nombre,
        domicilio = p_domicilio,
        sector = p_sector,
        zona = p_zona,
        descripcion_local = p_descripcion_local,
        superficie = p_superficie,
        giro = COALESCE(p_giro, 0),
        fecha_alta = p_fecha_alta,
        fecha_baja = p_fecha_baja,
        fecha_modificacion = now(),
        vigencia = p_vigencia,
        id_usuario = v_id_usuario,
        clave_cuota = p_clave_cuota,
        bloqueo = COALESCE(p_bloqueo, 0),
        observacion = p_observacion
    WHERE id_local = p_id_local;

    -- Verificar si se actualizó
    IF FOUND THEN
        v_msg := 'Local modificado correctamente';
    ELSE
        v_msg := 'No se encontró el local';
    END IF;

    RETURN QUERY SELECT v_msg;
END;
$$ LANGUAGE plpgsql;
