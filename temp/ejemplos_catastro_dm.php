<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "EJEMPLOS PARA PROBAR CatastroDM.vue\n";
    echo "===========================================\n\n";

    // Ejemplo 1: Búsqueda por nombre de propietario
    echo "EJEMPLO 1: Búsqueda por nombre de propietario\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('PASOS', 0, 0, 5)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "En el módulo CatastroDM.vue:\n";
    echo "- Filtro: PASOS\n";
    echo "- Año: 0 (todos)\n\n";
    echo "Resultado esperado: {$results[0]['total_count']} registros encontrados\n";
    echo "Primeros resultados:\n";
    foreach (array_slice($results, 0, 3) as $i => $row) {
        echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
    }

    // Ejemplo 2: Búsqueda por clave catastral
    echo "\n\nEJEMPLO 2: Búsqueda por clave catastral\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('D65I', 0, 0, 5)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "En el módulo CatastroDM.vue:\n";
    echo "- Filtro: D65I\n";
    echo "- Año: 0 (todos)\n\n";
    echo "Resultado esperado: {$results[0]['total_count']} registros encontrados\n";
    echo "Primeros resultados:\n";
    foreach (array_slice($results, 0, 3) as $i => $row) {
        echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
    }

    // Ejemplo 3: Búsqueda por cuenta específica
    echo "\n\nEJEMPLO 3: Búsqueda por cuenta específica\n";
    echo "---------------------------------------------\n";

    // Obtener una cuenta del sistema
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('12143', 0, 0, 3)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "En el módulo CatastroDM.vue:\n";
        echo "- Filtro: 12143\n";
        echo "- Año: 0 (todos)\n\n";
        echo "Resultado esperado: {$results[0]['total_count']} registros encontrados\n";
        echo "Resultados:\n";
        foreach ($results as $i => $row) {
            echo "  " . ($i+1) . ". {$row['clave_cuenta']} - {$row['propietario']}\n";
            echo "     Domicilio: {$row['domicilio']}\n";
        }
    }

    echo "\n\n===========================================\n";
    echo "INSTRUCCIONES:\n";
    echo "===========================================\n";
    echo "1. Abre el módulo CatastroDM en el navegador\n";
    echo "2. Ingresa uno de los valores de 'Filtro' mencionados arriba\n";
    echo "3. Puedes dejar el campo 'Año' en 0 para ver todos los años\n";
    echo "4. Haz clic en el botón 'Buscar'\n";
    echo "5. Verás los resultados con paginación automática\n";
    echo "6. Usa los controles de paginación para navegar entre páginas\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
