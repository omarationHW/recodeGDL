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
                placeholder='{"tipo":"predial","recaud":1,"folio_ini":1000,"folio_fin":1010,"fecha":"2025-01-17","accion":"consultar"}'
              ></textarea>
            </div>
          </div>

          <!-- Ejemplos rápidos -->
          <div class="ejemplos-section">
            <label class="municipal-form-label">Ejemplos rápidos:</label>
            <div class="ejemplos-buttons">
              <button class="btn-ejemplo" @click="cargarEjemplo(1)">
                <font-awesome-icon icon="file-alt" /> Predial
              </button>
              <button class="btn-ejemplo" @click="cargarEjemplo(2)">
                <font-awesome-icon icon="gavel" /> Multa
              </button>
              <button class="btn-ejemplo" @click="cargarEjemplo(3)">
                <font-awesome-icon icon="id-card" /> Licencia
              </button>
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
                  <th>Tipo</th>
                  <th>Registros Afectados</th>
                  <th>Folio Inicio</th>
                  <th>Folio Final</th>
                  <th>Mensaje</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(resultado, idx) in resultados" :key="idx" :class="getRowClass(resultado)">
                  <td>
                    <span class="badge" :class="getBadgeTipo(resultado.tipo_req)">
                      {{ resultado.tipo_req }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge-count" :class="getCountClass(resultado.registros_actualizados)">
                      {{ resultado.registros_actualizados }}
                    </span>
                  </td>
                  <td class="text-center text-mono">{{ resultado.folio_inicio }}</td>
                  <td class="text-center text-mono">{{ resultado.folio_final }}</td>
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
            <h6>Acciones disponibles:</h6>
            <ul>
              <li><strong>consultar:</strong> Solo cuenta registros (no modifica datos)</li>
              <li><strong>modificar:</strong> Actualiza fechas de práctica/entrega</li>
              <li><strong>cancelar:</strong> Marca como cancelados o elimina registros (⚠️ irreversible)</li>
            </ul>

            <h6>Tipos de requerimientos:</h6>
            <ul>
              <li><strong>predial:</strong> Requerimientos de pago predial (3,676,785 registros)</li>
              <li><strong>multa:</strong> Requerimientos de multas (403,145 registros)</li>
              <li><strong>licencia:</strong> Requerimientos de licencias (224,736 registros)</li>
            </ul>

            <h6>⚠️ Importante:</h6>
            <ul>
              <li>Siempre usa <code>"accion":"consultar"</code> primero para verificar</li>
              <li>La acción "cancelar" ELIMINA permanentemente registros de multas y licencias</li>
              <li>El año se extrae automáticamente de la fecha proporcionada</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_UPDATE = 'RECAUDADORA_MODIF_MASIVA'

const { loading, execute } = useApi()

const jsonPayload = ref('')
const resultados = ref([])
const searched = ref(false)
const error = ref('')

// Ejemplos predefinidos
const ejemplos = {
  1: {
    tipo: 'predial',
    recaud: 3,
    folio_ini: 1328820,
    folio_fin: 1328830,
    fecha: '2025-01-17',
    accion: 'consultar'
  },
  2: {
    tipo: 'multa',
    recaud: 2,
    folio_ini: 100635,
    folio_fin: 100650,
    fecha: '2024-04-29',
    accion: 'consultar'
  },
  3: {
    tipo: 'licencia',
    recaud: 2,
    folio_ini: 28745,
    folio_fin: 28755,
    fecha: '2024-01-01',
    accion: 'consultar'
  }
}

function cargarEjemplo(num) {
  jsonPayload.value = JSON.stringify(ejemplos[num], null, 2)
}

async function aplicar() {
  searched.value = false
  resultados.value = []
  error.value = ''

  try {
    const params = [{ nombre: 'datos', tipo: 'string', valor: jsonPayload.value }]
    const data = await execute(OP_UPDATE, BASE_DB, params)

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

function getBadgeTipo(tipo) {
  const badges = {
    'predial': 'badge-primary',
    'multa': 'badge-danger',
    'licencia': 'badge-success',
    'error': 'badge-error'
  }
  return badges[tipo] || 'badge-secondary'
}

function getCountClass(count) {
  if (count === 0) return 'count-zero'
  if (count < 10) return 'count-low'
  if (count < 50) return 'count-medium'
  return 'count-high'
}

function getMensajeClass(mensaje) {
  if (mensaje.includes('Error')) return 'mensaje-error'
  if (mensaje.includes('exitosamente')) return 'mensaje-success'
  if (mensaje.includes('Consulta')) return 'mensaje-info'
  return ''
}

function getRowClass(resultado) {
  if (resultado.tipo_req === 'error') return 'row-error'
  if (resultado.registros_actualizados > 0) return 'row-success'
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

/* Ejemplos rápidos */
.ejemplos-section {
  margin-top: 1rem;
  margin-bottom: 1rem;
}

.ejemplos-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin-top: 0.5rem;
}

.btn-ejemplo {
  padding: 0.5rem 1rem;
  border: 1px solid #007bff;
  background-color: #fff;
  color: #007bff;
  cursor: pointer;
  border-radius: 0.25rem;
  transition: all 0.2s;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-ejemplo:hover {
  background-color: #007bff;
  color: #fff;
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

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

/* Responsive */
@media (max-width: 768px) {
  .ejemplos-buttons {
    flex-direction: column;
  }

  .btn-ejemplo {
    width: 100%;
    justify-content: center;
  }

  .municipal-table {
    font-size: 0.875rem;
  }

  .municipal-table th,
  .municipal-table td {
    padding: 0.5rem;
  }
}
</style>

