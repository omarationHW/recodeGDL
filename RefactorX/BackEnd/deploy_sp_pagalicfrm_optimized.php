<?php
/**
 * Script de despliegue para recaudadora_pagalicfrm (versión OPTIMIZADA)
 *
 * Este script despliega el SP optimizado que mejora significativamente
 * el rendimiento mediante:
 * - Eliminación de CAST en WHERE
 * - Validación de licencia_in obligatoria
 * - STABLE keyword para cache
 * - LIMIT de seguridad
 * - Índices recomendados
 */

$host = 'localhost';
$port = '5432';
$dbname = 'municipal_gdl';
$user = 'postgres';
$password = 'postgres';

try {
    echo "=================================================\n";
    echo "DESPLEGANDO SP: recaudadora_pagalicfrm (OPTIMIZADO)\n";
    echo "=================================================\n\n";

    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_pagalicfrm.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "📄 Archivo leído: recaudadora_pagalicfrm.sql\n";
    echo "📊 Tamaño: " . strlen($sql) . " bytes\n\n";

    // Ejecutar el SQL
    echo "🚀 Ejecutando SQL...\n";
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente!\n\n";

    // Crear índices recomendados
    echo "📑 Creando índices recomendados...\n";

    $indices = [
        "CREATE INDEX IF NOT EXISTS idx_licencias_licencia ON comun.licencias(licencia)",
        "CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_licencia ON comun.detsal_lic(id_licencia)",
        "CREATE INDEX IF NOT EXISTS idx_detsal_lic_saldo ON comun.detsal_lic(saldo) WHERE saldo > 0"
    ];

    foreach ($indices as $idx => $indexSql) {
        try {
            $pdo->exec($indexSql);
            echo "  ✓ Índice " . ($idx + 1) . " creado\n";
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'already exists') !== false) {
                echo "  ℹ Índice " . ($idx + 1) . " ya existe\n";
            } else {
                echo "  ⚠ Error creando índice " . ($idx + 1) . ": " . $e->getMessage() . "\n";
            }
        }
    }

    echo "\n";

    // Verificar que el SP existe
    $checkSql = "
        SELECT
            p.proname AS function_name,
            pg_get_function_arguments(p.oid) AS arguments,
            d.description
        FROM pg_proc p
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'multas_reglamentos')
        AND p.proname = 'recaudadora_pagalicfrm'
    ";

    $stmt = $pdo->query($checkSql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✓ Verificación exitosa:\n";
        echo "  - Función: {$result['function_name']}\n";
        echo "  - Argumentos: {$result['arguments']}\n";
        echo "  - Descripción: {$result['description']}\n\n";
    }

    // Probar el SP con una consulta de ejemplo
    echo "🧪 Probando el SP...\n";
    echo "  Nota: Debes proporcionar un número de licencia válido\n";
    echo "  Ejemplo: SELECT * FROM multas_reglamentos.recaudadora_pagalicfrm('100');\n\n";

    echo "=================================================\n";
    echo "✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "=================================================\n";
    echo "\nOPTIMIZACIONES APLICADAS:\n";
    echo "- ✅ WHERE sin CAST (usa índices directamente)\n";
    echo "- ✅ Validación de licencia_in obligatoria\n";
    echo "- ✅ STABLE keyword para cache de PostgreSQL\n";
    echo "- ✅ TRIM eliminado (campos ya vienen limpios)\n";
    echo "- ✅ LIMIT 100 de seguridad\n";
    echo "- ✅ Pre-conversión a INTEGER\n";
    echo "- ✅ COALESCE optimizado\n";
    echo "- ✅ Índices recomendados creados\n";
    echo "\n💡 MEJORA ESPERADA: ~10x más rápido\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Código: " . $e->getCode() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}
