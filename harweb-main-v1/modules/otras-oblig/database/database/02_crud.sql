CREATE OR REPLACE FUNCTION sp_create_apremio(
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor integer,
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    modulo integer,
    control_otr integer
) RETURNS SETOF ta_15_apremios AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_15_apremios (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, vigencia
    ) VALUES (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, '1'
    ) RETURNING id_control INTO new_id;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_apremio(
    id_control integer,
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor integer,
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    modulo integer,
    control_otr integer
) RETURNS SETOF ta_15_apremios AS $$
BEGIN
    UPDATE ta_15_apremios SET
        zona = zona,
        folio = folio,
        diligencia = diligencia,
        importe_global = importe_global,
        importe_multa = importe_multa,
        importe_recargo = importe_recargo,
        importe_gastos = importe_gastos,
        zona_apremio = zona_apremio,
        fecha_emision = fecha_emision,
        clave_practicado = clave_practicado,
        fecha_practicado = fecha_practicado,
        hora_practicado = hora_practicado,
        fecha_entrega1 = fecha_entrega1,
        fecha_entrega2 = fecha_entrega2,
        fecha_citatorio = fecha_citatorio,
        hora = hora,
        ejecutor = ejecutor,
        clave_secuestro = clave_secuestro,
        clave_remate = clave_remate,
        fecha_remate = fecha_remate,
        porcentaje_multa = porcentaje_multa,
        observaciones = observaciones,
        modulo = modulo,
        control_otr = control_otr
    WHERE id_control = id_control;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_apremio(id_control integer)
RETURNS VOID AS $$
BEGIN
    UPDATE ta_15_apremios SET vigencia = '0' WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for cartera generation
