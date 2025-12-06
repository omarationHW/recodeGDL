<?php
echo "==============================================\n";
echo "ANÁLISIS: Valores de 'sector' en la BD\n";
echo "==============================================\n\n";

$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
]);

// 1. Valores únicos de sector
echo "1. Valores ÚNICOS de sector en publico.ta_11_locales:\n\n";
$unique = $pdo->query("
    SELECT DISTINCT sector, COUNT(*) as count
    FROM publico.ta_11_locales
    WHERE sector IS NOT NULL
    GROUP BY sector
    ORDER BY count DESC, sector
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($unique as $row) {
    echo "   sector: '{$row['sector']}' → {$row['count']} registros\n";
}

// 2. Local de prueba
echo "\n2. Local de prueba (id_local=11259):\n";
$test = $pdo->query("
    SELECT id_local, nombre, sector
    FROM publico.ta_11_locales
    WHERE id_local = 11259
")->fetch(PDO::FETCH_ASSOC);

if ($test) {
    echo "   id_local: {$test['id_local']}\n";
    echo "   nombre: {$test['nombre']}\n";
    echo "   sector: '{$test['sector']}'\n";
}

// 3. Verificar si 'E' existe como opción
echo "\n3. Opciones en el select del frontend:\n";
$frontend_options = ['01', '02', 'EA', 'PS', 'SS', 'T1', 'T2'];
echo "   Opciones: " . implode(', ', $frontend_options) . "\n";

echo "\n4. Valores de BD que NO están en el select:\n";
$missing = [];
foreach ($unique as $row) {
    if (!in_array($row['sector'], $frontend_options)) {
        $missing[] = $row['sector'];
        echo "   '{$row['sector']}' ({$row['count']} registros) ← NO ESTÁ EN SELECT\n";
    }
}

if (empty($missing)) {
    echo "   ✓ Todos los valores de la BD están en el select\n";
}

echo "\n==============================================\n";
echo "SOLUCIÓN\n";
echo "==============================================\n";

if (!empty($missing)) {
    echo "Necesitas agregar estas opciones al select del frontend:\n\n";
    foreach ($unique as $row) {
        if (!in_array($row['sector'], $frontend_options)) {
            echo "<option value=\"{$row['sector']}\">SECTOR {$row['sector']}</option>\n";
        }
    }
} else {
    echo "El select ya tiene todas las opciones necesarias.\n";
}
