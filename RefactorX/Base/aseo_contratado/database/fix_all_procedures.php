<?php
/**
 * Fix and Deploy All Aseo Contratado Stored Procedures
 * Fixes 14 SQL files with various errors
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos\n");
}

echo "=== FIXING AND DEPLOYING ASEO_CONTRATADO PROCEDURES ===\n\n";

$results = [];
$base_path = __DIR__ . '/database/';

// ========== 1. ABC_Gastos_all_procedures.sql ==========
echo "1. Fixing ABC_Gastos_all_procedures.sql...\n";
$sql = <<<SQL
-- Drop procedures before creating functions
DROP PROCEDURE IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP PROCEDURE IF EXISTS sp_gastos_delete_all();
DROP FUNCTION IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
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
DROP PROCEDURE IF EXISTS sp_adeudos_exe_del_logica(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, TEXT, INTEGER);
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
      AND aso_mes_pago = v_periodo
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
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS p_updated = ROW_COUNT;
END;
\$\$;

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
) LANGUAGE sql AS \$\$
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, b.costo_unidad, a.aso_mes_oblig::text
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON a.ctrol_recolec = b.ctrol_recolec
    WHERE a.num_contrato = p_contrato AND a.ctrol_aseo = p_ctrol_aseo;
\$\$;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'AdeudosExe_Del_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 3. Adeudos_OpcMult_all_procedures.sql - No duplicate column found, deploy as-is ==========
echo "3. Deploying Adeudos_OpcMult_all_procedures.sql (no duplicates found)...\n";
$sql = file_get_contents($base_path . 'Adeudos_OpcMult_all_procedures.sql');
$result = pg_query($conn, $sql);
$results[] = ['file' => 'Adeudos_OpcMult_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 4. Cons_Empresas_all_procedures.sql ==========
echo "4. Fixing Cons_Empresas_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_empresas_list();
DROP FUNCTION IF EXISTS sp_empresas_by_number(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS sp_empresas_by_name(VARCHAR);
DROP FUNCTION IF EXISTS sp_empresas_search(INTEGER, INTEGER, INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS sp_tipos_emp_list();

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_by_number(p_num_empresa INTEGER, p_ctrol_emp INTEGER)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_by_name(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE unaccent(upper(a.descripcion)) LIKE '%' || unaccent(upper(p_nombre)) || '%'
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_empresas_search(
    p_opcion INTEGER,
    p_num_empresa INTEGER DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL,
    p_nombre VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS \$\$
BEGIN
    IF p_opcion = 1 THEN
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp
        ORDER BY a.num_empresa, a.ctrol_emp;
    ELSIF p_opcion = 2 THEN
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        WHERE unaccent(upper(a.descripcion)) LIKE '%' || unaccent(upper(p_nombre)) || '%'
        ORDER BY a.descripcion, a.num_empresa, a.ctrol_emp;
    ELSE
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        ORDER BY a.descripcion, a.num_empresa, a.ctrol_emp;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE (
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM ta_16_tipos_emp
    ORDER BY ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Cons_Empresas_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 5. Contratos_Upd_01_all_procedures.sql ==========
echo "5. Fixing Contratos_Upd_01_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_get_tipo_aseo();
DROP FUNCTION IF EXISTS sp_get_unidades(integer);
DROP FUNCTION IF EXISTS sp_get_zonas();
DROP FUNCTION IF EXISTS sp_get_recaudadoras();
DROP FUNCTION IF EXISTS sp_busca_contrato(integer, integer);
DROP FUNCTION IF EXISTS sp_buscar_empresas(varchar);
DROP FUNCTION IF EXISTS sp_busca_convenio(integer);
DROP FUNCTION IF EXISTS sp_licencias_relacionadas(integer);
DROP FUNCTION IF EXISTS sp_licencia_giro_abc(varchar, integer, integer);
DROP FUNCTION IF EXISTS sp_upd16_contrato_01(integer, integer, integer, integer, integer, integer, integer, integer, integer, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo() RETURNS TABLE (ctrol_aseo integer, tipo_aseo varchar, descripcion varchar, cta_aplicacion integer) AS \$\$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipos_aseo ORDER BY ctrol_aseo;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_unidades(p_ejercicio integer) RETURNS TABLE (ctrol_recolec integer, cve_recolec varchar, descripcion varchar) AS \$\$
BEGIN
  RETURN QUERY SELECT ctrol_recolec, cve_recolec, descripcion FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio ORDER BY ctrol_recolec;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_zonas() RETURNS TABLE (ctrol_zona integer, zona smallint, sub_zona smallint, descripcion varchar) AS \$\$
BEGIN
  RETURN QUERY SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY zona, sub_zona;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_recaudadoras() RETURNS TABLE (id_rec smallint, id_zona integer, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS \$\$
BEGIN
  RETURN QUERY SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector FROM ta_12_recaudadoras ORDER BY id_rec;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_busca_contrato(p_num_contrato integer, p_ctrol_aseo integer) RETURNS TABLE (
  num_empresa integer, ctrol_emp integer, tipo_empresa varchar, descripcion varchar, nom_emp varchar, representante varchar,
  control_contrato integer, num_contrato integer, ctrol_aseo integer, tipo_aseo varchar, descrip_aseo varchar,
  ctrol_recolec integer, cve_recolec varchar, descrip_und varchar, cantidad_recolec smallint,
  domicilio varchar, sector varchar, ctrol_zona integer, zona smallint, sub_zona smallint, descripcion_1 varchar, datos_zona varchar,
  id_rec smallint, recaudadora varchar, fecha_hora_alta timestamp, status_vigencia varchar, aso_mes_oblig date, cve varchar, usuario integer, fecha_hora_baja timestamp
) AS \$\$
BEGIN
  RETURN QUERY
    SELECT A.num_empresa, A.ctrol_emp, B.tipo_empresa, B.descripcion, A.descripcion AS nom_emp, A.representante,
      C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion AS descrip_aseo,
      C.ctrol_recolec, E.cve_recolec, E.descripcion AS descrip_und, C.cantidad_recolec,
      C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion AS descripcion_1,
      (C.ctrol_zona || '-' || F.zona || '-' || F.sub_zona || '-' || F.descripcion) AS datos_zona,
      C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja
    FROM ta_16_contratos C
    JOIN ta_16_empresas A ON A.num_empresa = C.num_empresa AND A.ctrol_emp = C.ctrol_emp
    JOIN ta_16_tipos_emp B ON A.ctrol_emp = B.ctrol_emp
    JOIN ta_16_tipos_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
    WHERE C.num_contrato = p_num_contrato AND C.ctrol_aseo = p_ctrol_aseo;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_empresas(p_nombre varchar) RETURNS TABLE (num_empresa integer, ctrol_emp integer, descripcion varchar, representante varchar) AS \$\$
BEGIN
  RETURN QUERY SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante
    FROM ta_16_empresas a, ta_16_tipos_emp b
    WHERE a.descripcion ILIKE '%' || p_nombre || '%' AND b.ctrol_emp = a.ctrol_emp
    ORDER BY a.num_empresa;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_busca_convenio(p_idlc integer) RETURNS TABLE (convenio varchar, id_conv_resto integer) AS \$\$
BEGIN
  RETURN QUERY
    SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio, b.id_conv_resto
    FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d
    WHERE a.id_referencia = p_idlc AND a.modulo = 16
      AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
      AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_licencias_relacionadas(p_control_contrato integer) RETURNS TABLE (
  num_licencia integer, actividad varchar, propietario varchar
) AS \$\$
BEGIN
  RETURN QUERY
    SELECT a.num_licencia, b.actividad, b.propietario
    FROM ta_16_rel_licgiro a
    JOIN catastro_gdl."Licencias" b ON b.licencia = a.num_licencia AND b.vigente = 'V'
    WHERE a.control_contrato = p_control_contrato
    ORDER BY a.num_licencia;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_licencia_giro_abc(p_opc varchar, p_licencia_giro integer, p_control_contrato integer) RETURNS TABLE (status integer, leyenda varchar) AS \$\$
BEGIN
  IF p_opc = 'A' THEN
    INSERT INTO ta_16_rel_licgiro (id, num_licencia, control_contrato, vigencia)
    VALUES (DEFAULT, p_licencia_giro, p_control_contrato, 'V')
    ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V';
    RETURN QUERY SELECT 0, 'Licencia activada o reactivada';
  ELSIF p_opc = 'D' THEN
    DELETE FROM ta_16_rel_licgiro WHERE num_licencia = p_licencia_giro AND control_contrato = p_control_contrato;
    RETURN QUERY SELECT 0, 'Licencia desligada/eliminada';
  ELSIF p_opc = 'C' THEN
    UPDATE ta_16_rel_licgiro SET vigencia = 'C' WHERE num_licencia = p_licencia_giro AND control_contrato = p_control_contrato;
    RETURN QUERY SELECT 0, 'Licencia cancelada';
  ELSE
    RETURN QUERY SELECT 1, 'Opción no válida';
  END IF;
END; \$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_upd16_contrato_01(
  par_Control_Cont integer,
  par_Num_Emp integer,
  par_Ctrol_Emp integer,
  par_Cant_recolec integer,
  par_Ctrol_Zona integer,
  par_Id_Rec integer,
  par_Axo_Ini integer,
  par_Mes_Ini integer,
  par_Opcion integer,
  par_Cve_recolec varchar,
  par_Domicilio varchar,
  par_Sector varchar,
  par_Docto varchar,
  par_Descrip varchar
) RETURNS TABLE (status integer, concepto varchar) AS \$\$
DECLARE
  v_status integer := 0;
  v_concepto varchar := '';
BEGIN
  IF par_Opcion = 0 THEN
    UPDATE ta_16_contratos SET ctrol_recolec = (SELECT ctrol_recolec FROM ta_16_unidades WHERE cve_recolec = par_Cve_recolec LIMIT 1)
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Tipo de unidad de recolección actualizado';
  ELSIF par_Opcion = 1 THEN
    UPDATE ta_16_contratos SET aso_mes_oblig = make_date(par_Axo_Ini, par_Mes_Ini, 1)
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Inicio de obligación actualizado';
  ELSIF par_Opcion = 2 THEN
    UPDATE ta_16_contratos SET cantidad_recolec = par_Cant_recolec
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Cantidad de unidades actualizada';
  ELSIF par_Opcion = 3 THEN
    UPDATE ta_16_contratos SET num_empresa = par_Num_Emp, ctrol_emp = par_Ctrol_Emp
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Empresa actualizada';
  ELSIF par_Opcion = 4 THEN
    UPDATE ta_16_contratos SET domicilio = par_Domicilio
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Domicilio actualizado';
  ELSIF par_Opcion = 5 THEN
    UPDATE ta_16_contratos SET ctrol_zona = par_Ctrol_Zona
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Zona actualizada';
  ELSIF par_Opcion = 6 THEN
    UPDATE ta_16_contratos SET sector = par_Sector
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Sector actualizado';
  ELSIF par_Opcion = 7 THEN
    UPDATE ta_16_contratos SET id_rec = par_Id_Rec
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Recaudadora actualizada';
  ELSE
    v_status := 1;
    v_concepto := 'Opción no válida';
  END IF;
  RETURN QUERY SELECT v_status, v_concepto;
END; \$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Contratos_Upd_01_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 6. Licencias_Relacionadas_all_procedures.sql ==========
echo "6. Fixing Licencias_Relacionadas_all_procedures.sql...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp16_licenciagiro_abc(VARCHAR, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS sp16_licencias_relacionadas(INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS sp16_tipos_aseo();

CREATE OR REPLACE FUNCTION sp16_licenciagiro_abc(
    par_opc VARCHAR,
    par_licenciagiro INTEGER,
    par_control_contrato INTEGER,
    par_usuario INTEGER DEFAULT 0
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS \$\$
DECLARE
BEGIN
    IF par_opc = 'D' THEN
        DELETE FROM ta_16_rel_licgiro
        WHERE num_licencia = par_licenciagiro AND control_contrato = par_control_contrato;
        RETURN QUERY SELECT 0 AS status, 'Licencia desligada correctamente' AS leyenda;
    ELSIF par_opc = 'A' THEN
        INSERT INTO ta_16_rel_licgiro (num_licencia, control_contrato, vigencia, usuario)
        VALUES (par_licenciagiro, par_control_contrato, 'V', par_usuario)
        ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V', usuario = par_usuario;
        RETURN QUERY SELECT 0 AS status, 'Licencia ligada correctamente' AS leyenda;
    ELSE
        RETURN QUERY SELECT 1 AS status, 'Operación no soportada' AS leyenda;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp16_licencias_relacionadas(
    p_opcion INTEGER,
    p_num_licencia INTEGER DEFAULT NULL,
    p_control_contrato INTEGER DEFAULT NULL
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio_recoleccion_contrato VARCHAR,
    empresa_contrato VARCHAR,
    representante_contrato VARCHAR,
    num_licencia INTEGER,
    actividad_licencia VARCHAR,
    propietario_licencia VARCHAR,
    domicilio_licencia VARCHAR,
    numext_prop INTEGER,
    ubicacion_licencia VARCHAR,
    numext_ubic INTEGER,
    vigencia_rel VARCHAR,
    tipo_aseo VARCHAR
) AS \$\$
BEGIN
    IF p_opcion = 0 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipos_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.control_contrato > 0
        ORDER BY c.num_contrato, a.num_licencia;
    ELSIF p_opcion = 1 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipos_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.num_licencia = p_num_licencia
        ORDER BY c.num_contrato, a.num_licencia;
    ELSIF p_opcion = 2 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipos_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.control_contrato = p_control_contrato
        ORDER BY c.num_contrato, a.num_licencia;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp16_tipos_aseo() RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipos_aseo ORDER BY ctrol_aseo;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Licencias_Relacionadas_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 7-11. Mannto files ==========
$mannto_files = [
    'Mannto_Empresas_all_procedures.sql',
    'Mannto_Gastos_all_procedures.sql',
    'Mannto_Recargos_all_procedures.sql',
    'Mannto_Tipos_Aseo_all_procedures.sql',
    'Mannto_Zonas_all_procedures.sql'
];

foreach ($mannto_files as $idx => $file) {
    echo (7 + $idx) . ". Deploying $file...\n";
    $file_path = $base_path . $file;

    if (!file_exists($file_path)) {
        $results[] = ['file' => $file, 'status' => 'ERROR: File not found'];
        echo "   ✗ Error: File not found\n";
        continue;
    }

    $sql = file_get_contents($file_path);

    // Fix Mannto_Tipos_Aseo - rename 'exists' column
    if ($file === 'Mannto_Tipos_Aseo_all_procedures.sql') {
        $sql = str_replace("RETURNS TABLE(exists boolean)", "RETURNS TABLE(cta_exists boolean)", $sql);
    }

    // Fix Mannto_Gastos - Convert PROCEDURE to FUNCTION
    if ($file === 'Mannto_Gastos_all_procedures.sql') {
        $sql = str_replace("CREATE OR REPLACE PROCEDURE sp_gastos_insert(", "DROP PROCEDURE IF EXISTS sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);\nCREATE OR REPLACE FUNCTION sp_gastos_insert(", $sql);
        $sql = str_replace("CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()", "DROP PROCEDURE IF EXISTS sp_gastos_delete_all();\nCREATE OR REPLACE FUNCTION sp_gastos_delete_all()\nRETURNS VOID", $sql);
        $sql = str_replace(")
LANGUAGE plpgsql
AS \$\$
BEGIN
    INSERT INTO ta_16_gastos", ")\nRETURNS VOID\nLANGUAGE plpgsql\nAS \$\$\nBEGIN\n    INSERT INTO ta_16_gastos", $sql);
    }

    $result = pg_query($conn, $sql);
    $results[] = ['file' => $file, 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
    echo $result ? "   ✓ Deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";
}

// ========== 12. Menu_all_procedures.sql ==========
echo "12. Fixing Menu_all_procedures.sql (SERIAL fix)...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_cat_unidades_list(INTEGER);
DROP FUNCTION IF EXISTS sp_cat_unidades_create(INTEGER, VARCHAR, VARCHAR, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS sp_cat_unidades_update(INTEGER, VARCHAR, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS sp_cat_unidades_delete(INTEGER);
DROP FUNCTION IF EXISTS sp_cat_tipos_aseo_list();
DROP FUNCTION IF EXISTS sp_cat_zonas_list();
DROP FUNCTION IF EXISTS sp_cat_empresas_list();
DROP FUNCTION IF EXISTS sp_cat_tipos_emp_list();
DROP FUNCTION IF EXISTS sp_cat_recargos_list(INTEGER);
DROP FUNCTION IF EXISTS sp_cat_gastos_list();
DROP FUNCTION IF EXISTS sp_cat_operaciones_list();
DROP FUNCTION IF EXISTS sp_rep_unidades_export(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION sp_cat_unidades_list(p_ejercicio INTEGER)
RETURNS TABLE(
    id INTEGER,
    ejercicio INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ctrol_recolec;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_unidades_create(
    p_ejercicio INTEGER,
    p_clave VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS \$\$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_clave;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Ya existe la clave para ese ejercicio';
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_clave, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'OK';
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_id INTEGER,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS \$\$
BEGIN
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo_unidad, costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_id;
    RETURN QUERY SELECT 'OK';
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_unidades_delete(p_id INTEGER)
RETURNS TABLE(result TEXT) AS \$\$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE ctrol_recolec = p_id;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Existen contratos asociados, no se puede eliminar';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_id;
    RETURN QUERY SELECT 'OK';
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE(id INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR, cta_aplicacion INTEGER) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipos_aseo ORDER BY ctrol_aseo;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_zonas_list()
RETURNS TABLE(id INTEGER, zona INTEGER, sub_zona INTEGER, descripcion VARCHAR) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_zona, zona::INTEGER, sub_zona::INTEGER, descripcion FROM ta_16_zonas ORDER BY ctrol_zona;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_empresas_list()
RETURNS TABLE(id INTEGER, num_empresa INTEGER, ctrol_emp INTEGER, descripcion VARCHAR, representante VARCHAR) AS \$\$
BEGIN
    RETURN QUERY
    SELECT num_empresa, num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY num_empresa;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_tipos_emp_list()
RETURNS TABLE(id INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_recargos_list(p_ejercicio INTEGER)
RETURNS TABLE(id INTEGER, aso_mes_recargo DATE, porc_recargo NUMERIC, porc_multa NUMERIC) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ROW_NUMBER() OVER (ORDER BY aso_mes_recargo)::INTEGER, aso_mes_recargo, porc_recargo, porc_multa
    FROM ta_16_recargos
    WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_ejercicio
    ORDER BY aso_mes_recargo;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_gastos_list()
RETURNS TABLE(id INTEGER, sdzmg NUMERIC, porc1_req NUMERIC, porc2_embargo NUMERIC, porc3_secuestro NUMERIC) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ROW_NUMBER() OVER ()::INTEGER, sdzmg, porc1_req, porc2_embargo, porc3_secuestro
    FROM ta_16_gastos;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_operaciones_list()
RETURNS TABLE(id INTEGER, cve_operacion VARCHAR, descripcion VARCHAR) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rep_unidades_export(p_ejercicio INTEGER, p_order_by VARCHAR)
RETURNS TABLE(id INTEGER, ejercicio INTEGER, clave VARCHAR, descripcion VARCHAR, costo_unidad NUMERIC, costo_exed NUMERIC) AS \$\$
BEGIN
    RETURN QUERY EXECUTE format('SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM ta_16_unidades WHERE ejercicio_recolec = %L ORDER BY %I', p_ejercicio, p_order_by);
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Menu_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 13. Prueba_all_procedures.sql ==========
echo "13. Fixing Prueba_all_procedures.sql (table name fix)...\n";
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
    WHERE c.tipo_aseo = p_tipo AND c.num_contrato = p_numero
  ) THEN
    RETURN QUERY
      SELECT 0 AS status_licencias, 'Licencia relacionada encontrada' AS concepto_licencias;
  ELSE
    RETURN QUERY
      SELECT 1 AS status_licencias, 'No existe relación de licencia para este contrato' AS concepto_licencias;
  END IF;
END;
\$\$;

CREATE OR REPLACE FUNCTION sp_prueba_query(parCtrol INTEGER)
RETURNS TABLE(tipo_aseo VARCHAR, num_contrato INTEGER)
LANGUAGE sql AS \$\$
  SELECT b.tipo_aseo, a.num_contrato
  FROM ta_16_contratos a
  JOIN ta_16_tipos_aseo b ON b.ctrol_aseo = a.ctrol_aseo
  WHERE a.num_contrato >= 2120
    AND a.ctrol_aseo = parCtrol
  ORDER BY num_contrato;
\$\$;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'Prueba_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== 14. uDM_Procesos_all_procedures.sql ==========
echo "14. Fixing uDM_Procesos_all_procedures.sql (duplicate params fix)...\n";
$sql = <<<SQL
DROP FUNCTION IF EXISTS sp_get_tipo_aseo(integer);
DROP FUNCTION IF EXISTS sp_get_dia_limite(integer);
DROP FUNCTION IF EXISTS sp_get_contratos_count(integer, varchar);
DROP FUNCTION IF EXISTS sp_get_pagos_summary(integer, varchar, integer, varchar);
DROP FUNCTION IF EXISTS sp_procesos_dashboard(integer, varchar, varchar);

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo(p_tipo integer)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer
) AS \$\$
BEGIN
    IF p_tipo = 0 THEN
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipos_aseo WHERE ctrol_aseo <> 0;
    ELSE
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipos_aseo WHERE ctrol_aseo = p_tipo;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_dia_limite(p_mes integer)
RETURNS TABLE (
    mes integer,
    dia integer
) AS \$\$
BEGIN
    RETURN QUERY SELECT mes, dia FROM ta_16_dia_limite WHERE mes = p_mes;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_contratos_count(p_ctrol integer, p_status varchar DEFAULT NULL)
RETURNS TABLE (
    registros integer
) AS \$\$
BEGIN
    IF p_status IS NULL THEN
        RETURN QUERY SELECT COUNT(*)::integer FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol;
    ELSE
        RETURN QUERY SELECT COUNT(*)::integer FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol AND status_vigencia = p_status;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_pagos_summary(
    p_ctrol_a integer,
    p_fecha varchar,
    p_operacion integer DEFAULT NULL,
    p_status varchar DEFAULT NULL
)
RETURNS TABLE (
    registros integer,
    importe numeric
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::integer AS registros, COALESCE(SUM(b.importe),0) AS importe
    FROM ta_16_contratos a
    JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
    WHERE a.ctrol_aseo = p_ctrol_a
      AND (p_operacion IS NULL OR b.ctrol_operacion = p_operacion)
      AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha::date
      AND (p_status IS NULL OR b.status_vigencia = p_status);
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_procesos_dashboard(
    p_ctrol_a integer,
    p_fecha1 varchar,
    p_fecha2 varchar
)
RETURNS TABLE (
    contratos_total integer,
    contratos_vigentes integer,
    contratos_cancelados integer,
    pagos jsonb
) AS \$\$
DECLARE
    pagos_arr jsonb := '[]'::jsonb;
    op integer;
    op_nombre text;
    regs integer;
    imp numeric;
    v integer;
    c integer;
    p integer;
    s integer;
    opers integer[] := ARRAY[6,7,8];
    opers_nombres text[] := ARRAY['CN','EXE','CON'];
    i integer;
BEGIN
    SELECT COUNT(*)::integer INTO contratos_total FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol_a;
    SELECT COUNT(*)::integer INTO contratos_vigentes FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol_a AND status_vigencia = 'V';
    SELECT COUNT(*)::integer INTO contratos_cancelados FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol_a AND status_vigencia = 'C';

    FOR i IN 1..array_length(opers,1) LOOP
        op := opers[i];
        op_nombre := opers_nombres[i];

        SELECT COUNT(*)::integer, COALESCE(SUM(b.importe),0) INTO regs, imp
        FROM ta_16_contratos a
        JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = p_ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha1::date;

        SELECT COUNT(*)::integer INTO v FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = p_ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha1::date AND b.status_vigencia = 'V';
        SELECT COUNT(*)::integer INTO c FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = p_ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha1::date AND b.status_vigencia = 'C';
        SELECT COUNT(*)::integer INTO p FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = p_ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha1::date AND b.status_vigencia = 'P';
        SELECT COUNT(*)::integer INTO s FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = p_ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND p_fecha1::date AND b.status_vigencia = 'S';

        pagos_arr := pagos_arr || jsonb_build_object(
            'operacion', op,
            'operacion_nombre', op_nombre,
            'registros', regs,
            'importe', imp,
            'vigente', v,
            'cancelado', c,
            'pendiente', p,
            'suspendido', s
        );
    END LOOP;
    RETURN QUERY SELECT contratos_total, contratos_vigentes, contratos_cancelados, pagos_arr;
END;
\$\$ LANGUAGE plpgsql;
SQL;

$result = pg_query($conn, $sql);
$results[] = ['file' => 'uDM_Procesos_all_procedures.sql', 'status' => $result ? 'OK' : 'ERROR: ' . pg_last_error($conn)];
echo $result ? "   ✓ Fixed and deployed\n" : "   ✗ Error: " . pg_last_error($conn) . "\n";

// ========== SUMMARY ==========
echo "\n=== DEPLOYMENT SUMMARY ===\n\n";
$success = 0;
$failed = 0;

foreach ($results as $result) {
    $status_icon = $result['status'] === 'OK' ? '✓' : '✗';
    echo sprintf("%s %s: %s\n", $status_icon, $result['file'], $result['status']);
    if ($result['status'] === 'OK') {
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
