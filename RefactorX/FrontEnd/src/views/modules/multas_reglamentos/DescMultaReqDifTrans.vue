<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Descuento Multas - Req. Dif. Transmisiones</h1>
        <p>Multas y Reglamentos - Descuento de Multas para Requerimientos de Diferencias de Transmisiones</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
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
            <font-awesome-icon icon="filter" /> Busqueda de Requerimiento
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio de Transmision</label>
              <input type="number" class="municipal-form-control" v-model="filters.folio" placeholder="Numero de folio" @keyup.enter="buscar" />
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
          <h5><font-awesome-icon icon="file-alt" /> Datos del Requerimiento</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Ingrese el folio de transmision para buscar</p>
            </div>
          </div>

          <div v-else-if="!requerimientoData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro requerimiento para esta transmision</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="file-invoice" /> Datos de la Transmision</h6>
                <table class="detail-table">
                  <tr><td class="label">Folio:</td><td><strong class="text-primary">{{ requerimientoData.folio }}</strong></td></tr>
                  <tr><td class="label">Cuenta:</td><td>{{ requerimientoData.cuenta }}</td></tr>
                  <tr><td class="label">Contribuyente:</td><td>{{ requerimientoData.contribuyente || 'N/A' }}</td></tr>
                  <tr><td class="label">Fecha:</td><td>{{ formatDate(requerimientoData.fecha) }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="dollar-sign" /> Adeudos</h6>
                <table class="detail-table">
                  <tr><td class="label">Diferencia:</td><td class="text-end">{{ formatCurrency(requerimientoData.diferencia) }}</td></tr>
                  <tr><td class="label">Recargos:</td><td class="text-end">{{ formatCurrency(requerimientoData.recargos) }}</td></tr>
                  <tr><td class="label">Multas:</td><td class="text-end"><strong class="text-danger">{{ formatCurrency(requerimientoData.multas) }}</strong></td></tr>
                  <tr><td class="label">Total:</td><td class="text-end"><strong>{{ formatCurrency(requerimientoData.total) }}</strong></td></tr>
                </table>
              </div>
            </div>

            <div v-if="requerimientoData.multas > 0 && requerimientoData.vigencia === 'V'" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="percent" /> Aplicar Descuento</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Porcentaje de Descuento</label>
                    <input type="number" class="municipal-form-control" v-model="descuento.porcentaje" min="0" max="100" placeholder="%" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Funcionario</label>
                    <select class="municipal-form-control" v-model="descuento.funcionario">
                      <option value="">Seleccione...</option>
                      <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">
                        {{ func.nombre }} (Max: {{ func.porcentajetope }}%)
                      </option>
                    </select>
                  </div>
                </div>

                <div class="button-group mt-4">
                  <button class="btn-municipal-success" @click="aplicarDescuento" :disabled="loading || !descuento.funcionario">
                    <font-awesome-icon icon="check" /> Aplicar Descuento
                  </button>
                </div>
              </div>
            </div>

            <div v-else-if="requerimientoData.vigencia === 'P'" class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Este requerimiento ya fue pagado
            </div>

            <div v-else-if="requerimientoData.vigencia === 'C'" class="alert alert-warning">
              <font-awesome-icon icon="times-circle" class="me-2" />
              Este requerimiento fue cancelado
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

    <DocumentationModal :show="showDocModal" :componentName="'DescMultaReqDifTrans'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Multas Req. Dif. Trans.'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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
const requerimientoData = ref(null)
const funcionarios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ folio: '' })
const descuento = ref({ porcentaje: 0, funcionario: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const cargarFuncionarios = async () => {
  try {
    const response = await execute('sp_get_funcionarios_autoriza', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (response?.result) funcionarios.value = response.result
  } catch (error) { console.error('Error cargando funcionarios:', error) }
}

const buscar = async () => {
  if (!filters.value.folio) {
    showToast('warning', 'Debe ingresar el folio de transmision')
    return
  }

  showLoading('Buscando requerimiento...', 'Consultando base de datos')
  searchPerformed.value = true
  descuento.value = { porcentaje: 0, funcionario: '' }

  try {
    const response = await execute('sp_descmultareqdiftrans_consulta', 'multas_reglamentos',
      [{ nombre: 'p_folio', valor: parseInt(filters.value.folio), tipo: 'integer' }],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      requerimientoData.value = response.result[0]
      showToast('success', 'Requerimiento encontrado')
    } else {
      requerimientoData.value = null
      showToast('info', 'No se encontro requerimiento')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar requerimiento')
    requerimientoData.value = null
  } finally {
    hideLoading()
  }
}

const aplicarDescuento = async () => {
  const funcSelec = funcionarios.value.find(f => f.cveautoriza === descuento.value.funcionario)

  if (funcSelec && descuento.value.porcentaje > funcSelec.porcentajetope) {
    await Swal.fire({
      icon: 'warning', title: 'Porcentaje excedido',
      text: `El porcentaje maximo permitido es ${funcSelec.porcentajetope}%`,
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirm = await Swal.fire({
    icon: 'question', title: 'Confirmar Descuento',
    html: `<p>Se aplicara descuento del <strong>${descuento.value.porcentaje}%</strong></p>`,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, aplicar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Aplicando descuento...', 'Por favor espere')

  try {
    const response = await execute('sp_descmultareqdiftrans_aplicar', 'multas_reglamentos',
      [
        { nombre: 'p_id_req', valor: requerimientoData.value.id_req, tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: descuento.value.porcentaje, tipo: 'integer' },
        { nombre: 'p_funcionario', valor: descuento.value.funcionario, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({ icon: 'success', title: 'Descuento aplicado', confirmButtonColor: '#ea8215' })
      buscar()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: response?.result?.[0]?.message || 'No se pudo aplicar', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const limpiar = () => {
  filters.value = { folio: '' }
  requerimientoData.value = null
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

onMounted(() => { cargarFuncionarios() })
</script>
