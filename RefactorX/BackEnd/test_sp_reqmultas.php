<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== PROBANDO STORED PROCEDURE ===\n\n";

try {
    // Prueba 1: Con folio específico
    echo "1. Buscando folio 84497:\n";
    $result1 = DB::select("SELECT * FROM recaudadora_reqmultas400frm(?)", ['84497']);
    echo "   Registros encontrados: " . count($result1) . "\n";

    if (count($result1) > 0 && count($result1) <= 3) {
        echo "   Primeros registros:\n";
        foreach (array_slice($result1, 0, 3) as $row) {
            echo "   - Folio: {$row->folreq}, Año: {$row->axoreq}, Clave: {$row->cvelet}\n";
        }
    } else if (count($result1) > 3) {
        echo "   ⚠️ PROBLEMA: Se esperaba 1 registro pero se encontraron " . count($result1) . "\n";
        echo "   Primeros 5 registros:\n";
        foreach (array_slice($result1, 0, 5) as $row) {
            echo "   - Folio: {$row->folreq}, Año: {$row->axoreq}, Clave: {$row->cvelet}\n";
        }
    }

    echo "\n";

    // Prueba 2: Con folio específico
    echo "2. Buscando folio 84496:\n";
    $result2 = DB::select("SELECT * FROM recaudadora_reqmultas400frm(?)", ['84496']);
    echo "   Registros encontrados: " . count($result2) . "\n";

    if (count($result2) > 0 && count($result2) <= 3) {
        echo "   Primeros registros:\n";
        foreach (array_slice($result2, 0, 3) as $row) {
            echo "   - Folio: {$row->folreq}, Año: {$row->axoreq}, Clave: {$row->cvelet}\n";
        }
    } else if (count($result2) > 3) {
        echo "   ⚠️ PROBLEMA: Se esperaba 1 registro pero se encontraron " . count($result2) . "\n";
        echo "   Primeros 5 registros:\n";
        foreach (array_slice($result2, 0, 5) as $row) {
            echo "   - Folio: {$row->folreq}, Año: {$row->axoreq}, Clave: {$row->cvelet}\n";
        }
    }

    echo "\n";

    // Prueba 3: Sin parámetro (todos)
    echo "3. Sin parámetro (todos):\n";
    $result3 = DB::select("SELECT * FROM recaudadora_reqmultas400frm(NULL)");
    echo "   Registros encontrados: " . count($result3) . "\n";
    echo "   Primeros 3 folios: ";
    echo implode(', ', array_map(fn($r) => $r->folreq, array_slice($result3, 0, 3)));
    echo "\n\n";

    // Verificar el SP actual
    echo "4. Verificando definición del SP:\n";
    $spDef = DB::select("
        SELECT pg_get_functiondef(oid) as definition
        FROM pg_proc
        WHERE proname = 'recaudadora_reqmultas400frm'
    ");

    if ($spDef) {
        echo "   SP encontrado. Mostrando parte relevante:\n";
        $def = $spDef[0]->definition;

        // Extraer la parte del WHERE
        if (preg_match('/WHERE.*?LIMIT/s', $def, $matches)) {
            echo "   Condición WHERE:\n";
            echo "   " . trim($matches[0]) . "\n";
        }
    }

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
