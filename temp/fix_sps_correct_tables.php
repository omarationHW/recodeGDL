<?php
/**
 * Script para corregir los SPs con las tablas correctas:
 * - ta_12_passwords -> usuarios
 * - id_usuario -> id (en tabla usuarios)
 * - ta_11_secciones -> consulta directa desde ta_11_cuo_locales
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Corrigiendo SPs con tablas correctas ===\n\n";

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Conexion OK\n\n";
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

$sps = [
    // CuotasMdo - corregido
    'sp_cuotasmdo_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_list(p_axo INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo INTEGER,
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50),
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo::INTEGER, a.categoria::INTEGER, a.seccion, a.clave_cuota::INTEGER,
           a.importe_cuota, a.fecha_alta, a.id_usuario,
           COALESCE(b.usuario, 'N/A')::VARCHAR(50) as usuario,
           c.descripcion
    FROM ta_11_cuo_locales a
    LEFT JOIN usuarios b ON a.id_usuario = b.id
    JOIN ta_11_cve_cuota c ON a.clave_cuota = c.clave_cuota
    WHERE a.axo >= p_axo
    ORDER BY a.axo DESC, a.categoria DESC, a.seccion DESC, a.clave_cuota DESC;
END;
$$ LANGUAGE plpgsql;
SQL,

    // Secciones - obtener valores únicos de ta_11_cuo_locales
    'sp_secciones_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE (seccion VARCHAR(10), descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a.seccion, ('Sección ' || a.seccion)::VARCHAR(100) as descripcion
    FROM ta_11_cuo_locales a
    WHERE a.seccion IS NOT NULL
    ORDER BY a.seccion;
END;
$$ LANGUAGE plpgsql;
SQL,

    // DatosMovimientos - corregido
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
    SELECT a.id_local, a.axo_memo, a.numero_memo, a.nombre, a.sector, a.zona,
           a.drescripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja,
           a.tipo_movimiento, a.fecha,
           COALESCE(b.usuario, 'N/A')::VARCHAR as usuario,
           a.vigencia, a.clave_cuota, c.oficina, c.num_mercado, c.categoria, c.seccion
    FROM ta_11_movimientos a
    LEFT JOIN usuarios b ON a.id_usuario = b.id
    JOIN ta_11_locales c ON c.id_local = a.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.fecha;
END;
$$ LANGUAGE plpgsql;
SQL,

    // DatosRequerimientos - corregido
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
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz,
           a.usuario, b.id, b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel,
           a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2,
           a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate,
           a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago,
           a.recaudadora, a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM ta_15_apremios a
    LEFT JOIN usuarios b ON a.usuario = b.id
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;
SQL

];

$exitosos = 0;
$fallidos = 0;
$errores = [];

foreach ($sps as $nombre => $sql) {
    echo "Corrigiendo: {$nombre}... ";
    try {
        $pdo->exec($sql);
        echo "OK\n";
        $exitosos++;
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
        $errores[$nombre] = $e->getMessage();
        $fallidos++;
    }
}

echo "\n=== Resumen ===\n";
echo "Exitosos: {$exitosos}\n";
echo "Fallidos: {$fallidos}\n";

// Probar sp_cuotasmdo_list
echo "\n=== Probando sp_cuotasmdo_list(2020) ===\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_cuotasmdo_list(2020) LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros encontrados: " . count($rows) . "\n";
    if (count($rows) > 0) {
        print_r($rows[0]);
    }
} catch (PDOException $e) {
    echo "ERROR al probar: " . $e->getMessage() . "\n";
}
