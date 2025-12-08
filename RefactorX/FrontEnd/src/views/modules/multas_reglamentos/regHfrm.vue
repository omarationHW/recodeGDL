<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="history" />
      </div>
      <div class="module-view-info">
        <h1>Registro Histórico</h1>
        <p>Consulta histórica de registros de multas y reglamentos</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>🔍 Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Multa</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.id_multa"
                placeholder="Ej: 415284"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Dependencia</label>
              <select class="municipal-form-control" v-model="filtros.id_dependencia">
                <option value="">Todas</option>
                <option value="3">3 - Tránsito</option>
                <option value="7">7 - Reglamentos</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicio</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_inicio"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_fin"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Límite de registros</label>
              <select class="municipal-form-control" v-model.number="filtros.limite">
                <option :value="10">10 registros</option>
                <option :value="20">20 registros</option>
                <option :value="50">50 registros</option>
                <option :value="100">100 registros</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año de Acta</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.axo_acta"
                placeholder="Ej: 2025"
                min="2000"
                max="2030"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="consultar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Consultando...</span>
              <span v-else>Consultar</span>
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

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>Éxito:</strong> {{ success }}
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

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados ({{ resultado.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Dependencia</th>
                  <th>Acta</th>
                  <th>Fecha</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Licencia</th>
                  <th>Giro</th>
                  <th>Calificación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultado" :key="idx" class="row-hover">
                  <td style="font-weight: 600;">{{ row.id_multa }}</td>
                  <td>{{ row.id_dependencia }}</td>
                  <td>{{ row.axo_acta }}/{{ row.num_acta }}</td>
                  <td>{{ formatDate(row.fecha_acta) }}</td>
                  <td>{{ truncate(row.contribuyente, 30) }}</td>
                  <td>{{ truncate(row.domicilio, 30) }}</td>
                  <td>{{ row.num_licencia || '-' }}</td>
                  <td>{{ truncate(row.giro, 25) }}</td>
                  <td style="text-align: right;">{{ formatNumber(row.calificacion) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="summary-info">
            <p><strong>Total encontrado:</strong> {{ resultado.length }} registros</p>
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
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REGHFRM'
const { loading, execute } = useApi()

const filtros = ref({
  id_multa: null,
  id_dependencia: '',
  fecha_inicio: '',
  fecha_fin: '',
  axo_acta: null,
  limite: 20
})

const resultado = ref(null)
const success = ref(null)
const error = ref(null)

onMounted(() => {
  // Establecer fechas por defecto (últimos 30 días)
  const hoy = new Date()
  const hace30dias = new Date()
  hace30dias.setDate(hoy.getDate() - 30)

  filtros.value.fecha_fin = hoy.toISOString().split('T')[0]
  filtros.value.fecha_inicio = hace30dias.toISOString().split('T')[0]
})

async function consultar() {
  error.value = null
  success.value = null
  resultado.value = null

  try {
    console.log('🔍 Ejecutando consulta:', OP)
    console.log('🔍 Filtros:', filtros.value)

    // Construir objeto de búsqueda
    const busqueda = {
      limite: filtros.value.limite,
      fecha_inicio: filtros.value.fecha_inicio,
      fecha_fin: filtros.value.fecha_fin
    }

    // Agregar filtros opcionales
    if (filtros.value.id_multa) {
      busqueda.id_multa = filtros.value.id_multa
      busqueda.tipo = 'id'
    } else if (filtros.value.id_dependencia) {
      busqueda.id_dependencia = parseInt(filtros.value.id_dependencia)
      busqueda.tipo = 'dependencia'
    } else {
      busqueda.tipo = 'rango'
    }

    if (filtros.value.axo_acta) {
      busqueda.axo_acta = filtros.value.axo_acta
    }

    // Enviar parámetros en el formato correcto
    const params = [
      {
        nombre: 'p_filtros',
        valor: JSON.stringify(busqueda),
        tipo: 'string'
      }
    ]

    const data = await execute(OP, BASE_DB, params)

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

    if (arr.length > 0) {
      success.value = `Se encontraron ${arr.length} registros históricos`
    } else {
      error.value = 'No se encontraron registros con los filtros especificados'
    }

  } catch (e) {
    error.value = e.message || 'Error al consultar registros históricos'
    console.error('❌ Error:', e)
  }
}

function limpiar() {
  filtros.value = {
    id_multa: null,
    id_dependencia: '',
    fecha_inicio: '',
    fecha_fin: '',
    axo_acta: null,
    limite: 20
  }

  // Restablecer fechas por defecto
  const hoy = new Date()
  const hace30dias = new Date()
  hace30dias.setDate(hoy.getDate() - 30)

  filtros.value.fecha_fin = hoy.toISOString().split('T')[0]
  filtros.value.fecha_inicio = hace30dias.toISOString().split('T')[0]

  resultado.value = null
  success.value = null
  error.value = null
}

function formatDate(dateString) {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX')
}

function formatNumber(num) {
  if (num === null || num === undefined) return '-'
  return parseFloat(num).toFixed(2)
}

function truncate(text, maxLength) {
  if (!text) return '-'
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
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
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
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
  font-size: 14px;
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

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.municipal-table th {
  font-weight: bold;
  color: white;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.table-responsive {
  overflow-x: auto;
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

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}
</style>
