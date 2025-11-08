<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "EJECUTAR: Crear SPs de Registro\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/crear_sp_registro_adaptado.sql';
    $sql = file_get_contents($sqlFile);

    echo "Ejecutando SQL...\n";
    $pdo->exec($sql);

    echo "✅ SPs creados exitosamente\n\n";

    // Verificar que se crearon
    echo "Verificando SPs:\n";
    echo "========================================\n";

    $sps = ['sp_registro_solicitud', 'sp_agregar_documento'];

    foreach ($sps as $sp) {
        $stmt = $pdo->prepare("
            SELECT
                n.nspname as schema,
                p.proname as name,
                pg_get_function_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'comun' AND p.proname = ?
        ");
        $stmt->execute([$sp]);
        $info = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($info) {
            echo "  ✅ {$sp}\n";
            echo "      Schema: {$info['schema']}\n";
            echo "      Args: " . substr($info['arguments'], 0, 80) . "...\n";
        } else {
            echo "  ❌ {$sp}: NO SE PUDO CREAR\n";
        }
    }

    echo "\n========================================\n";
    echo "✅ Proceso completado\n";
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
