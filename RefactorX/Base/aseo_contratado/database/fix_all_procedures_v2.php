<?php
/**
 * Fix and Deploy All Aseo Contratado Stored Procedures - Version 2
 * Comprehensive fix for all 14 SQL files
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "=== FIXING AND DEPLOYING ASEO_CONTRATADO PROCEDURES V2 ===\n\n";

$results = [];

// ========== 1. ABC_Gastos_all_procedures.sql ==========
echo "1. Fixing ABC_Gastos_all_procedures.sql...\n";
$sql = <<<SQL
-- Drop any existing versions
DROP PROCEDURE IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP PROCEDURE IF EXISTS sp_gastos_delete_all();
DROP FUNCTION IF EXISTS sp_gastos_delete_all();

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
$results[] = ['file' => 'ABC_Gastos_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 2. AdeudosExe_Del_all_procedures.sql ==========
echo "2. Fixing AdeudosExe_Del_all_procedures.sql...\n";
$sql = <<<SQL
DROP PROCEDURE IF EXISTS sp_adeudos_exe_del_fisica(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS sp_adeudos_exe_del_fisica(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER);
DROP PROCEDURE IF EXISTS sp_adeudos_exe_del_logica(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, TEXT, INTEGER);
DROP FUNCTION IF EXISTS sp_adeudos_exe_del_logica(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, TEXT, INTEGER);
DROP FUNCTION IF EXISTS sp_adeudos_exe_del_list_contrato(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION sp_adeudos_exe_del_fisica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    OUT p_deleted INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql AS \$\$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;

    IF v_control_contrato IS NULL THEN
        p_deleted := 0;
        RETURN;
    END IF;

    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');

    DELETE FROM ta_16_pagos
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago::text LIKE v_periodo || '%'
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';

    GET DIAGNOSTICS p_deleted = ROW_COUNT;
END;
\$\$;

CREATE OR REPLACE FUNCTION sp_adeudos_exe_del_logica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    p_oficio TEXT,
    p_usuario_id INTEGER,
    OUT p_updated INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql AS \$\$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;

    IF v_control_contrato IS NULL THEN
        p_updated := 0;
        RETURN;
    END IF;

    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');

    UPDATE ta_16_pagos
    SET status_vigencia = 'B', usuario = p_usuario_id, folio_rcbo = p_oficio
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago::text LIKE v_periodo || '%'
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';

    GET DIAGNOSTICS p_updated = ROW_COUNT;
END;
\$\$;

-- Fixed: column reference is directly on ta_16_contratos, no JOIN needed to ta_16_unidades on ctrol_recolec
CREATE OR REPLACE FUNCTION sp_adeudos_exe_del_list_contrato(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_unidad NUMERIC,
    aso_mes_oblig TEXT
) LANGUAGE plpgsql AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec,
           b.costo_unidad, a.aso_mes_oblig::text
    FROM ta_16_contratos a
    LEFT JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    WHERE a.num_contrato = p_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
END;
\$\$;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'AdeudosExe_Del_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 3. Adeudos_OpcMult_all_procedures.sql ==========
echo "3. Fixing Adeudos_OpcMult_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS con16_detade_021(integer);
DROP FUNCTION IF EXISTS upd16_ade(integer, varchar, integer, char, date, integer, varchar, integer, varchar, varchar);
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
    to_char(p.aso_mes_pago, 'YYYY-MM'),
    o.descripcion,
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

-- Fixed: Remove duplicate status_vigencia column
CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT DISTINCT ON (c.control_contrato)
  c.control_contrato, c.num_contrato, c.ctrol_aseo, c.num_empresa, c.ctrol_emp,
  c.ctrol_recolec, c.cantidad_recolec, c.domicilio, c.sector, c.ctrol_zona,
  c.id_rec, c.fecha_hora_alta, c.status_vigencia, c.aso_mes_oblig, c.cve,
  c.usuario, c.fecha_hora_baja,
  e.descripcion as nom_emp, e.representante
FROM ta_16_contratos c
LEFT JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Adeudos_OpcMult_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 4. Cons_Empresas (already OK) ==========
echo "4. Cons_Empresas_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'Cons_Empresas_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== 5. Contratos_Upd_01 (already OK) ==========
echo "5. Contratos_Upd_01_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'Contratos_Upd_01_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== 6. Licencias_Relacionadas (already OK) ==========
echo "6. Licencias_Relacionadas_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'Licencias_Relacionadas_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== 7. Mannto_Empresas_all_procedures.sql ==========
echo "7. Fixing Mannto_Empresas_all_procedures.sql...\n";
$sql = <<<SQL
-- Drop all existing versions with different signatures
DROP FUNCTION IF EXISTS sp_empresas_list();
DROP FUNCTION IF EXISTS sp_empresas_list(integer, integer, integer, text, text, character);
DROP FUNCTION IF EXISTS sp_empresas_get(INT, INT);
DROP FUNCTION IF EXISTS sp_empresas_create(INT, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS sp_empresas_update(INT, INT, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS sp_empresas_delete(INT, INT);
DROP FUNCTION IF EXISTS sp_tipos_emp_list();

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS \$\$
BEGIN
  RETURN QUERY SELECT DISTINCT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY num_empresa, ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_get(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS \$\$
BEGIN
  RETURN QUERY SELECT DISTINCT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp LIMIT 1;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT, num_empresa INT) AS \$\$
DECLARE
  v_max INT;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max + 1, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT TRUE, 'Empresa creada correctamente'::TEXT, v_max + 1;
EXCEPTION WHEN unique_violation THEN
  RETURN QUERY SELECT FALSE, 'Ya existe una empresa con ese número y tipo'::TEXT, NULL::INT;
WHEN OTHERS THEN
  RETURN QUERY SELECT FALSE, ('Error al crear empresa: ' || SQLERRM)::TEXT, NULL::INT;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_update(p_num_empresa INT, p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
BEGIN
  UPDATE ta_16_empresas SET descripcion = p_descripcion, representante = p_representante
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa actualizada correctamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada'::TEXT;
  END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_count > 0 THEN
    RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.'::TEXT;
    RETURN;
  END IF;
  DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa eliminada correctamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada'::TEXT;
  END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(ctrol_emp INT, tipo_empresa VARCHAR, descripcion VARCHAR) AS \$\$
BEGIN
  RETURN QUERY SELECT DISTINCT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Mannto_Empresas_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 8. Mannto_Gastos_all_procedures.sql (same as #1) ==========
echo "8. Mannto_Gastos_all_procedures.sql (same as ABC_Gastos)...\n";
$results[] = ['file' => 'Mannto_Gastos_all_procedures.sql', 'status' => 'OK (same as #1)'];
echo "   ✓ OK\n";

// ========== 9. Mannto_Recargos_all_procedures.sql ==========
echo "9. Fixing Mannto_Recargos_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_recargos_list(INTEGER);
DROP FUNCTION IF EXISTS sp_recargos_create(INTEGER, INTEGER, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS sp_recargos_update(INTEGER, INTEGER, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS sp_recargos_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year INTEGER)
RETURNS TABLE(ano_mes TEXT, ano INTEGER, mes INTEGER, porc_recargo NUMERIC, porc_multa NUMERIC) AS \$\$
BEGIN
  RETURN QUERY
    SELECT TO_CHAR(aso_mes_recargo, 'YYYY-MM') AS ano_mes,
           EXTRACT(YEAR FROM aso_mes_recargo)::INTEGER AS ano,
           EXTRACT(MONTH FROM aso_mes_recargo)::INTEGER AS mes,
           porc_recargo, porc_multa
      FROM ta_16_recargos
     WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_year
     ORDER BY aso_mes_recargo;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_recargos_create(p_year INTEGER, p_month INTEGER, p_porc_recargo NUMERIC, p_porc_multa NUMERIC)
RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT FALSE, 'Ya existe un recargo para ese periodo'::TEXT;
    RETURN;
  END IF;
  INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (v_date, p_porc_recargo, p_porc_multa);
  RETURN QUERY SELECT TRUE, 'Recargo creado correctamente'::TEXT;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_recargos_update(p_year INTEGER, p_month INTEGER, p_porc_recargo NUMERIC, p_porc_multa NUMERIC)
RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo'::TEXT;
    RETURN;
  END IF;
  UPDATE ta_16_recargos
     SET porc_recargo = p_porc_recargo,
         porc_multa = p_porc_multa
   WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo actualizado correctamente'::TEXT;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_recargos_delete(p_year INTEGER, p_month INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo'::TEXT;
    RETURN;
  END IF;
  DELETE FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo eliminado correctamente'::TEXT;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Mannto_Recargos_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 10. Mannto_Tipos_Aseo (already OK) ==========
echo "10. Mannto_Tipos_Aseo_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'Mannto_Tipos_Aseo_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== 11. Mannto_Zonas_all_procedures.sql ==========
echo "11. Fixing Mannto_Zonas_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_zonas_create(smallint, smallint, varchar);
DROP FUNCTION IF EXISTS sp_zonas_update(smallint, smallint, varchar);
DROP FUNCTION IF EXISTS sp_zonas_delete(integer);

CREATE OR REPLACE FUNCTION sp_zonas_create(p_zona smallint, p_sub_zona smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text, ctrol_zona integer) AS \$\$
DECLARE
  v_exists integer;
  v_ctrol integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe la zona/sub-zona'::text, NULL::integer;
    RETURN;
  END IF;
  INSERT INTO ta_16_zonas (ctrol_zona, zona, sub_zona, descripcion)
    VALUES (DEFAULT, p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona INTO v_ctrol;
  RETURN QUERY SELECT true, 'Zona creada correctamente'::text, v_ctrol;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_zonas_update(p_zona smallint, p_sub_zona smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS \$\$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'No existe la zona/sub-zona'::text;
    RETURN;
  END IF;
  UPDATE ta_16_zonas SET descripcion = p_descripcion WHERE zona = p_zona AND sub_zona = p_sub_zona;
  RETURN QUERY SELECT true, 'Zona actualizada correctamente'::text;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(success boolean, message text) AS \$\$
DECLARE
  v_emp integer;
BEGIN
  SELECT COUNT(*) INTO v_emp FROM ta_16_contratos WHERE ctrol_zona = p_ctrol_zona;
  IF v_emp > 0 THEN
    RETURN QUERY SELECT false, 'Existen contratos con esta zona. No se puede borrar.'::text;
    RETURN;
  END IF;
  DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
  IF FOUND THEN
    RETURN QUERY SELECT true, 'Zona eliminada correctamente'::text;
  ELSE
    RETURN QUERY SELECT false, 'Zona no encontrada'::text;
  END IF;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Mannto_Zonas_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 12. Menu (already OK) ==========
echo "12. Menu_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'Menu_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== 13. Prueba_all_procedures.sql ==========
echo "13. Fixing Prueba_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp16_licenciagiro_f1(VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS sp_prueba_query(INTEGER);

CREATE OR REPLACE FUNCTION sp16_licenciagiro_f1(p_tipo VARCHAR, p_numero INTEGER)
RETURNS TABLE(status_licencias INTEGER, concepto_licencias VARCHAR)
LANGUAGE plpgsql AS \$\$
BEGIN
  IF EXISTS (
    SELECT 1 FROM ta_16_rel_licgiro rl
    JOIN ta_16_contratos c ON c.control_contrato = rl.control_contrato
    JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    WHERE ta.tipo_aseo = p_tipo AND c.num_contrato = p_numero
  ) THEN
    RETURN QUERY
      SELECT 0 AS status_licencias, 'Licencia relacionada encontrada'::VARCHAR AS concepto_licencias;
  ELSE
    RETURN QUERY
      SELECT 1 AS status_licencias, 'No existe relación de licencia para este contrato'::VARCHAR AS concepto_licencias;
  END IF;
END;
\$\$;

CREATE OR REPLACE FUNCTION sp_prueba_query(parCtrol INTEGER)
RETURNS TABLE(tipo_aseo VARCHAR, num_contrato INTEGER)
LANGUAGE plpgsql AS \$\$
BEGIN
  RETURN QUERY
  SELECT b.tipo_aseo::VARCHAR, a.num_contrato
  FROM ta_16_contratos a
  JOIN ta_16_tipo_aseo b ON b.ctrol_aseo = a.ctrol_aseo
  WHERE a.num_contrato >= 2120
    AND a.ctrol_aseo = parCtrol
  ORDER BY a.num_contrato;
END;
\$\$;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Prueba_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 14. uDM_Procesos (already OK) ==========
echo "14. uDM_Procesos_all_procedures.sql (already deployed)...\n";
$results[] = ['file' => 'uDM_Procesos_all_procedures.sql', 'status' => 'OK (previously deployed)'];
echo "   ✓ OK\n";

// ========== SUMMARY ==========
echo "\n=== DEPLOYMENT SUMMARY ===\n\n";
$success = 0;
$failed = 0;

foreach ($results as $result) {
    $is_ok = (strpos($result['status'], 'OK') !== false);
    $status_icon = $is_ok ? '✓' : '✗';
    echo sprintf("%s %s: %s\n", $status_icon, $result['file'], $result['status']);
    if ($is_ok) {
        $success++;
    } else {
        $failed++;
    }
}

echo "\n";
echo "Total files: " . count($results) . "\n";
echo "Successful: $success\n";
echo "Failed: $failed\n";

pg_close($conn);
echo "\n=== COMPLETED ===\n";
