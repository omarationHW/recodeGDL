-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Gen_Individual
-- Generado: 2025-08-27 13:46:40
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_gen_individual_add
-- Tipo: CRUD
-- Descripción: Busca registros en ta14_folios_histo según opción (placa, placa+folio, axo+folio) y los inserta en ta14_datos_mpio para la remesa indicada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    p_opcion integer, -- 0=placa, 1=placa+folio, 2=axo+folio
    p_placa varchar, 
    p_axo integer, 
    p_folio varchar, -- puede ser lista separada por coma
    p_remesa varchar
) RETURNS TABLE(
    idrmunicipio integer,
    tipoact varchar,
    folio bigint,
    placa varchar,
    fechapago date,
    fechacancelado date,
    fechaalta date,
    folioecmpio varchar,
    remesa varchar,
    fecharemesa date
) AS $$
DECLARE
    r RECORD;
    folios_arr integer[];
    folio_item integer;
    v_tipoact varchar;
    v_fechapago date;
    v_folioecmpio varchar;
    v_idrmunicipio integer := 113;
    v_fecharemesa date := CURRENT_DATE;
BEGIN
    IF p_folio IS NOT NULL THEN
        folios_arr := string_to_array(replace(p_folio, ' ', ''), ',')::integer[];
    END IF;
    FOR r IN
        SELECT * FROM ta14_folios_histo
        WHERE (
            (p_opcion = 0 AND placa = p_placa)
            OR (p_opcion = 1 AND placa = p_placa AND folio = ANY(folios_arr))
            OR (p_opcion = 2 AND axo = p_axo AND folio = ANY(folios_arr))
        )
    LOOP
        -- Determinar tipoact
        IF r.codigo_movto IN (3,4,5,6,8,9,10,13,24) THEN
            v_tipoact := 'PN';
        ELSE
            v_tipoact := 'C';
        END IF;
        -- Buscar fechapago y folioecmpio
        IF r.codigo_movto IN (3,4,5,6,8,9,13,24) THEN
            SELECT fecha_recibo, reca || '-' || fecha_recibo || '-' || caja || '-' || operacion
            INTO v_fechapago, v_folioecmpio
            FROM ta14_refrecibo WHERE control = r.control LIMIT 1;
            IF v_fechapago IS NULL THEN
                v_fechapago := r.fecha_movto;
                v_folioecmpio := '';
            END IF;
        ELSIF r.codigo_movto = 10 THEN
            SELECT fec_pago INTO v_fechapago FROM ta14_fol_banorte WHERE axo = r.axo AND folio = r.folio LIMIT 1;
            IF v_fechapago IS NULL THEN
                v_fechapago := r.fecha_movto;
                v_folioecmpio := '';
            ELSE
                v_folioecmpio := 'Pago en Banorte ' || r.fecha_movto;
            END IF;
        ELSE
            v_fechapago := r.fecha_movto;
            v_folioecmpio := '';
        END IF;
        -- Insertar en ta14_datos_mpio
        INSERT INTO ta14_datos_mpio (
            idrmunicipio, tipoact, folio, fechagenreq, placa, folionot, fechanot, fechapago, fechacancelado, importe, clave, fechaalta, fechavenc, folioec, folioecmpio, gastos, remesa, fecharemesa
        ) VALUES (
            v_idrmunicipio, v_tipoact, (r.axo*10000000)+r.folio, NULL, r.placa, NULL, NULL, v_fechapago, r.fecha_movto, NULL, NULL, r.fecha_folio, NULL, NULL, v_folioecmpio, NULL, p_remesa, v_fecharemesa
        )
        ON CONFLICT DO NOTHING;
        RETURN NEXT (v_idrmunicipio, v_tipoact, (r.axo*10000000)+r.folio, r.placa, v_fechapago, r.fecha_movto, r.fecha_folio, v_folioecmpio, p_remesa, v_fecharemesa);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_gen_individual_execute
-- Tipo: CRUD
-- Descripción: Registra la remesa en ta14_bitacora y retorna el conteo de pagos normales y cancelaciones.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gen_individual_execute(
    p_remesa varchar
) RETURNS TABLE(
    pagos_normales integer,
    cancelaciones integer,
    total integer
) AS $$
DECLARE
    pn integer;
    can integer;
    num_remesa integer;
    fecha_fin date;
    fecha_inicio date;
BEGIN
    SELECT COUNT(*) INTO pn FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = 'PN';
    SELECT COUNT(*) INTO can FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = 'C';
    SELECT COALESCE(MAX(num_remesa),0)+1 INTO num_remesa FROM ta14_bitacora WHERE tipo IN ('C','B','D');
    SELECT fecha_inicio, fecha_fin INTO fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1;
    -- Insertar en bitacora
    INSERT INTO ta14_bitacora (control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg)
    VALUES (0, 'C', fecha_inicio, fecha_fin, CURRENT_DATE, num_remesa, pn+can);
    RETURN QUERY SELECT pn, can, pn+can;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_gen_individual_generate_file
-- Tipo: Report
-- Descripción: Devuelve los datos de la remesa en formato de texto plano, cada campo separado por '|'.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gen_individual_generate_file(
    p_remesa varchar
) RETURNS TABLE(
    idrmunicipio integer,
    tipoact varchar,
    folio varchar,
    fechagenreq varchar,
    placa varchar,
    folionot varchar,
    fechanot varchar,
    fechapago varchar,
    fechacancelado varchar,
    importe numeric,
    clave integer,
    fechaalta varchar,
    fechavenc varchar,
    folioec numeric,
    folioecmpio varchar,
    gastos numeric,
    remesa varchar,
    fecharemesa varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        idrmunicipio,
        tipoact,
        folio::varchar,
        to_char(fechagenreq, 'MM/DD/YYYY'),
        placa,
        folionot,
        to_char(fechanot, 'MM/DD/YYYY'),
        to_char(fechapago, 'MM/DD/YYYY'),
        to_char(fechacancelado, 'MM/DD/YYYY'),
        importe,
        clave,
        to_char(fechaalta, 'MM/DD/YYYY'),
        to_char(fechavenc, 'MM/DD/YYYY'),
        folioec,
        folioecmpio,
        gastos,
        remesa,
        to_char(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio
    WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

