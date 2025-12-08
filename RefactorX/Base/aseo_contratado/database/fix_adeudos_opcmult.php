<?php
/**
 * Fix Adeudos_OpcMult - Final Fix
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "=== FIXING ADEUDOS_OPCMULT ===\n\n";

$sql = <<<SQL
DROP FUNCTION IF EXISTS con16_detade_021(integer) CASCADE;
DROP FUNCTION IF EXISTS upd16_ade(integer, varchar, integer, char, date, integer, varchar, integer, varchar, varchar) CASCADE;
DROP VIEW IF EXISTS vw_contratos_detalle CASCADE;
DROP VIEW IF EXISTS vw_convenios CASCADE;

CREATE OR REPLACE FUNCTION con16_detade_021(p_control integer)
RETURNS TABLE (
  expression integer,
  expression_1 varchar,
  expression_2 varchar,
  expression_3 integer,
  expression_4 integer,
  expression_5 numeric,
  expression_6 numeric
) AS \$\$
BEGIN
  RETURN QUERY
  SELECT
    p.control_contrato,
    to_char(p.aso_mes_pago, 'YYYY-MM')::varchar,
    o.descripcion::varchar,
    p.ctrol_operacion,
    p.exedencias,
    p.importe,
    0.0::numeric
  FROM ta_16_pagos p
  JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
  WHERE p.control_contrato = p_control
    AND p.status_vigencia = 'V';
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upd16_ade(
  p_control_contrato integer,
  p_periodo varchar,
  p_ctrol_oper integer,
  p_vigencia char(1),
  p_fecha date,
  p_reca integer,
  p_caja varchar,
  p_operacion integer,
  p_folio_rcbo varchar,
  p_obs varchar
) RETURNS text AS \$\$
DECLARE
  v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';

  IF v_count = 0 THEN
    RETURN 'No existe adeudo vigente para el periodo';
  END IF;

  UPDATE ta_16_pagos
    SET status_vigencia = p_vigencia,
        fecha_hora_pago = p_fecha,
        id_rec = p_reca,
        caja = p_caja,
        consec_operacion = CASE WHEN p_vigencia = 'P' THEN p_operacion ELSE 0 END,
        folio_rcbo = p_folio_rcbo,
        observaciones = p_obs
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';

  RETURN 'OK';
END;
\$\$ LANGUAGE plpgsql;

-- Simplified view - use MIN(ctid) to get only one row per control_contrato
CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.control_contrato,
  c.num_contrato,
  c.num_empresa,
  c.ctrol_emp,
  c.domicilio,
  c.sector,
  c.id_rec,
  c.fecha_hora_alta,
  c.status_vigencia,
  c.aso_mes_oblig,
  c.cve,
  c.usuario,
  c.fecha_hora_baja,
  e.descripcion as nom_emp,
  e.representante
FROM ta_16_contratos c
LEFT JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp
WHERE c.ctid IN (
  SELECT MIN(ctid)
  FROM ta_16_contratos
  GROUP BY control_contrato
);

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
SQL;

$result = pg_query($conn, $sql);
if ($result) {
    echo "✓ Adeudos_OpcMult fixed and deployed successfully!\n";
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n=== COMPLETED ===\n";
