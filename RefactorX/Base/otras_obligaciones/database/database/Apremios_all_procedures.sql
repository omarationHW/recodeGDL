-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Apremios
-- Generado: 2025-08-28 12:35:37
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_apremios
-- Tipo: Catalog
-- Descripción: Obtiene los registros de apremios filtrados por módulo y control, incluyendo el nombre del ejecutor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_apremios(par_modulo integer, par_control integer)
RETURNS TABLE (
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
    ejecutor varchar(50),
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.hora_practicado::time,
           a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora::time, b.usuario AS ejecutor,
           a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON b.id_usuario = a.ejecutor
    WHERE a.modulo = par_modulo
      AND a.control_otr = par_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_periodos_by_control
-- Tipo: Catalog
-- Descripción: Obtiene los periodos requeridos para un control de apremio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_periodos_by_control(id_control integer)
RETURNS TABLE (
    ayo integer,
    periodo integer,
    importe numeric(15,2),
    recargos numeric(15,2),
    cantidad integer,
    tipo varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ayo, periodo, importe, recargos, cantidad, tipo
    FROM ta_15_periodos
    WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_create_apremio
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de apremio.
-- --------------------------------------------

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

-- ============================================

-- SP 4/5: sp_update_apremio
-- Tipo: CRUD
-- Descripción: Actualiza un registro de apremio existente.
-- --------------------------------------------

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

-- ============================================

-- SP 5/5: sp_delete_apremio
-- Tipo: CRUD
-- Descripción: Elimina (o marca como no vigente) un registro de apremio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_apremio(id_control integer)
RETURNS VOID AS $$
BEGIN
    UPDATE ta_15_apremios SET vigencia = '0' WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

