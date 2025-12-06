<?php
/**
 * Script para desplegar todos los SPs de los componentes Vue:
 * - DatosConvenio
 * - DatosMovimientos
 * - DatosRequerimientos
 * - DatosIndividuales
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Desplegando SPs de Componentes Vue ===\n\n";

try {
    $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "Conexion exitosa a la base de datos\n\n";
} catch (PDOException $e) {
    die("Error de conexion: " . $e->getMessage() . "\n");
}

$sps = [
    // ============ DATOS CONVENIO ============
    'sp_get_datos_convenio' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_datos_convenio(p_id_conv integer)
RETURNS TABLE (
  id_control integer,
  id_conv_resto integer,
  id_referencia integer,
  modulo smallint,
  id_usuario integer,
  fecha_actual timestamp,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint,
  impuesto numeric,
  recargos numeric,
  gastos numeric,
  multa numeric,
  total numeric,
  referencia varchar,
  anuncio numeric,
  impreso numeric,
  id_conv_resto_1 integer,
  tipo smallint,
  id_conv_diver integer,
  id_referencia_1 integer,
  id_rec smallint,
  id_zona integer,
  nombre varchar,
  calle varchar,
  num_exterior smallint,
  num_interior smallint,
  inciso varchar,
  fecha_inicio date,
  fecha_venc date,
  cantidad_total numeric,
  cantidad_inicio numeric,
  pago_parcial numeric,
  pago_final numeric,
  total_pagos smallint,
  metros float,
  tipo_pago varchar,
  observaciones varchar,
  vigencia varchar,
  id_usuario_1 integer,
  fecha_actual_1 timestamp,
  id_adeudo integer,
  id_conv_resto_2 integer,
  pago_parcial_1 smallint,
  importe numeric,
  fecha_venc_1 date,
  id_usuario_2 integer,
  fecha_actual_2 timestamp,
  clave_pago varchar,
  cve_parcialidad varchar,
  axo_desde_1 smallint,
  mes_desde_1 smallint,
  axo_hasta_1 smallint,
  mes_hasta_1 smallint,
  id_conv_pago integer,
  id_conv_resto_3 integer,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer,
  pago_parcial_2 smallint,
  total_parciales smallint,
  importe_pago numeric,
  importe_recargo numeric,
  cve_venc smallint,
  cve_descuento smallint,
  cve_bonificacion smallint,
  id_usuario_3 integer,
  fecha_actual_3 timestamp,
  descripcion varchar,
  desc_subtipo varchar,
  letras_exp varchar,
  numero_exp integer,
  axo_exp smallint,
  estado varchar,
  tipodesc varchar,
  periodos varchar,
  peradeudos varchar,
  convenio varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id_control, a.id_conv_resto, a.id_referencia, a.modulo, a.id_usuario, a.fecha_actual,
    a.axo_desde, a.mes_desde, a.axo_hasta, a.mes_hasta, a.impuesto, a.recargos, a.gastos, a.multa,
    a.total, a.referencia, a.anuncio, a.impreso,
    b.id_conv_resto as id_conv_resto_1, b.tipo, b.id_conv_diver, b.id_referencia as id_referencia_1,
    b.id_rec, b.id_zona, b.nombre, b.calle, b.num_exterior::smallint, b.num_interior::smallint, b.inciso,
    b.fecha_inicio, b.fecha_venc, b.cantidad_total, b.cantidad_inicio, b.pago_parcial, b.pago_final,
    b.total_pagos, b.metros, b.tipo_pago, b.observaciones, b.vigencia, b.id_usuario as id_usuario_1,
    b.fecha_actual as fecha_actual_1,
    c.id_adeudo, c.id_conv_resto as id_conv_resto_2, c.pago_parcial as pago_parcial_1, c.importe,
    c.fecha_venc as fecha_venc_1, c.id_usuario as id_usuario_2, c.fecha_actual as fecha_actual_2,
    c.clave_pago, c.cve_parcialidad, c.axo_desde as axo_desde_1, c.mes_desde as mes_desde_1,
    c.axo_hasta as axo_hasta_1, c.mes_hasta as mes_hasta_1,
    COALESCE(d.id_conv_pago, 0) as id_conv_pago, COALESCE(d.id_conv_resto, 0) as id_conv_resto_3,
    d.fecha_pago, d.oficina_pago, d.caja_pago, d.operacion_pago, d.pago_parcial as pago_parcial_2,
    d.total_parciales, d.importe_pago, d.importe_recargo, d.cve_venc, d.cve_descuento, d.cve_bonificacion,
    d.id_usuario as id_usuario_3, d.fecha_actual as fecha_actual_3,
    f.descripcion, g.descripcion as desc_subtipo,
    e.letras_exp, e.numero_exp, e.axo_exp,
    CASE WHEN b.vigencia = 'B' THEN 'BAJA'
         WHEN b.vigencia = 'C' THEN 'CANCELADO'
         WHEN b.vigencia = 'P' THEN 'PAGADO'
         ELSE 'VIGENTE' END::varchar as estado,
    CASE WHEN b.tipo_pago = 'S' THEN 'SEMANAL'
         WHEN b.tipo_pago = 'Q' THEN 'QUINCENAL'
         ELSE 'MENSUAL' END::varchar as tipodesc,
    (a.mes_desde::text || '/' || a.axo_desde::text || ' - ' || a.mes_hasta::text || '/' || a.axo_hasta::text)::varchar as periodos,
    (c.mes_desde::text || '/' || c.axo_desde::text || ' - ' || c.mes_hasta::text || '/' || c.axo_hasta::text)::varchar as peradeudos,
    (e.letras_exp || '/' || e.numero_exp::text || '/' || e.axo_exp::text)::varchar as convenio
  FROM ta_17_referencia a
    JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_17_adeudos_div c ON c.id_conv_resto = a.id_conv_resto
    LEFT JOIN ta_17_conv_pagos d ON d.id_conv_resto = c.id_conv_resto AND d.pago_parcial = c.pago_parcial
    JOIN ta_17_conv_diverso e ON e.tipo = b.tipo AND e.id_conv_diver = b.id_conv_diver
    JOIN ta_17_tipos f ON f.tipo = e.tipo
    JOIN ta_17_subtipo_conv g ON g.tipo = e.tipo AND g.subtipo = e.subtipo
  WHERE a.modulo = 11 AND a.id_referencia = p_id_conv
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_convenio_parciales' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_convenio_parciales(p_id_conv integer)
RETURNS TABLE (
  pago_parcial_1 smallint,
  descparc varchar,
  importe numeric,
  peradeudos varchar,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.pago_parcial as pago_parcial_1,
    CASE WHEN c.cve_parcialidad = 'I' THEN 'INICIAL'
         WHEN c.cve_parcialidad = 'P' THEN 'PARCIAL'
         ELSE 'FINAL' END::varchar as descparc,
    c.importe,
    (c.mes_desde::text || '/' || c.axo_desde::text || ' - ' || c.mes_hasta::text || '/' || c.axo_hasta::text)::varchar as peradeudos,
    d.fecha_pago,
    d.oficina_pago,
    d.caja_pago,
    d.operacion_pago
  FROM ta_17_referencia a
    JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_17_adeudos_div c ON c.id_conv_resto = a.id_conv_resto
    LEFT JOIN ta_17_conv_pagos d ON d.id_conv_resto = c.id_conv_resto AND d.pago_parcial = c.pago_parcial
  WHERE a.modulo = 11 AND a.id_referencia = p_id_conv
  ORDER BY c.pago_parcial;
END;
$$ LANGUAGE plpgsql;
SQL,

    // ============ DATOS MOVIMIENTOS ============
    'sp_get_movimientos_by_local' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_movimientos_by_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR,
    sector VARCHAR,
    zona SMALLINT,
    drescripcion_local VARCHAR,
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP,
    usuario VARCHAR,
    vigencia VARCHAR,
    clave_cuota SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo_memo, a.numero_memo, a.nombre, a.sector, a.zona, a.drescripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.tipo_movimiento, a.fecha, b.usuario, a.vigencia, a.clave_cuota, c.oficina, c.num_mercado, c.categoria, c.seccion
    FROM ta_11_movimientos a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON c.id_local = a.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.fecha;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_clave_movimientos' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_clave_movimientos()
RETURNS TABLE (
    clave_movimiento SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.clave_movimiento, a.descripcion
    FROM ta_11_clave_mov a
    ORDER BY a.clave_movimiento;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_cuota_by_params' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_cuota_by_params(
    p_vaxo SMALLINT,
    p_vcat SMALLINT,
    p_vsec VARCHAR,
    p_vcuo SMALLINT
)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota, a.importe_cuota, a.fecha_alta, a.id_usuario
    FROM ta_11_cuo_locales a
    WHERE a.axo = p_vaxo AND a.categoria = p_vcat AND a.seccion = p_vsec AND a.clave_cuota = p_vcuo;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_cve_cuotas' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE (
    clave_cuota SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.clave_cuota, a.descripcion
    FROM ta_11_cve_cuota a
    ORDER BY a.clave_cuota;
END;
$$ LANGUAGE plpgsql;
SQL,

    // ============ DATOS REQUERIMIENTOS ============
    'sp_get_locales' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_mercado' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.oficina, a.num_mercado_nvo, a.categoria, a.descripcion, a.cuenta_ingreso, a.cuenta_energia
    FROM ta_11_mercados a
    WHERE a.oficina = p_oficina AND a.num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_requerimientos' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado varchar,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    id_usuario integer,
    usuario_1 varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint,
    zona smallint,
    zona_apremio smallint,
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
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz, a.usuario, b.id_usuario, b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel, a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_periodos' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.control_otr, a.ayo, a.periodo, a.importe, a.recargos
    FROM ta_15_periodos a
    WHERE a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;
SQL,

    // ============ DATOS INDIVIDUALES ============
    'sp_get_adeudos_local' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_adeudos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo, a.periodo, a.importe,
        (a.importe * COALESCE((SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE axo = a.axo AND mes >= a.periodo),0)/100) AS recargos
    FROM ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_requerimientos_local' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_requerimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    fecha_emision DATE,
    clave_practicado VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_recargo, r.importe_gastos, r.fecha_emision, r.clave_practicado, r.vigencia
    FROM ta_15_apremios r
    WHERE r.control_otr = p_id_local AND r.vigencia = '1' AND r.clave_practicado = 'P'
    ORDER BY r.fecha_emision, r.folio;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_movimientos_local' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_movimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_movimiento INTEGER,
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR,
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_movimiento, a.id_local, a.axo_memo, a.numero_memo, a.nombre, a.tipo_movimiento, a.fecha
    FROM ta_11_movimientos a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo_memo, a.numero_memo;
END;
$$ LANGUAGE plpgsql;
SQL

];

$exitosos = 0;
$fallidos = 0;
$errores = [];

foreach ($sps as $nombre => $sql) {
    echo "Desplegando: {$nombre}... ";
    try {
        $pdo->exec($sql);
        echo "OK\n";
        $exitosos++;
    } catch (PDOException $e) {
        $msg = $e->getMessage();
        echo "ERROR\n";
        $errores[$nombre] = $msg;
        $fallidos++;
    }
}

echo "\n=== Resumen ===\n";
echo "Exitosos: {$exitosos}\n";
echo "Fallidos: {$fallidos}\n";

if (count($errores) > 0) {
    echo "\n=== Errores ===\n";
    foreach ($errores as $sp => $msg) {
        echo "{$sp}: {$msg}\n\n";
    }
}

// Verificar que existen
echo "\n=== Verificando SPs en la BD ===\n";
$spNames = array_keys($sps);
$placeholders = implode(',', array_fill(0, count($spNames), '?'));

$query = "SELECT routine_name FROM information_schema.routines
          WHERE routine_schema = 'public'
          AND routine_name LIKE 'sp_%'
          ORDER BY routine_name";

$stmt = $pdo->query($query);
$found = $stmt->fetchAll(PDO::FETCH_COLUMN);

echo "SPs desplegados encontrados en BD:\n";
foreach ($found as $sp) {
    if (in_array($sp, $spNames)) {
        echo "  [OK] {$sp}\n";
    }
}
