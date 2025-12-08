<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Individual de Contrato</h1>
        <p>Aseo Contratado - Modificación de datos de un contrato específico</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Contrato
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <input type="number" class="municipal-form-control" v-model="numContrato"
                placeholder="Ej: 12345" @keyup.enter="buscarContrato" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Cuenta Catastral</label>
              <input type="text" class="municipal-form-control" v-model="cuentaCatastral"
                placeholder="Ej: 123456789012" @keyup.enter="buscarContrato" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarContrato" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarBusqueda" :disabled="loading">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Información del Contrato -->
      <div class="municipal-card" v-if="contrato">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-contract" />
            Contrato #{{ contrato.num_contrato }}
          </h5>
          <span class="badge" :class="contrato.status_vigencia === 'V' ? 'badge-success' : 'badge-secondary'">
            {{ contrato.status_vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
          </span>
        </div>
        <div class="municipal-card-body">
          <div class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">Empresa</label>
              <p class="detail-value">{{ contrato.empresa_descripcion }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Tipo de Aseo</label>
              <p class="detail-value">{{ contrato.tipo_aseo_descripcion }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Zona</label>
              <p class="detail-value">{{ contrato.zona_id }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Monto Mensual</label>
              <p class="detail-value">${{ formatCurrency(contrato.monto_mensual) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Edición -->
      <div class="municipal-card" v-if="contrato && contrato.status_vigencia === 'V'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Actualización de Datos
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Tabs -->
          <div class="municipal-tabs">
            <button class="municipal-tab" :class="{ active: tabActiva === 'servicio' }"
              @click="tabActiva = 'servicio'">
              <font-awesome-icon icon="truck" /> Servicio
            </button>
            <button class="municipal-tab" :class="{ active: tabActiva === 'cuota' }"
              @click="tabActiva = 'cuota'">
              <font-awesome-icon icon="dollar-sign" /> Cuota
            </button>
            <button class="municipal-tab" :class="{ active: tabActiva === 'observaciones' }"
              @click="tabActiva = 'observaciones'">
              <font-awesome-icon icon="sticky-note" /> Observaciones
            </button>
          </div>

          <!-- Tab Servicio -->
          <div class="tab-content" v-show="tabActiva === 'servicio'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Empresa</label>
                <select class="municipal-form-control" v-model="datosEdicion.num_empresa">
                  <option value="">Seleccione...</option>
                  <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                    {{ emp.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Aseo</label>
                <select class="municipal-form-control" v-model="datosEdicion.tipo_aseo_id">
                  <option value="">Seleccione...</option>
                  <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
                    {{ t.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Zona</label>
                <select class="municipal-form-control" v-model="datosEdicion.zona_id">
                  <option value="">Seleccione...</option>
                  <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.ctrol_zona">
                    Zona {{ z.zona }} - {{ z.descripcion || '' }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Unidades Recolección</label>
                <input type="number" class="municipal-form-control" v-model.number="datosEdicion.unidades_recoleccion"
                  min="1" />
              </div>
            </div>
          </div>

          <!-- Tab Cuota -->
          <div class="tab-content" v-show="tabActiva === 'cuota'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Monto Mensual</label>
                <div class="input-with-prefix">
                  <span class="input-prefix">$</span>
                  <input type="number" class="municipal-form-control" v-model.number="datosEdicion.monto_mensual"
                    step="0.01" min="0" />
                </div>
              </div>
            </div>
          </div>

          <!-- Tab Observaciones -->
          <div class="tab-content" v-show="tabActiva === 'observaciones'">
            <div class="form-group">
              <label class="municipal-form-label">Observaciones</label>
              <textarea class="municipal-form-control" v-model="datosEdicion.observaciones" rows="4"
                placeholder="Notas adicionales sobre el contrato..."></textarea>
            </div>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-secondary" @click="cancelarEdicion">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-primary" @click="guardarCambios" :disabled="!hayCambios">
              <font-awesome-icon icon="save" /> Guardar Cambios
            </button>
          </div>
        </div>
      </div>

      <!-- Alerta contrato cancelado -->
      <div class="municipal-card" v-if="contrato && contrato.status_vigencia !== 'V'">
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            Este contrato está <strong>cancelado</strong> y no puede ser modificado.
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'UpdxCont'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  loading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const numContrato = ref('')
const cuentaCatastral = ref('')
const contrato = ref(null)
const contratoOriginal = ref(null)
const tabActiva = ref('servicio')
const zonas = ref([])
const empresas = ref([])
const tiposAseo = ref([])

const datosEdicion = ref({
  num_empresa: '',
  tipo_aseo_id: '',
  zona_id: '',
  unidades_recoleccion: 1,
  monto_mensual: 0,
  observaciones: ''
})

// Computed
const hayCambios = computed(() => {
  if (!contratoOriginal.value) return false
  return datosEdicion.value.num_empresa != contratoOriginal.value.num_empresa ||
         datosEdicion.value.tipo_aseo_id != contratoOriginal.value.tipo_aseo_id ||
         datosEdicion.value.zona_id != contratoOriginal.value.zona_id ||
         datosEdicion.value.unidades_recoleccion != contratoOriginal.value.unidades_recoleccion ||
         datosEdicion.value.monto_mensual != contratoOriginal.value.monto_mensual ||
         datosEdicion.value.observaciones != (contratoOriginal.value.observaciones || '')
})

// Métodos
async function loadCatalogos() {
  try {
    const [respZonas, respEmpresas, respTipos] = await Promise.all([
      execute('sp_zonas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_empresas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    ])
    zonas.value = respZonas?.result || []
    empresas.value = respEmpresas?.result || []
    tiposAseo.value = respTipos?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

async function buscarContrato() {
  if (!numContrato.value && !cuentaCatastral.value) {
    showToast('Ingrese número de contrato o cuenta catastral', 'warning')
    return
  }

  showLoading('Buscando contrato...', 'Consultando base de datos')

  try {
    const params = [
      { nombre: 'p_limit', valor: 500, tipo: 'integer' },
      { nombre: 'p_offset', valor: 0, tipo: 'integer' }
    ]
    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)

    let data = response?.result || []

    // Filtrar por número de contrato o cuenta
    if (numContrato.value) {
      data = data.filter(c => c.num_contrato == parseInt(numContrato.value))
    }

    if (data.length > 0) {
      contrato.value = data[0]
      contratoOriginal.value = JSON.parse(JSON.stringify(data[0]))
      cargarDatosEdicion()
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'warning')
      contrato.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contrato.value = null
  } finally {
    hideLoading()
  }
}

function cargarDatosEdicion() {
  datosEdicion.value = {
    num_empresa: contrato.value.num_empresa || '',
    tipo_aseo_id: contrato.value.tipo_aseo_id || '',
    zona_id: contrato.value.zona_id || '',
    unidades_recoleccion: contrato.value.unidades_recoleccion || 1,
    monto_mensual: parseFloat(contrato.value.monto_mensual || 0),
    observaciones: contrato.value.observaciones || ''
  }
  tabActiva.value = 'servicio'
}

function limpiarBusqueda() {
  numContrato.value = ''
  cuentaCatastral.value = ''
  contrato.value = null
  contratoOriginal.value = null
}

function cancelarEdicion() {
  if (contratoOriginal.value) {
    cargarDatosEdicion()
    showToast('Cambios descartados', 'info')
  }
}

async function guardarCambios() {
  const result = await Swal.fire({
    title: '¿Guardar Cambios?',
    text: 'Se actualizarán los datos del contrato',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Guardando cambios...', 'Actualizando contrato')

  try {
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_num_empresa', valor: datosEdicion.value.num_empresa || null, tipo: 'integer' },
      { nombre: 'p_tipo_aseo_id', valor: datosEdicion.value.tipo_aseo_id || null, tipo: 'integer' },
      { nombre: 'p_zona_id', valor: datosEdicion.value.zona_id || null, tipo: 'integer' },
      { nombre: 'p_unidades_recoleccion', valor: datosEdicion.value.unidades_recoleccion || 1, tipo: 'integer' },
      { nombre: 'p_monto_mensual', valor: datosEdicion.value.monto_mensual || 0, tipo: 'numeric' },
      { nombre: 'p_observaciones', valor: datosEdicion.value.observaciones || '', tipo: 'string' }
    ]

    const response = await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)
    hideLoading()

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'Error al actualizar', 'error')
      return
    }

    await Swal.fire('¡Guardado!', 'Los cambios han sido guardados correctamente', 'success')
    await buscarContrato()
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error)
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando módulo...', 'Iniciando')
  await loadCatalogos()
  hideLoading()
})
</script>

