<?php
$pdo = new PDO('pgsql:host=localhost;port=5432;dbname=padron_licencias', 'postgres', 'postgres');

echo "========================================\n";
echo "VERIFICACIÓN REAL DE STORED PROCEDURES\n";
echo "========================================\n\n";

// 1. Ver todos los SPs relacionados con bloqueorfc en TODOS los esquemas
echo "1. TODOS los SPs sp_bloqueorfc* en TODOS los esquemas:\n\n";
$stmt = $pdo->query("
    SELECT
        n.nspname as schema,
        p.proname as nombre,
        pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname LIKE 'sp_bloqueorfc%'
    ORDER BY n.nspname, p.proname
");

$procedures = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($procedures as $proc) {
    echo "   {$proc['schema']}.{$proc['nombre']}({$proc['args']})\n";
}

if (count($procedures) === 0) {
    echo "   ⚠ NO SE ENCONTRARON SPs\n";
}

// 2. Ver el search_path actual
echo "\n2. Search path actual de la conexión:\n\n";
$stmt = $pdo->query("SHOW search_path");
$path = $stmt->fetchColumn();
echo "   $path\n";

// 3. Ver si hay algún search_path configurado para el usuario postgres
echo "\n3. Search path configurado para usuario postgres:\n\n";
$stmt = $pdo->query("
    SELECT rolname, rolconfig
    FROM pg_roles
    WHERE rolname = 'postgres'
");
$role = $stmt->fetch(PDO::FETCH_ASSOC);
if ($role && $role['rolconfig']) {
    echo "   Config: " . print_r($role['rolconfig'], true) . "\n";
} else {
    echo "   Sin configuración especial\n";
}

// 4. Ver search_path de la base de datos
echo "\n4. Search path de la base de datos padron_licencias:\n\n";
$stmt = $pdo->query("
    SELECT datname, datacl
    FROM pg_database
    WHERE datname = 'padron_licencias'
");
$db = $stmt->fetch(PDO::FETCH_ASSOC);
echo "   Database: {$db['datname']}\n";

echo "\n========================================\n";
echo "FIN DE VERIFICACIÓN\n";
echo "========================================\n";
