<?php
// Script para probar el stored procedure recaudadora_consultapredial actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consultapredial...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consultapredial.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar una clave catastral de ejemplo
    echo "2. Buscando claves catastrales de ejemplo...\n";
    $stmt = $pdo->query("SELECT DISTINCT cvecatnva FROM public.cartainvpredial WHERE cvecatnva IS NOT NULL LIMIT 5");
    $claves = $stmt->fetchAll(PDO::FETCH_COLUMN);

    echo "   Claves catastrales encontradas:\n";
    foreach ($claves as $clave) {
        echo "     - $clave\n";
    }

    if (count($claves) > 0) {
        $claveEjemplo = $claves[0];

        // 3. Probar con clave catastral de ejemplo
        echo "\n\n3. Probando con clave catastral '$claveEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial(?)");
        $stmt->execute([$claveEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

        if (count($rows) > 0) {
            $r = $rows[0];
            echo "\n   Datos del predio:\n";
            echo "     ID: " . $r["id_predio"] . "\n";
            echo "     Clave Catastral: " . $r["cvecatnva"] . "\n";
            echo "     Cuenta: " . $r["cvecuenta"] . "\n";
            echo "     Vigente: " . $r["vigente"] . "\n";
            echo "     Urbano/Rústico: " . $r["urbano_rustico"] . "\n";
            echo "     Valor Fiscal: $" . number_format($r["val_fiscal"], 2) . "\n";
            echo "     Saldo: $" . number_format($r["saldo"], 2) . "\n";
            echo "     Año Adeudo: " . $r["axoadeudo"] . "\n";
            echo "     Tipo: " . $r["tipo_predio"] . "\n";
            echo "     Bloqueado: " . ($r["bloqueado"] == 'S' ? 'Sí' : 'No') . "\n";
            echo "     Fecha Registro: " . $r["fecha_registro"] . "\n";
        }
    }

    // 4. Probar con otra clave catastral si hay más
    if (count($claves) > 1) {
        $claveEjemplo2 = $claves[1];

        echo "\n\n4. Probando con clave catastral '$claveEjemplo2'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial(?)");
        $stmt->execute([$claveEjemplo2]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

        if (count($rows) > 0) {
            $r = $rows[0];
            echo "   - Cuenta: {$r['cvecuenta']}, Saldo: $" . number_format($r['saldo'], 2) . "\n";
        }
    }

    // 5. Probar con clave inexistente
    echo "\n\n5. Probando con clave catastral inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial(?)");
    $stmt->execute(['CLAVE-NO-EXISTE']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
