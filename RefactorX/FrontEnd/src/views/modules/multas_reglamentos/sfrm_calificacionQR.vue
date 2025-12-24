<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="qrcode" />
      </div>
      <div class="module-view-info">
        <h1>Calificación QR</h1>
        <p>Consulta de calificaciones de multas</p>
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
          <h5>Búsqueda de Calificaciones</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta (ID Multa)</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.cuenta"
                placeholder="ID de multa"
                @keyup.enter="buscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio (Número de Acta)</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.folio"
                placeholder="Número de acta"
                @keyup.enter="buscar"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !isFormValid"
              @click="buscar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="rows.length > 0 || hasSearched">
        <div class="municipal-card-header">
          <h5>Calificaciones ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" v-if="rows.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Folio</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Calificación</th>
                  <th>Multa</th>
                  <th>Total</th>
                  <th>Tipo</th>
                  <th>Usuario</th>
                  <th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_multa" class="row-hover">
                  <td><strong>{{ r.id_multa }}</strong></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td class="text-right">${{ formatMoney(r.calificacion) }}</td>
                  <td class="text-right">${{ formatMoney(r.multa) }}</td>
                  <td class="text-right"><strong>${{ formatMoney(r.total) }}</strong></td>
                  <td>
                    <span :class="getTipoClass(r.tipo_calificacion_cod)">
                      {{ r.tipo_calificacion_desc }}
                    </span>
                  </td>
                  <td>{{ r.usuario_calificacion }}</td>
                  <td>{{ formatDate(r.fecha_calificacion) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="empty-state">
            <font-awesome-icon icon="search" size="3x" />
            <p>No se encontraron calificaciones</p>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'sfrm_calificacionQR'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Calificación QR'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'sfrm_calificacionQR'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Calificación QR'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_SFRM_CALIFICACIONQR'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const formData = ref({
  cuenta: '',
  folio: ''
})

const rows = ref([])
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

// Validación del formulario
const isFormValid = computed(() => {
  return formData.value.cuenta || formData.value.folio
})

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Formatear moneda
function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Clase CSS según tipo de calificación
function getTipoClass(tipo) {
  if (tipo === 'M') return 'badge badge-warning'
  if (tipo === 'O') return 'badge badge-info'
  return 'badge badge-secondary'
}

async function buscar() {
  hasSearched.value = true

  // IMPORTANTE: Enviar parámetros separados, no JSON
  const params = [
    { nombre: 'p_cuenta', tipo: 'string', valor: String(formData.value.cuenta || '') },
    { nombre: 'p_folio', tipo: 'string', valor: String(formData.value.folio || '') }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta
    let arr = []
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1
  } catch (e) {
    console.error('Error al buscar calificaciones:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  formData.value = {
    cuenta: '',
    folio: ''
  }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
}
</script>

