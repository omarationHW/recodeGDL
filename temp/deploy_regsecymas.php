<?php
// Desplegar y probar SP: recaudadora_regsecymas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_regsecymas ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_regsecymas.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // EJEMPLO 1: Buscar por nombre "JAVIER"
    echo "=== EJEMPLO 1: Buscar por nombre 'JAVIER' ===\n";
    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_regsecymas(?)");
    $stmt1->execute(['JAVIER']);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados encontrados: " . count($result1) . "\n\n";
    foreach (array_slice($result1, 0, 5) as $row) {
        echo "  ID: {$row['id_ejecutor']} | Clave: {$row['cve_eje']} | Nombre: {$row['nombre']}\n";
    }
    if (count($result1) > 5) {
        echo "  ... y " . (count($result1) - 5) . " más\n";
    }

    // EJEMPLO 2: Buscar por RFC "CEGJ"
    echo "\n\n=== EJEMPLO 2: Buscar por RFC 'CEGJ' ===\n";
    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_regsecymas(?)");
    $stmt2->execute(['CEGJ']);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados encontrados: " . count($result2) . "\n\n";
    foreach ($result2 as $row) {
        echo "  ID: {$row['id_ejecutor']} | Clave: {$row['cve_eje']} | Nombre: {$row['nombre']} | RFC: {$row['ini_rfc']}\n";
    }

    // EJEMPLO 3: Buscar por clave "154"
    echo "\n\n=== EJEMPLO 3: Buscar por clave '154' ===\n";
    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_regsecymas(?)");
    $stmt3->execute(['154']);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados encontrados: " . count($result3) . "\n\n";
    foreach ($result3 as $row) {
        echo "  ID: {$row['id_ejecutor']} | Clave: {$row['cve_eje']} | Nombre: {$row['nombre']}\n";
    }

    // Ejemplo adicional: Todos los ejecutores (sin filtro)
    echo "\n\n=== EJEMPLO 4: Todos los ejecutores (primeros 10) ===\n";
    $stmt4 = $pdo->prepare("SELECT * FROM public.recaudadora_regsecymas(?)");
    $stmt4->execute(['']);
    $result4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de ejecutores: " . count($result4) . "\n\n";
    foreach (array_slice($result4, 0, 10) as $row) {
        echo "  ID: {$row['id_ejecutor']} | Clave: {$row['cve_eje']} | Nombre: {$row['nombre']}\n";
    }
    if (count($result4) > 10) {
        echo "  ... y " . (count($result4) - 10) . " más\n";
    }

    echo "\n\n✅ TODAS LAS PRUEBAS EXITOSAS\n";

    echo "\n=== 3 EJEMPLOS PARA PROBAR EL FORMULARIO ===\n\n";
    echo "1. Buscar por NOMBRE:\n";
    echo "   Escribir en el campo: JAVIER\n";
    echo "   Resultado esperado: " . count($result1) . " ejecutores\n\n";

    echo "2. Buscar por RFC:\n";
    echo "   Escribir en el campo: CEGJ\n";
    echo "   Resultado esperado: " . count($result2) . " ejecutor(es)\n\n";

    echo "3. Buscar por CLAVE:\n";
    echo "   Escribir en el campo: 154\n";
    echo "   Resultado esperado: " . count($result3) . " ejecutor(es)\n\n";

    echo "4. Ver TODOS (dejar vacío o hacer clic en Buscar sin escribir nada):\n";
    echo "   Resultado esperado: Hasta 100 ejecutores con paginación de 10 en 10\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
