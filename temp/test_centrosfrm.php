<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "EJEMPLOS PARA PROBAR centrosfrm.vue\n";
    echo "===========================================\n\n";

    // Ejemplo 1: Ver todos los centros (sin filtro)
    echo "EJEMPLO 1: Ver todos los centros\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_centrosfrm('')");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "En el módulo centrosfrm.vue:\n";
    echo "- Filtro: (dejar vacío)\n\n";
    echo "Resultado esperado: " . count($results) . " centros encontrados\n\n";
    echo "Primeros 5 centros:\n";
    foreach (array_slice($results, 0, 5) as $i => $row) {
        echo "  " . ($i+1) . ". ID: {$row['id_centro']} - {$row['nombre']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
        echo "     Teléfonos: {$row['telefonos']}\n\n";
    }

    // Ejemplo 2: Buscar por nombre "CENTRO"
    echo "\n\nEJEMPLO 2: Buscar centros que contengan 'CENTRO'\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_centrosfrm('CENTRO')");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "En el módulo centrosfrm.vue:\n";
    echo "- Filtro: CENTRO\n\n";
    echo "Resultado esperado: " . count($results) . " centros encontrados\n\n";
    echo "Resultados:\n";
    foreach (array_slice($results, 0, 5) as $i => $row) {
        echo "  " . ($i+1) . ". ID: {$row['id_centro']} - {$row['nombre']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
        if ($row['domicilio2']) {
            echo "     Domicilio 2: {$row['domicilio2']}\n";
        }
        echo "\n";
    }

    // Ejemplo 3: Buscar por domicilio "REFORMA"
    echo "\n\nEJEMPLO 3: Buscar centros en 'REFORMA'\n";
    echo "---------------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_centrosfrm('REFORMA')");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "En el módulo centrosfrm.vue:\n";
    echo "- Filtro: REFORMA\n\n";
    echo "Resultado esperado: " . count($results) . " centros encontrados\n\n";
    echo "Resultados:\n";
    foreach ($results as $i => $row) {
        echo "  " . ($i+1) . ". ID: {$row['id_centro']} - {$row['nombre']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
        if ($row['domicilio2']) {
            echo "     Domicilio 2: {$row['domicilio2']}\n";
        }
        echo "     Horario: {$row['horario']}\n";
        echo "     Teléfonos: {$row['telefonos']}\n";
        echo "     Cajas: {$row['cajas']}\n\n";
    }

    echo "\n===========================================\n";
    echo "NOTAS:\n";
    echo "===========================================\n";
    echo "- Total de centros en la base de datos: " . count($results) . "\n";
    echo "- Puedes buscar por nombre, domicilio, ID o teléfono\n";
    echo "- Si dejas el filtro vacío, se muestran todos los centros\n";
    echo "- La búsqueda no distingue entre mayúsculas y minúsculas\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
