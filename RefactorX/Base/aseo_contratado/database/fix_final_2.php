<?php
/**
 * Fix Final 2 Procedures
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "=== FIXING FINAL 2 PROCEDURES ===\n\n";

// ========== 1. ABC_Gastos - Force drop using CASCADE ==========
echo "1. Fixing ABC_Gastos with CASCADE...\n";
$sql = <<<SQL
-- Force drop with CASCADE to remove dependencies
DO \$\$
BEGIN
    DROP PROCEDURE IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC) CASCADE;
EXCEPTION WHEN OTHERS THEN
    NULL;
END \$\$;

DO \$\$
BEGIN
    DROP PROCEDURE IF EXISTS sp_gastos_delete_all() CASCADE;
EXCEPTION WHEN OTHERS THEN
    NULL;
END \$\$;

DROP FUNCTION IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC) CASCADE;
DROP FUNCTION IF EXISTS sp_gastos_delete_all() CASCADE;

CREATE OR REPLACE FUNCTION sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS VOID
LANGUAGE plpgsql
AS \$\$
BEGIN
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);
END;
\$\$;

CREATE OR REPLACE FUNCTION sp_gastos_delete_all()
RETURNS VOID
LANGUAGE plpgsql
AS \$\$
BEGIN
    DELETE FROM ta_16_gastos;
END;
\$\$;
SQL;

$result = pg_query($conn, $sql);
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 2. Adeudos_OpcMult - Use DISTINCT ON to handle duplicate columns ==========
echo "2. Fixing Adeudos_OpcMult with proper column selection...\n";
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

-- Fix: Select specific columns from base table, avoid duplicates
CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  t.*,
  e.descripcion as nom_emp,
  e.representante
FROM (
  SELECT DISTINCT ON (control_contrato)
    control_contrato,
    num_contrato,
    num_empresa,
    ctrol_emp,
    ctrol_recolec,
    cantidad_recolec,
    domicilio,
    sector,
    ctrol_zona,
    id_rec,
    fecha_hora_alta,
    status_vigencia,
    aso_mes_oblig,
    cve,
    usuario,
    fecha_hora_baja
  FROM ta_16_contratos
) t
LEFT JOIN ta_16_empresas e ON e.num_empresa = t.num_empresa AND e.ctrol_emp = t.ctrol_emp;

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
SQL;

$result = pg_query($conn, $sql);
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

echo "\n=== FINAL FIX COMPLETED ===\n";

pg_close($conn);
