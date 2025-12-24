<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="times-circle" /></div>
      <div class="module-view-info">
        <h1>Cancelacion de Recibos</h1>
        <p>Multas y Reglamentos - Cancelacion de Recibos de Pago</p>
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
            <font-awesome-icon icon="filter" /> Busqueda de Recibo
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input type="number" class="municipal-form-control" v-model="filters.recaudadora" placeholder="Recaudadora" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <input type="text" class="municipal-form-control" v-model="filters.caja" placeholder="Caja" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input type="number" class="municipal-form-control" v-model="filters.folio" placeholder="Folio" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaPago" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Importe</label>
              <input type="number" step="0.01" class="municipal-form-control" v-model="filters.importe" placeholder="Importe" @keyup.enter="buscar" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar Recibo
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
          <h5><font-awesome-icon icon="receipt" /> Datos del Recibo</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Ingrese los datos del recibo a buscar</p>
            </div>
          </div>

          <div v-else-if="!reciboData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro el recibo con los datos especificados</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="receipt" /> Informacion del Recibo</h6>
                <table class="detail-table">
                  <tr><td class="label">Folio:</td><td><strong class="text-primary">{{ reciboData.folio }}</strong></td></tr>
                  <tr><td class="label">Fecha Pago:</td><td>{{ formatDate(reciboData.fecha_pago) }}</td></tr>
                  <tr><td class="label">Recaudadora:</td><td>{{ reciboData.recaud }}</td></tr>
                  <tr><td class="label">Caja:</td><td>{{ reciboData.caja }}</td></tr>
                  <tr><td class="label">Operacion:</td><td>{{ reciboData.operacion }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="dollar-sign" /> Importes</h6>
                <table class="detail-table">
                  <tr><td class="label">Importe:</td><td class="text-end"><strong>{{ formatCurrency(reciboData.importe) }}</strong></td></tr>
                  <tr><td class="label">Concepto:</td><td>{{ reciboData.concepto || 'N/A' }}</td></tr>
                  <tr>
                    <td class="label">Estado:</td>
                    <td>
                      <span class="badge" :class="reciboData.cancelado ? 'badge-danger' : 'badge-success'">
                        {{ reciboData.cancelado ? 'Cancelado' : 'Vigente' }}
                      </span>
                    </td>
                  </tr>
                </table>
              </div>
            </div>

            <div v-if="!reciboData.cancelado" class="button-group">
              <button class="btn-municipal-danger" @click="confirmarCancelacion" :disabled="loading">
                <font-awesome-icon icon="times-circle" /> Cancelar Recibo
              </button>
            </div>

            <div v-else class="alert alert-warning">
              <font-awesome-icon icon="exclamation-triangle" class="me-2" />
              Este recibo ya fue cancelado el {{ formatDate(reciboData.fecha_cancelacion) }} por {{ reciboData.usuario_cancela }}
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

    <DocumentationModal :show="showDocModal" :componentName="'cancelarecibo'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Cancelacion de Recibos'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const reciboData = ref(null)
const showDocModal = ref(false)
const docType = ref('ayuda')

const today = new Date().toISOString().split('T')[0]
const filters = ref({ recaudadora: '', caja: '', folio: '', fechaPago: today, importe: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const buscar = async () => {
  if (!filters.value.recaudadora || !filters.value.caja || !filters.value.folio) {
    showToast('warning', 'Debe ingresar recaudadora, caja y folio')
    return
  }

  showLoading('Buscando recibo...', 'Consultando base de datos')
  searchPerformed.value = true

  try {
    const response = await execute('sp_cancelarecibo_consulta', 'multas_reglamentos',
      [
        { nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' },
        { nombre: 'p_caja', valor: filters.value.caja, tipo: 'string' },
        { nombre: 'p_folio', valor: parseInt(filters.value.folio), tipo: 'integer' },
        { nombre: 'p_fecha', valor: filters.value.fechaPago, tipo: 'date' },
        { nombre: 'p_importe', valor: filters.value.importe ? parseFloat(filters.value.importe) : null, tipo: 'numeric' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      reciboData.value = response.result[0]
      showToast('success', 'Recibo encontrado')
    } else {
      reciboData.value = null
      showToast('info', 'No se encontro el recibo')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar recibo')
    reciboData.value = null
  } finally {
    hideLoading()
  }
}

const confirmarCancelacion = async () => {
  const { value: motivo } = await Swal.fire({
    title: 'Cancelar Recibo',
    html: `
      <p>Esta seguro de cancelar el recibo <strong>${reciboData.value.folio}</strong>?</p>
      <p class="text-danger">Esta accion no se puede deshacer.</p>
    `,
    input: 'textarea',
    inputLabel: 'Motivo de cancelacion',
    inputPlaceholder: 'Ingrese el motivo de la cancelacion...',
    inputValidator: (value) => {
      if (!value?.trim()) return 'Debe ingresar el motivo de cancelacion'
    },
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Cancelar Recibo',
    cancelButtonText: 'No, volver'
  })

  if (!motivo) return

  showLoading('Cancelando recibo...', 'Por favor espere')

  try {
    const response = await execute('sp_cancelarecibo_cancelar', 'multas_reglamentos',
      [
        { nombre: 'p_id_pago', valor: reciboData.value.id_pago, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({
        icon: 'success', title: 'Recibo cancelado',
        text: 'El recibo ha sido cancelado exitosamente',
        confirmButtonColor: '#ea8215', timer: 2000
      })
      buscar()
    } else {
      await Swal.fire({
        icon: 'error', title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo cancelar el recibo',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cancelar recibo')
  }
}

const limpiar = () => {
  filters.value = { recaudadora: '', caja: '', folio: '', fechaPago: today, importe: '' }
  reciboData.value = null
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
