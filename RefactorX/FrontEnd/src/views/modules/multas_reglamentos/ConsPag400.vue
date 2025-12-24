<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="history" /></div>
      <div class="module-view-info">
        <h1>Consulta Pagos 400</h1>
        <p>Multas y Reglamentos - Consulta de Pagos del Sistema AS400 Historico</p>
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
          <div class="btn-group mb-3" role="group">
            <button type="button" class="btn btn-outline-primary" :class="{ active: tipoBusqueda === 'cuenta' }" @click="tipoBusqueda = 'cuenta'">
              <font-awesome-icon icon="user" /> Por Cuenta
            </button>
            <button type="button" class="btn btn-outline-primary" :class="{ active: tipoBusqueda === 'folio' }" @click="tipoBusqueda = 'folio'">
              <font-awesome-icon icon="file-alt" /> Por Folio
            </button>
          </div>

          <div v-if="tipoBusqueda === 'cuenta'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora</label>
                <input type="number" class="municipal-form-control" v-model="filters.recaudadora" placeholder="Recaudadora" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Urbano/Rustico</label>
                <input type="text" class="municipal-form-control" v-model="filters.urbrus" placeholder="U/R" maxlength="1" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Cuenta</label>
                <input type="number" class="municipal-form-control" v-model="filters.cuenta" placeholder="Numero de cuenta" @keyup.enter="buscar" />
              </div>
            </div>
          </div>

          <div v-else>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Ano</label>
                <input type="number" class="municipal-form-control" v-model="filters.axo" placeholder="Ano" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Folio</label>
                <input type="number" class="municipal-form-control" v-model="filters.folio" placeholder="Numero de folio" @keyup.enter="buscar" />
              </div>
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
            <span class="badge-purple" v-if="pagos.length > 0">{{ pagos.length }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Utilice los filtros para buscar pagos del sistema 400</p>
            </div>
          </div>

          <div v-else-if="pagos.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron pagos con los criterios especificados</p>
            </div>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Recaudadora</th>
                  <th>Cuenta</th>
                  <th>Ano</th>
                  <th>Folio</th>
                  <th>Fecha Pago</th>
                  <th>Importe</th>
                  <th>Caja</th>
                  <th>Operacion</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, index) in pagos" :key="index" class="row-hover"
                  :class="{ 'table-row-selected': selectedPago === pago }" @click="selectedPago = pago">
                  <td>{{ pago.recaud }}</td>
                  <td><strong class="text-primary">{{ pago.urbrus }}{{ pago.cuenta }}</strong></td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ formatDate(pago.fecha_pago) }}</td>
                  <td class="text-end">{{ formatCurrency(pago.importe) }}</td>
                  <td>{{ pago.caja }}</td>
                  <td>{{ pago.operacion }}</td>
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

    <DocumentationModal :show="showDocModal" :componentName="'ConsPag400'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Pagos 400'" @close="showDocModal = false" />
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
const tipoBusqueda = ref('cuenta')
const pagos = ref([])
const selectedPago = ref(null)
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ recaudadora: '', urbrus: '', cuenta: '', axo: '', folio: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const buscar = async () => {
  if (tipoBusqueda.value === 'cuenta') {
    if (!filters.value.recaudadora || !filters.value.cuenta) {
      showToast('warning', 'Debe ingresar recaudadora y cuenta')
      return
    }
  } else {
    if (!filters.value.axo || !filters.value.folio) {
      showToast('warning', 'Debe ingresar ano y folio')
      return
    }
  }

  showLoading('Buscando pagos...', 'Consultando sistema 400')
  searchPerformed.value = true

  try {
    const params = tipoBusqueda.value === 'cuenta'
      ? [
          { nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' },
          { nombre: 'p_urbrus', valor: filters.value.urbrus.toUpperCase(), tipo: 'string' },
          { nombre: 'p_cuenta', valor: parseInt(filters.value.cuenta), tipo: 'integer' }
        ]
      : [
          { nombre: 'p_axo', valor: parseInt(filters.value.axo), tipo: 'integer' },
          { nombre: 'p_folio', valor: parseInt(filters.value.folio), tipo: 'integer' }
        ]

    const spName = tipoBusqueda.value === 'cuenta' ? 'sp_conspag400_por_cuenta' : 'sp_conspag400_por_folio'

    const response = await execute(spName, 'multas_reglamentos', params, 'guadalajara', null, 'publico')

    if (response?.result) {
      pagos.value = response.result
      if (pagos.value.length > 0) {
        selectedPago.value = pagos.value[0]
        showToast('success', `Se encontraron ${pagos.value.length} pago(s)`)
      } else {
        showToast('info', 'No se encontraron pagos')
      }
    } else {
      pagos.value = []
      showToast('info', 'No hay pagos')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar pagos')
    pagos.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { recaudadora: '', urbrus: '', cuenta: '', axo: '', folio: '' }
  pagos.value = []
  selectedPago.value = null
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
