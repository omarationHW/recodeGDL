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
    out_idrmunicipio integer,
    out_tipoact varchar,
    out_folio bigint,
    out_placa varchar,
    out_fechapago date,
    out_fechacancelado date,
    out_fechaalta date,
    out_folioecmpio varchar,
    out_remesa varchar,
    out_fecharemesa date
) AS $$
DECLARE
    r RECORD;
    folios_arr integer[];
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
        SELECT t.* FROM ta14_folios_histo t
        WHERE (
            (p_opcion = 0 AND t.placa = p_placa)
            OR (p_opcion = 1 AND t.placa = p_placa AND t.folio = ANY(folios_arr))
            OR (p_opcion = 2 AND t.axo = p_axo AND t.folio = ANY(folios_arr))
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
            SELECT ref.fecha_recibo, ref.reca || '-' || ref.fecha_recibo || '-' || ref.caja || '-' || ref.operacion
            INTO v_fechapago, v_folioecmpio
            FROM ta14_refrecibo ref WHERE ref.control = r.control LIMIT 1;
            IF v_fechapago IS NULL THEN
                v_fechapago := r.fecha_movto;
                v_folioecmpio := '';
            END IF;
        ELSIF r.codigo_movto = 10 THEN
            SELECT ban.fec_pago INTO v_fechapago FROM ta14_fol_banorte ban WHERE ban.axo = r.axo AND ban.folio = r.folio LIMIT 1;
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
            v_idrmunicipio, v_tipoact, (r.axo::bigint*10000000)+r.folio, NULL, r.placa, NULL, NULL, v_fechapago, r.fecha_movto, NULL, NULL, r.fecha_folio, NULL, NULL, v_folioecmpio, NULL, p_remesa, v_fecharemesa
        )
        ON CONFLICT DO NOTHING;

        -- Retornar registro insertado
        out_idrmunicipio := v_idrmunicipio;
        out_tipoact := v_tipoact;
        out_folio := (r.axo::bigint*10000000)+r.folio;
        out_placa := r.placa;
        out_fechapago := v_fechapago;
        out_fechacancelado := r.fecha_movto;
        out_fechaalta := r.fecha_folio;
        out_folioecmpio := v_folioecmpio;
        out_remesa := p_remesa;
        out_fecharemesa := v_fecharemesa;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;