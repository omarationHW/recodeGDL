CREATE OR REPLACE FUNCTION sp_modificar_datos_generales_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_rec INTEGER,
    p_id_zona INTEGER,
    p_nombre VARCHAR,
    p_calle VARCHAR,
    p_num_exterior INTEGER,
    p_num_interior INTEGER,
    p_inciso VARCHAR,
    p_metros NUMERIC,
    p_observaciones VARCHAR,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_oficio VARCHAR,
    p_fechaoficio DATE,
    p_nombrefirma VARCHAR,
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_manzana VARCHAR,
    p_lote INTEGER,
    p_letra VARCHAR,
    p_letras_ofi VARCHAR,
    p_folio_ofi INTEGER,
    p_alo_oficio INTEGER,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        nombre = p_nombre,
        calle = p_calle,
        num_exterior = p_num_exterior,
        num_interior = p_num_interior,
        inciso = p_inciso,
        metros = p_metros,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual,
        telefono = p_telefono,
        correo = p_correo,
        oficio = p_oficio,
        fechaoficio = p_fechaoficio,
        nombrefirma = p_nombrefirma
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_bloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        bloqueo = 1,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        bloqueo = 0,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_dar_pagado_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        vigencia = 'P',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_dar_baja_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        vigencia = 'B',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_tipo(p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    new_tipo INTEGER;
BEGIN
    SELECT COALESCE(MAX(tipo), 0) + 1 INTO new_tipo FROM ta_17_tipos;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (new_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = new_tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo INTEGER)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    old_tipo INTEGER;
    old_desc VARCHAR;
BEGIN
    SELECT tipo, descripcion INTO old_tipo, old_desc FROM ta_17_tipos WHERE tipo = p_tipo;
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    RETURN QUERY SELECT old_tipo, old_desc;
END;
$$ LANGUAGE plpgsql;