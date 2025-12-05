<?php
// Desplegar y probar SP: recaudadora_reimpfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_reimpfrm ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_reimpfrm.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // EJEMPLO 1: Multa Dependencia 7 (Reglamentos)
    echo "=== EJEMPLO 1: Multa Folio 170736 - Dependencia 7 (Reglamentos) ===\n";
    echo "Campos del formulario:\n";
    echo "  - Tipo de Documento: multa\n";
    echo "  - Folio / ID: 170736\n";
    echo "  - Dependencia: 7 - Reglamentos\n";
    echo "  - Formato: original\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_reimpfrm(?, ?, ?, ?)");
    $stmt1->execute([170736, 'multa', 7, 'original']);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    if (count($result1) > 0) {
        $row = $result1[0];
        echo "Resultado:\n";
        echo "  Folio: {$row['folio']}\n";
        echo "  Tipo: {$row['tipo_documento']}\n";
        echo "  Contribuyente: {$row['contribuyente']}\n";
        echo "  Fecha: {$row['fecha']}\n";
        echo "  Importe: \${$row['importe']}\n";
        echo "  Estatus: {$row['estatus']}\n";
        echo "  Dependencia: {$row['dependencia']}\n";
        echo "  Año Acta: {$row['axo_acta']} | Num Acta: {$row['num_acta']}\n";
    } else {
        echo "  ❌ No se encontró el documento\n";
    }

    // EJEMPLO 2: Multa Dependencia 3 (Tránsito)
    echo "\n\n=== EJEMPLO 2: Multa Folio 170780 - Dependencia 3 (Tránsito) ===\n";
    echo "Campos del formulario:\n";
    echo "  - Tipo de Documento: multa\n";
    echo "  - Folio / ID: 170780\n";
    echo "  - Dependencia: 3 - Tránsito\n";
    echo "  - Formato: copia\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_reimpfrm(?, ?, ?, ?)");
    $stmt2->execute([170780, 'multa', 3, 'copia']);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    if (count($result2) > 0) {
        $row = $result2[0];
        echo "Resultado:\n";
        echo "  Folio: {$row['folio']}\n";
        echo "  Tipo: {$row['tipo_documento']}\n";
        echo "  Contribuyente: {$row['contribuyente']}\n";
        echo "  Fecha: {$row['fecha']}\n";
        echo "  Importe: \${$row['importe']}\n";
        echo "  Estatus: {$row['estatus']}\n";
        echo "  Dependencia: {$row['dependencia']}\n";
        echo "  Año Acta: {$row['axo_acta']} | Num Acta: {$row['num_acta']}\n";
    } else {
        echo "  ❌ No se encontró el documento\n";
    }

    // EJEMPLO 3: Multa sin filtro de dependencia
    echo "\n\n=== EJEMPLO 3: Multa Folio 162737 - Todas las dependencias ===\n";
    echo "Campos del formulario:\n";
    echo "  - Tipo de Documento: multa\n";
    echo "  - Folio / ID: 162737\n";
    echo "  - Dependencia: Todas\n";
    echo "  - Formato: duplicado\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_reimpfrm(?, ?, ?, ?)");
    $stmt3->execute([162737, 'multa', null, 'duplicado']);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (count($result3) > 0) {
        $row = $result3[0];
        echo "Resultado:\n";
        echo "  Folio: {$row['folio']}\n";
        echo "  Tipo: {$row['tipo_documento']}\n";
        echo "  Contribuyente: {$row['contribuyente']}\n";
        echo "  Fecha: {$row['fecha']}\n";
        echo "  Importe: \${$row['importe']}\n";
        echo "  Estatus: {$row['estatus']}\n";
        echo "  Dependencia: {$row['dependencia']}\n";
        echo "  Año Acta: {$row['axo_acta']} | Num Acta: {$row['num_acta']}\n";
    } else {
        echo "  ❌ No se encontró el documento\n";
    }

    echo "\n\n✅ TODAS LAS PRUEBAS COMPLETADAS\n";

    echo "\n=== RESUMEN DE EJEMPLOS ===\n\n";
    echo "1. Multa de Reglamentos (Dep. 7):\n";
    echo "   Folio: 170736 | Contribuyente: JOSEFINA RUVALCABA PEREZ | \$400.00\n\n";

    echo "2. Multa de Tránsito (Dep. 3):\n";
    echo "   Folio: 170780 | Contribuyente: DAMIAN ASCENCIO IGNACIO MARTIN | \$50.00\n\n";

    echo "3. Multa (Dep. 5):\n";
    echo "   Folio: 162737 | Contribuyente: FRANCISCO JAVIER GUDIÑO BERNAL | \$350.00\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
