<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'open_file':
                    // File upload and preview
                    if ($request->hasFile('file')) {
                        $file = $request->file('file');
                        $path = $file->store('valet_uploads');
                        // Optionally, parse the file (e.g., CSV, XLSX)
                        $preview = $this->previewFile($file);
                        $eResponse['success'] = true;
                        $eResponse['message'] = 'Archivo subido correctamente';
                        $eResponse['data'] = [
                            'path' => $path,
                            'preview' => $preview
                        ];
                    } else {
                        $eResponse['message'] = 'No se recibió archivo';
                    }
                    break;
                case 'process_valet_data':
                    // Process uploaded file and insert data
                    $filePath = $eRequest['file_path'] ?? null;
                    if (!$filePath || !Storage::exists($filePath)) {
                        $eResponse['message'] = 'Archivo no encontrado';
                        break;
                    }
                    $fullPath = storage_path('app/' . $filePath);
                    $result = DB::select('SELECT * FROM process_valet_file(:p_file_path)', [
                        'p_file_path' => $fullPath
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Datos procesados correctamente';
                    $eResponse['data'] = $result;
                    break;
                case 'get_valet_preview':
                    // Preview parsed data from file
                    $filePath = $eRequest['file_path'] ?? null;
                    if (!$filePath || !Storage::exists($filePath)) {
                        $eResponse['message'] = 'Archivo no encontrado';
                        break;
                    }
                    $fullPath = storage_path('app/' . $filePath);
                    $preview = $this->previewFile(fopen($fullPath, 'r'));
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Vista previa generada';
                    $eResponse['data'] = $preview;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error('ExecuteController error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error interno: ' . $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Preview file content (first 10 rows, CSV or XLSX)
     */
    private function previewFile($file)
    {
        // For simplicity, only CSV preview is implemented
        $rows = [];
        if (is_string($file)) {
            $handle = fopen($file, 'r');
        } else {
            $handle = $file;
        }
        if ($handle) {
            $i = 0;
            while (($data = fgetcsv($handle, 1000, ',')) !== false && $i < 10) {
                $rows[] = $data;
                $i++;
            }
            fclose($handle);
        }
        return $rows;
    }
}
