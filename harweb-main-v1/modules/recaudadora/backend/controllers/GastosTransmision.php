<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class GastosTransmisionController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'consulta_foliotransm':
                return $this->consultaFolioTransm($params);
            case 'afecta_gastostransm':
                return $this->afectaGastosTransm($params, $user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Consulta los datos de un folio de transmisión
     */
    private function consultaFolioTransm($params)
    {
        $validator = Validator::make($params, [
            'folio' => 'required|integer',
            'opc' => 'required|string|in:T,D'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        $folio = $params['folio'];
        $opc = $params['opc'];
        $result = DB::select('SELECT * FROM consulta_foliotransm(:folio, :opc)', [
            'folio' => $folio,
            'opc' => $opc
        ]);
        if (empty($result)) {
            return response()->json([
                'success' => false,
                'message' => 'Folio no encontrado',
                'data' => null
            ], 404);
        }
        return response()->json([
            'success' => true,
            'message' => 'Consulta exitosa',
            'data' => $result[0]
        ]);
    }

    /**
     * Aplica los gastos a un folio de transmisión
     */
    private function afectaGastosTransm($params, $user)
    {
        $validator = Validator::make($params, [
            'folio' => 'required|integer',
            'gastos' => 'required|numeric|min:0',
            'opc' => 'required|string|in:T,D'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        $folio = $params['folio'];
        $gastos = $params['gastos'];
        $opc = $params['opc'];
        $usuario = $user ? $user->username : 'sistema';
        $result = DB::select('SELECT * FROM afecta_gastostransm(:folio, :gastos, :opc, :usuario)', [
            'folio' => $folio,
            'gastos' => $gastos,
            'opc' => $opc,
            'usuario' => $usuario
        ]);
        if (empty($result)) {
            return response()->json([
                'success' => false,
                'message' => 'No se pudo aplicar el gasto',
                'data' => null
            ], 500);
        }
        return response()->json([
            'success' => $result[0]->estado == 1,
            'message' => $result[0]->msg,
            'data' => $result[0]
        ]);
    }
}
