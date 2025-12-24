<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percentage" /></div>
      <div class="module-view-info">
        <h1>Descuento Multas - Licencias</h1>
        <p>Multas y Reglamentos - Aplicacion de Descuentos a Multas de Licencias</p>
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
            <font-awesome-icon icon="filter" /> Busqueda de Licencia
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Numero de Licencia</label>
              <input type="number" class="municipal-form-control" v-model="filters.licencia" placeholder="Numero de licencia" @keyup.enter="buscar" />
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
          <h5><font-awesome-icon icon="id-card" /> Datos de la Licencia</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Ingrese el numero de licencia a consultar</p>
            </div>
          </div>

          <div v-else-if="!licenciaData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro la licencia o no tiene requerimiento activo</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="store" /> Datos de la Licencia</h6>
                <table class="detail-table">
                  <tr><td class="label">Licencia:</td><td><strong class="text-primary">{{ licenciaData.licencia }}</strong></td></tr>
                  <tr><td class="label">Propietario:</td><td>{{ licenciaData.propietario || 'N/A' }}</td></tr>
                  <tr><td class="label">RFC:</td><td>{{ licenciaData.rfc || 'N/A' }}</td></tr>
                  <tr><td class="label">Ubicacion:</td><td>{{ licenciaData.ubicacion || 'N/A' }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="file-invoice" /> Datos del Requerimiento</h6>
                <table class="detail-table">
                  <tr><td class="label">Folio Req:</td><td>{{ licenciaData.folio_req || 'N/A' }}</td></tr>
                  <tr><td class="label">Multas:</td><td class="text-end text-danger"><strong>{{ formatCurrency(licenciaData.multas) }}</strong></td></tr>
                  <tr><td class="label">Total Req:</td><td class="text-end"><strong>{{ formatCurrency(licenciaData.total_req) }}</strong></td></tr>
                </table>
              </div>
            </div>

            <div v-if="descuentoExistente" class="alert alert-info mb-4">
              <font-awesome-icon icon="info-circle" class="me-2" />
              <strong>Descuento existente:</strong> {{ descuentoExistente.porcentaje }}% aplicado el {{ formatDate(descuentoExistente.fecha) }}
              <span class="badge ms-2" :class="getBadgeClass(descuentoExistente.vigencia)">
                {{ getEstadoText(descuentoExistente.vigencia) }}
              </span>
              <button v-if="descuentoExistente.vigencia === 'V'" class="btn btn-sm btn-danger ms-3" @click="cancelarDescuento">
                <font-awesome-icon icon="times" /> Cancelar Descuento
              </button>
            </div>

            <div v-if="licenciaData.multas > 0 && (!descuentoExistente || descuentoExistente.vigencia !== 'V')" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="percent" /> Aplicar Nuevo Descuento</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Porcentaje de Descuento</label>
                    <input type="number" class="municipal-form-control" v-model="descuento.porcentaje" min="1" max="100" placeholder="%" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Funcionario que Autoriza</label>
                    <select class="municipal-form-control" v-model="descuento.funcionario">
                      <option value="">Seleccione...</option>
                      <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">
                        {{ func.nombre }} (Max: {{ func.porcentajetope }}%)
                      </option>
                    </select>
                  </div>
                </div>

                <div v-if="descuento.porcentaje > 0" class="alert alert-warning mt-3">
                  <strong>Monto de descuento:</strong> {{ formatCurrency(montoDescuento) }}
                  <br>
                  <strong>Nuevo total multas:</strong> {{ formatCurrency(nuevoTotalMultas) }}
                </div>

                <div class="button-group mt-4">
                  <button class="btn-municipal-success" @click="aplicarDescuento" :disabled="loading || !descuento.funcionario || descuento.porcentaje <= 0">
                    <font-awesome-icon icon="check" /> Aplicar Descuento
                  </button>
                </div>
              </div>
            </div>

            <div v-else-if="licenciaData.multas <= 0" class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Esta licencia no tiene multas pendientes
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

    <DocumentationModal :show="showDocModal" :componentName="'descmultalic'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Multas Licencias'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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
const licenciaData = ref(null)
const descuentoExistente = ref(null)
const funcionarios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ licencia: '' })
const descuento = ref({ porcentaje: 0, funcionario: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const montoDescuento = computed(() => {
  if (!licenciaData.value || descuento.value.porcentaje <= 0) return 0
  return licenciaData.value.multas * (descuento.value.porcentaje / 100)
})

const nuevoTotalMultas = computed(() => {
  if (!licenciaData.value) return 0
  return licenciaData.value.multas - montoDescuento.value
})

const cargarFuncionarios = async () => {
  try {
    const response = await execute('sp_get_funcionarios_autoriza', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (response?.result) funcionarios.value = response.result
  } catch (error) {
    console.error('Error cargando funcionarios:', error)
  }
}

const buscar = async () => {
  if (!filters.value.licencia) {
    showToast('warning', 'Debe ingresar el numero de licencia')
    return
  }

  showLoading('Buscando licencia...', 'Consultando base de datos')
  searchPerformed.value = true
  descuento.value = { porcentaje: 0, funcionario: '' }
  descuentoExistente.value = null

  try {
    const response = await execute('sp_descmultalic_consulta', 'multas_reglamentos',
      [{ nombre: 'p_licencia', valor: parseInt(filters.value.licencia), tipo: 'integer' }],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      licenciaData.value = response.result[0]

      // Buscar descuento existente
      const descResp = await execute('sp_descmultalic_descuento', 'multas_reglamentos',
        [{ nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' }],
        'guadalajara', null, 'publico')

      if (descResp?.result?.[0]) {
        descuentoExistente.value = descResp.result[0]
      }

      showToast('success', 'Licencia encontrada')
    } else {
      licenciaData.value = null
      showToast('info', 'No se encontro la licencia o no tiene requerimiento')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar licencia')
    licenciaData.value = null
  } finally {
    hideLoading()
  }
}

const aplicarDescuento = async () => {
  const funcSelec = funcionarios.value.find(f => f.cveautoriza === descuento.value.funcionario)

  if (funcSelec && descuento.value.porcentaje > funcSelec.porcentajetope) {
    await Swal.fire({
      icon: 'warning', title: 'Porcentaje excedido',
      text: `El porcentaje maximo permitido por ${funcSelec.nombre} es ${funcSelec.porcentajetope}%`,
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirm = await Swal.fire({
    icon: 'question', title: 'Confirmar Descuento',
    html: `
      <p>Se aplicara descuento del <strong>${descuento.value.porcentaje}%</strong> a la licencia <strong>${licenciaData.value.licencia}</strong></p>
      <p>Monto: <strong>${formatCurrency(montoDescuento.value)}</strong></p>
    `,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, aplicar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Aplicando descuento...', 'Por favor espere')

  try {
    const response = await execute('sp_descmultalic_aplicar', 'multas_reglamentos',
      [
        { nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: descuento.value.porcentaje, tipo: 'integer' },
        { nombre: 'p_funcionario', valor: descuento.value.funcionario, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({ icon: 'success', title: 'Descuento aplicado', text: `Folio: ${response.result[0].id_descto || 'N/A'}`, confirmButtonColor: '#ea8215' })
      buscar()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: response?.result?.[0]?.message || 'No se pudo aplicar', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const cancelarDescuento = async () => {
  const confirm = await Swal.fire({
    icon: 'warning', title: 'Cancelar Descuento',
    text: 'Esta seguro de cancelar el descuento vigente?',
    showCancelButton: true, confirmButtonColor: '#dc3545', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, cancelar', cancelButtonText: 'No'
  })

  if (!confirm.isConfirmed) return

  showLoading('Cancelando descuento...', 'Por favor espere')

  try {
    const response = await execute('sp_descmultalic_cancelar', 'multas_reglamentos',
      [
        { nombre: 'p_id_descto', valor: descuentoExistente.value.id_descto, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({ icon: 'success', title: 'Descuento cancelado', confirmButtonColor: '#ea8215' })
      buscar()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo cancelar', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cancelar descuento')
  }
}

const limpiar = () => {
  filters.value = { licencia: '' }
  licenciaData.value = null
  descuentoExistente.value = null
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
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

onMounted(() => { cargarFuncionarios() })
</script>
