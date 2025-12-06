<?php
/**
 * DEPLOYMENT - SP CargaPagosTexto
 * sp_importar_pago_texto (CORREGIDO con esquema comun)
 * Base: padron_licencias
 * Fecha: 2025-12-05
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "\n";
echo "==========================================================\n";
echo " DEPLOYMENT - sp_importar_pago_texto (CORREGIDO)\n";
echo "==========================================================\n";
echo "\n";

$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/CargaPagosTexto_sp_importar_pago_texto_CORREGIDO.sql';

if (!file_exists($sqlFile)) {
    echo "❌ ERROR: Archivo SQL no encontrado\n";
    echo "Ruta: {$sqlFile}\n";
    exit(1);
}

$sql = file_get_contents($sqlFile);

echo "📄 Archivo: CargaPagosTexto_sp_importar_pago_texto_CORREGIDO.sql\n";
echo "🔧 Corrección: public → comun\n";
echo "\n";

try {
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP desplegado exitosamente en padron_licencias\n";
    echo "\n";
    echo "📋 Detalles:\n";
    echo "   - Nombre: sp_importar_pago_texto\n";
    echo "   - Base: padron_licencias\n";
    echo "   - Esquema: comun (corregido)\n";
    echo "   - Tablas: comun.ta_11_pagos_local, comun.ta_11_adeudo_local\n";
    echo "   - Retorna: grabado (BOOLEAN), adeudo_borrado (BOOLEAN)\n";
    echo "\n";
} catch (Exception $e) {
    echo "❌ ERROR al desplegar SP\n";
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

echo "==========================================================\n";
echo "\n";