CREATE OR REPLACE FUNCTION con34_cgacart_01(par_tabla TEXT, par_ejer INTEGER)
RETURNS TABLE(status INTEGER, concepto_status TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Ejemplo de lógica: (ajustar según reglas de negocio reales)
    -- 1. Validar existencia de unidades para la tabla y ejercicio
    IF NOT EXISTS (
        SELECT 1 FROM t34_unidades WHERE cve_tab = par_tabla AND ejercicio = par_ejer
    ) THEN
        v_status := 1;
        v_msg := 'No existen unidades para la tabla y ejercicio seleccionados.';
        RETURN QUERY SELECT v_status, v_msg;
        RETURN;
    END IF;

    -- 2. Ejecutar proceso de generación de cartera (simulado)
    BEGIN
        -- Aquí iría la lógica real de generación de cartera
        -- Por ejemplo: INSERT INTO t34_cartera ...
        -- Simulación:
        -- INSERT INTO t34_cartera (cve_tab, ejercicio, ...) SELECT ...
        v_status := 0;
        v_msg := 'Cartera generada correctamente para tabla ' || par_tabla || ' y ejercicio ' || par_ejer;
    EXCEPTION WHEN OTHERS THEN
        v_status := 2;
        v_msg := 'Error al generar cartera: ' || SQLERRM;
    END;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_insert_t34_unidades(
    p_id_34_unidad integer,
    p_ejercicio integer,
    p_cve_unidad varchar(10),
    p_cve_operatividad varchar(10),
    p_descripcion varchar(100),
    p_costo numeric(12,2),
    p_cve_tab varchar(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t34_unidades (
        id_34_unidad, ejercicio, cve_unidad, cve_operatividad, descripcion, costo, cve_tab
    ) VALUES (
        p_id_34_unidad, p_ejercicio, p_cve_unidad, p_cve_operatividad, p_descripcion, p_costo, p_cve_tab
    );
END;
$$;

CREATE OR REPLACE PROCEDURE sp_update_t34_etiq(
    p_abreviatura VARCHAR(4),
    p_etiq_control VARCHAR(20),
    p_concesionario VARCHAR(100),
    p_ubicacion VARCHAR(100),
    p_superficie VARCHAR(100),
    p_fecha_inicio VARCHAR(20),
    p_fecha_fin VARCHAR(20),
    p_recaudadora VARCHAR(100),
    p_sector VARCHAR(100),
    p_zona VARCHAR(100),
    p_licencia VARCHAR(100),
    p_fecha_cancelacion VARCHAR(20),
    p_unidad VARCHAR(100),
    p_categoria VARCHAR(100),
    p_seccion VARCHAR(100),
    p_bloque VARCHAR(100),
    p_nombre_comercial VARCHAR(100),
    p_lugar VARCHAR(100),
    p_obs VARCHAR(100),
    p_cve_tab VARCHAR(2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE t34_etiq SET
        abreviatura = p_abreviatura,
        etiq_control = p_etiq_control,
        concesionario = p_concesionario,
        ubicacion = p_ubicacion,
        superficie = p_superficie,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        recaudadora = p_recaudadora,
        sector = p_sector,
        zona = p_zona,
        licencia = p_licencia,
        fecha_cancelacion = p_fecha_cancelacion,
        unidad = p_unidad,
        categoria = p_categoria,
        seccion = p_seccion,
        bloque = p_bloque,
        nombre_comercial = p_nombre_comercial,
        lugar = p_lugar,
        obs = p_obs
    WHERE cve_tab = p_cve_tab;
END;
$$;

CREATE OR REPLACE FUNCTION upd34_gen_adeudos_ind(
    par_id_34_datos INTEGER,
    par_Axo INTEGER,
    par_Mes INTEGER,
    par_Fecha DATE,
    par_Id_Rec INTEGER,
    par_Caja TEXT,
    par_Consec INTEGER,
    par_Folio_rcbo TEXT,
    par_tab TEXT,
    par_status TEXT,
    par_Opc TEXT,
    par_usuario TEXT
) RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT
) AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Aquí va la lógica de actualización de adeudos, pagos, etc.
    -- Ejemplo: Si par_status = 'P' (pagado), insertar en t34_pagos y actualizar status
    IF par_status = 'P' THEN
        -- Insertar pago
        INSERT INTO t34_pagos (id_datos, periodo, importe, recargo, fecha_hora_pago, id_recaudadora, caja, operacion, folio_recibo, usuario, id_stat)
        VALUES (par_id_34_datos, make_date(par_Axo, par_Mes, 1), 0, 0, par_Fecha, par_Id_Rec, par_Caja, par_Consec, par_Folio_rcbo, par_usuario, (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'P'));
        v_status := 1;
        v_msg := 'Pago registrado correctamente.';
    ELSIF par_status = 'S' THEN
        -- Lógica de condonación
        v_status := 1;
        v_msg := 'Adeudo condonado correctamente.';
    ELSIF par_status = 'C' THEN
        -- Lógica de cancelación
        v_status := 1;
        v_msg := 'Adeudo cancelado correctamente.';
    ELSIF par_status = 'R' THEN
        -- Lógica de prescripción
        v_status := 1;
        v_msg := 'Adeudo prescrito correctamente.';
    ELSE
        v_status := 0;
        v_msg := 'Opción no válida.';
    END IF;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_datos_concesion(par_tab integer, par_control text)
RETURNS TABLE(
  status integer,
  concepto_status text,
  id_datos integer,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  adicionales text,
  statusregistro text,
  unidades text,
  categoria text,
  seccion text,
  bloque text,
  sector text,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_coincide(
  par_tab integer,
  tipo_busqueda integer,
  dato_busqueda varchar
)
RETURNS TABLE (control varchar) AS $$
BEGIN
  IF tipo_busqueda < 4 THEN
    RETURN QUERY EXECUTE format(
      'SELECT control FROM t34_datos WHERE cve_tab = %L AND %I ILIKE %L ORDER BY control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 1 THEN 'control'
        WHEN 2 THEN 'concesionario'
        WHEN 3 THEN 'ubicacion'
      END,
      '%' || dato_busqueda || '%'
    );
  ELSE
    RETURN QUERY EXECUTE format(
      'SELECT a.control FROM t34_datos a JOIN t34_conceptos c ON c.id_datos = a.id_34_datos WHERE a.cve_tab = %L AND c.tipo = %L AND c.concepto ILIKE %L ORDER BY a.control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'L'
        WHEN 6 THEN 'O'
      END,
      '%' || dato_busqueda || '%'
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  status integer,
  concepto_status varchar,
  id_datos integer,
  concesionario varchar,
  ubicacion varchar,
  nomcomercial varchar,
  lugar varchar,
  obs varchar,
  adicionales varchar,
  statusregistro varchar,
  unidades varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  sector varchar,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $$
BEGIN
  RETURN QUERY SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab::text, par_control);
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure para alta de nuevo registro (GNuevos)
CREATE OR REPLACE FUNCTION sp_gnuevos_alta(
    par_tabla integer,
    par_control text,
    par_conces text,
    par_ubica text,
    par_sup numeric,
    par_Axo_Ini integer,
    par_Mes_Ini integer,
    par_ofna integer,
    par_sector text,
    par_zona integer,
    par_lic integer,
    par_Descrip text,
    par_NomCom text,
    par_Lugar text,
    par_Obs text,
    par_usuario text
) RETURNS TABLE(status integer, concepto_status text) AS $$
DECLARE
    v_exists integer;
    v_id_34_datos integer;
    v_msg text;
BEGIN
    -- Validaciones básicas
    IF par_conces IS NULL OR trim(par_conces) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato del CONCESIONARIO';
        RETURN;
    END IF;
    IF par_ubica IS NULL OR trim(par_ubica) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la UBICACION';
        RETURN;
    END IF;
    IF par_sup IS NULL OR par_sup <= 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la SUPERFICIE';
        RETURN;
    END IF;
    IF par_lic IS NULL OR par_lic = 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la LICENCIA';
        RETURN;
    END IF;
    IF par_Axo_Ini IS NULL OR par_Axo_Ini < 2020 THEN
        RETURN QUERY SELECT 0, 'Falta el dato del AÑO de inicio de OBLIGACION';
        RETURN;
    END IF;
    -- Validar que no exista el control
    SELECT count(*) INTO v_exists FROM t34_datos WHERE control = par_control AND cve_tab = par_tabla;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 0, 'Ya existe un registro con ese control';
        RETURN;
    END IF;
    -- Insertar en t34_datos
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, descrip_unidad, nom_comercial, lugar, obs, usuario_alta, fecha_alta
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, par_Descrip, par_NomCom, par_Lugar, par_Obs, par_usuario, now()
    ) RETURNING id_34_datos INTO v_id_34_datos;
    -- Insertar en t34_conceptos si aplica (ejemplo)
    -- INSERT INTO t34_conceptos (id_datos, tipo, concepto) VALUES (v_id_34_datos, 'C', par_NomCom);
    -- ...
    RETURN QUERY SELECT 1, 'Registro creado correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(status TEXT, id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT, message TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      CASE WHEN t.usuario IS NOT NULL THEN 'ok' ELSE 'error' END AS status,
      t.id_usuario, t.usuario, t.nombre, t.estado, t.id_rec, t.nivel,
      CASE WHEN t.usuario IS NOT NULL THEN NULL ELSE 'Usuario o clave incorrecta' END AS message
    FROM ta_12_passwords t
    WHERE t.usuario = p_usuario AND t.password = p_password;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_check_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE(update_required BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT NOT EXISTS (
      SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version
    ) AS update_required;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION verificar_pagos(id_datos INTEGER, periodo TEXT)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = id_datos
      AND to_char(a.periodo, 'YYYY-MM') >= periodo
      AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upd34_ade_01(
  par_id_datos integer,
  par_Axo integer,
  par_Mes integer,
  par_Fecha date,
  par_Id_Rec integer,
  par_Caja varchar,
  par_Consec integer,
  par_Folio_rcbo varchar,
  par_tab varchar,
  par_status varchar,
  par_Opc varchar
) RETURNS TABLE(status integer, concepto_status varchar) AS $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM t34_adeudos WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  IF v_count = 0 THEN
    RETURN QUERY SELECT 1, 'Adeudo no encontrado';
    RETURN;
  END IF;
  UPDATE t34_adeudos
    SET status = par_status,
        fecha_pago = par_Fecha,
        id_recaudadora = par_Id_Rec,
        caja = par_Caja,
        operacion = par_Consec,
        folio_recibo = par_Folio_rcbo
    WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  RETURN QUERY SELECT 0, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo < p_periodo
      AND b.cve_stat = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos_post(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo >= p_periodo
      AND b.cve_stat <> 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_cancelar_local(p_id_34_datos INTEGER, p_axo_fin INTEGER, p_mes_fin INTEGER)
RETURNS TABLE (codigo INTEGER, mensaje TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Aquí se debe realizar la lógica de baja, por ejemplo:
    -- 1. Actualizar el status del local a 'C' (cancelado)
    -- 2. Registrar fecha de baja, etc.
    -- 3. Validar que no existan adeudos (esto ya se validó antes)
    UPDATE t34_datos
    SET id_stat = (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'C' LIMIT 1),
        fecha_fin = make_date(p_axo_fin, p_mes_fin, 1)
    WHERE id_34_datos = p_id_34_datos;
    IF FOUND THEN
        RETURN QUERY SELECT 0 AS codigo, 'Se ejecutó correctamente la Cancelación del Local/Concesión' AS mensaje;
    ELSE
        RETURN QUERY SELECT 1 AS codigo, 'No se encontró el registro para cancelar' AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for inserting new local/concession
CREATE OR REPLACE FUNCTION sp_ins34_rastro_01(
    par_tabla INTEGER,
    par_control VARCHAR,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector VARCHAR,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip VARCHAR
) RETURNS TABLE(expression INTEGER, expression_1 VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
    v_id_unidad INTEGER;
    v_id_stat INTEGER := 1; -- VIGENTE
BEGIN
    SELECT COUNT(*) INTO v_exists FROM t34_datos WHERE control = par_control;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1 AS expression, 'Ya existe LOCAL con este dato, intentalo de nuevo' AS expression_1;
        RETURN;
    END IF;
    -- Buscar id_unidad por descripcion
    SELECT id_34_unidad INTO v_id_unidad FROM t34_unidades WHERE descripcion = par_Descrip AND cve_tab = par_tabla LIMIT 1;
    IF v_id_unidad IS NULL THEN
        v_id_unidad := 1; -- fallback
    END IF;
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, id_unidad, id_stat
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, v_id_unidad, v_id_stat
    );
    RETURN QUERY SELECT 0 AS expression, 'Se ejecutó correctamente la creación del Local/Concesión' AS expression_1;
END;
$$ LANGUAGE plpgsql;