<?php
/**
 * Buscar en qué schema está la tabla reqdiftransmision
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Buscar la tabla en todos los schemas
    echo "🔍 Buscando tabla 'reqdiftransmision' en todos los schemas...\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name, table_type
        FROM information_schema.tables
        WHERE table_name LIKE '%reqdif%'
           OR table_name LIKE '%req%'
        ORDER BY table_schema, table_name
    ");

    $found = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  ✅ {$row['table_schema']}.{$row['table_name']} ({$row['table_type']})\n";
        $found[] = $row;

        if (strtolower($row['table_name']) == 'reqdiftransmision') {
            echo "     ⭐ ¡ENCONTRADA!\n";
        }
    }

    if (empty($found)) {
        echo "  ❌ No se encontró ninguna tabla con 'req' o 'reqdif' en el nombre\n\n";

        // Buscar tablas relacionadas con multas o folios
        echo "🔍 Buscando tablas relacionadas con multas/folios...\n\n";
        $stmt2 = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE (table_name LIKE '%multa%' OR table_name LIKE '%folio%')
            ORDER BY table_schema, table_name
            LIMIT 20
        ");

        while ($row = $stmt2->fetch(PDO::FETCH_ASSOC)) {
            echo "  - {$row['table_schema']}.{$row['table_name']}\n";
        }
    }

    echo "\n📊 Total de tablas encontradas: " . count($found) . "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
