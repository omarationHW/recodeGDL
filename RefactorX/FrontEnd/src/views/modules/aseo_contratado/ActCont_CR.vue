<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="sync-alt" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Masiva de Contratos</h1>
        <p>Aseo Contratado - Cambio de recargos y actualizaciones masivas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selección de Operación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="tasks" /> Tipo de Actualización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Operación a Realizar <span class="required">*</span></label>
              <select v-model="tipoOperacion" class="municipal-form-control" @change="cambiarOperacion">
                <option value="">Seleccione una operación...</option>
                <option value="CAMBIO_RECARGO">Cambio Masivo de Recargos</option>
                <option value="ACTUALIZAR_PERIODO">Actualizar Periodo de Contratos</option>
                <option value="CAMBIAR_UNIDADES">Cambiar Unidades de Recolección</option>
                <option value="ACTIVAR_CONTRATOS">Activar Contratos (Nuevo a Vigente)</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Cambio de Recargos -->
      <div v-if="tipoOperacion === 'CAMBIO_RECARGO'" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="percent" /> Cambio Masivo de Recargos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning mb-3">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Advertencia:</strong> Esta operación actualizará los porcentajes de recargos para todos los contratos seleccionados.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="">Todos</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status de Contratos</label>
              <select v-model="filtros.status" class="municipal-form-control">
                <option value="V">Solo Vigentes</option>
                <option value="N">Solo Nuevos</option>
                <option value="">Todos</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio Fiscal <span class="required">*</span></label>
              <input type="number" v-model.number="parametros.ejercicio" class="municipal-form-control"
                :min="currentYear - 1" :max="currentYear + 1" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Mes Inicial <span class="required">*</span></label>
              <select v-model="parametros.mes_inicial" class="municipal-form-control">
                <option v-for="mes in 12" :key="mes" :value="mes">
                  {{ getNombreMes(mes) }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes Final <span class="required">*</span></label>
              <select v-model="parametros.mes_final" class="municipal-form-control">
                <option v-for="mes in 12" :key="mes" :value="mes">
                  {{ getNombreMes(mes) }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-info" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon icon="eye" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon icon="sync-alt" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Actualizar Periodo -->
      <div v-if="tipoOperacion === 'ACTUALIZAR_PERIODO'" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Actualizar Periodo de Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-info mb-3">
            <font-awesome-icon icon="info-circle" />
            Esta operación permite extender o modificar el periodo de vigencia de contratos.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nueva Fecha de Inicio <span class="required">*</span></label>
              <input type="date" v-model="parametros.nuevo_inicio" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Fecha de Fin <span class="required">*</span></label>
              <input type="date" v-model="parametros.nuevo_fin" class="municipal-form-control" />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-info" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon icon="eye" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon icon="sync-alt" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Cambiar Unidades -->
      <div v-if="tipoOperacion === 'CAMBIAR_UNIDADES'" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="truck" /> Cambiar Unidades de Recolección</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-info mb-3">
            <font-awesome-icon icon="info-circle" />
            Cambie las unidades de recolección de múltiples contratos simultáneamente.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Unidades Origen <span class="required">*</span></label>
              <input type="number" v-model.number="parametros.unidad_origen" class="municipal-form-control"
                placeholder="Cantidad actual" min="1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Unidades Destino <span class="required">*</span></label>
              <input type="number" v-model.number="parametros.unidad_destino" class="municipal-form-control"
                placeholder="Nueva cantidad" min="1" />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-info" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon icon="eye" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon icon="sync-alt" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Activar Contratos -->
      <div v-if="tipoOperacion === 'ACTIVAR_CONTRATOS'" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle" /> Activar Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-success mb-3">
            <font-awesome-icon icon="info-circle" />
            Cambie el status de contratos de "Nuevo" a "Vigente" de forma masiva.
          </div>

          <div class="button-group">
            <button class="btn-municipal-info" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon icon="eye" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon icon="check-circle" /> Activar Contratos
            </button>
          </div>
        </div>
      </div>

      <!-- Vista Previa de Contratos Afectados -->
      <div v-if="contratosAfectados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Contratos que Serán Afectados
            <span class="badge-info">{{ contratosAfectados.length }} registros</span>
          </h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 400px;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Tipo Aseo</th>
                  <th>Zona</th>
                  <th class="text-end">Monto</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratosAfectados" :key="contrato.control_contrato">
                  <td><code>{{ contrato.num_contrato }}</code></td>
                  <td>{{ contrato.empresa_descripcion }}</td>
                  <td>{{ contrato.tipo_aseo_descripcion }}</td>
                  <td class="text-center">{{ contrato.zona_id }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.monto_mensual) }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getStatusClass(contrato.status_vigencia)">
                      {{ getStatusLabel(contrato.status_vigencia) }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Resultado de la Operación -->
      <div v-if="resultado" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" />
            {{ resultado.success ? 'Operación Completada' : 'Error en Operación' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div :class="resultado.success ? 'municipal-alert municipal-alert-success' : 'municipal-alert municipal-alert-danger'">
            <strong>{{ resultado.message }}</strong>
          </div>
          <div v-if="resultado.success" class="detail-grid mt-3">
            <div class="detail-item">
              <label class="detail-label">Contratos Procesados</label>
              <p class="detail-value">{{ resultado.contratos_procesados }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Actualizaciones Exitosas</label>
              <p class="detail-value">{{ resultado.actualizaciones_exitosas }}</p>
            </div>
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
    :componentName="'ActCont_CR'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

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

const tipoOperacion = ref('')
const tiposAseo = ref([])
const contratosAfectados = ref([])
const resultado = ref(null)
const currentYear = new Date().getFullYear()

const filtros = ref({
  tipo_aseo: '',
  status: 'V'
})

const parametros = ref({
  ejercicio: currentYear,
  mes_inicial: 1,
  mes_final: 12,
  nuevo_inicio: '',
  nuevo_fin: '',
  unidad_origen: 1,
  unidad_destino: 1
})

// Métodos
function cambiarOperacion() {
  contratosAfectados.value = []
  resultado.value = null
}

async function cargarCatalogos() {
  try {
    const response = await execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    tiposAseo.value = response?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

async function previsualizarContratos() {
  showLoading('Cargando contratos...', 'Consultando base de datos')

  try {
    const params = [
      { nombre: 'p_limit', valor: 500, tipo: 'integer' },
      { nombre: 'p_offset', valor: 0, tipo: 'integer' }
    ]
    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)

    let data = response?.result || []

    // Filtros según tipo de operación
    if (filtros.value.status) {
      data = data.filter(c => c.status_vigencia === filtros.value.status)
    }

    if (filtros.value.tipo_aseo) {
      data = data.filter(c => c.tipo_aseo_id == filtros.value.tipo_aseo)
    }

    // Filtro especial para activar contratos (solo nuevos)
    if (tipoOperacion.value === 'ACTIVAR_CONTRATOS') {
      data = data.filter(c => c.status_vigencia === 'N')
    }

    // Filtro para cambiar unidades
    if (tipoOperacion.value === 'CAMBIAR_UNIDADES' && parametros.value.unidad_origen) {
      data = data.filter(c => c.unidades_recoleccion == parametros.value.unidad_origen)
    }

    contratosAfectados.value = data

    if (contratosAfectados.value.length === 0) {
      showToast('No se encontraron contratos para los criterios seleccionados', 'info')
    } else {
      showToast(`Se encontraron ${contratosAfectados.value.length} contratos`, 'success')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contratosAfectados.value = []
  } finally {
    hideLoading()
  }
}

async function ejecutarActualizacion() {
  if (contratosAfectados.value.length === 0) {
    showToast('No hay contratos para actualizar', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Ejecutar Actualización Masiva?',
    html: `<p>Se actualizarán <strong>${contratosAfectados.value.length} contratos</strong></p>
           <p class="text-warning">Esta operación no es reversible automáticamente</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, ejecutar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Ejecutando actualización...', 'Procesando contratos')

  try {
    let actualizados = 0
    let errores = 0

    for (const contrato of contratosAfectados.value) {
      try {
        const params = buildUpdateParams(contrato)
        await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)
        actualizados++
      } catch (e) {
        hideLoading()
        errores++
      }
    }

    hideLoading()

    resultado.value = {
      success: errores === 0,
      message: errores === 0 ? 'Actualización completada exitosamente' : `Completado con ${errores} error(es)`,
      contratos_procesados: contratosAfectados.value.length,
      actualizaciones_exitosas: actualizados
    }

    await Swal.fire(
      '¡Proceso completado!',
      `Actualizados: ${actualizados}, Errores: ${errores}`,
      errores === 0 ? 'success' : 'warning'
    )

    if (errores === 0) {
      contratosAfectados.value = []
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error)
    resultado.value = {
      success: false,
      message: error.message || 'Error desconocido',
      contratos_procesados: 0,
      actualizaciones_exitosas: 0
    }
  }
}

function buildUpdateParams(contrato) {
  const baseParams = [
    { nombre: 'p_control_contrato', valor: contrato.control_contrato, tipo: 'integer' },
    { nombre: 'p_num_empresa', valor: contrato.num_empresa, tipo: 'integer' },
    { nombre: 'p_tipo_aseo_id', valor: contrato.tipo_aseo_id, tipo: 'integer' },
    { nombre: 'p_zona_id', valor: contrato.zona_id, tipo: 'integer' }
  ]

  switch (tipoOperacion.value) {
    case 'CAMBIAR_UNIDADES':
      baseParams.push({ nombre: 'p_unidades_recoleccion', valor: parametros.value.unidad_destino, tipo: 'integer' })
      baseParams.push({ nombre: 'p_monto_mensual', valor: contrato.monto_mensual, tipo: 'numeric' })
      baseParams.push({ nombre: 'p_observaciones', valor: `Cambio unidades: ${parametros.value.unidad_origen} -> ${parametros.value.unidad_destino}`, tipo: 'string' })
      break

    case 'ACTIVAR_CONTRATOS':
      baseParams.push({ nombre: 'p_unidades_recoleccion', valor: contrato.unidades_recoleccion || 1, tipo: 'integer' })
      baseParams.push({ nombre: 'p_monto_mensual', valor: contrato.monto_mensual, tipo: 'numeric' })
      baseParams.push({ nombre: 'p_observaciones', valor: 'Contrato activado masivamente', tipo: 'string' })
      break

    default:
      baseParams.push({ nombre: 'p_unidades_recoleccion', valor: contrato.unidades_recoleccion || 1, tipo: 'integer' })
      baseParams.push({ nombre: 'p_monto_mensual', valor: contrato.monto_mensual, tipo: 'numeric' })
      baseParams.push({ nombre: 'p_observaciones', valor: `Actualización masiva: ${tipoOperacion.value}`, tipo: 'string' })
  }

  return baseParams
}

function getNombreMes(mes) {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[mes - 1]
}

function getStatusLabel(status) {
  const labels = { V: 'Vigente', N: 'Nuevo', B: 'Baja', C: 'Cancelado' }
  return labels[status] || status
}

function getStatusClass(status) {
  const classes = { V: 'badge-success', N: 'badge-info', B: 'badge-warning', C: 'badge-secondary' }
  return classes[status] || 'badge-secondary'
}

function formatCurrency(value) {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando módulo...', 'Iniciando')
  await cargarCatalogos()
  hideLoading()
})
</script>

