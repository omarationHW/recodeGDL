<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "EJEMPLO 4: FILTRADO POR AÑO ESPECÍFICO\n";
    echo "===========================================\n\n";

    // Ejemplo 1: Solo filtro de año 2018
    echo "--- Opción 1: Solo filtrar por año ---\n\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 2018, 0, 5)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "En el módulo CatastroDM.vue:\n";
        echo "- Filtro: (dejar vacío)\n";
        echo "- Año: 2018\n\n";
        echo "Resultado esperado: " . number_format($results[0]['total_count']) . " registros encontrados\n\n";
        echo "Primeros 5 resultados:\n";
        foreach ($results as $i => $row) {
            echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
            echo "     Domicilio: {$row['domicilio']}\n";
            echo "     Año: {$row['ejercicio']}\n\n";
        }
    }

    // Ejemplo 2: Combinar búsqueda con año
    echo "\n--- Opción 2: Buscar 'BUENROSTRO' del año 2018 ---\n\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('BUENROSTRO', 2018, 0, 5)");
    $stmt->execute();
    $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results2) > 0) {
        echo "En el módulo CatastroDM.vue:\n";
        echo "- Filtro: BUENROSTRO\n";
        echo "- Año: 2018\n\n";
        echo "Resultado esperado: {$results2[0]['total_count']} registros encontrados\n\n";
        echo "Resultados:\n";
        foreach ($results2 as $i => $row) {
            echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
            echo "     Domicilio: {$row['domicilio']}\n";
            echo "     Año: {$row['ejercicio']}\n\n";
        }
    }

    // Ejemplo 3: Año 2017
    echo "\n--- Opción 3: Registros del año 2017 ---\n\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 2017, 0, 5)");
    $stmt->execute();
    $results3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results3) > 0) {
        echo "En el módulo CatastroDM.vue:\n";
        echo "- Filtro: (dejar vacío)\n";
        echo "- Año: 2017\n\n";
        echo "Resultado esperado: " . number_format($results3[0]['total_count']) . " registros encontrados\n\n";
        echo "Primeros 3 resultados:\n";
        foreach (array_slice($results3, 0, 3) as $i => $row) {
            echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
            echo "     Domicilio: {$row['domicilio']}\n";
            echo "     Año: {$row['ejercicio']}\n\n";
        }
    }

    echo "\n===========================================\n";
    echo "AÑOS DISPONIBLES EN LA BASE DE DATOS:\n";
    echo "===========================================\n";
    echo "2018: 337,553 registros\n";
    echo "2017:  23,666 registros\n";
    echo "2016:   9,844 registros\n";
    echo "2015:   6,305 registros\n";
    echo "...\n";
    echo "(Años disponibles desde 1999 hasta 2018)\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
