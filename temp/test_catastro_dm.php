<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== TEST 1: Búsqueda general (sin filtros) ===\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 0, 0, 5)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "Total registros: " . $results[0]['total_count'] . "\n";
        echo "Primeros 5 resultados:\n";
        foreach ($results as $i => $row) {
            echo ($i+1) . ". Cuenta: {$row['clave_cuenta']}, Propietario: {$row['propietario']}, Colonia: {$row['colonia']}, Año: {$row['ejercicio']}\n";
        }
    } else {
        echo "No hay resultados\n";
    }

    echo "\n=== TEST 2: Búsqueda por cuenta específica ===\n";
    if (count($results) > 0) {
        // Usar una cuenta del primer resultado
        $cuenta_test = $results[0]['clave_cuenta'];
        $busqueda = substr($cuenta_test, 0, 5); // Buscar por los primeros caracteres

        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm(?, 0, 0, 3)");
        $stmt->execute([$busqueda]);
        $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Búsqueda: '$busqueda'\n";
        echo "Resultados encontrados: " . count($results2) . "\n";
        foreach ($results2 as $i => $row) {
            echo ($i+1) . ". Cuenta: {$row['clave_cuenta']}, Propietario: {$row['propietario']}\n";
        }
    }

    echo "\n=== TEST 3: Filtrar por año ===\n";
    if (count($results) > 0) {
        $year_test = $results[0]['ejercicio'];

        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', ?, 0, 5)");
        $stmt->execute([$year_test]);
        $results3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Filtro de año: $year_test\n";
        echo "Resultados encontrados: " . count($results3) . "\n";
        foreach ($results3 as $i => $row) {
            echo ($i+1) . ". Cuenta: {$row['clave_cuenta']}, Año: {$row['ejercicio']}, Propietario: {$row['propietario']}\n";
        }
    }

    echo "\n=== TEST 4: Paginación (página 2) ===\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 0, 5, 5)");
    $stmt->execute();
    $results4 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Offset: 5, Limit: 5\n";
    echo "Resultados encontrados: " . count($results4) . "\n";
    foreach ($results4 as $i => $row) {
        echo ($i+1) . ". Cuenta: {$row['clave_cuenta']}, Propietario: {$row['propietario']}\n";
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
