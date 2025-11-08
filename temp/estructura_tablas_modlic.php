<?php
// Script para obtener estructura exacta de tablas para modlicfrm

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

function mostrarEstructuraTabla($schema, $tabla) {
    echo "\n=== $schema.$tabla ===\n";

    $columnas = DB::select("
        SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale, is_nullable
        FROM information_schema.columns
        WHERE table_schema = ? AND table_name = ?
        ORDER BY ordinal_position
    ", [$schema, $tabla]);

    foreach ($columnas as $col) {
        $tipo = $col->data_type;

        if ($tipo === 'character' && $col->character_maximum_length) {
            $tipo = "CHAR({$col->character_maximum_length})";
        } elseif ($tipo === 'character varying' && $col->character_maximum_length) {
            $tipo = "VARCHAR({$col->character_maximum_length})";
        } elseif ($tipo === 'numeric' && $col->numeric_precision) {
            if ($col->numeric_scale && $col->numeric_scale > 0) {
                $tipo = "NUMERIC({$col->numeric_precision},{$col->numeric_scale})";
            } else {
                $tipo = "NUMERIC({$col->numeric_precision})";
            }
        }

        $nullable = $col->is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
        echo "  {$col->column_name} {$tipo} {$nullable}\n";
    }
}

echo "\n=== ESTRUCTURAS DE TABLAS PARA modlicfrm.vue ===\n";

// 1. Tabla de licencias
mostrarEstructuraTabla('comun', 'licencias');

// 2. Tabla de anuncios
mostrarEstructuraTabla('comun', 'anuncios');

// 3. Tabla SCIAN
mostrarEstructuraTabla('public', 'c_scian');

// 4. Tabla de giros (primeros 20 campos)
echo "\n=== comun.liccat_giros (PRIMEROS 30 CAMPOS) ===\n";
$columnas_giros = DB::select("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'liccat_giros'
    ORDER BY ordinal_position
    LIMIT 30
");

foreach ($columnas_giros as $col) {
    $tipo = $col->data_type;
    if ($tipo === 'character' && $col->character_maximum_length) {
        $tipo = "CHAR({$col->character_maximum_length})";
    } elseif ($tipo === 'character varying' && $col->character_maximum_length) {
        $tipo = "VARCHAR({$col->character_maximum_length})";
    }
    echo "  {$col->column_name} {$tipo}\n";
}

// 5. Tabla de saldos (campos relevantes)
echo "\n=== comun.detsaldos (CAMPOS CLAVE) ===\n";
$columnas_saldos = DB::select("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'detsaldos'
    AND column_name IN ('licencia', 'id_licencia', 'anuncio', 'id_anuncio', 'ejercicio', 'bimestre', 'saldo', 'recargos')
    ORDER BY ordinal_position
");

foreach ($columnas_saldos as $col) {
    $tipo = $col->data_type;
    echo "  {$col->column_name} {$tipo}\n";
}

// 6. Tabla de ubicación
mostrarEstructuraTabla('comun', 'ubicacion');

// 7. Tabla de sesiones
echo "\n=== comun.sysproxysessions (CAMPOS RELEVANTES) ===\n";
$columnas_sesion = DB::select("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'sysproxysessions'
    ORDER BY ordinal_position
    LIMIT 10
");

foreach ($columnas_sesion as $col) {
    echo "  {$col->column_name} {$col->data_type}\n";
}

echo "\n";
