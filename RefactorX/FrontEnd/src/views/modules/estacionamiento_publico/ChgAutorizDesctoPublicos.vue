<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-shield" /></div>
      <div class="module-view-info">
        <h1>Autorización de Descuentos</h1>
        <p>Consulta histórica y cambio a Tesorero</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" @keyup.enter="buscar" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Folios Históricos</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha Folio</th><th>Acción</th></tr></thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td>
                  <td><button class="btn-municipal-primary btn-sm" @click="cambiar(r)"><font-awesome-icon icon="user-check" /> Tesorero</button></td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>

          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="previousPage"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="nextPage"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Registros por página:</label>
              <select v-model.number="pageSize" @change="resetPagination" class="municipal-form-control">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>

          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ChgAutorizDesctoPublicos"
    >
      <h3>Chg Autoriz Descto Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ChgAutorizDesctoPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const placa = ref('')
const rows = ref([])
const message = ref('')

// Paginación
const currentPage = ref(1)
const pageSize = ref(10)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value))
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, rows.value.length))

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

function resetPagination() {
  currentPage.value = 1
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function formatDate(d) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('es-MX')
}

async function buscar() {
  if (!placa.value.trim()) {
    showToast('warning', 'Ingrese una placa para buscar')
    return
  }

  showLoading('Buscando...', 'Consultando folios históricos')
  rows.value = []
  resetPagination()
  try {
    const params = [
      { nombre: 'p_placa', valor: placa.value.toUpperCase(), tipo: 'string' }
    ]
    const resp = await execute('sp_buscar_folios_histo', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    hideLoading()

    if (rows.value.length === 0) {
      showToast('info', 'No se encontraron folios para esta placa')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

async function cambiar(r) {
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Cambiar a Tesorero',
    html: `<p>¿Cambiar autorización a Tesorero?</p>
           <ul class="swal-list-left">
             <li><strong>Año:</strong> ${r.axo}</li>
             <li><strong>Folio:</strong> ${r.folio}</li>
             <li><strong>Placa:</strong> ${r.placa}</li>
           </ul>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cambiar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Actualizando...', 'Cambiando autorización')
  message.value = ''
  try {
    const params = [
      { nombre: 'p_axo', valor: r.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: r.folio, tipo: 'integer' }
    ]
    const resp = await execute('sp_cambiar_a_tesorero', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Actualizado',
        text: data?.message || 'Autorización cambiada a Tesorero',
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      message.value = 'Actualizado correctamente'
      buscar()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo actualizar la autorización'
      })
      message.value = data?.message || 'Error al actualizar'
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

