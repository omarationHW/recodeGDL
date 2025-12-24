<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Requerimientos por Clave Catastral</h1>
        <p>Consulta por cvecat</p>
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
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Clave Catastral</label>
              <input
                class="municipal-form-control"
                v-model="filters.cvecat"
                @keyup.enter="reload"
                placeholder="Ingrese clave catastral (ej: D65J4262005)"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Folio</th>
                  <th>Cuenta</th>
                  <th>Clave Catastral</th>
                  <th>Ejercicio</th>
                  <th>Fecha Emisión</th>
                  <th>Fecha Entrega</th>
                  <th>Impuesto</th>
                  <th>Recargos</th>
                  <th>Gastos</th>
                  <th>Multas</th>
                  <th>Total</th>
                  <th>Vigencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.cvereq" class="row-hover">
                  <td>{{ r.cvereq }}</td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.cuenta }}</td>
                  <td><strong>{{ r.clave_catastral || 'N/A' }}</strong></td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.fecha_emision || 'N/A' }}</td>
                  <td>{{ r.fecha_entrega || 'N/A' }}</td>
                  <td class="text-right">${{ formatNumber(r.impuesto) }}</td>
                  <td class="text-right">${{ formatNumber(r.recargos) }}</td>
                  <td class="text-right">${{ formatNumber(r.gastos) }}</td>
                  <td class="text-right">${{ formatNumber(r.multas) }}</td>
                  <td class="text-right"><strong>${{ formatNumber(r.total) }}</strong></td>
                  <td><span :class="getVigenciaClass(r.vigencia)">{{ r.vigencia }}</span></td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="13" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
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
      :component-name="'RequerxCvecat'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Requerimientos por Clave Catastral'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'RequerxCvecat'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Requerimientos por Clave Catastral'"
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
const OP_LIST = 'RECAUDADORA_REQUERXCVECAT'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const filters = ref({ cvecat: '' })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Función para recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'cvecat', tipo: 'C', valor: String(filters.value.cvecat || '') }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_LIST, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta según la estructura de la API
    let arr = []

    // La API puede retornar diferentes estructuras
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
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar requerimientos:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

// Formatear números con 2 decimales
function formatNumber(value) {
  if (value === null || value === undefined) return '0.00'
  return Number(value).toFixed(2)
}

// Clase CSS según vigencia
function getVigenciaClass(vigencia) {
  if (vigencia === 'Pendiente') return 'badge badge-warning'
  if (vigencia === 'Cancelado') return 'badge badge-danger'
  if (vigencia === 'Entregado') return 'badge badge-success'
  return 'badge badge-secondary'
}

// Cargar datos al montar (comentado para no cargar automáticamente)
// reload()
</script>

