<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LigaPagoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'listPagos':
                    $response['data'] = DB::select('SELECT * FROM pagos WHERE cvecuenta = ?', [$params['cvecuenta']]);
                    $response['success'] = true;
                    break;
                case 'getPagoDetalle':
                    $response['data'] = DB::select('SELECT * FROM pagos WHERE cvepago = ?', [$params['cvepago']]);
                    $response['success'] = true;
                    break;
                case 'ligarPago':
                    $validator = Validator::make($params, [
                        'cvepago' => 'required|integer',
                        'cvecuenta' => 'required|integer',
                        'usuario' => 'required|string',
                        'tipo' => 'required|integer',
                        'folio' => 'nullable|integer',
                        'fecha' => 'nullable|date',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_ligar_pago(:cvepago, :cvecuenta, :usuario, :tipo, :folio, :fecha)', $params);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'listFoliosTransmision':
                    $response['data'] = DB::select('SELECT * FROM folios_transmision WHERE cvecuenta = ?', [$params['cvecuenta']]);
                    $response['success'] = true;
                    break;
                case 'ligarPagoDiferencia':
                    $result = DB::select('SELECT * FROM sp_ligar_pago_diferencia(:cvepago, :cvecuenta, :usuario, :folio, :fecha)', $params);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getCuentaStatus':
                    $response['data'] = DB::select('SELECT exento, vigente FROM cuentas WHERE cvecuenta = ?', [$params['cvecuenta']]);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
