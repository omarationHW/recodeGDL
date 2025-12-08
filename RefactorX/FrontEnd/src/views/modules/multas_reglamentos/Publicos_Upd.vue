<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Públicos</h1>
        <p>Actualización masiva de conceptos de pago</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">JSON de actualización</label>
              <textarea
                class="municipal-form-control"
                rows="12"
                v-model="jsonPayload"
                placeholder='[{"cveconcepto": 1, "descripcion": "...", "ncorto": "...", "cvegrupo": 1}]'
              ></textarea>
              <small class="form-text text-muted">
                Formato: Array de objetos con cveconcepto, descripcion, ncorto y cvegrupo
              </small>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="aplicar"
            >
              <font-awesome-icon icon="check" v-if="!loading" />
              <span v-if="loading">Procesando...</span>
              <span v-else>Aplicar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados de la Actualización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table" style="width: 100%; border: 1px solid #ddd;">
              <thead class="municipal-table-header" style="background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);">
                <tr>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">ID</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Descripción</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Nombre Corto</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Grupo</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Acción</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Resultado</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(row, idx) in resultado"
                  :key="idx"
                  :class="{
                    'row-success': row.accion === 'ACTUALIZADO' || row.accion === 'INSERTADO',
                    'row-error': row.accion === 'ERROR',
                    'row-hover': true
                  }"
                  style="border-bottom: 1px solid #ddd;"
                >
                  <td style="padding: 8px; border: 1px solid #ddd; font-weight: 600;">
                    {{ row.cveconcepto || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.descripcion }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.ncorto || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd; text-align: center;">
                    {{ row.cvegrupo || '-' }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    <span :class="getBadgeClass(row.accion)">
                      {{ row.accion }}
                    </span>
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.resultado }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="summary-info">
            <p><strong>Total procesados:</strong> {{ resultado.length }} registros</p>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_UPDATE = 'RECAUDADORA_PUBLICOS_UPD'
const { loading, execute } = useApi()

const jsonPayload = ref('')
const resultado = ref(null)
const error = ref(null)

function cargarEjemplo(num) {
  switch(num) {
    case 1:
      jsonPayload.value = JSON.stringify([{
        "cveconcepto": 4,
        "descripcion": "PAGO DE DIVERSOS ACTUALIZADO",
        "ncorto": "DIV-ACT",
        "cvegrupo": 1
      }], null, 2)
      break
    case 2:
      jsonPayload.value = JSON.stringify([{
        "cveconcepto": 0,
        "descripcion": "NUEVO CONCEPTO DE PAGO",
        "ncorto": "NUEVO",
        "cvegrupo": 2
      }], null, 2)
      break
    case 3:
      jsonPayload.value = JSON.stringify([
        {"cveconcepto": 1, "descripcion": "IMPUESTO PREDIAL", "ncorto": "PREDIAL", "cvegrupo": 1},
        {"cveconcepto": 2, "descripcion": "TRANSMISION PATRIMONIAL", "ncorto": "TRANSM-PAT", "cvegrupo": 1}
      ], null, 2)
      break
  }
}

async function aplicar() {
  error.value = null
  resultado.value = null

  try {
    // Validar JSON
    let jsonData
    try {
      jsonData = JSON.parse(jsonPayload.value)
    } catch (e) {
      error.value = 'El JSON no es válido: ' + e.message
      return
    }

    console.log('🔍 Ejecutando SP:', OP_UPDATE)
    console.log('🔍 Datos:', jsonData)

    // Enviar parámetros en el formato que espera GenericController
    const params = [
      {
        nombre: 'p_datos',
        valor: jsonPayload.value,
        tipo: 'string'
      }
    ]

    const data = await execute(OP_UPDATE, BASE_DB, params)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    resultado.value = arr

  } catch (e) {
    error.value = e.message || 'Error al ejecutar la actualización'
    console.error('❌ Error:', e)
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
  error.value = null
}

function getBadgeClass(accion) {
  if (accion === 'ACTUALIZADO') return 'badge badge-warning'
  if (accion === 'INSERTADO') return 'badge badge-success'
  if (accion === 'ERROR') return 'badge badge-danger'
  return 'badge badge-info'
}
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  margin-bottom: 15px;
}

.form-group.full-width {
  width: 100%;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
  display: block;
}

.municipal-form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-family: monospace;
  font-size: 13px;
  resize: vertical;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
}

.text-muted {
  color: #6c757d;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.row-success {
  background-color: #d4edda;
}

.row-error {
  background-color: #f8d7da;
}

.table-responsive {
  overflow-x: auto;
}

.badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.badge-success {
  background: #28a745;
  color: white;
}

.badge-warning {
  background: #ffc107;
  color: #212529;
}

.badge-danger {
  background: #dc3545;
  color: white;
}

.badge-info {
  background: #17a2b8;
  color: white;
}

.summary-info {
  margin-top: 20px;
  padding-top: 15px;
  border-top: 2px solid #ea8215;
}

.summary-info p {
  margin: 5px 0;
  font-size: 1.1rem;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}
</style>
