-- Stored Procedure: sp_localesmodif_modificar_local
-- Tipo: CRUD
-- Descripción: Realiza la modificación de un local en ta_11_localpaso
-- Generado para formulario: LocalesModif
-- Fecha: 2025-11-28 (Corregido)

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
    -- Actualizar local en ta_11_locales
    -- Truncar campos con restricciones de longitud para evitar errores
    UPDATE publico.ta_11_locales SET
        nombre = SUBSTRING(p_nombre, 1, 60),
        domicilio = SUBSTRING(p_domicilio, 1, 70),
        sector = SUBSTRING(p_sector, 1, 1),
        zona = p_zona,
        descripcion_local = SUBSTRING(p_descripcion_local, 1, 20),
        superficie = p_superficie,
        giro = COALESCE(p_giro, 0),
        fecha_alta = p_fecha_alta,
        fecha_baja = p_fecha_baja,
        fecha_modificacion = now(),
        vigencia = SUBSTRING(p_vigencia, 1, 1),
        id_usuario = v_id_usuario,
        clave_cuota = p_clave_cuota,
        bloqueo = COALESCE(p_bloqueo, 0),
        observacion = SUBSTRING(COALESCE(p_observacion, ''), 1, 250)
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