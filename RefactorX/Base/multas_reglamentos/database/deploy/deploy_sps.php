<?php
/**
 * Script para desplegar SPs de Multas y Reglamentos
 * Ejecutar: php deploy_sps.php
 */

// Configuracion BD
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== DEPLOY SPs MULTAS Y REGLAMENTOS ===\n";
echo "Conectando a: $host:$port/$dbname\n\n";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "[OK] Conexion establecida\n\n";
} catch (PDOException $e) {
    die("[ERROR] No se pudo conectar: " . $e->getMessage() . "\n");
}

// Verificar si existe el esquema multas_reglamentos
$result = $pdo->query("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'multas_reglamentos'");
if ($result->rowCount() == 0) {
    echo "[INFO] Creando esquema multas_reglamentos...\n";
    $pdo->exec("CREATE SCHEMA IF NOT EXISTS multas_reglamentos");
}
echo "[OK] Esquema multas_reglamentos verificado\n\n";

// Archivos a ejecutar
$files = [
    'DEPLOY_BATCH1_5_COMPONENTES.sql',
    'DEPLOY_BATCH2_3_COMPONENTES.sql',
    'DEPLOY_BATCH3_3_COMPONENTES.sql'
];

foreach ($files as $file) {
    $filepath = __DIR__ . '/' . $file;
    if (!file_exists($filepath)) {
        echo "[SKIP] Archivo no encontrado: $file\n";
        continue;
    }

    echo "=== Procesando: $file ===\n";
    $sql = file_get_contents($filepath);

    // Dividir por CREATE OR REPLACE FUNCTION usando delimitador $$
    $pattern = '/CREATE OR REPLACE FUNCTION\s+(\w+)\s*\([^)]*\)[^$]+\$\$[^$]+\$\$ LANGUAGE plpgsql;/s';
    preg_match_all($pattern, $sql, $matches, PREG_SET_ORDER);

    $count = 0;
    $errors = 0;

    foreach ($matches as $match) {
        $function = $match[0];
        $funcName = $match[1];

        try {
            $pdo->exec($function);
            echo "  [OK] $funcName\n";
            $count++;
        } catch (PDOException $e) {
            $errorMsg = $e->getMessage();
            // Solo mostrar parte relevante del error
            if (strpos($errorMsg, 'already exists') !== false) {
                echo "  [OK] $funcName (reemplazado)\n";
                $count++;
            } else {
                echo "  [ERR] $funcName: " . substr($errorMsg, 0, 100) . "\n";
                $errors++;
            }
        }
    }

    // Buscar CREATE TABLE IF NOT EXISTS
    preg_match_all('/(CREATE TABLE IF NOT EXISTS\s+(\w+)[^;]+;)/s', $sql, $tableMatches, PREG_SET_ORDER);
    foreach ($tableMatches as $tableMatch) {
        $tableName = $tableMatch[2];
        try {
            $pdo->exec($tableMatch[1]);
            echo "  [OK] Tabla: $tableName\n";
        } catch (PDOException $e) {
            echo "  [INFO] Tabla $tableName: ya existe o error menor\n";
        }
    }

    // Buscar CREATE INDEX IF NOT EXISTS
    preg_match_all('/(CREATE INDEX IF NOT EXISTS[^;]+;)/s', $sql, $indexMatches);
    foreach ($indexMatches[0] as $index) {
        try {
            $pdo->exec($index);
        } catch (PDOException $e) {
            // Ignorar errores de indices
        }
    }

    echo "  >> $count funciones, $errors errores\n\n";
}

// Verificar SPs instalados
echo "=== Verificando SPs instalados ===\n";
$query = "SELECT routine_name FROM information_schema.routines
          WHERE routine_type = 'FUNCTION'
          AND routine_schema = 'public'
          AND (routine_name LIKE 'actualizafechaempresas_%'
               OR routine_name LIKE 'aplicasdosfavor_%'
               OR routine_name LIKE 'autdescto_%'
               OR routine_name LIKE 'bloqctasreqfrm_%'
               OR routine_name LIKE 'bloqueomulta_%'
               OR routine_name LIKE 'catastrodm_%'
               OR routine_name LIKE 'consreq400_%'
               OR routine_name LIKE 'reqtrans_%'
               OR routine_name LIKE 'descderechosmerc_%'
               OR routine_name LIKE 'busca_%_trans'
               OR routine_name LIKE 'alta_descuento_trans'
               OR routine_name LIKE 'cancelar_descuento_trans'
               OR routine_name LIKE 'get_autorizadores_trans'
               OR routine_name LIKE 'drecgofosa_%')
          ORDER BY routine_name";

$result = $pdo->query($query);
$sps = $result->fetchAll(PDO::FETCH_COLUMN);

echo "Total SPs instalados: " . count($sps) . "\n";
foreach ($sps as $sp) {
    echo "  - $sp\n";
}

echo "\n=== DEPLOY COMPLETADO ===\n";
