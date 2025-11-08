<?php
// Script para analizar estructuras de tablas para modlicfrm

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

// Configurar conexión
DB::purge('pgsql');
config(['database.connections.pgsql' => [
    'driver' => 'pgsql',
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'padron_licencias',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'comun',
]]);
DB::reconnect('pgsql');

echo "\n=== ANÁLISIS DE TABLAS PARA modlicfrm.vue ===\n\n";

// 1. Buscar tabla de licencias
echo "1️⃣ BÚSQUEDA DE TABLA DE LICENCIAS:\n";
$tablas_licencias = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%licen%'
    AND table_schema IN ('comun', 'public')
    ORDER BY table_schema, table_name
");

foreach ($tablas_licencias as $tabla) {
    echo "   - {$tabla->table_schema}.{$tabla->table_name}\n";
}

// 2. Buscar tabla de anuncios
echo "\n2️⃣ BÚSQUEDA DE TABLA DE ANUNCIOS:\n";
$tablas_anuncios = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%anunc%'
    AND table_schema IN ('comun', 'public')
    ORDER BY table_schema, table_name
");

foreach ($tablas_anuncios as $tabla) {
    echo "   - {$tabla->table_schema}.{$tabla->table_name}\n";
}

// 3. Buscar tabla SCIAN
echo "\n3️⃣ BÚSQUEDA DE TABLA SCIAN:\n";
$tablas_scian = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%scian%'
    AND table_schema IN ('comun', 'public')
    ORDER BY table_schema, table_name
");

foreach ($tablas_scian as $tabla) {
    echo "   - {$tabla->table_schema}.{$tabla->table_name}\n";
}

// 4. Ya conocemos comun.liccat_giros
echo "\n4️⃣ TABLA DE GIROS/ACTIVIDADES:\n";
echo "   - comun.liccat_giros (YA CONOCIDA)\n";

// 5. Buscar tabla de saldos
echo "\n5️⃣ BÚSQUEDA DE TABLA DE SALDOS/ADEUDOS:\n";
$tablas_saldos = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE (table_name LIKE '%saldo%' OR table_name LIKE '%adeud%')
    AND table_schema IN ('comun', 'public')
    ORDER BY table_schema, table_name
");

foreach ($tablas_saldos as $tabla) {
    echo "   - {$tabla->table_schema}.{$tabla->table_name}\n";
}

// 6. Buscar tabla de sesiones
echo "\n6️⃣ BÚSQUEDA DE TABLA DE SESIONES (MAPA):\n";
$tablas_sesion = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE (table_name LIKE '%sesion%' OR table_name LIKE '%session%' OR table_name LIKE '%ubicacion%')
    AND table_schema IN ('comun', 'public')
    ORDER BY table_schema, table_name
");

foreach ($tablas_sesion as $tabla) {
    echo "   - {$tabla->table_schema}.{$tabla->table_name}\n";
}

echo "\n";
