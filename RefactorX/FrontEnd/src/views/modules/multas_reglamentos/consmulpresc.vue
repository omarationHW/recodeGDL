<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="clock" /></div>
      <div class="module-view-info">
        <h1>Consulta Multas con Prescripcion</h1>
        <p>Multas y Reglamentos - Consulta de Multas que han Prescrito</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" /> Filtros de Busqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio Multa</label>
              <input type="number" class="municipal-form-control" v-model="filters.folio" placeholder="Numero de folio" @keyup.enter="buscar" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Prescripcion Inicio</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaInicio" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Prescripcion Fin</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaFin" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="table" /> Multas Prescritas</h5>
          <span v-if="multas.length > 0" class="badge badge-primary">{{ multas.length }} registros</span>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione criterios de busqueda</p>
            </div>
          </div>

          <div v-else-if="multas.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron multas prescritas</p>
            </div>
          </div>

          <div v-else>
            <div class="table-responsive mb-4">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Folio</th>
                    <th>Fecha Multa</th>
                    <th>Fecha Prescripcion</th>
                    <th>Contribuyente</th>
                    <th class="text-end">Importe</th>
                    <th>Motivo</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="multa in multas" :key="multa.folio"
                      @click="selectMulta(multa)"
                      :class="{ 'table-active': selectedMulta?.folio === multa.folio }"
                      style="cursor: pointer;">
                    <td><strong class="text-primary">{{ multa.folio }}</strong></td>
                    <td>{{ formatDate(multa.fecha_multa) }}</td>
                    <td>{{ formatDate(multa.fecha_prescripcion) }}</td>
                    <td>{{ multa.contribuyente || 'N/A' }}</td>
                    <td class="text-end">{{ formatCurrency(multa.importe) }}</td>
                    <td>{{ multa.motivo || 'N/A' }}</td>
                  </tr>
                </tbody>
                <tfoot v-if="multas.length > 0">
                  <tr>
                    <td colspan="4" class="text-end"><strong>Total:</strong></td>
                    <td class="text-end"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                    <td></td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div v-if="selectedMulta" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="file-alt" /> Observaciones - Folio {{ selectedMulta.folio }}</h5>
              </div>
              <div class="municipal-card-body">
                <div class="observation-text">
                  {{ selectedMulta.observaciones || 'Sin observaciones registradas' }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'consmulpresc'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Multas con Prescripcion'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const multas = ref([])
const selectedMulta = ref(null)
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ folio: '', fechaInicio: '', fechaFin: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const totalImporte = computed(() => {
  return multas.value.reduce((sum, m) => sum + (parseFloat(m.importe) || 0), 0)
})

const selectMulta = (multa) => {
  selectedMulta.value = selectedMulta.value?.folio === multa.folio ? null : multa
}

const buscar = async () => {
  showLoading('Buscando multas prescritas...', 'Consultando base de datos')
  searchPerformed.value = true
  selectedMulta.value = null

  try {
    const response = await execute('sp_consmulpresc_lista', 'multas_reglamentos',
      [
        { nombre: 'p_folio', valor: filters.value.folio ? parseInt(filters.value.folio) : null, tipo: 'integer' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' }
      ],
      'guadalajara', null, 'publico')

    multas.value = response?.result || []
    showToast(multas.value.length > 0 ? 'success' : 'info',
      multas.value.length > 0 ? `${multas.value.length} multas prescritas encontradas` : 'No se encontraron multas prescritas')
  } catch (error) {
    handleApiError(error, 'Error al buscar multas prescritas')
    multas.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { folio: '', fechaInicio: '', fechaFin: '' }
  multas.value = []
  selectedMulta.value = null
  searchPerformed.value = false
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try { return new Date(dateString).toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' }) }
  catch { return 'N/A' }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}
</script>
