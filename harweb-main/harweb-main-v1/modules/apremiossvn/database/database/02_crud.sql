CREATE OR REPLACE FUNCTION sp_modificar_apremio(
    p_id_control integer,
    p_modulo integer,
    p_folio integer,
    p_usuario integer,
    p_params_json jsonb
) RETURNS TABLE (result text) AS $$
DECLARE
    v_old RECORD;
    v_new RECORD;
    v_hist_id integer;
BEGIN
    -- Obtener registro actual
    SELECT * INTO v_old FROM ta_15_apremios WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'No existe el folio';
        RETURN;
    END IF;
    -- Actualizar registro
    UPDATE ta_15_apremios SET
        usuario = p_usuario,
        fecha_actualiz = CURRENT_DATE,
        zona_apremio = COALESCE((p_params_json->>'zona_apremio')::smallint, zona_apremio),
        observaciones = COALESCE(p_params_json->>'observaciones', observaciones),
        porcentaje_multa = COALESCE((p_params_json->>'porcentaje_multa')::smallint, porcentaje_multa),
        clave_mov = COALESCE(p_params_json->>'clave_mov', clave_mov),
        importe_gastos = COALESCE((p_params_json->>'importe_gastos')::numeric, importe_gastos),
        importe_multa = COALESCE((p_params_json->>'importe_multa')::numeric, importe_multa),
        clave_practicado = COALESCE(p_params_json->>'clave_practicado', clave_practicado),
        fecha_practicado = COALESCE((p_params_json->>'fecha_practicado')::date, fecha_practicado),
        hora_practicado = COALESCE((p_params_json->>'hora_practicado')::time, hora_practicado),
        fecha_citatorio = COALESCE((p_params_json->>'fecha_citatorio')::date, fecha_citatorio),
        hora = COALESCE((p_params_json->>'hora')::time, hora),
        ejecutor = COALESCE((p_params_json->>'ejecutor')::smallint, ejecutor),
        fecha_entrega1 = COALESCE((p_params_json->>'fecha_entrega1')::date, fecha_entrega1),
        fecha_entrega2 = COALESCE((p_params_json->>'fecha_entrega2')::date, fecha_entrega2),
        fecha_pago = COALESCE((p_params_json->>'fecha_pago')::date, fecha_pago),
        recaudadora = COALESCE((p_params_json->>'recaudadora')::smallint, recaudadora),
        caja = COALESCE(p_params_json->>'caja', caja),
        operacion = COALESCE((p_params_json->>'operacion')::integer, operacion),
        importe_pago = COALESCE((p_params_json->>'importe_pago')::numeric, importe_pago),
        clave_secuestro = COALESCE((p_params_json->>'clave_secuestro')::smallint, clave_secuestro),
        clave_remate = COALESCE(p_params_json->>'clave_remate', clave_remate),
        fecha_remate = COALESCE((p_params_json->>'fecha_remate')::date, fecha_remate),
        vigencia = COALESCE(p_params_json->>'vigencia', vigencia)
    WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    -- Insertar historial
    INSERT INTO ta_15_historia (
        id_control, control, zona, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos, zona_apremio, fecha_emision, clave_practicado, fecha_practicado, fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, vigencia, fecha_actualiz, usuario, clave_mov, hora_practicado
    ) VALUES (
        v_old.id_control, v_old.control, v_old.zona, v_old.modulo, v_old.control_otr, v_old.folio, v_old.diligencia, v_old.importe_global, v_old.importe_multa, v_old.importe_recargo, v_old.importe_gastos, v_old.zona_apremio, v_old.fecha_emision, v_old.clave_practicado, v_old.fecha_practicado, v_old.fecha_entrega1, v_old.fecha_entrega2, v_old.fecha_citatorio, v_old.hora, v_old.ejecutor, v_old.clave_secuestro, v_old.clave_remate, v_old.fecha_remate, v_old.porcentaje_multa, v_old.observaciones, v_old.fecha_pago, v_old.recaudadora, v_old.caja, v_old.operacion, v_old.importe_pago, v_old.vigencia, v_old.fecha_actualiz, v_old.usuario, v_old.clave_mov, v_old.hora_practicado
    );
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_user_by_credentials(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre, a.estado, a.id_rec, b.id_zona, b.recaudadora, b.domicilio, b.tel, b.recaudador, a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_new_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE (
    nueva_version BOOLEAN
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version) THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;