<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Probando datos en comun.ta_11_locales ===\n\n";

// 1. Verificar qué hay con oficina=3, mercado=4, seccion=02, local=1
echo "1. Buscando locales con oficina=3, mercado=4, seccion=02, local=1:\n";
$stmt = $pdo->query("
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque
    FROM comun.ta_11_locales
    WHERE oficina = 3 AND num_mercado = 4 AND categoria = 1 AND seccion = '02' AND local = 1
    LIMIT 10
");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros encontrados: " . count($rows) . "\n";
foreach ($rows as $row) {
    echo "  - id_local: {$row['id_local']}, letra: '{$row['letra_local']}', bloque: '{$row['bloque']}'\n";
}

// 2. Ver algunos locales de oficina 3, mercado 4
echo "\n2. Mostrando algunos locales de oficina=3, mercado=4:\n";
$stmt = $pdo->query("
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque
    FROM comun.ta_11_locales
    WHERE oficina = 3 AND num_mercado = 4
    LIMIT 10
");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $row) {
    echo "  - Sec: {$row['seccion']}, Local: {$row['local']}, Letra: '{$row['letra_local']}', Bloque: '{$row['bloque']}'\n";
}

// 3. Ver qué secciones hay en oficina 3, mercado 4
echo "\n3. Secciones disponibles en oficina=3, mercado=4:\n";
$stmt = $pdo->query("
    SELECT DISTINCT seccion
    FROM comun.ta_11_locales
    WHERE oficina = 3 AND num_mercado = 4
    ORDER BY seccion
");
$secciones = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo "Secciones: " . implode(", ", $secciones) . "\n";

// 4. Probar el SP con los parámetros del usuario (NULL en lugar de "1")
echo "\n4. Probando SP con parámetros: oficina=3, mercado=4, cat=1, sec='02', local=1, letra=NULL, bloque=NULL:\n";
$stmt = $pdo->query("SELECT * FROM sp_cons_requerimientos_buscar(3, 4, 1, '02', 1, NULL, NULL)");
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros: " . count($result) . "\n";
foreach ($result as $r) {
    echo "  - id_local: {$r['id_local']}, letra: '{$r['letra_local']}', bloque: '{$r['bloque']}'\n";
}

// 5. Probar con letra='1' y bloque='1'
echo "\n5. Probando SP con letra='1', bloque='1':\n";
$stmt = $pdo->query("SELECT * FROM sp_cons_requerimientos_buscar(3, 4, 1, '02', 1, '1', '1')");
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros: " . count($result) . "\n";

// 6. Ver valores únicos de letra_local y bloque
echo "\n6. Valores únicos de letra_local en oficina=3, mercado=4, seccion='02':\n";
$stmt = $pdo->query("
    SELECT DISTINCT letra_local, COUNT(*) as total
    FROM comun.ta_11_locales
    WHERE oficina = 3 AND num_mercado = 4 AND seccion = '02'
    GROUP BY letra_local
    ORDER BY letra_local
");
$letras = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($letras as $l) {
    $letra = $l['letra_local'] === null ? 'NULL' : "'{$l['letra_local']}'";
    echo "  - Letra: $letra ({$l['total']} locales)\n";
}

echo "\n7. Valores únicos de bloque:\n";
$stmt = $pdo->query("
    SELECT DISTINCT bloque, COUNT(*) as total
    FROM comun.ta_11_locales
    WHERE oficina = 3 AND num_mercado = 4 AND seccion = '02'
    GROUP BY bloque
    ORDER BY bloque
");
$bloques = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($bloques as $b) {
    $bloque = $b['bloque'] === null ? 'NULL' : "'{$b['bloque']}'";
    echo "  - Bloque: $bloque ({$b['total']} locales)\n";
}
