<?php
// Probar el fix del stored procedure consultapredial

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Aplicar el fix
    echo "1. Aplicando fix al stored procedure...\n";
    $sql = file_get_contents(__DIR__ . '/fix_consultapredial.sql');
    $pdo->exec($sql);
    echo "   ✓ Fix aplicado exitosamente.\n\n";

    // 2. Probar con parámetro vacío (caso que está fallando)
    echo "2. Probando con parámetro vacío (NULL)...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial(NULL)");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 3 predios:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   " . ($i + 1) . ". Cuenta: {$r['cvecuenta']}, Clave: {$r['cvecatnva']}, Saldo: $" . number_format($r['saldo'], 2) . "\n";
        }
    }

    // 3. Probar con parámetro vacío string ''
    echo "\n\n3. Probando con parámetro vacío ('')...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial('')");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

    if (count($rows) > 0) {
        echo "   - Primer predio: Cuenta {$r['cvecuenta']}, Saldo $" . number_format($rows[0]['saldo'], 2) . "\n";
    }

    // 4. Probar con una clave catastral específica
    echo "\n\n4. Buscando una clave catastral de ejemplo...\n";
    $stmt = $pdo->query("SELECT cvecatnva FROM public.cartainvpredial WHERE cvecatnva IS NOT NULL AND cvecatnva != '' LIMIT 1");
    $clave = $stmt->fetchColumn();

    if ($clave) {
        echo "   Clave encontrada: $clave\n";
        echo "   Probando búsqueda con esta clave...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consultapredial(?)");
        $stmt->execute([$clave]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Resultados: " . count($rows) . " predio(s) encontrado(s)\n";

        if (count($rows) > 0) {
            $r = $rows[0];
            echo "\n   Datos del predio:\n";
            echo "     Cuenta: {$r['cvecuenta']}\n";
            echo "     Clave Catastral: {$r['cvecatnva']}\n";
            echo "     Saldo: $" . number_format($r['saldo'], 2) . "\n";
            echo "     Vigente: {$r['vigente']}\n";
        }
    }

    echo "\n\n✅ Fix aplicado y probado exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
