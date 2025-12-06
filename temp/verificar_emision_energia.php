<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Verificando condiciones del SP ===\n\n";

$oficina = 5;
$mercado = 1;
$axo = 2013;
$periodo = 6;

// Verificar locales
echo "1. Locales con oficina={$oficina} y mercado={$mercado}:\n";
$stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_locales WHERE oficina = {$oficina} AND num_mercado = {$mercado}");
echo "   Total: " . $stmt->fetch(PDO::FETCH_COLUMN) . "\n\n";

// Verificar locales con vigencia 'A'
echo "2. Locales con vigencia='A':\n";
$stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_locales WHERE oficina = {$oficina} AND num_mercado = {$mercado} AND vigencia = 'A'");
echo "   Total: " . $stmt->fetch(PDO::FETCH_COLUMN) . "\n\n";

// Verificar ta_11_kilowhatts
echo "3. Registros en ta_11_kilowhatts con axo={$axo} y periodo={$periodo}:\n";
$stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_kilowhatts WHERE axo = {$axo} AND periodo = {$periodo}");
$total_kw = $stmt->fetch(PDO::FETCH_COLUMN);
echo "   Total: {$total_kw}\n\n";

if ($total_kw > 0) {
    $stmt = $pdo->query("SELECT * FROM publico.ta_11_kilowhatts WHERE axo = {$axo} AND periodo = {$periodo} LIMIT 1");
    $kw = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Ejemplo: axo={$kw['axo']}, periodo={$kw['periodo']}, importe=\${$kw['importe']}\n\n";
}

// Verificar ta_11_energia
echo "4. Locales con registros en ta_11_energia:\n";
$stmt = $pdo->query("
    SELECT a.id_local, a.nombre, e.id_energia, e.vigencia, e.local_adicional
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_energia e ON a.id_local = e.id_local
    WHERE a.oficina = {$oficina} AND a.num_mercado = {$mercado}
    LIMIT 5
");
$energias = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "   Total encontrados: " . count($energias) . "\n";
foreach ($energias as $e) {
    echo "   - Local {$e['id_local']} ({$e['nombre']}): energia_id={$e['id_energia']}, vigencia={$e['vigencia']}, local_adicional={$e['local_adicional']}\n";
}

echo "\n5. Verificando el query completo del SP:\n";
$stmt = $pdo->query("
    SELECT COUNT(*) as total
    FROM publico.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN publico.ta_11_kilowhatts c ON c.axo = {$axo} AND c.periodo = {$periodo}
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = {$oficina}
      AND a.num_mercado = {$mercado}
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
");
$total = $stmt->fetch(PDO::FETCH_COLUMN);
echo "   Total registros que cumple todas las condiciones: {$total}\n\n";

// Si el total es 0, verificar qué condición falla
if ($total == 0) {
    echo "Verificando qué condición está fallando:\n\n";

    // Sin vigencia E
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.ta_11_locales a
        JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN publico.ta_11_kilowhatts c ON c.axo = {$axo} AND c.periodo = {$periodo}
        JOIN publico.ta_11_energia d ON a.id_local = d.id_local
        WHERE a.oficina = {$oficina}
          AND a.num_mercado = {$mercado}
          AND a.vigencia = 'A'
    ");
    echo "   Sin filtro d.vigencia='E': " . $stmt->fetch(PDO::FETCH_COLUMN) . " registros\n";

    // Mostrar valores de vigencia únicos en ta_11_energia
    $stmt = $pdo->query("
        SELECT DISTINCT e.vigencia, COUNT(*) as total
        FROM publico.ta_11_locales a
        JOIN publico.ta_11_energia e ON a.id_local = e.id_local
        WHERE a.oficina = {$oficina} AND a.num_mercado = {$mercado}
        GROUP BY e.vigencia
    ");
    echo "\n   Valores de vigencia en ta_11_energia:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $v) {
        echo "     vigencia='{$v['vigencia']}': {$v['total']} registros\n";
    }
}
