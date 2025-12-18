<?php
// Script para verificar el stored procedure conscentrosfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el contenido del stored procedure existente
    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_conscentrosfrm ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_conscentrosfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

    // Verificar si existe la tabla c_dependencias (que usamos antes)
    echo "\n\n=== VERIFICANDO TABLA publico.c_dependencias ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.c_dependencias WHERE vigencia = 'V'");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de dependencias activas: {$result['total']}\n";

    echo "\nEjemplo de datos:\n";
    $stmt = $pdo->query("SELECT * FROM publico.c_dependencias WHERE vigencia = 'V' LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $i => $row) {
        echo "  " . ($i + 1) . ". ID: {$row['id_dependencia']}, Nombre: " . trim($row['descripcion']) . ", Tipo: " . trim($row['tipo']) . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
