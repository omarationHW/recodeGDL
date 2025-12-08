<?php
/**
 * Fix Adeudos_OpcMult - Without vw_convenios
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "=== FIXING ADEUDOS_OPCMULT (SKIP MISSING TABLES) ===\n\n";

$sql = <<<SQL
DROP FUNCTION IF EXISTS con16_detade_021(integer) CASCADE;
DROP FUNCTION IF EXISTS upd16_ade(integer, varchar, integer, char, date, integer, varchar, integer, varchar, varchar) CASCADE;
DROP VIEW IF EXISTS vw_contratos_detalle CASCADE;

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
    COALESCE(p.exedencias, 0),
    COALESCE(p.importe, 0.0),
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

-- Minimal view - only essential columns that we know exist
CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT DISTINCT ON (control_contrato)
  control_contrato,
  num_contrato,
  num_empresa,
  ctrol_emp,
  status_vigencia
FROM ta_16_contratos;
SQL;

$result = pg_query($conn, $sql);
if ($result) {
    echo "✓ Adeudos_OpcMult fixed and deployed successfully!\n";
    echo "  Note: vw_convenios skipped (ta_17_referencia table does not exist)\n";
} else {
    echo "✗ Error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n=== COMPLETED ===\n";
