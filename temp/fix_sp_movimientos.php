<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Corrigiendo SP de Movimientos ===\n\n";

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

// Primero verificar la estructura de ta_11_movimientos
echo "=== Estructura de ta_11_movimientos ===\n";
$stmt = $pdo->query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_11_movimientos' ORDER BY ordinal_position");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $col) {
    echo "  {$col['column_name']}: {$col['data_type']}\n";
}

// Verificar estructura de ta_11_cuo_locales
echo "\n=== Estructura de ta_11_cuo_locales ===\n";
$stmt = $pdo->query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_11_cuo_locales' ORDER BY ordinal_position LIMIT 20");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $col) {
    echo "  {$col['column_name']}: {$col['data_type']}\n";
}

// Eliminar la función existente
echo "\n=== Eliminando función existente ===\n";
try {
    $pdo->exec("DROP FUNCTION IF EXISTS sp_get_movimientos_by_local(integer)");
    echo "DROP: OK\n";
} catch (PDOException $e) {
    echo "DROP: " . $e->getMessage() . "\n";
}

// Crear la función corregida usando ta_11_cuo_locales
$sql = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_movimientos_by_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR(60),
    sector CHAR(2),
    zona CHAR(2),
    descripcion_local VARCHAR(60),
    superficie NUMERIC,
    giro VARCHAR(50),
    fecha_alta DATE,
    fecha_baja DATE,
    tipo_movimiento CHAR(1),
    fecha DATE,
    usuario VARCHAR(20),
    vigencia CHAR(1),
    clave_cuota SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria CHAR(1),
    seccion CHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_local,
        a.axo_memo,
        a.numero_memo,
        a.nombre,
        a.sector,
        a.zona,
        a.drescripcion_local as descripcion_local,
        a.superficie,
        a.giro,
        a.fecha_alta,
        a.fecha_baja,
        a.tipo_movimiento,
        a.fecha,
        COALESCE(b.usuario, 'N/A')::VARCHAR(20) as usuario,
        a.vigencia,
        a.clave_cuota,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion
    FROM ta_11_movimientos a
    LEFT JOIN usuarios b ON a.id_usuario = b.id
    LEFT JOIN ta_11_cuo_locales c ON c.id_local = a.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.fecha;
END;
$$ LANGUAGE plpgsql;
SQL;

echo "\n=== Creando sp_get_movimientos_by_local ===\n";
try {
    $pdo->exec($sql);
    echo "CREATE: OK\n";
} catch (PDOException $e) {
    echo "CREATE ERROR: " . $e->getMessage() . "\n";
}

// Probar con un local existente
echo "\n=== Buscando un local con movimientos ===\n";
$stmt = $pdo->query("SELECT DISTINCT id_local FROM ta_11_movimientos LIMIT 5");
$locals = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo "Locales con movimientos: " . implode(", ", $locals) . "\n";

if (count($locals) > 0) {
    $testId = $locals[0];
    echo "\n=== Probando sp_get_movimientos_by_local({$testId}) ===\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_get_movimientos_by_local({$testId}) LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Registros encontrados: " . count($rows) . "\n";
        if (count($rows) > 0) {
            print_r($rows[0]);
        }
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}
