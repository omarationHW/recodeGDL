-- Stored Procedure: sp_modificar_datos_generales_convenio_diversos
-- Tipo: CRUD
-- Descripción: Modifica los datos generales de un convenio diversos
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

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