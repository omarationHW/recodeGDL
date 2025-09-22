<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AdeudosEnergiaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (API Unificada)
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'getOficinas':
                    $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    break;
                case 'getMercadosByOficina':
                    $oficina = $params['oficina'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_mercados WHERE oficina = ? AND cuenta_energia > 0 ORDER BY num_mercado_nvo', [$oficina]);
                    break;
                case 'getAdeudosEnergia':
                    $oficina = $params['oficina'] ?? null;
                    $mercado = $params['mercado'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_get_adeudos_energia(?, ?, ?, ?)', [$oficina, $mercado, $axo, $mes]);
                    break;
                case 'getMesesAdeudoEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_get_meses_adeudo_energia(?, ?, ?)', [$id_energia, $axo, $mes]);
                    break;
                case 'exportExcel':
                    // Implementar exportación a Excel (puede ser con un paquete Laravel Excel)
                    // Aquí solo se retorna un mensaje de ejemplo
                    $result = ['message' => 'Exportación a Excel generada'];
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error('AdeudosEnergiaController error: ' . $ex->getMessage());
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}
