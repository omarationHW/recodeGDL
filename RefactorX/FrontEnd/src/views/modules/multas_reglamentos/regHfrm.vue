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
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'regHfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Registro Histórico'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'regHfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Registro Histórico'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REGHFRM'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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
    showLoading('Consultando...', 'Por favor espere')
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

    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)

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
  } finally {
    hideLoading()
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

