<?php
/**
 * Script para desplegar el SP recaudadora_listchq usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_listchq ===\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_listchq.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_listchq.sql\n";
echo "📂 Ruta: $sql_file\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Tabla origen: comun.ta_12_cheques (262,236 registros)\n\n";

try {
    // Conectar a la base de datos
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Ejecutar el SQL
    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_listchq desplegado exitosamente\n\n";

    // Verificar que el SP existe
    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_listchq'
          AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    } else {
        echo "⚠️  SP no encontrado después del despliegue\n\n";
        exit(1);
    }

    // Probar el SP con ejemplos
    echo "🧪 Probando el SP con ejemplos usando DATOS REALES:\n\n";

    // Ejemplo 1: Sin filtro (primeros 5 cheques más recientes)
    echo "=== EJEMPLO 1: Sin filtro (cheques más recientes) ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listchq('')
        LIMIT 5
    ");

    if (count($result) > 0) {
        echo "Total de registros encontrados: " . count($result) . "\n\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "Cheque #$num:\n";
            echo "  Fecha: {$row->fecha}\n";
            echo "  Banco: {$row->banco}\n";
            echo "  Número Cheque: {$row->cheque}\n";
            echo "  Cuenta: {$row->cuenta}\n";
            echo "  Importe: {$row->importe_formato}\n";
            echo "  Tipo Pago: {$row->tipo_pag}\n";
            echo "  Folio: {$row->folio_completo}\n";
            echo "  Recaudadora: {$row->id_rec} | Caja: {$row->caja} | Operación: {$row->operacion}\n";
            echo "\n";
        }
    } else {
        echo "⚠️ No se encontraron cheques\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Obtener un número de cheque real para el ejemplo 2
    echo "=== EJEMPLO 2: Buscar por número de cheque específico ===\n";

    // Primero obtener un cheque real
    $cheque_ejemplo = DB::connection('pgsql')->selectOne("
        SELECT cheque
        FROM comun.ta_12_cheques
        WHERE cheque IS NOT NULL
        AND cheque != ''
        AND LENGTH(cheque) > 3
        AND importe > 0
        ORDER BY fecha DESC
        LIMIT 1
    ");

    if ($cheque_ejemplo && $cheque_ejemplo->cheque) {
        $num_cheque = $cheque_ejemplo->cheque;
        echo "Buscando cheques con número: '$num_cheque'\n\n";

        $result = DB::connection('pgsql')->select("
            SELECT * FROM multas_reglamentos.recaudadora_listchq(?)
            LIMIT 3
        ", [$num_cheque]);

        if (count($result) > 0) {
            echo "Cheques encontrados: " . count($result) . "\n\n";
            foreach ($result as $i => $row) {
                $num = $i + 1;
                echo "$num. Cheque: {$row->cheque} | Banco: {$row->banco} | Importe: {$row->importe_formato}\n";
                echo "   Fecha: {$row->fecha} | Folio: {$row->folio_completo}\n\n";
            }
        } else {
            echo "No se encontraron resultados\n";
        }
    } else {
        echo "No se pudo obtener un número de cheque de ejemplo\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Ejemplo 3: Buscar por banco
    echo "=== EJEMPLO 3: Buscar por banco (BANAMEX - ID 1) ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listchq('1')
        LIMIT 5
    ");

    if (count($result) > 0) {
        echo "Cheques de BANAMEX encontrados: " . count($result) . "\n\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "$num. Cheque: {$row->cheque}\n";
            echo "   Banco: {$row->banco}\n";
            echo "   Cuenta: {$row->cuenta}\n";
            echo "   Importe: {$row->importe_formato}\n";
            echo "   Fecha: {$row->fecha}\n";
            echo "\n";
        }
    } else {
        echo "No se encontraron cheques de BANAMEX\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";
    echo "\n📋 RESUMEN:\n";
    echo "✓ SP: multas_reglamentos.recaudadora_listchq\n";
    echo "✓ Parámetro: p_filtro (VARCHAR)\n";
    echo "✓ Tabla origen: comun.ta_12_cheques (262,236 registros)\n";
    echo "✓ Funcionalidad: Listado de cheques con búsqueda\n";
    echo "✓ Límite: 100 registros por consulta\n";
    echo "\n🎯 PRÓXIMO PASO:\n";
    echo "Abre el formulario en: http://localhost:3000/multas_reglamentos/listchq\n";
    echo "Y prueba con los ejemplos descritos arriba\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
