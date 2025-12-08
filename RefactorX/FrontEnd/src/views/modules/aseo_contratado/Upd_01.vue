<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="wrench" />
      </div>
      <div class="module-view-info">
        <h1>Actualización General de Contratos</h1>
        <p>Aseo Contratado - Modificación masiva de datos de contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Paso 1: Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Paso 1: Selección de Contratos
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <select class="municipal-form-control" v-model="filtros.zona">
                <option value="">Todas</option>
                <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                  Zona {{ z.zona }} - {{ z.descripcion || '' }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select class="municipal-form-control" v-model="filtros.tipoAseo">
                <option value="">Todos</option>
                <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
                  {{ t.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Empresa</label>
              <select class="municipal-form-control" v-model="filtros.empresa">
                <option value="">Todas</option>
                <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                  {{ emp.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Contrato Desde</label>
              <input type="number" class="municipal-form-control" v-model="filtros.contratoDesde" placeholder="Desde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Contrato Hasta</label>
              <input type="number" class="municipal-form-control" v-model="filtros.contratoHasta" placeholder="Hasta" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarContratos" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
            <button class="btn-municipal-secondary" @click="buscarContratos" :disabled="loading">
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de contratos -->
      <div class="municipal-card" v-if="contratos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Contratos para Actualizar
            <span class="badge-info">{{ contratos.length }} registros</span>
          </h5>
          <div class="button-group">
            <button class="btn-municipal-primary btn-sm" @click="seleccionarTodos">
              <font-awesome-icon icon="check-double" /> Todos
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="limpiarSeleccion">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" v-model="seleccionarTodo" @change="toggleSeleccionTodos" />
                  </th>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Zona</th>
                  <th>Tipo Aseo</th>
                  <th class="text-end">Monto</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                    :class="{ 'row-selected': contratosSeleccionados.includes(contrato.control_contrato) }">
                  <td>
                    <input type="checkbox" :value="contrato.control_contrato" v-model="contratosSeleccionados" />
                  </td>
                  <td><code>{{ contrato.num_contrato }}</code></td>
                  <td>{{ contrato.empresa_descripcion }}</td>
                  <td class="text-center">{{ contrato.zona_id }}</td>
                  <td>{{ contrato.tipo_aseo_descripcion }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.monto_mensual) }}</td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status_vigencia === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ contrato.status_vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay contratos -->
      <div class="municipal-card" v-if="buscado && contratos.length === 0">
        <div class="municipal-card-body text-center">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron contratos con los filtros seleccionados</p>
        </div>
      </div>

      <!-- Paso 2: Configurar actualizaciones -->
      <div class="municipal-card" v-if="contratosSeleccionados.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Paso 2: Configurar Actualizaciones
            <span class="badge-warning">{{ contratosSeleccionados.length }} seleccionados</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning mb-3">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Importante:</strong> Solo se aplicarán los campos que tengan valor. Deje en blanco los que no desea modificar.
          </div>

          <!-- Cambios de Empresa y Zona -->
          <h6 class="section-title">Cambios de Empresa y Zona</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nueva Empresa</label>
              <select class="municipal-form-control" v-model="actualizaciones.empresa">
                <option value="">No modificar</option>
                <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                  {{ emp.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Zona</label>
              <select class="municipal-form-control" v-model="actualizaciones.zona">
                <option value="">No modificar</option>
                <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.ctrol_zona">
                  Zona {{ z.zona }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Unidad Recolectora</label>
              <select class="municipal-form-control" v-model="actualizaciones.unidad">
                <option value="">No modificar</option>
                <option v-for="u in unidades" :key="u.control_contrato" :value="u.control_contrato">
                  {{ u.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Tipo de Aseo</label>
              <select class="municipal-form-control" v-model="actualizaciones.tipoAseo">
                <option value="">No modificar</option>
                <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
                  {{ t.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Ajustes de Cuota -->
          <h6 class="section-title">Ajustes de Cuota</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Ajuste</label>
              <select class="municipal-form-control" v-model="actualizaciones.tipoAjusteCuota">
                <option value="">No ajustar cuota</option>
                <option value="FIJA">Cuota fija</option>
                <option value="PORCENTAJE">Porcentaje de incremento</option>
                <option value="MONTO">Incremento por monto</option>
              </select>
            </div>
            <div class="form-group" v-if="actualizaciones.tipoAjusteCuota === 'FIJA'">
              <label class="municipal-form-label">Nueva Cuota Mensual</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.cuotaFija"
                step="0.01" min="0" placeholder="0.00" />
            </div>
            <div class="form-group" v-if="actualizaciones.tipoAjusteCuota === 'PORCENTAJE'">
              <label class="municipal-form-label">Porcentaje (%)</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.porcentajeIncremento"
                step="0.01" min="0" max="100" placeholder="0.00" />
            </div>
            <div class="form-group" v-if="actualizaciones.tipoAjusteCuota === 'MONTO'">
              <label class="municipal-form-label">Monto a Incrementar</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.montoIncremento"
                step="0.01" min="0" placeholder="0.00" />
            </div>
          </div>

          <!-- Información Adicional -->
          <h6 class="section-title">Información Adicional</h6>
          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Motivo de la Actualización <span class="required">*</span></label>
              <input type="text" class="municipal-form-control" v-model="actualizaciones.motivo"
                placeholder="Ej: Reorganización de zonas y ajuste de tarifas 2024" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Aplicación <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="actualizaciones.fechaAplicacion" />
            </div>
          </div>

          <!-- Previsualización -->
          <div v-if="previsualizacion && tieneAlgunCambio" class="municipal-alert municipal-alert-info">
            <h6><font-awesome-icon icon="eye" /> Previsualización de Cambios:</h6>
            <ul class="mb-0">
              <li v-if="actualizaciones.empresa">Empresa cambiará a: <strong>{{ obtenerNombreEmpresa(actualizaciones.empresa) }}</strong></li>
              <li v-if="actualizaciones.zona">Zona cambiará a: <strong>{{ obtenerNombreZona(actualizaciones.zona) }}</strong></li>
              <li v-if="actualizaciones.unidad">Unidad cambiará a: <strong>{{ obtenerNombreUnidad(actualizaciones.unidad) }}</strong></li>
              <li v-if="actualizaciones.tipoAseo">Tipo de aseo cambiará a: <strong>{{ obtenerNombreTipoAseo(actualizaciones.tipoAseo) }}</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'FIJA'">Cuota se establecerá en: <strong>${{ formatCurrency(actualizaciones.cuotaFija) }}</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'PORCENTAJE'">Cuota se incrementará en: <strong>{{ actualizaciones.porcentajeIncremento }}%</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'MONTO'">Cuota se incrementará en: <strong>${{ formatCurrency(actualizaciones.montoIncremento) }}</strong></li>
            </ul>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-info" @click="previsualizacion = !previsualizacion">
              <font-awesome-icon icon="eye" /> {{ previsualizacion ? 'Ocultar' : 'Ver' }} Previsualización
            </button>
            <button class="btn-municipal-primary" @click="aplicarActualizaciones"
              :disabled="!validarActualizacion()">
              <font-awesome-icon icon="save" /> Aplicar Actualizaciones
            </button>
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
    :componentName="'Upd_01'"
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

const buscado = ref(false)
const contratos = ref([])
const zonas = ref([])
const empresas = ref([])
const unidades = ref([])
const tiposAseo = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const previsualizacion = ref(false)

const filtros = ref({
  zona: '',
  tipoAseo: '',
  empresa: '',
  contratoDesde: '',
  contratoHasta: ''
})

const actualizaciones = ref({
  empresa: '',
  zona: '',
  unidad: '',
  tipoAseo: '',
  tipoAjusteCuota: '',
  cuotaFija: 0,
  porcentajeIncremento: 0,
  montoIncremento: 0,
  motivo: '',
  fechaAplicacion: new Date().toISOString().split('T')[0]
})

// Computed
const tieneAlgunCambio = computed(() => {
  return actualizaciones.value.empresa ||
         actualizaciones.value.zona ||
         actualizaciones.value.unidad ||
         actualizaciones.value.tipoAseo ||
         actualizaciones.value.tipoAjusteCuota
})

// Métodos
async function loadCatalogos() {
  try {
    const [respZonas, respEmpresas, respUnidades, respTipos] = await Promise.all([
      execute('sp_zonas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_empresas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_unidades_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    ])
    zonas.value = respZonas?.result || []
    empresas.value = respEmpresas?.result || []
    unidades.value = respUnidades?.result || []
    tiposAseo.value = respTipos?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

async function buscarContratos() {
  showLoading('Buscando contratos...', 'Consultando base de datos')
  buscado.value = true

  try {
    const params = [
      { nombre: 'p_limit', valor: 500, tipo: 'integer' },
      { nombre: 'p_offset', valor: 0, tipo: 'integer' }
    ]
    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)

    let data = response?.result || []

    // Filtrar en cliente
    if (filtros.value.zona) {
      data = data.filter(c => c.zona_id == filtros.value.zona)
    }
    if (filtros.value.tipoAseo) {
      data = data.filter(c => c.tipo_aseo_id == filtros.value.tipoAseo)
    }
    if (filtros.value.empresa) {
      data = data.filter(c => c.num_empresa == filtros.value.empresa)
    }
    if (filtros.value.contratoDesde) {
      data = data.filter(c => c.num_contrato >= parseInt(filtros.value.contratoDesde))
    }
    if (filtros.value.contratoHasta) {
      data = data.filter(c => c.num_contrato <= parseInt(filtros.value.contratoHasta))
    }

    contratos.value = data
    contratosSeleccionados.value = []
    seleccionarTodo.value = false

    showToast(`${contratos.value.length} contrato(s, 'success') encontrado(s)`)
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contratos.value = []
  } finally {
    hideLoading()
  }
}

function limpiarFiltros() {
  filtros.value = {
    zona: '',
    tipoAseo: '',
    empresa: '',
    contratoDesde: '',
    contratoHasta: ''
  }
  contratos.value = []
  contratosSeleccionados.value = []
  buscado.value = false
}

function seleccionarTodos() {
  contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
  seleccionarTodo.value = true
}

function limpiarSeleccion() {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
}

function toggleSeleccionTodos() {
  if (seleccionarTodo.value) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

function validarActualizacion() {
  if (contratosSeleccionados.value.length === 0) return false
  if (!actualizaciones.value.motivo.trim()) return false
  if (!actualizaciones.value.fechaAplicacion) return false
  return tieneAlgunCambio.value
}

function obtenerNombreEmpresa(numEmpresa) {
  const emp = empresas.value.find(e => e.num_empresa === numEmpresa)
  return emp ? emp.descripcion : ''
}

function obtenerNombreZona(ctrolZona) {
  const zona = zonas.value.find(z => z.ctrol_zona === ctrolZona)
  return zona ? `Zona ${zona.zona}` : ''
}

function obtenerNombreUnidad(controlContrato) {
  const unidad = unidades.value.find(u => u.control_contrato === controlContrato)
  return unidad ? unidad.descripcion : ''
}

function obtenerNombreTipoAseo(ctrolAseo) {
  const tipo = tiposAseo.value.find(t => t.ctrol_aseo === ctrolAseo)
  return tipo ? tipo.descripcion : ''
}

async function aplicarActualizaciones() {
  const result = await Swal.fire({
    title: '¿Aplicar Actualizaciones?',
    html: `Se actualizarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s).<br>
           Esta operación no se puede deshacer.`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Aplicando actualizaciones...', 'Procesando contratos')

  try {
    let actualizados = 0
    let errores = 0

    for (const controlContrato of contratosSeleccionados.value) {
      try {
        const params = [
          { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' },
          { nombre: 'p_num_empresa', valor: actualizaciones.value.empresa || null, tipo: 'integer' },
          { nombre: 'p_tipo_aseo_id', valor: actualizaciones.value.tipoAseo || null, tipo: 'integer' },
          { nombre: 'p_zona_id', valor: actualizaciones.value.zona || null, tipo: 'integer' },
          { nombre: 'p_unidades_recoleccion', valor: actualizaciones.value.unidad || null, tipo: 'integer' },
          { nombre: 'p_monto_mensual', valor: calcularNuevaCuota(controlContrato), tipo: 'numeric' },
          { nombre: 'p_observaciones', valor: `Actualización masiva: ${actualizaciones.value.motivo}`, tipo: 'string' }
        ]
        await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)
        actualizados++
      } catch (e) {
        hideLoading()
        errores++
      }
    }

    hideLoading()

    await Swal.fire(
      '¡Proceso completado!',
      `Actualizados: ${actualizados}, Errores: ${errores}`,
      errores === 0 ? 'success' : 'warning'
    )

    await buscarContratos()
    cancelar()
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error)
  }
}

function calcularNuevaCuota(controlContrato) {
  if (!actualizaciones.value.tipoAjusteCuota) return null

  const contrato = contratos.value.find(c => c.control_contrato === controlContrato)
  if (!contrato) return null

  const cuotaActual = contrato.monto_mensual || 0

  switch (actualizaciones.value.tipoAjusteCuota) {
    case 'FIJA':
      return actualizaciones.value.cuotaFija
    case 'PORCENTAJE':
      return cuotaActual * (1 + actualizaciones.value.porcentajeIncremento / 100)
    case 'MONTO':
      return cuotaActual + actualizaciones.value.montoIncremento
    default:
      return null
  }
}

function cancelar() {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
  previsualizacion.value = false
  actualizaciones.value = {
    empresa: '',
    zona: '',
    unidad: '',
    tipoAseo: '',
    tipoAjusteCuota: '',
    cuotaFija: 0,
    porcentajeIncremento: 0,
    montoIncremento: 0,
    motivo: '',
    fechaAplicacion: new Date().toISOString().split('T')[0]
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

