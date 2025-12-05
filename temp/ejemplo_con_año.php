<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "BUSCANDO REGISTROS CON AÑOS ESPECÍFICOS\n";
    echo "===========================================\n\n";

    // Primero, ver qué años existen en la base de datos
    echo "Años disponibles en la base de datos:\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->query("
        SELECT axoadeudo, COUNT(*) as cantidad
        FROM catastro_gdl.controladora
        WHERE axoadeudo IS NOT NULL AND axoadeudo > 0
        GROUP BY axoadeudo
        ORDER BY cantidad DESC
        LIMIT 10
    ");
    $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($years as $year) {
        echo "Año {$year['axoadeudo']}: {$year['cantidad']} registros\n";
    }

    // Tomar el año con más registros
    if (count($years) > 0) {
        $year_selected = $years[0]['axoadeudo'];

        echo "\n\n===========================================\n";
        echo "EJEMPLO CON AÑO: $year_selected\n";
        echo "===========================================\n\n";

        // Búsqueda general con año específico
        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', ?, 0, 5)");
        $stmt->execute([$year_selected]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "En el módulo CatastroDM.vue:\n";
            echo "- Filtro: (dejar vacío o buscar algo específico)\n";
            echo "- Año: $year_selected\n\n";
            echo "Resultado esperado: {$results[0]['total_count']} registros encontrados\n\n";
            echo "Primeros 5 resultados:\n";
            foreach ($results as $i => $row) {
                echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
                echo "     Domicilio: {$row['domicilio']}\n";
                echo "     Año: {$row['ejercicio']}\n\n";
            }
        }

        // Ahora buscar algo específico con ese año
        echo "\n===========================================\n";
        echo "EJEMPLO COMBINANDO BÚSQUEDA + AÑO\n";
        echo "===========================================\n\n";

        // Obtener un propietario del año seleccionado
        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', ?, 0, 1)");
        $stmt->execute([$year_selected]);
        $sample = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sample && $sample['propietario'] != 'Sin nombre') {
            $nombre_buscar = explode(' ', $sample['propietario'])[0];

            $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm(?, ?, 0, 5)");
            $stmt->execute([$nombre_buscar, $year_selected]);
            $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($results2) > 0) {
                echo "En el módulo CatastroDM.vue:\n";
                echo "- Filtro: $nombre_buscar\n";
                echo "- Año: $year_selected\n\n";
                echo "Resultado esperado: {$results2[0]['total_count']} registros encontrados\n\n";
                echo "Primeros resultados:\n";
                foreach (array_slice($results2, 0, 3) as $i => $row) {
                    echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
                    echo "     Domicilio: {$row['domicilio']}\n";
                    echo "     Año: {$row['ejercicio']}\n\n";
                }
            }
        }
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
