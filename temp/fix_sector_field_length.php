<?php
// Script para cambiar el campo sector de char(1) a char(2)

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== MODIFICANDO CAMPO sector EN ta_11_localpaso ===\n\n";

    // Cambiar el tipo de dato
    $alterSQL = "ALTER TABLE public.ta_11_localpaso ALTER COLUMN sector TYPE char(2)";

    echo "Ejecutando: $alterSQL\n";
    $pdo->exec($alterSQL);
    echo "✓ Campo modificado exitosamente\n\n";

    // Verificar el cambio
    $verifyQuery = "
        SELECT
            column_name,
            data_type,
            character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'ta_11_localpaso'
        AND column_name = 'sector'
    ";

    $stmt = $pdo->query($verifyQuery);
    $col = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "=== VERIFICACIÓN ===\n";
    echo "Campo: {$col['column_name']}\n";
    echo "Tipo: {$col['data_type']}({$col['character_maximum_length']})\n";
    echo "\n✓✓✓ CAMBIO COMPLETADO\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
