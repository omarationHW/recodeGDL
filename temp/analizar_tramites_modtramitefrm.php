<?php
/**
 * Script para analizar la estructura de tabla comun.tramites
 * para el componente modtramitefrm
 */

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

echo "=== ANÁLISIS DE TABLA comun.tramites ===\n\n";

// 1. Estructura de la tabla
echo "1. ESTRUCTURA DE LA TABLA:\n";
echo str_repeat("=", 80) . "\n";

$columns = DB::select("
    SELECT
        column_name,
        data_type,
        character_maximum_length,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'tramites'
    ORDER BY ordinal_position
");

foreach ($columns as $col) {
    $type = $col->data_type;
    if ($col->character_maximum_length) {
        $type .= "({$col->character_maximum_length})";
    }
    $nullable = $col->is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
    $default = $col->column_default ? "DEFAULT {$col->column_default}" : '';

    echo sprintf("%-30s %-30s %-10s %s\n",
        $col->column_name,
        $type,
        $nullable,
        $default
    );
}

// 2. Campos relacionados con propietario
echo "\n\n2. CAMPOS DEL PROPIETARIO:\n";
echo str_repeat("=", 80) . "\n";

$propietario_fields = ['primer_apellido', 'segundo_apellido', 'nombres', 'propietario',
    'rfc', 'curp', 'telefono', 'email', 'celular'];

foreach ($columns as $col) {
    $lower_name = strtolower($col->column_name);
    foreach ($propietario_fields as $field) {
        if (strpos($lower_name, $field) !== false) {
            echo "- {$col->column_name} ({$col->data_type})\n";
        }
    }
}

// 3. Campos de ubicación
echo "\n\n3. CAMPOS DE UBICACIÓN:\n";
echo str_repeat("=", 80) . "\n";

$ubicacion_fields = ['ubicacion', 'domicilio', 'calle', 'numero', 'numext', 'numint',
    'colonia', 'cp', 'zona', 'subzona', 'letra'];

foreach ($columns as $col) {
    $lower_name = strtolower($col->column_name);
    foreach ($ubicacion_fields as $field) {
        if (strpos($lower_name, $field) !== false) {
            echo "- {$col->column_name} ({$col->data_type})\n";
        }
    }
}

// 4. Campos de giro y actividad
echo "\n\n4. CAMPOS DE GIRO Y ACTIVIDAD:\n";
echo str_repeat("=", 80) . "\n";

$giro_fields = ['giro', 'actividad', 'scian', 'id_giro'];

foreach ($columns as $col) {
    $lower_name = strtolower($col->column_name);
    foreach ($giro_fields as $field) {
        if (strpos($lower_name, $field) !== false) {
            echo "- {$col->column_name} ({$col->data_type})\n";
        }
    }
}

// 5. Campos de datos técnicos
echo "\n\n5. CAMPOS DE DATOS TÉCNICOS:\n";
echo str_repeat("=", 80) . "\n";

$tecnicos_fields = ['superficie', 'sup_', 'empleados', 'cajones', 'aforo',
    'inversion', 'horario'];

foreach ($columns as $col) {
    $lower_name = strtolower($col->column_name);
    foreach ($tecnicos_fields as $field) {
        if (strpos($lower_name, $field) !== false) {
            echo "- {$col->column_name} ({$col->data_type})\n";
        }
    }
}

// 6. Campos de control y auditoría
echo "\n\n6. CAMPOS DE CONTROL Y AUDITORÍA:\n";
echo str_repeat("=", 80) . "\n";

$control_fields = ['estatus', 'feccap', 'capturista', 'fecha_modificacion',
    'usuario_modificacion', 'tipo_tramite', 'folio'];

foreach ($columns as $col) {
    $lower_name = strtolower($col->column_name);
    foreach ($control_fields as $field) {
        if (strpos($lower_name, $field) !== false) {
            echo "- {$col->column_name} ({$col->data_type})\n";
        }
    }
}

// 7. Contar trámites por estado
echo "\n\n7. ESTADÍSTICAS DE TRÁMITES POR ESTADO:\n";
echo str_repeat("=", 80) . "\n";

try {
    $estados = DB::select("
        SELECT
            estatus,
            COUNT(*) as total,
            CASE
                WHEN estatus = 'T' THEN 'En trámite'
                WHEN estatus = 'A' THEN 'Autorizado'
                WHEN estatus = 'R' THEN 'Rechazado'
                WHEN estatus = 'C' THEN 'Cancelado'
                ELSE 'Otro'
            END as descripcion
        FROM comun.tramites
        GROUP BY estatus
        ORDER BY total DESC
    ");

    foreach ($estados as $estado) {
        echo sprintf("%-10s %-20s %10d trámites\n",
            $estado->estatus,
            $estado->descripcion,
            $estado->total
        );
    }
} catch (Exception $e) {
    echo "Error al consultar estados: " . $e->getMessage() . "\n";
}

// 8. Muestra de un registro
echo "\n\n8. MUESTRA DE UN REGISTRO (Trámite en proceso):\n";
echo str_repeat("=", 80) . "\n";

try {
    $muestra = DB::select("
        SELECT *
        FROM comun.tramites
        WHERE estatus IN ('T', 'R')
        ORDER BY id_tramite DESC
        LIMIT 1
    ");

    if (count($muestra) > 0) {
        $tramite = (array) $muestra[0];
        foreach ($tramite as $campo => $valor) {
            if ($valor !== null) {
                $valor_mostrar = is_string($valor) ? trim($valor) : $valor;
                if (strlen($valor_mostrar) > 50) {
                    $valor_mostrar = substr($valor_mostrar, 0, 50) . '...';
                }
                echo sprintf("%-30s: %s\n", $campo, $valor_mostrar);
            }
        }
    }
} catch (Exception $e) {
    echo "Error al obtener muestra: " . $e->getMessage() . "\n";
}

echo "\n\n=== ANÁLISIS COMPLETADO ===\n";
