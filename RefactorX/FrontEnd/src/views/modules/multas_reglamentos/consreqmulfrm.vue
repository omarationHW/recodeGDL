<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Consulta Requerimientos de Multas</h1>
        <p>Multas y Reglamentos - Consulta de Requerimientos Emitidos para Multas</p>
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
              <input type="number" class="municipal-form-control" v-model="filters.folioMulta" placeholder="Folio de multa" @keyup.enter="buscar" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio Requerimiento</label>
              <input type="number" class="municipal-form-control" v-model="filters.folioReq" placeholder="Folio requerimiento" @keyup.enter="buscar" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estado</label>
              <select class="municipal-form-control" v-model="filters.vigencia">
                <option value="">Todos</option>
                <option value="V">Vigente</option>
                <option value="P">Pagado</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Emision Inicio</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaInicio" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Emision Fin</label>
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
          <h5><font-awesome-icon icon="table" /> Requerimientos de Multas</h5>
          <span v-if="requerimientos.length > 0" class="badge badge-primary">{{ requerimientos.length }} registros</span>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione criterios de busqueda</p>
            </div>
          </div>

          <div v-else-if="requerimientos.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron requerimientos</p>
            </div>
          </div>

          <div v-else>
            <div class="table-responsive mb-4">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Folio Req.</th>
                    <th>Folio Multa</th>
                    <th>Fecha Emision</th>
                    <th>Fecha Citatorio</th>
                    <th class="text-end">Total</th>
                    <th>Ejecutor</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="req in requerimientos" :key="req.cvereq"
                      @click="selectRequerimiento(req)"
                      :class="{ 'table-active': selectedReq?.cvereq === req.cvereq }"
                      style="cursor: pointer;">
                    <td><strong class="text-primary">{{ req.folioreq }}</strong></td>
                    <td>{{ req.folio_multa }}</td>
                    <td>{{ formatDate(req.fecemi) }}</td>
                    <td>{{ formatDate(req.feccit) }}</td>
                    <td class="text-end">{{ formatCurrency(req.total) }}</td>
                    <td>{{ req.ejecutor || 'N/A' }}</td>
                    <td>
                      <span class="badge" :class="getBadgeClass(req.vigencia)">
                        {{ getEstadoText(req.vigencia) }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div v-if="selectedReq" class="row">
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
                    <h5><font-awesome-icon icon="file-alt" /> Observaciones</h5>
                  </div>
                  <div class="municipal-card-body">
                    <div class="observation-text">
                      {{ selectedReq.obs || 'Sin observaciones' }}
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
                    <h5><font-awesome-icon icon="dollar-sign" /> Desglose</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="detail-table">
                      <tr><td class="label">Formas:</td><td class="text-end">{{ formatCurrency(selectedReq.formas) }}</td></tr>
                      <tr><td class="label">Derechos:</td><td class="text-end">{{ formatCurrency(selectedReq.derechos) }}</td></tr>
                      <tr><td class="label">Recargos:</td><td class="text-end">{{ formatCurrency(selectedReq.recargos) }}</td></tr>
                      <tr><td class="label">Gastos:</td><td class="text-end">{{ formatCurrency(selectedReq.gastos) }}</td></tr>
                      <tr><td class="label">Multas:</td><td class="text-end text-danger">{{ formatCurrency(selectedReq.multas) }}</td></tr>
                      <tr><td class="label">Gasto Req:</td><td class="text-end">{{ formatCurrency(selectedReq.gasto_req) }}</td></tr>
                      <tr class="table-active"><td class="label"><strong>Total:</strong></td><td class="text-end"><strong>{{ formatCurrency(selectedReq.total) }}</strong></td></tr>
                    </table>
                  </div>
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

    <DocumentationModal :show="showDocModal" :componentName="'consreqmulfrm'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Requerimientos Multas'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const requerimientos = ref([])
const selectedReq = ref(null)
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ folioMulta: '', folioReq: '', vigencia: '', fechaInicio: '', fechaFin: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const selectRequerimiento = (req) => {
  selectedReq.value = selectedReq.value?.cvereq === req.cvereq ? null : req
}

const buscar = async () => {
  showLoading('Buscando requerimientos...', 'Consultando base de datos')
  searchPerformed.value = true
  selectedReq.value = null

  try {
    const response = await execute('sp_consreqmul_lista', 'multas_reglamentos',
      [
        { nombre: 'p_folio_multa', valor: filters.value.folioMulta ? parseInt(filters.value.folioMulta) : null, tipo: 'integer' },
        { nombre: 'p_folio_req', valor: filters.value.folioReq ? parseInt(filters.value.folioReq) : null, tipo: 'integer' },
        { nombre: 'p_vigencia', valor: filters.value.vigencia || null, tipo: 'string' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' }
      ],
      'guadalajara', null, 'publico')

    requerimientos.value = response?.result || []
    showToast(requerimientos.value.length > 0 ? 'success' : 'info',
      requerimientos.value.length > 0 ? `${requerimientos.value.length} requerimientos encontrados` : 'No se encontraron requerimientos')
  } catch (error) {
    handleApiError(error, 'Error al buscar requerimientos')
    requerimientos.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { folioMulta: '', folioReq: '', vigencia: '', fechaInicio: '', fechaFin: '' }
  requerimientos.value = []
  selectedReq.value = null
  searchPerformed.value = false
}

const getBadgeClass = (vigencia) => {
  const classes = { V: 'badge-success', P: 'badge-info', C: 'badge-danger' }
  return classes[vigencia] || 'badge-secondary'
}

const getEstadoText = (vigencia) => {
  const estados = { V: 'Vigente', P: 'Pagado', C: 'Cancelado' }
  return estados[vigencia] || vigencia
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
