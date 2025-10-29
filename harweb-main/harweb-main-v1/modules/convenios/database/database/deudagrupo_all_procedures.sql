-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: deudagrupo
-- Generado: 2025-08-27 14:24:17
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_deuda_grupo
-- Tipo: Report
-- Descripción: Obtiene la relación de adeudos de convenios con recargos calculados a una fecha dada.
-- --------------------------------------------

-- PostgreSQL stored procedure for Deuda Grupo
CREATE OR REPLACE FUNCTION sp_deuda_grupo(p_axo integer, p_fecha_recargo date)
RETURNS TABLE (
    obra smallint,
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar(60),
    pago_total numeric(18,2),
    fecha_vencimiento date,
    numpagos integer,
    pagos numeric(18,2),
    cve_descuento numeric(18,2),
    desc_calle varchar(50),
    descripcion varchar(50),
    devolucion numeric(18,2),
    recargos numeric(18,2),
    recar_conv numeric(18,2),
    total numeric(18,2),
    deuda numeric(18,2)
) AS $$
DECLARE
    r RECORD;
    v_adeudos numeric(18,2);
    v_recargos numeric(18,2);
    v_total numeric(18,2);
    v_porc numeric(18,6);
    alo integer;
    mes integer;
    dia integer;
    alov integer;
    mesv integer;
    diav integer;
    porc numeric(18,6);
BEGIN
    SELECT EXTRACT(YEAR FROM p_fecha_recargo)::integer, EXTRACT(MONTH FROM p_fecha_recargo)::integer, EXTRACT(DAY FROM p_fecha_recargo)::integer
      INTO alo, mes, dia;

    FOR r IN
        SELECT c.axo_obra as obra, a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, a.fecha_vencimiento,
               COUNT(b.id_convenio) as numpagos, COALESCE(SUM(b.importe),0) as pagos, SUM(b.cve_descuento) as cve_descuento,
               c.desc_calle, d.descripcion,
               (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) as devolucion,
               (SELECT COALESCE(SUM(g.importe),0) FROM ta_17_convenios h, ta_17_pagos f, ta_12_recibosdet g
                WHERE h.id_convenio=a.id_convenio AND f.id_convenio=h.id_convenio AND h.clave_historia=2
                  AND g.fecha=f.fecha_pago AND g.id_rec=f.oficina_pago AND g.caja=f.caja_pago AND g.operacion=f.operacion_pago
                  AND g.cuenta IN (46210,570200000)) as recar_conv
        FROM ta_17_convenios a
        LEFT JOIN ta_17_pagos b ON a.id_convenio=b.id_convenio AND b.fecha_pago>=a.fecha_firma
        JOIN ta_17_calles c ON a.colonia=c.colonia AND a.calle=c.calle
        JOIN ta_17_colonias d ON a.colonia=d.colonia
        WHERE c.axo_obra = p_axo AND a.vigencia = 'A' AND SUBSTRING(a.observacion,1,1) NOT IN ('@')
        GROUP BY c.axo_obra, a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion, a.fecha_vencimiento
        HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) +
                (SELECT COALESCE(SUM(g.importe),0) FROM ta_17_convenios h, ta_17_pagos f, ta_12_recibosdet g
                 WHERE h.id_convenio=a.id_convenio AND f.id_convenio=h.id_convenio AND h.clave_historia=2
                   AND g.fecha=f.fecha_pago AND g.id_rec=f.oficina_pago AND g.caja=f.caja_pago AND g.operacion=f.operacion_pago
                   AND g.cuenta IN (46210,570200000)) ) -
                (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio)
               ) > 0
        ORDER BY a.colonia, a.calle, a.folio
    LOOP
        v_adeudos := r.pago_total - (r.pagos + COALESCE(r.recar_conv,0));
        SELECT EXTRACT(YEAR FROM r.fecha_vencimiento)::integer, EXTRACT(MONTH FROM r.fecha_vencimiento)::integer, EXTRACT(DAY FROM r.fecha_vencimiento)::integer
          INTO alov, mesv, diav;
        porc := 0;
        IF v_adeudos < 0 THEN
            v_recargos := 0;
        ELSE
            SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc
              FROM ta_13_recargosrcm
             WHERE (axo=alov AND mes>=mesv)
               AND ((alov=alo AND mes<=CASE WHEN dia<=diav THEN mes-1 ELSE mes END)
                    OR (axo>alov AND axo<alo));
            IF p_fecha_recargo > r.fecha_vencimiento THEN
                IF porc > 100 THEN
                    v_recargos := (v_adeudos*100)/100;
                ELSE
                    v_recargos := (v_adeudos*porc)/100;
                END IF;
            ELSE
                v_recargos := 0;
            END IF;
            IF v_recargos > 0 THEN
                v_recargos := TRUNC(v_recargos*100)/100;
            END IF;
        END IF;
        v_total := v_adeudos + v_recargos;
        RETURN NEXT (
            r.obra, r.id_convenio, r.colonia, r.calle, r.folio, r.nombre, r.pago_total, r.fecha_vencimiento,
            r.numpagos, r.pagos, r.cve_descuento, r.desc_calle, r.descripcion, r.devolucion, v_recargos, r.recar_conv, v_total, v_adeudos
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- ============================================

