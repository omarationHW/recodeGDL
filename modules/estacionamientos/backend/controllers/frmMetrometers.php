<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for MetroMeters.
     * Endpoint: /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getMetrometerByAxoFolio':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'folio' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_metrometer_by_axo_folio(?, ?)', [
                        $params['axo'],
                        $params['folio']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'updateMetrometer':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'folio' => 'required|integer',
                        'direccion' => 'required|string',
                        'marca' => 'required|string',
                        'motivo' => 'required|string',
                        'modelo' => 'nullable|string',
                        'poslong' => 'nullable|string',
                        'poslat' => 'nullable|string',
                        'linkfoto1' => 'nullable|string',
                        'linkfoto2' => 'nullable|string',
                        'idmedio' => 'nullable|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_metrometer(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['axo'],
                        $params['folio'],
                        $params['direccion'],
                        $params['marca'],
                        $params['motivo'],
                        $params['modelo'] ?? null,
                        $params['poslong'] ?? null,
                        $params['poslat'] ?? null,
                        $params['linkfoto1'] ?? null,
                        $params['linkfoto2'] ?? null,
                        $params['idmedio'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'getMetrometerPhoto':
                    $validator = Validator::make($params, [
                        'folio' => 'required|string',
                        'photo_number' => 'required|integer|in:1,2'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    // Simulate SOAP call to external service (should be replaced with actual integration)
                    $photoBase64 = $this->getPhotoFromSoap($params['folio'], $params['photo_number']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'base64' => $photoBase64
                    ];
                    break;

                default:
                    $eResponse['message'] = 'Invalid eRequest.';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Simulate SOAP call to get photo (replace with real SOAP client as needed)
     */
    private function getPhotoFromSoap($folio, $photo_number)
    {
        // TODO: Integrate with real SOAP client
        // For now, return a placeholder base64 string
        return base64_encode('FakeImageDataForFolio_' . $folio . '_Photo_' . $photo_number);
    }
}
