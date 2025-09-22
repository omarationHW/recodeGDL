<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RegHController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
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
                case 'get_historic_records':
                    $eResponse['data'] = $this->getHistoricRecords($params);
                    $eResponse['success'] = true;
                    break;
                case 'get_historic_record':
                    $eResponse['data'] = $this->getHistoricRecord($params);
                    $eResponse['success'] = true;
                    break;
                case 'create_historic_record':
                    $eResponse['data'] = $this->createHistoricRecord($params);
                    $eResponse['success'] = true;
                    break;
                case 'update_historic_record':
                    $eResponse['data'] = $this->updateHistoricRecord($params);
                    $eResponse['success'] = true;
                    break;
                case 'delete_historic_record':
                    $eResponse['data'] = $this->deleteHistoricRecord($params);
                    $eResponse['success'] = true;
                    break;
                default:
                    $eResponse['message'] = 'eRequest not supported';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }

    /**
     * Get all historic records for a given cvecuenta
     */
    private function getHistoricRecords($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('cvecuenta is required');
        }
        $records = DB::select('SELECT axocomp, nocomp FROM h_catastro WHERE cvecuenta = ?', [$cvecuenta]);
        return $records;
    }

    /**
     * Get a single historic record by cvecuenta, axocomp, nocomp
     */
    private function getHistoricRecord($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $axocomp = $params['axocomp'] ?? null;
        $nocomp = $params['nocomp'] ?? null;
        if (!$cvecuenta || !$axocomp || !$nocomp) {
            throw new \Exception('cvecuenta, axocomp, nocomp are required');
        }
        $record = DB::selectOne('SELECT * FROM h_catastro WHERE cvecuenta = ? AND axocomp = ? AND nocomp = ?', [$cvecuenta, $axocomp, $nocomp]);
        return $record;
    }

    /**
     * Create a new historic record
     */
    private function createHistoricRecord($params)
    {
        $validator = Validator::make($params, [
            'cvecuenta' => 'required|integer',
            'axocomp' => 'required|integer',
            'nocomp' => 'required|integer',
            // Add other fields as needed
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $fields = [
            'cvecuenta' => $params['cvecuenta'],
            'axocomp' => $params['axocomp'],
            'nocomp' => $params['nocomp'],
            // Add other fields as needed
        ];
        $columns = implode(',', array_keys($fields));
        $placeholders = implode(',', array_fill(0, count($fields), '?'));
        DB::insert("INSERT INTO h_catastro ($columns) VALUES ($placeholders)", array_values($fields));
        return ['message' => 'Historic record created'];
    }

    /**
     * Update an existing historic record
     */
    private function updateHistoricRecord($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $axocomp = $params['axocomp'] ?? null;
        $nocomp = $params['nocomp'] ?? null;
        if (!$cvecuenta || !$axocomp || !$nocomp) {
            throw new \Exception('cvecuenta, axocomp, nocomp are required');
        }
        $fields = $params;
        unset($fields['cvecuenta'], $fields['axocomp'], $fields['nocomp']);
        $set = [];
        $values = [];
        foreach ($fields as $k => $v) {
            $set[] = "$k = ?";
            $values[] = $v;
        }
        $values[] = $cvecuenta;
        $values[] = $axocomp;
        $values[] = $nocomp;
        $sql = "UPDATE h_catastro SET ".implode(',', $set)." WHERE cvecuenta = ? AND axocomp = ? AND nocomp = ?";
        DB::update($sql, $values);
        return ['message' => 'Historic record updated'];
    }

    /**
     * Delete a historic record
     */
    private function deleteHistoricRecord($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $axocomp = $params['axocomp'] ?? null;
        $nocomp = $params['nocomp'] ?? null;
        if (!$cvecuenta || !$axocomp || !$nocomp) {
            throw new \Exception('cvecuenta, axocomp, nocomp are required');
        }
        DB::delete('DELETE FROM h_catastro WHERE cvecuenta = ? AND axocomp = ? AND nocomp = ?', [$cvecuenta, $axocomp, $nocomp]);
        return ['message' => 'Historic record deleted'];
    }
}
