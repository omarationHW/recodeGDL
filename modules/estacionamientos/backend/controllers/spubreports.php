<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar operaciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'error' => null
            ]
        ];

        try {
            switch ($operation) {
                case 'spubreports_list':
                    $opc = $params['opc'] ?? 1;
                    $result = DB::select('SELECT * FROM spubreports_list(?)', [$opc]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'spubreports_sector_summary':
                    $result = DB::select('SELECT * FROM spubreports_sector_summary()');
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'spubreports_edocta':
                    $numesta = $params['numesta'] ?? null;
                    if (!$numesta) throw new \Exception('numesta requerido');
                    $result = DB::select('SELECT * FROM spubreports_edocta(?)', [$numesta]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'spubreports_adeudos':
                    $result = DB::select('SELECT * FROM spubreports_adeudos()');
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                default:
                    $response['eResponse']['error'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $response['eResponse']['error'] = $ex->getMessage();
        }
        return response()->json($response);
    }
}
