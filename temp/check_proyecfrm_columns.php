<?php
// Verificar columnas del SP recaudadora_proyecfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== VERIFICANDO COLUMNAS DEL SP ===\n\n";

    $sql = "SELECT * FROM public.recaudadora_proyecfrm('') LIMIT 1";
    $stmt = $pdo->query($sql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Columnas retornadas (en orden):\n\n";
        $idx = 1;
        foreach ($result as $key => $value) {
            $valueDisplay = $value ?? '(null)';
            if (strlen($valueDisplay) > 50) {
                $valueDisplay = substr($valueDisplay, 0, 50) . '...';
            }
            echo "$idx. Columna: '$key' | Valor: $valueDisplay\n";
            $idx++;
        }

        // Verificar si hay alguna columna con nombre vacío
        $emptyKeys = array_filter(array_keys($result), function($key) {
            return trim($key) === '';
        });

        if (!empty($emptyKeys)) {
            echo "\n⚠️ PROBLEMA DETECTADO: Se encontraron columnas con nombres vacíos\n";
        } else {
            echo "\n✅ No hay columnas con nombres vacíos\n";
        }

        // Mostrar todas las claves
        echo "\nLista de claves:\n";
        echo json_encode(array_keys($result), JSON_PRETTY_PRINT) . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
