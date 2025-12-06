<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Corrigiendo sp_get_cuota_by_params ===\n\n";

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

// Verificar estructura de ta_11_cuo_locales
echo "=== Estructura de ta_11_cuo_locales ===\n";
$stmt = $pdo->query("SELECT column_name, data_type, character_maximum_length
                     FROM information_schema.columns
                     WHERE table_name = 'ta_11_cuo_locales'
                     ORDER BY ordinal_position");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $col) {
    $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
    echo "  {$col['column_name']}: {$col['data_type']}{$len}\n";
}

// Eliminar función existente
echo "\n=== Eliminando función existente ===\n";
try {
    $pdo->exec("DROP FUNCTION IF EXISTS sp_get_cuota_by_params(smallint, smallint, varchar, smallint)");
    $pdo->exec("DROP FUNCTION IF EXISTS sp_get_cuota_by_params(smallint, smallint, character varying, smallint)");
    echo "DROP: OK\n";
} catch (PDOException $e) {
    echo "DROP: " . $e->getMessage() . "\n";
}

// Crear función con tipos correctos
$sql = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_cuota_by_params(
    p_vaxo SMALLINT,
    p_vcat SMALLINT,
    p_vsec CHAR(2),
    p_vcuo SMALLINT
)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
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
SQL;

echo "\n=== Creando sp_get_cuota_by_params ===\n";
try {
    $pdo->exec($sql);
    echo "CREATE: OK\n";
} catch (PDOException $e) {
    echo "CREATE ERROR: " . $e->getMessage() . "\n";
}

// Probar
echo "\n=== Probando con datos existentes ===\n";
$stmt = $pdo->query("SELECT axo, categoria, seccion, clave_cuota FROM ta_11_cuo_locales LIMIT 1");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
    echo "Datos de prueba: axo={$row['axo']}, cat={$row['categoria']}, sec={$row['seccion']}, cuo={$row['clave_cuota']}\n";

    try {
        $stmt = $pdo->prepare("SELECT * FROM sp_get_cuota_by_params(?, ?, ?, ?)");
        $stmt->execute([$row['axo'], $row['categoria'], trim($row['seccion']), $row['clave_cuota']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            echo "Resultado: importe_cuota = {$result['importe_cuota']}\n";
            print_r($result);
        } else {
            echo "(sin resultados)\n";
        }
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}
