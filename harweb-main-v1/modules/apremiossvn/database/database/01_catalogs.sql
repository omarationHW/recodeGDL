CREATE OR REPLACE FUNCTION sp_lista_eje_get(p_rec integer, p_rec1 integer)
RETURNS TABLE (
    id_ejecutor integer,
    cve_eje integer,
    ini_rfc varchar(4),
    fec_rfc date,
    hom_rfc varchar(3),
    nombre varchar(60),
    id_rec smallint,
    categoria varchar(60),
    observacion varchar(60),
    oficio varchar(14),
    fecinic date,
    fecterm date,
    vigencia varchar(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE id_rec >= p_rec AND id_rec <= p_rec1
    ORDER BY id_rec, cve_eje;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_vigencias()
RETURNS TABLE(clave VARCHAR, descrip VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT clave, descrip FROM ta_15_claves WHERE tipo_clave=5 ORDER BY clave;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_ejecutores(p_rec INT)
RETURNS TABLE(cve_eje INT, nombre VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT cve_eje, nombre FROM ta_15_ejecutores WHERE id_rec = p_rec ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_apremio(p_modulo integer, p_folio integer, p_recaudadora integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_control, zona, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos, zona_apremio, fecha_emision, clave_practicado, fecha_practicado, fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, vigencia, fecha_actualiz, usuario, clave_mov
    FROM ta_15_apremios
    WHERE modulo = p_modulo AND folio = p_folio AND zona = p_recaudadora;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_historial_apremio(p_id_control integer)
RETURNS TABLE (
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    observaciones varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha_actualiz, usuario, clave_mov, observaciones
    FROM ta_15_historia
    WHERE id_control = p_id_control
    ORDER BY fecha_actualiz DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION date_to_words(p_date DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    dia INT;
    mes INT;
    anio INT;
BEGIN
    dia := EXTRACT(DAY FROM p_date);
    mes := EXTRACT(MONTH FROM p_date);
    anio := EXTRACT(YEAR FROM p_date);
    RETURN dia::TEXT || ' de ' || meses[mes] || ' de ' || anio::TEXT;
END;
$$ LANGUAGE plpgsql;