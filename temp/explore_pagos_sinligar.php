<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Analizando estructura de pagos y ligaduras...\n\n";

try {
    // Ver estructura de qligapago
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📋 ESTRUCTURA DE comun.qligapago (pagos ligados):\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'qligapago'
        ORDER BY ordinal_position
    ");

    foreach ($cols as $col) {
        echo "  • {$col->column_name} ({$col->data_type})\n";
    }

    // Ver ejemplos de pagos ligados
    echo "\n📝 EJEMPLOS DE PAGOS LIGADOS (últimos 10):\n\n";

    $ligados = DB::connection('pgsql')->select("
        SELECT *
        FROM comun.qligapago
        ORDER BY id_control DESC
        LIMIT 10
    ");

    foreach ($ligados as $i => $p) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID Control: {$p->id_control}\n";
        echo "  Clave Pago: {$p->cvepago}\n";
        echo "  Clave Cuenta: {$p->cvecta}\n";
        echo "  Usuario: " . trim($p->usuario) . "\n";
        echo "  Fecha: {$p->fecha_act}\n";
        echo "  Tipo: {$p->tipo}\n";
        echo "\n";
    }

    // Buscar tablas de pagos para encontrar los sin ligar
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📊 BUSCANDO TABLAS DE PAGOS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $pagosTables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun')
        AND tablename ILIKE '%pago%'
        AND tablename NOT ILIKE '%h_%'
        AND tablename NOT ILIKE '%hist%'
        ORDER BY schemaname, tablename
        LIMIT 20
    ");

    foreach ($pagosTables as $t) {
        $count = DB::connection('pgsql')->selectOne("
            SELECT COUNT(*) as total FROM {$t->schemaname}.{$t->tablename}
        ");
        echo "  • {$t->schemaname}.{$t->tablename} ({$count->total} registros)\n";
    }

    // Verificar si existe tabla de pagos principales
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📋 ANALIZANDO comun.pagos (si existe):\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    try {
        $pagosCount = DB::connection('pgsql')->selectOne("
            SELECT COUNT(*) as total FROM comun.pagos
        ");
        echo "Total de pagos: {$pagosCount->total}\n\n";

        // Ver estructura
        $pagosCols = DB::connection('pgsql')->select("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'comun' AND table_name = 'pagos'
            ORDER BY ordinal_position
            LIMIT 15
        ");

        echo "Columnas principales:\n";
        foreach ($pagosCols as $col) {
            echo "  • {$col->column_name} ({$col->data_type})\n";
        }

        // Buscar pagos sin ligar (que NO estén en qligapago)
        echo "\n🔍 BUSCANDO PAGOS SIN LIGAR:\n\n";

        $sinLigar = DB::connection('pgsql')->select("
            SELECT p.*
            FROM comun.pagos p
            LEFT JOIN comun.qligapago q ON p.cvepago = q.cvepago
            WHERE q.cvepago IS NULL
            ORDER BY p.cvepago DESC
            LIMIT 5
        ");

        echo "Pagos sin ligar encontrados: " . count($sinLigar) . "\n\n";

        if (count($sinLigar) > 0) {
            foreach ($sinLigar as $i => $sl) {
                echo "Ejemplo " . ($i + 1) . " (sin ligar):\n";
                $data = (array)$sl;
                $shown = 0;
                foreach ($data as $key => $value) {
                    if ($shown >= 8) break;
                    $val = $value ?? 'NULL';
                    if (is_string($val) && strlen($val) > 30) {
                        $val = substr($val, 0, 30) . '...';
                    }
                    echo "  • $key: $val\n";
                    $shown++;
                }
                echo "\n";
            }
        }

    } catch (Exception $e) {
        echo "❌ Tabla comun.pagos no existe o error: " . $e->getMessage() . "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
