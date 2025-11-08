<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VERIFICAR: SPs de Registro de Solicitud\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Verificar los SPs necesarios
    $sps_requeridos = [
        'sp_registro_solicitud',
        'sp_agregar_documento'
    ];

    echo "Verificando SPs requeridos:\n";
    echo "========================================\n";

    foreach ($sps_requeridos as $sp_name) {
        $stmt = $pdo->prepare("
            SELECT
                n.nspname as schema,
                p.proname as name,
                pg_get_function_arguments(p.oid) as arguments,
                pg_get_function_result(p.oid) as return_type
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE LOWER(p.proname) = LOWER(?)
        ");
        $stmt->execute([$sp_name]);
        $sp_info = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sp_info) {
            echo "  ✅ {$sp_name}:\n";
            echo "      Schema: {$sp_info['schema']}\n";
            echo "      Argumentos: {$sp_info['arguments']}\n";
            echo "      Retorna: {$sp_info['return_type']}\n";
        } else {
            echo "  ❌ {$sp_name}: NO EXISTE\n";
            echo "      Necesita ser creado\n";
        }
        echo "\n";
    }

    echo "========================================\n";
    echo "Verificación completada\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
