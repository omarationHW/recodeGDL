<?php
chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "TEST FINAL: LocalesModif SPs\n";
echo "==============================================\n\n";

try {
    // 1. Get actual local data
    echo "1. Obteniendo datos del local id_local=11257...\n";
    $local = DB::connection('pgsql')->selectOne("
        SELECT oficina, num_mercado, categoria, seccion, local, letra_local, bloque, domicilio, nombre
        FROM publico.ta_11_locales
        WHERE id_local = 11257
    ");

    if (!$local) {
        echo "   ✗ Local no encontrado\n";
        exit(1);
    }

    echo "   ✓ Local encontrado:\n";
    echo "     Oficina: {$local->oficina}\n";
    echo "     Mercado: {$local->num_mercado}\n";
    echo "     Categoria: {$local->categoria}\n";
    echo "     Seccion: {$local->seccion}\n";
    echo "     Local: {$local->local}\n";
    echo "     Letra: " . ($local->letra_local ?? 'NULL') . "\n";
    echo "     Bloque: " . ($local->bloque ?? 'NULL') . "\n";
    echo "     Nombre: {$local->nombre}\n";
    echo "     Domicilio actual: '{$local->domicilio}'\n\n";

    // 2. Test search SP
    echo "2. Probando sp_localesmodif_buscar_local...\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM sp_localesmodif_buscar_local(?, ?, ?, ?, ?, ?, ?)
    ", [
        $local->oficina,
        $local->num_mercado,
        $local->categoria,
        $local->seccion,
        $local->local,
        $local->letra_local,
        $local->bloque
    ]);

    if (!empty($result)) {
        echo "   ✓ SP de búsqueda funciona correctamente\n";
        echo "     ID Local: {$result[0]->id_local}\n";
        echo "     Nombre: {$result[0]->nombre}\n";
        echo "     Domicilio: '{$result[0]->domicilio}'\n\n";
    } else {
        echo "   ✗ SP no retornó resultados\n\n";
    }

    // 3. Test modify SP
    echo "3. Probando sp_localesmodif_modificar_local...\n";
    echo "   Cambiando domicilio a 'TEST_DOMICILIO_MODIFICADO'...\n";

    $modifyResult = DB::connection('pgsql')->select("
        SELECT * FROM sp_localesmodif_modificar_local(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ", [
        11257,                              // p_id_local
        $result[0]->nombre,                 // p_nombre
        'TEST_DOMICILIO_MODIFICADO',        // p_domicilio (CAMBIO)
        $result[0]->sector,                 // p_sector
        $result[0]->zona,                   // p_zona
        $result[0]->descripcion_local,      // p_descripcion_local
        $result[0]->superficie,             // p_superficie
        $result[0]->giro,                   // p_giro
        $result[0]->fecha_alta,             // p_fecha_alta
        $result[0]->fecha_baja,             // p_fecha_baja
        $result[0]->vigencia,               // p_vigencia
        $result[0]->clave_cuota,            // p_clave_cuota
        1,                                  // p_tipo_movimiento
        $result[0]->bloqueo,                // p_bloqueo
        null,                               // p_cve_bloqueo
        null,                               // p_fecha_inicio_bloqueo
        null,                               // p_fecha_final_bloqueo
        ''                                  // p_observacion
    ]);

    if (!empty($modifyResult)) {
        echo "   ✓ SP de modificación ejecutado\n";
        echo "     Resultado: {$modifyResult[0]->result}\n\n";
    } else {
        echo "   ✗ SP no retornó resultados\n\n";
    }

    // 4. Verify change
    echo "4. Verificando cambio guardado...\n";
    $verify = DB::connection('pgsql')->selectOne("
        SELECT domicilio FROM publico.ta_11_locales WHERE id_local = 11257
    ");

    if ($verify) {
        echo "   Domicilio después de modificar: '{$verify->domicilio}'\n";
        if ($verify->domicilio === 'TEST_DOMICILIO_MODIFICADO') {
            echo "   ✓✓✓ CAMBIO GUARDADO EXITOSAMENTE ✓✓✓\n";
        } else {
            echo "   ✗ El cambio NO se guardó\n";
        }
    }

    echo "\n==============================================\n";
    echo "✓ TEST COMPLETADO\n";
    echo "==============================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
