<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuento Multas - Otras Obligaciones</h1>
        <p>Multas y Reglamentos - Descuento de Multas para Otras Obligaciones</p>
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
            <font-awesome-icon icon="filter" /> Busqueda de Obligacion
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Obligacion</label>
              <select class="municipal-form-control" v-model="filters.tipoObligacion">
                <option value="">Seleccione...</option>
                <option value="G">Gastos</option>
                <option value="A">Aseo</option>
                <option value="O">Otros</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Numero de Control</label>
              <input type="number" class="municipal-form-control" v-model="filters.control" placeholder="Numero de control" @keyup.enter="buscar" />
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
          <h5><font-awesome-icon icon="file-invoice-dollar" /> Datos de la Obligacion</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione tipo de obligacion e ingrese el numero de control</p>
            </div>
          </div>

          <div v-else-if="!obligacionData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro la obligacion con los datos especificados</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="file-alt" /> Informacion General</h6>
                <table class="detail-table">
                  <tr><td class="label">Control:</td><td><strong class="text-primary">{{ obligacionData.control }}</strong></td></tr>
                  <tr><td class="label">Tipo:</td><td>{{ getTipoNombre(obligacionData.tipo) }}</td></tr>
                  <tr><td class="label">Nombre:</td><td>{{ obligacionData.nombre || 'N/A' }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="dollar-sign" /> Adeudos</h6>
                <table class="detail-table">
                  <tr><td class="label">Multas:</td><td class="text-end"><strong class="text-danger">{{ formatCurrency(obligacionData.multas) }}</strong></td></tr>
                  <tr><td class="label">Recargos:</td><td class="text-end">{{ formatCurrency(obligacionData.recargos) }}</td></tr>
                  <tr><td class="label">Total:</td><td class="text-end"><strong>{{ formatCurrency(obligacionData.total) }}</strong></td></tr>
                </table>
              </div>
            </div>

            <div v-if="obligacionData.multas > 0" class="municipal-card">
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
                    <label class="municipal-form-label">Funcionario que Autoriza</label>
                    <select class="municipal-form-control" v-model="descuento.funcionario">
                      <option value="">Seleccione...</option>
                      <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">
                        {{ func.nombre }}
                      </option>
                    </select>
                  </div>
                </div>

                <div v-if="descuento.porcentaje > 0" class="alert alert-info mt-3">
                  <strong>Monto de descuento:</strong> {{ formatCurrency(montoDescuento) }}
                  <br>
                  <strong>Nuevo total:</strong> {{ formatCurrency(nuevoTotal) }}
                </div>

                <div class="button-group mt-4">
                  <button class="btn-municipal-success" @click="aplicarDescuento" :disabled="loading || !descuento.funcionario || descuento.porcentaje <= 0">
                    <font-awesome-icon icon="check" /> Aplicar Descuento
                  </button>
                </div>
              </div>
            </div>

            <div v-else class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Esta obligacion no tiene multas pendientes
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

    <DocumentationModal :show="showDocModal" :componentName="'DMultaOtrasObligaciones'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Multas Otras Obligaciones'" @close="showDocModal = false" />
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
const obligacionData = ref(null)
const funcionarios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ tipoObligacion: '', control: '' })
const descuento = ref({ porcentaje: 0, funcionario: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const montoDescuento = computed(() => {
  if (!obligacionData.value || descuento.value.porcentaje <= 0) return 0
  return obligacionData.value.multas * (descuento.value.porcentaje / 100)
})

const nuevoTotal = computed(() => {
  if (!obligacionData.value) return 0
  return obligacionData.value.total - montoDescuento.value
})

const getTipoNombre = (tipo) => {
  const tipos = { G: 'Gastos', A: 'Aseo', O: 'Otros' }
  return tipos[tipo] || tipo
}

const cargarFuncionarios = async () => {
  try {
    const response = await execute('sp_get_funcionarios_autoriza', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (response?.result) funcionarios.value = response.result
  } catch (error) {
    console.error('Error cargando funcionarios:', error)
  }
}

const buscar = async () => {
  if (!filters.value.tipoObligacion || !filters.value.control) {
    showToast('warning', 'Debe seleccionar tipo e ingresar numero de control')
    return
  }

  showLoading('Buscando obligacion...', 'Consultando base de datos')
  searchPerformed.value = true
  descuento.value = { porcentaje: 0, funcionario: '' }

  try {
    const response = await execute('sp_dmultaotras_consulta', 'multas_reglamentos',
      [
        { nombre: 'p_tipo', valor: filters.value.tipoObligacion, tipo: 'string' },
        { nombre: 'p_control', valor: parseInt(filters.value.control), tipo: 'integer' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      obligacionData.value = response.result[0]
      showToast('success', 'Obligacion encontrada')
    } else {
      obligacionData.value = null
      showToast('info', 'No se encontro la obligacion')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar obligacion')
    obligacionData.value = null
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
      <p>Se aplicara un descuento del <strong>${descuento.value.porcentaje}%</strong></p>
      <p>Monto: <strong>${formatCurrency(montoDescuento.value)}</strong></p>
      <p>Nuevo total: <strong>${formatCurrency(nuevoTotal.value)}</strong></p>
    `,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, aplicar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Aplicando descuento...', 'Por favor espere')

  try {
    const response = await execute('sp_dmultaotras_aplicar', 'multas_reglamentos',
      [
        { nombre: 'p_control', valor: obligacionData.value.id_control, tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: descuento.value.porcentaje, tipo: 'integer' },
        { nombre: 'p_funcionario', valor: descuento.value.funcionario, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({
        icon: 'success', title: 'Descuento aplicado',
        text: `Folio de descuento: ${response.result[0].folio || 'N/A'}`,
        confirmButtonColor: '#ea8215'
      })
      buscar()
    } else {
      await Swal.fire({
        icon: 'error', title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo aplicar el descuento',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const limpiar = () => {
  filters.value = { tipoObligacion: '', control: '' }
  obligacionData.value = null
  descuento.value = { porcentaje: 0, funcionario: '' }
  searchPerformed.value = false
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

onMounted(() => { cargarFuncionarios() })
</script>
