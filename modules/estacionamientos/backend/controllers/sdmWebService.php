<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use SoapClient;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'eRequest' => 'required|array',
            'eRequest.action' => 'required|string',
            'eRequest.data' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 400);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);

        try {
            switch ($action) {
                case 'consultaPredio':
                    return $this->consultaPredio($data);
                default:
                    return response()->json([
                        'eResponse' => [
                            'status' => 'error',
                            'message' => 'Acción no soportada',
                            'data' => null
                        ]
                    ], 400);
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $e->getMessage(),
                    'data' => null
                ]
            ], 500);
        }
    }

    /**
     * Consulta información de predio vía WebService y almacena en PostgreSQL
     * @param array $data
     * @return \Illuminate\Http\JsonResponse
     */
    private function consultaPredio($data)
    {
        // Validar datos requeridos
        $validator = Validator::make($data, [
            's_idpredial' => 'required|string',
            's_opcion' => 'required|string',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 400);
        }

        // Construir XML de envío
        $xmlEnviado = '<BusquedaPredio numIdPredio="' . htmlspecialchars($data['s_idpredial']) . '" idOpcion="' . htmlspecialchars($data['s_opcion']) . '"/>';

        // Consumir el WebService SOAP
        $wsdl = config('services.sdmwebservice.wsdl', 'http://192.168.17.90:1888/EJBMpredio/SeBePredio?wsdl');
        $client = new SoapClient($wsdl, [
            'trace' => 1,
            'exceptions' => true,
            'cache_wsdl' => WSDL_CACHE_NONE,
        ]);
        $xmlRecibido = $client->consultaPredio($xmlEnviado);

        // Procesar XML recibido y extraer datos
        $predios = $this->parsePredioXML($xmlRecibido);

        // Guardar en base de datos (llama SP)
        $result = DB::select('SELECT * FROM sp_insert_predio_virtual(:json_data)', [
            'json_data' => json_encode($predios)
        ]);

        return response()->json([
            'eResponse' => [
                'status' => 'success',
                'message' => 'Consulta realizada correctamente',
                'data' => $predios
            ]
        ]);
    }

    /**
     * Parse XML de respuesta del WebService y retorna array de predios
     * @param string $xml
     * @return array
     */
    private function parsePredioXML($xml)
    {
        $result = [];
        $doc = new \DOMDocument();
        $doc->loadXML($xml);
        $listaPredio = $doc->getElementsByTagName('ListaPredio');
        foreach ($listaPredio as $lp) {
            $datPredio = $lp->getElementsByTagName('DatPredio')->item(0);
            if ($datPredio) {
                $item = [
                    'cvecuenta' => (int)($datPredio->getAttribute('idCveCuenta') ?: 0),
                    'recaud' => (int)($datPredio->getAttribute('idRecaudadora') ?: 0),
                    'tipo' => $datPredio->getAttribute('idTipo') ?: '',
                    'cuenta' => (int)($datPredio->getAttribute('idCuenta') ?: 0),
                    'cvecatastral' => $datPredio->getAttribute('cveCatastral') ?: '',
                    'subpredio' => (int)($datPredio->getAttribute('numIndiviso') ?: 0),
                    'propietario' => $datPredio->getAttribute('contribuyente') ?: '',
                    'calle' => $datPredio->getAttribute('calleUbic') ?: '',
                    'numext' => $datPredio->getAttribute('numExtUbic') ?: '',
                    'numint' => '', // No viene en XML
                    'colonia' => '', // No viene en XML
                    'zona' => (int)($datPredio->getAttribute('zona') ?: 0),
                    'subzona' => (int)($datPredio->getAttribute('subzona') ?: 0),
                    'status' => (int)($datPredio->getAttribute('rsStatus') ?: 0),
                    'mensaje' => $datPredio->getAttribute('rsMensaje') ?: ''
                ];
                $result[] = $item;
            }
        }
        return $result;
    }
}
