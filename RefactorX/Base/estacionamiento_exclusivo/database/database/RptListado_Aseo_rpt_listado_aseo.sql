-- Stored Procedure: rpt_listado_aseo
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos para requerimiento de pago y embargo, derechos de aseo contratado, incluyendo cálculo de recargos y gastos.
-- Generado para formulario: RptListado_Aseo
-- Fecha: 2025-08-27 14:51:23

-- SP: rpt_listado_aseo
-- Params: vtipo TEXT, xnum1 INT, xnum2 INT, vrec INT, vaxo INT, vxmes TEXT
CREATE OR REPLACE FUNCTION rpt_listado_aseo(
    vtipo TEXT,
    xnum1 INT,
    xnum2 INT,
    vrec INT,
    vaxo INT,
    vxmes TEXT
)
RETURNS TABLE (
    control_contrato INT,
    num_contrato INT,
    ctrol_aseo INT,
    num_empresa INT,
    ctrol_emp INT,
    ctrol_recolec INT,
    cantidad_recolec SMALLINT,
    domicilio TEXT,
    sector TEXT,
    ctrol_zona INT,
    id_rec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia TEXT,
    aso_mes_oblig DATE,
    cve TEXT,
    usuario INT,
    fecha_hora_baja TIMESTAMP,
    control_contrato_1 INT,
    aso_mes_pago DATE,
    ctrol_operacion INT,
    importe NUMERIC,
    status_vigencia_1 TEXT,
    fecha_hora_pago TIMESTAMP,
    id_rec_1 SMALLINT,
    caja TEXT,
    consec_operacion INT,
    folio_rcbo TEXT,
    usuario_1 INT,
    exedencias SMALLINT,
    ctrol_aseo_1 INT,
    tipo_aseo TEXT,
    descripcion TEXT,
    cta_aplicacion INT,
    num_empresa_1 INT,
    ctrol_emp_1 INT,
    descripcion_1 TEXT,
    representante TEXT,
    ctrol_operacion_1 INT,
    cve_operacion TEXT,
    descripcion_2 TEXT,
    ctrol_zona_1 INT,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_3 TEXT,
    axoade TEXT,
    mesade TEXT,
    total_gasto NUMERIC,
    recargos NUMERIC
) AS $$
DECLARE
    r RECORD;
    vporcentaje FLOAT;
    varaxoper INT;
    varperiodo INT;
BEGIN
    FOR r IN
        SELECT a.*, b.*, c.*, d.*, e.*, f.*,
            to_char(b.aso_mes_pago, 'YYYY') AS axoade,
            to_char(b.aso_mes_pago, 'MM') AS mesade,
            (
                SELECT COALESCE(SUM(importe_gastos),0)
                FROM ta_15_apremios
                WHERE modulo=16 AND control_otr=a.control_contrato AND clave_practicado='P' AND vigencia='1'
            ) AS total_gasto
        FROM ta_16_contratos a
        JOIN ta_16_pagos b ON a.control_contrato = b.control_contrato
        JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
        JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
        JOIN ta_16_operacion e ON b.ctrol_operacion = e.ctrol_operacion
        JOIN ta_16_zonas f ON a.ctrol_zona = f.ctrol_zona
        WHERE b.status_vigencia = 'V'
          AND a.id_rec = vrec
          AND to_char(b.aso_mes_pago, 'YYYY-MM') <= concat(vaxo, '-', vxmes)
          AND (vtipo = 'todos' OR c.tipo_aseo = vtipo)
          AND (xnum1 = 0 OR a.num_contrato BETWEEN xnum1 AND xnum2)
        ORDER BY a.num_contrato, b.aso_mes_pago
    LOOP
        -- Cálculo de recargos
        IF r.ctrol_operacion = 7 THEN
            IF r.mesade::int = 11 THEN
                varaxoper := r.axoade::int + 1;
                varperiodo := 1;
            ELSIF r.mesade::int = 12 THEN
                varaxoper := r.axoade::int + 1;
                varperiodo := 2;
            ELSE
                varperiodo := r.mesade::int + 2;
                varaxoper := r.axoade::int;
            END IF;
        ELSE
            varperiodo := r.mesade::int;
            varaxoper := r.axoade::int;
        END IF;

        SELECT COALESCE(SUM(porcentaje_mes),0) INTO vporcentaje
        FROM padron_licencias.comun.ta_12_recargos
        WHERE (axo = varaxoper AND mes >= varperiodo)
           OR (axo = vaxo AND mes <= vxmes::int)
           OR (axo > varaxoper AND axo < vaxo);

        IF vporcentaje > 250 THEN
            vporcentaje := 250;
        END IF;
        
        -- Recargos calculados
        DECLARE vrecargos NUMERIC := ROUND((r.importe * vporcentaje) / 100.0, 2);

        RETURN NEXT (
            r.control_contrato,
            r.num_contrato,
            r.ctrol_aseo,
            r.num_empresa,
            r.ctrol_emp,
            r.ctrol_recolec,
            r.cantidad_recolec,
            r.domicilio,
            r.sector,
            r.ctrol_zona,
            r.id_rec,
            r.fecha_hora_alta,
            r.status_vigencia,
            r.aso_mes_oblig,
            r.cve,
            r.usuario,
            r.fecha_hora_baja,
            r.control_contrato_1,
            r.aso_mes_pago,
            r.ctrol_operacion,
            r.importe,
            r.status_vigencia_1,
            r.fecha_hora_pago,
            r.id_rec_1,
            r.caja,
            r.consec_operacion,
            r.folio_rcbo,
            r.usuario_1,
            r.exedencias,
            r.ctrol_aseo_1,
            r.tipo_aseo,
            r.descripcion,
            r.cta_aplicacion,
            r.num_empresa_1,
            r.ctrol_emp_1,
            r.descripcion_1,
            r.representante,
            r.ctrol_operacion_1,
            r.cve_operacion,
            r.descripcion_2,
            r.ctrol_zona_1,
            r.zona,
            r.sub_zona,
            r.descripcion_3,
            r.axoade,
            r.mesade,
            r.total_gasto,
            vrecargos
        );
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;