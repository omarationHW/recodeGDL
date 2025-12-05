<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO DATOS PARA REPORTE DE DESCUENTOS DE IMPUESTO ===\n\n";

// Buscar tablas relacionadas con descuentos
echo "1. BUSCANDO TABLAS DE DESCUENTOS:\n";
$stmt1 = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%desc%'
    AND table_schema IN ('comun', 'public', 'multas_reglamentos')
    ORDER BY table_schema, table_name
");
$tablas = $stmt1->fetchAll(PDO::FETCH_ASSOC);
foreach ($tablas as $t) {
    echo "  {$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar datos en tabla descpredial (descuentos predial)
echo "\n\n2. DATOS EN comun.descpredial:\n";
try {
    $stmt2 = $pdo->query("
        SELECT
            ejercicio,
            COUNT(*) as total_registros,
            SUM(CASE WHEN descuento > 0 THEN 1 ELSE 0 END) as con_descuento
        FROM comun.descpredial
        WHERE ejercicio IS NOT NULL
        GROUP BY ejercicio
        ORDER BY ejercicio DESC
        LIMIT 10
    ");
    $ejercicios = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach ($ejercicios as $e) {
        echo "  Ejercicio: {$e['ejercicio']} | Registros: {$e['total_registros']} | Con descuento: {$e['con_descuento']}\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Buscar datos en tabla descrec (descuentos recaudación)
echo "\n\n3. DATOS EN comun.descrec:\n";
try {
    $stmt3 = $pdo->query("
        SELECT
            ejercicio,
            COUNT(*) as total_registros,
            SUM(porcentaje) as suma_porcentajes
        FROM comun.descrec
        WHERE ejercicio IS NOT NULL
        GROUP BY ejercicio
        ORDER BY ejercicio DESC
        LIMIT 10
    ");
    $descrec = $stmt3->fetchAll(PDO::FETCH_ASSOC);
    foreach ($descrec as $d) {
        echo "  Ejercicio: {$d['ejercicio']} | Registros: {$d['total_registros']} | Suma %: {$d['suma_porcentajes']}\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Ver estructura de descpredial
echo "\n\n4. ESTRUCTURA DE comun.descpredial (primeros 5 registros):\n";
try {
    $stmt4 = $pdo->query("
        SELECT *
        FROM comun.descpredial
        WHERE ejercicio >= 2020
        ORDER BY ejercicio DESC
        LIMIT 5
    ");
    $muestra = $stmt4->fetchAll(PDO::FETCH_ASSOC);
    if (count($muestra) > 0) {
        echo "  Columnas: " . implode(', ', array_keys($muestra[0])) . "\n\n";
        foreach ($muestra as $m) {
            echo "  Ejercicio: {$m['ejercicio']} | Cuenta: {$m['cve_cuenta']} | Descuento: {$m['descuento']}%\n";
        }
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Buscar años con más datos
echo "\n\n5. EJERCICIOS CON MÁS DATOS:\n";
try {
    $stmt5 = $pdo->query("
        SELECT
            ejercicio,
            COUNT(*) as total,
            AVG(descuento) as promedio_descuento,
            MAX(descuento) as max_descuento
        FROM comun.descpredial
        WHERE ejercicio BETWEEN 2015 AND 2030
        GROUP BY ejercicio
        HAVING COUNT(*) > 0
        ORDER BY total DESC
        LIMIT 5
    ");
    $top = $stmt5->fetchAll(PDO::FETCH_ASSOC);
    foreach ($top as $t) {
        echo "  Ejercicio: {$t['ejercicio']} | Total: {$t['total']} | Promedio: {$t['promedio_descuento']}% | Max: {$t['max_descuento']}%\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Generar 3 ejemplos
echo "\n\n=== 3 EJEMPLOS PARA EL FORMULARIO ===\n\n";
try {
    $ejemplos = $pdo->query("
        SELECT ejercicio, COUNT(*) as total
        FROM comun.descpredial
        WHERE ejercicio BETWEEN 2020 AND 2025
        GROUP BY ejercicio
        HAVING COUNT(*) > 10
        ORDER BY ejercicio DESC
        LIMIT 3
    ")->fetchAll(PDO::FETCH_ASSOC);

    $i = 1;
    foreach ($ejemplos as $ej) {
        echo "EJEMPLO {$i}:\n";
        echo "  Ejercicio: {$ej['ejercicio']}\n";
        echo "  Registros esperados: {$ej['total']}\n\n";
        $i++;
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

?>
