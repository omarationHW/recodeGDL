-- Stored Procedure: rprt_listados
-- Tipo: Report
-- Descripción: Obtiene el listado de requerimientos de folios según los filtros y módulo, incluyendo datos relacionados y campos calculados.
-- Generado para formulario: RprtListados
-- Fecha: 2025-08-27 14:35:35

-- DROP FUNCTION IF EXISTS rprt_listados(integer, integer, integer, integer, text, text, date, date);
CREATE OR REPLACE FUNCTION rprt_listados(
    vrec integer,
    vmod integer,
    vfol1 integer,
    vfol2 integer,
    vcve text,
    vvig text,
    vfdsd date,
    vfhst date
)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado text,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate text,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones text,
    fecha_pago date,
    recaudadora smallint,
    caja text,
    operacion integer,
    importe_pago numeric,
    vigencia text,
    fecha_actualiz date,
    usuario integer,
    clave_mov text,
    hora_practicado timestamp,
    nombre text,
    datos text,
    recaudadora_1 text,
    zona_1 text
) AS $$
DECLARE
    r RECORD;
    datos_calc text;
BEGIN
    FOR r IN
        SELECT a.*, b.nombre, c.recaudadora AS recaudadora_1, d.zona AS zona_1
        FROM ta_15_apremios a
        LEFT JOIN ta_15_ejecutores b ON a.zona = b.id_rec
        JOIN ta_12_recaudadoras c ON a.zona = c.id_rec
        JOIN ta_12_zonas d ON c.id_zona = d.id_zona
        WHERE a.zona = vrec
          AND a.modulo = vmod
          AND a.folio BETWEEN vfol1 AND vfol2
          AND (
            (vcve = 'todas') OR
            (vcve = 'P' AND a.clave_practicado = vcve AND a.fecha_practicado BETWEEN vfdsd AND vfhst) OR
            (vcve <> 'todas' AND vcve <> 'P' AND a.clave_practicado = vcve)
          )
          AND (
            (vvig = 'todas') OR
            (vvig = '2' AND (a.vigencia = vvig OR a.vigencia = 'P')) OR
            (vvig <> 'todas' AND vvig <> '2' AND a.vigencia = vvig)
          )
    LOOP
        -- Calcula campo 'datos' según módulo
        datos_calc := NULL;
        IF r.modulo = 11 THEN
            SELECT CONCAT_WS('-',
                COALESCE(m.oficina::text, 'S/R'),
                COALESCE(m.num_mercado::text, 'S/R'),
                COALESCE(m.categoria::text, 'S/R'),
                COALESCE(m.seccion, 'S/R'),
                COALESCE(m.local::text, 'S/R'),
                COALESCE(m.letra_local, 'S/R'),
                COALESCE(m.bloque, 'S/R')
            ) INTO datos_calc
            FROM ta_11_locales m WHERE m.id_local = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSIF r.modulo = 16 THEN
            SELECT CONCAT_WS('-',
                COALESCE(a.tipo_aseo, 'S/R'),
                COALESCE(a.num_contrato::text, 'S/R')
            ) INTO datos_calc
            FROM ta_16_contratos a
            WHERE a.control_contrato = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSIF r.modulo = 24 THEN
            SELECT CONCAT('PUB. ', COALESCE(p.numesta::text, 'S/R')) INTO datos_calc
            FROM pubmain p WHERE p.id = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSIF r.modulo = 28 THEN
            SELECT CONCAT('EXC. ', COALESCE(e.no_exclusivo::text, 'S/R')) INTO datos_calc
            FROM ex_contrato e WHERE e.id = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSIF r.modulo = 14 THEN
            SELECT CONCAT('PLACA ', COALESCE(i.placa, 'S/R')) INTO datos_calc
            FROM ta_padron i WHERE i.id = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSIF r.modulo = 13 THEN
            SELECT CONCAT('Folio Cem. ', COALESCE(c.control_rcm::text, 'S/R')) INTO datos_calc
            FROM ta_13_datosrcm c WHERE c.control_rcm = r.control_otr;
            IF datos_calc IS NULL THEN datos_calc := 'S/R'; END IF;
        ELSE
            datos_calc := NULL;
        END IF;

        RETURN NEXT (
            r.id_control, r.zona, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_recargo, r.importe_gastos,
            r.zona_apremio, r.fecha_emision, r.clave_practicado, r.fecha_practicado, r.fecha_entrega1, r.fecha_entrega2, r.fecha_citatorio, r.hora,
            r.ejecutor, r.clave_secuestro, r.clave_remate, r.fecha_remate, r.porcentaje_multa, r.observaciones, r.fecha_pago, r.recaudadora, r.caja,
            r.operacion, r.importe_pago, r.vigencia, r.fecha_actualiz, r.usuario, r.clave_mov, r.hora_practicado, r.nombre, datos_calc, r.recaudadora_1, r.zona_1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;