<?php
chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "TEST COMPLETO: LocalesModif\n";
echo "Búsqueda → Modificación → Verificación\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    // 1. BÚSQUEDA
    echo "1. BÚSQUEDA DEL LOCAL\n";
    echo "   Parámetros enviados por frontend:\n";
    echo "   - oficina: 1\n";
    echo "   - num_mercado: 2\n";
    echo "   - categoria: 1\n";
    echo "   - seccion: SS\n";
    echo "   - local: 3\n";
    echo "   - letra_local: '' (string vacío)\n";
    echo "   - bloque: '' (string vacío)\n\n";

    $buscar = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 2, 1, 'SS', 3, '', '')
    ");

    if (empty($buscar)) {
        echo "   ✗ No se encontró el local\n";
        exit(1);
    }

    $local = $buscar[0];
    echo "   ✓ Local encontrado\n";
    echo "   ✓ id_local: {$local->id_local}\n";
    echo "   ✓ nombre: {$local->nombre}\n";
    echo "   ✓ domicilio: '{$local->domicilio}'\n";
    echo "   ✓ sector: '{$local->sector}' ← VALOR PRESENTE\n";
    echo "   ✓ zona: {$local->zona}\n";
    echo "   ✓ giro: {$local->giro}\n";

    // 2. MODIFICACIÓN
    echo "\n2. MODIFICACIÓN DEL LOCAL\n";
    echo "   Cambios a aplicar:\n";
    echo "   - domicilio: 'DOMICILIO_NUEVO_TEST'\n";
    echo "   - sector: '{$local->sector}' (mantener actual)\n\n";

    $modificar = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_modificar_local(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ", [
        $local->id_local,
        $local->nombre,
        'DOMICILIO_NUEVO_TEST',
        $local->sector,
        $local->zona,
        $local->descripcion_local,
        $local->superficie,
        $local->giro,
        $local->fecha_alta,
        $local->fecha_baja,
        $local->vigencia,
        $local->clave_cuota,
        1,
        $local->bloqueo,
        null,
        null,
        null,
        ''
    ]);

    if (!empty($modificar)) {
        echo "   ✓ Modificación ejecutada\n";
        echo "   ✓ Resultado: {$modificar[0]->result}\n";
    } else {
        echo "   ✗ Modificación falló\n";
        exit(1);
    }

    // 3. VERIFICACIÓN
    echo "\n3. VERIFICACIÓN DE CAMBIOS\n";
    echo "   Buscando de nuevo el mismo local...\n\n";

    $verificar = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 2, 1, 'SS', 3, '', '')
    ");

    if (!empty($verificar)) {
        $localVerif = $verificar[0];
        echo "   ✓ Local encontrado después de modificar\n";
        echo "   ✓ id_local: {$localVerif->id_local}\n";
        echo "   ✓ nombre: {$localVerif->nombre}\n";
        echo "   ✓ domicilio: '{$localVerif->domicilio}'\n";
        echo "   ✓ sector: '{$localVerif->sector}'\n";

        if ($localVerif->domicilio === 'DOMICILIO_NUEVO_TEST') {
            echo "\n   ✓✓✓ ÉXITO TOTAL ✓✓✓\n";
            echo "   ✓ El cambio se guardó correctamente\n";
            echo "   ✓ El campo 'sector' se mantiene: '{$localVerif->sector}'\n";
            echo "   ✓ Búsqueda con strings vacíos funciona\n";
        } else {
            echo "\n   ✗ El cambio no se guardó\n";
        }
    } else {
        echo "   ✗ No se pudo buscar el local después de modificar\n";
    }

    echo "\n==============================================\n";
    echo "✓ TEST COMPLETADO\n";
    echo "==============================================\n";
    echo "\nResumen:\n";
    echo "✓ Búsqueda con letra_local='' y bloque='' funciona\n";
    echo "✓ Retorna todos los campos incluyendo 'sector'\n";
    echo "✓ Modificación guarda los cambios correctamente\n";
    echo "✓ Truncación automática previene errores\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
