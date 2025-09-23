-- Stored Procedure: sp_gen_individual_add
-- Tipo: CRUD
-- Descripción: Busca registros en ta14_folios_histo según opción (placa, placa+folio, axo+folio) y los inserta en ta14_datos_mpio para la remesa indicada.
-- Generado para formulario: Gen_Individual
-- Fecha: 2025-08-27 13:46:40

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