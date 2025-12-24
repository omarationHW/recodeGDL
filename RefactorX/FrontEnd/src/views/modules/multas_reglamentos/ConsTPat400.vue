<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exchange-alt" /></div>
      <div class="module-view-info">
        <h1>Consulta Transmisiones Patrimoniales 400</h1>
        <p>Multas y Reglamentos - Consulta de Pagos de Transmisiones Patrimoniales del AS400</p>
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
              <label class="municipal-form-label">Fecha Inicial</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaInicial" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Final</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaFinal" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input type="number" class="municipal-form-control" v-model="filters.recaudadora" placeholder="Recaudadora" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <input type="text" class="municipal-form-control" v-model="filters.caja" placeholder="Caja" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operacion</label>
              <input type="number" class="municipal-form-control" v-model="filters.operacion" placeholder="Operacion" @keyup.enter="buscar" />
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
          <h5><font-awesome-icon icon="list" /> Resultados</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="transmisiones.length > 0">{{ transmisiones.length }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Utilice los filtros para buscar transmisiones patrimoniales</p>
            </div>
          </div>

          <div v-else-if="transmisiones.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron transmisiones con los criterios especificados</p>
            </div>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Fecha Pago</th>
                  <th>Recaudadora</th>
                  <th>Caja</th>
                  <th>Operacion</th>
                  <th>Importe</th>
                  <th>Concepto</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(trans, index) in transmisiones" :key="index" class="row-hover"
                  :class="{ 'table-row-selected': selectedTrans === trans }" @click="selectedTrans = trans">
                  <td><strong class="text-primary">{{ trans.folio }}</strong></td>
                  <td>{{ formatDate(trans.fecha_pago) }}</td>
                  <td>{{ trans.recaud }}</td>
                  <td>{{ trans.caja }}</td>
                  <td>{{ trans.operacion }}</td>
                  <td class="text-end">{{ formatCurrency(trans.importe) }}</td>
                  <td>{{ trans.concepto }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'ConsTPat400'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Transmisiones Patrimoniales 400'" @close="showDocModal = false" />
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
const transmisiones = ref([])
const selectedTrans = ref(null)
const showDocModal = ref(false)
const docType = ref('ayuda')

const today = new Date().toISOString().split('T')[0]
const filters = ref({ fechaInicial: today, fechaFinal: today, recaudadora: '', caja: '', operacion: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const buscar = async () => {
  if (!filters.value.fechaInicial || !filters.value.fechaFinal) {
    showToast('warning', 'Debe ingresar el rango de fechas')
    return
  }

  showLoading('Buscando transmisiones...', 'Consultando sistema 400')
  searchPerformed.value = true

  try {
    const response = await execute('sp_constpat400_consulta', 'multas_reglamentos',
      [
        { nombre: 'p_fecha_ini', valor: filters.value.fechaInicial, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFinal, tipo: 'date' },
        { nombre: 'p_recaud', valor: filters.value.recaudadora ? parseInt(filters.value.recaudadora) : null, tipo: 'integer' },
        { nombre: 'p_caja', valor: filters.value.caja || null, tipo: 'string' },
        { nombre: 'p_operacion', valor: filters.value.operacion ? parseInt(filters.value.operacion) : null, tipo: 'integer' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result) {
      transmisiones.value = response.result
      if (transmisiones.value.length > 0) {
        selectedTrans.value = transmisiones.value[0]
        showToast('success', `Se encontraron ${transmisiones.value.length} transmision(es)`)
      } else {
        showToast('info', 'No se encontraron transmisiones')
      }
    } else {
      transmisiones.value = []
      showToast('info', 'No hay transmisiones')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar transmisiones')
    transmisiones.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { fechaInicial: today, fechaFinal: today, recaudadora: '', caja: '', operacion: '' }
  transmisiones.value = []
  selectedTrans.value = null
  searchPerformed.value = false
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    return new Date(dateString).toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch { return 'N/A' }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}
</script>
