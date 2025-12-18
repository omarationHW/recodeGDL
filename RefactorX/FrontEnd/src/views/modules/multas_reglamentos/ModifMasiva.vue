<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="sliders" /></div>
      <div class="module-view-info">
        <h1>Modificación Masiva</h1>
        <p>Actualización masiva de requerimientos por rango de folios</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de entrada de datos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Parámetros de Modificación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">JSON de parámetros</label>
              <textarea
                class="municipal-form-control"
                rows="8"
                v-model="jsonPayload"
                placeholder='{"recaudadora": 1, "folio_inicio": 5000, "folio_fin": 5200, "estado": "ACTIVO"}'
              ></textarea>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="aplicar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Procesando...</span>
              <span v-else>Ejecutar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="resultados.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados de la Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Recaudadora</th>
                  <th>Total Encontrados</th>
                  <th>Folio Inicio</th>
                  <th>Folio Final</th>
                  <th>Estado</th>
                  <th>Mensaje</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(resultado, idx) in resultados" :key="idx" :class="getRowClass(resultado)">
                  <td class="text-center">
                    <span class="badge badge-primary">
                      {{ getDetalleValue(resultado, 'recaudadora') }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge-count" :class="getCountClass(resultado.total_encontrados)">
                      {{ resultado.total_encontrados }}
                    </span>
                  </td>
                  <td class="text-center text-mono">{{ getDetalleValue(resultado, 'folio_inicio') }}</td>
                  <td class="text-center text-mono">{{ getDetalleValue(resultado, 'folio_fin') }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getBadgeEstado(getDetalleValue(resultado, 'estado'))">
                      {{ getDetalleValue(resultado, 'estado') }}
                    </span>
                  </td>
                  <td>
                    <span :class="getMensajeClass(resultado.mensaje)">
                      {{ resultado.mensaje }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-else-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-error">
            <font-awesome-icon icon="exclamation-triangle" />
            <span>{{ error }}</span>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div class="municipal-card" v-else-if="searched && resultados.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <br />
            No se encontraron resultados. Ejecuta una consulta para ver los datos.
          </p>
        </div>
      </div>

      <!-- Card de ayuda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" /> Información
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-section">
            <h6>Formato JSON:</h6>
            <pre><code>{
  "recaudadora": 1,
  "folio_inicio": 5000,
  "folio_fin": 5200,
  "estado": "ACTIVO"
}</code></pre>

            <h6>Parámetros:</h6>
            <ul>
              <li><strong>recaudadora:</strong> Número de recaudadora (1-10)</li>
              <li><strong>folio_inicio:</strong> Cuenta catastral inicial</li>
              <li><strong>folio_fin:</strong> Cuenta catastral final</li>
              <li><strong>estado:</strong> ACTIVO, CANCELADO o PAGADO</li>
            </ul>

            <h6>Estados disponibles:</h6>
            <ul>
              <li><strong>ACTIVO:</strong> Requerimientos vigentes/activos (99,606 registros)</li>
              <li><strong>CANCELADO:</strong> Requerimientos cancelados (18 registros)</li>
              <li><strong>PAGADO:</strong> Requerimientos pagados</li>
            </ul>

            <h6>⚠️ Importante:</h6>
            <ul>
              <li>Esta operación solo <strong>consulta y cuenta</strong> registros (no modifica datos)</li>
              <li>El campo "folio" corresponde a la <strong>cuenta catastral</strong> (cvecuenta)</li>
              <li>Total de requerimientos disponibles: <strong>118,842</strong></li>
            </ul>
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
const OP_UPDATE = 'RECAUDADORA_MODIF_MASIVA'
const SCHEMA = 'publico'

const { loading, execute } = useApi()

const jsonPayload = ref('')
const resultados = ref([])
const searched = ref(false)
const error = ref('')

async function aplicar() {
  searched.value = false
  resultados.value = []
  error.value = ''

  try {
    const params = [{ nombre: 'datos', tipo: 'string', valor: jsonPayload.value }]
    const data = await execute(OP_UPDATE, BASE_DB, params, '', null, SCHEMA)

    // Extraer resultados
    let rows = []
    if (data?.result) {
      rows = data.result
    } else if (data?.rows) {
      rows = data.rows
    } else if (Array.isArray(data)) {
      rows = data
    }

    resultados.value = rows
    searched.value = true

    if (rows.length === 0) {
      error.value = 'No se obtuvieron resultados. Verifica el JSON ingresado.'
    }
  } catch (e) {
    console.error('Error al ejecutar modificación masiva:', e)
    error.value = e.message || 'Error al ejecutar la operación'
    searched.value = true
  }
}

// Extraer valores del campo detalles (JSONB)
function getDetalleValue(resultado, campo) {
  if (!resultado.detalles) return '-'

  // Si detalles es string (JSON), parsearlo
  let detallesObj = resultado.detalles
  if (typeof detallesObj === 'string') {
    try {
      detallesObj = JSON.parse(detallesObj)
    } catch (e) {
      return '-'
    }
  }

  return detallesObj[campo] || '-'
}

function getBadgeEstado(estado) {
  const badges = {
    'ACTIVO': 'badge-success',
    'VIGENTE': 'badge-success',
    'CANCELADO': 'badge-danger',
    'PAGADO': 'badge-primary'
  }
  return badges[estado] || 'badge-secondary'
}

function getCountClass(count) {
  if (count === 0) return 'count-zero'
  if (count < 10) return 'count-low'
  if (count < 50) return 'count-medium'
  return 'count-high'
}

function getMensajeClass(mensaje) {
  if (!mensaje) return ''
  if (mensaje.includes('Error')) return 'mensaje-error'
  if (mensaje.includes('encontraron') || mensaje.includes('encontró')) return 'mensaje-success'
  if (mensaje.includes('No se encontraron')) return 'mensaje-info'
  return 'mensaje-info'
}

function getRowClass(resultado) {
  if (resultado.total_encontrados === 0) return 'row-neutral'
  if (resultado.total_encontrados > 0) return 'row-success'
  return 'row-neutral'
}
</script>

<style scoped>
.full-width {
  width: 100%;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.text-mono {
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
}

.mb-3 {
  margin-bottom: 1rem;
}

/* Badges */
.badge {
  display: inline-block;
  padding: 0.35em 0.65em;
  font-size: 0.875em;
  font-weight: 600;
  line-height: 1;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0.25rem;
  text-transform: uppercase;
}

.badge-primary {
  background-color: #007bff;
}

.badge-success {
  background-color: #28a745;
}

.badge-danger {
  background-color: #dc3545;
}

.badge-error {
  background-color: #dc3545;
}

.badge-secondary {
  background-color: #6c757d;
}

/* Badge de conteo */
.badge-count {
  display: inline-block;
  padding: 0.5em 0.75em;
  font-size: 1.1em;
  font-weight: 700;
  border-radius: 0.25rem;
}

.count-zero {
  background-color: #6c757d;
  color: #fff;
}

.count-low {
  background-color: #17a2b8;
  color: #fff;
}

.count-medium {
  background-color: #ffc107;
  color: #212529;
}

.count-high {
  background-color: #28a745;
  color: #fff;
}

/* Mensajes */
.mensaje-error {
  color: #dc3545;
  font-weight: 600;
}

.mensaje-success {
  color: #28a745;
  font-weight: 600;
}

.mensaje-info {
  color: #17a2b8;
  font-weight: 500;
}

/* Filas de la tabla */
.row-error {
  background-color: #f8d7da !important;
}

.row-success {
  background-color: #d4edda !important;
}

.row-neutral {
  background-color: #fff3cd !important;
}

/* Alertas */
.alert {
  padding: 1rem;
  border-radius: 0.25rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.alert-error {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

/* Sección de información */
.info-section {
  line-height: 1.6;
}

.info-section h6 {
  margin-top: 1rem;
  margin-bottom: 0.5rem;
  color: #495057;
  font-weight: 600;
}

.info-section ul {
  margin-left: 1.5rem;
  margin-bottom: 0.5rem;
}

.info-section code {
  background-color: #f8f9fa;
  padding: 0.2em 0.4em;
  border-radius: 0.25rem;
  font-family: 'Courier New', monospace;
  font-size: 0.875em;
  color: #e83e8c;
}

.info-section pre {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 0.25rem;
  padding: 1rem;
  margin: 0.5rem 0;
  overflow-x: auto;
}

.info-section pre code {
  background-color: transparent;
  color: #212529;
  padding: 0;
  font-size: 0.875em;
  line-height: 1.5;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

/* Responsive */
@media (max-width: 768px) {
  .municipal-table {
    font-size: 0.875rem;
  }

  .municipal-table th,
  .municipal-table td {
    padding: 0.5rem;
  }
}
</style>

