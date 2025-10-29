-- Stored Procedure: rpt_listax_reg_mer
-- Tipo: Report
-- Descripción: Obtiene el listado de registros de mercados con requerimientos, filtrando por vigencia, clave_practicado, num_mercado y oficina.
-- Generado para formulario: RprtListaxRegMer
-- Fecha: 2025-08-27 14:45:29

CREATE OR REPLACE FUNCTION rpt_listax_reg_mer(
    p_vigencia VARCHAR,
    p_clave_practicado VARCHAR,
    p_num_mercado SMALLINT,
    p_oficina SMALLINT
)
RETURNS TABLE (
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR,
    hora_practicado TIMESTAMP,
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR,
    arrendatario VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    zona_1 SMALLINT,
    descripcion_local VARCHAR,
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia_1 VARCHAR,
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR,
    fec_rfc DATE,
    hom_rfc VARCHAR,
    nombre_1 VARCHAR,
    id_rec SMALLINT,
    categoria_1 VARCHAR,
    observacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local as id_control, a.oficina as zona, a.num_mercado as modulo, a.categoria as control_otr, a.seccion as folio, a.local as diligencia,
           b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos, b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado,
           b.fecha_entrega1, b.fecha_entrega2, b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa,
           b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia, b.fecha_actualiz, b.usuario, b.clave_mov,
           b.hora_practicado, b.id_local, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, b.id_contribuy_prop,
           b.id_contribuy_renta, b.nombre, b.arrendatario, b.domicilio, b.sector, b.zona_1, b.descripcion_local, b.superficie, b.giro, b.fecha_alta,
           b.fecha_baja, b.fecha_modificacion, b.vigencia_1, b.id_usuario, b.clave_cuota, c.id_ejecutor, c.cve_eje, c.ini_rfc, c.fec_rfc, c.hom_rfc,
           c.nombre as nombre_1, c.id_rec, c.categoria as categoria_1, c.observacion
    FROM ta_11_locales a
    JOIN ta_15_apremios b ON b.control_otr = a.id_local AND b.modulo = 11
    LEFT JOIN ta_15_ejecutores c ON b.ejecutor = c.cve_eje AND b.zona = c.id_rec
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_num_mercado
      AND (
        (p_clave_practicado <> 'todas' AND b.clave_practicado = p_clave_practicado)
        OR (p_clave_practicado = 'todas')
      )
      AND (
        (p_vigencia <> 'todas' AND (
            (p_vigencia = '2' AND (b.vigencia = p_vigencia OR b.vigencia = 'P'))
            OR (p_vigencia <> '2' AND b.vigencia = p_vigencia)
        ))
        OR (p_vigencia = 'todas')
      );
END;
$$ LANGUAGE plpgsql;