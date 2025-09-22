<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
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
                case 'getCurrentTime':
                    $result = DB::select('SELECT now() as current_time');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->current_time;
                    break;
                case 'getUserByCredentials':
                    $username = $params['username'] ?? '';
                    $password = $params['password'] ?? '';
                    $result = DB::select('SELECT * FROM sp_get_user_by_credentials(?, ?)', [$username, $password]);
                    if (count($result) === 1) {
                        $eResponse['success'] = true;
                        $eResponse['data'] = $result[0];
                    } else {
                        $eResponse['success'] = false;
                        $eResponse['message'] = 'Usuario y/o contraseña incorrectos o inactivo.';
                    }
                    break;
                case 'checkNewVersion':
                    $proyecto = $params['proyecto'] ?? '';
                    $version = $params['version'] ?? '';
                    $result = DB::select('SELECT * FROM sp_check_new_version(?, ?)', [$proyecto, $version]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'dateToWords':
                    $date = $params['date'] ?? null;
                    if (!$date) {
                        $eResponse['success'] = false;
                        $eResponse['message'] = 'Fecha requerida';
                        break;
                    }
                    $result = DB::select('SELECT date_to_words(?) as words', [$date]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->words;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
