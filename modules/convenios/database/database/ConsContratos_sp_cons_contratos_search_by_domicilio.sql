-- Stored Procedure: sp_cons_contratos_search_by_domicilio
-- Tipo: Report
-- Descripción: Busca contratos por descripción de calle y número (LIKE)
-- Generado para formulario: ConsContratos
-- Fecha: 2025-08-27 14:09:01

CREATE OR REPLACE FUNCTION sp_cons_contratos_search_by_domicilio(p_desc_calle varchar, p_numero varchar)
RETURNS TABLE(
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo_casa varchar,
    mtrs_frente float,
    mtrs_ancho float,
    metros2 float,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total numeric,
    pago_inicial numeric,
    pago_quincenal numeric,
    pagos_parciales smallint,
    fecha_firma date,
    fecha_vencimiento date,
    escritura varchar,
    propiedad varchar,
    compro_dom varchar,
    otros varchar,
    observacion varchar,
    fecha_impresion date,
    fecha_rev date,
    fecha_cancelado date,
    vigencia varchar,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_17_convenios
    WHERE desc_calle ILIKE '%' || p_desc_calle || '%'
      AND numero ILIKE '%' || p_numero || '%'
    ORDER BY desc_calle ASC, numero ASC, colonia ASC, calle ASC, folio ASC;
END;
$$ LANGUAGE plpgsql;