<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Inicialización de Obligaciones</h1>
        <p>Aseo Contratado - Establece el periodo inicial de facturación para contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Paso 1: Selección de Contratos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarContratos" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
        <div class="alert alert-info mb-0">
          <font-awesome-icon icon="info-circle" class="me-2" />
          Se mostrarán solo los contratos activos que <strong>no tienen periodo inicial establecido</strong>.
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Contratos Sin Periodo Inicial ({{ contratos.length }})</h6>
          <div>
            <button class="btn btn-sm btn-success" @click="seleccionarTodos">
              <font-awesome-icon icon="check-double" /> Todos
            </button>
            <button class="btn btn-sm btn-secondary ms-2" @click="limpiarSeleccion">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="table-light" style="position: sticky; top: 0;">
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" class="form-check-input" v-model="seleccionarTodo"
                      @change="toggleSeleccionTodos" />
                  </th>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Zona</th>
                  <th>Tipo</th>
                  <th>Fecha de Alta</th>
                  <th class="text-end">Cuota</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                    :class="{ 'table-success': contratosSeleccionados.includes(contrato.control_contrato) }">
                  <td>
                    <input type="checkbox" class="form-check-input"
                      :value="contrato.control_contrato" v-model="contratosSeleccionados" />
                  </td>
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td class="text-center">{{ contrato.zona }}</td>
                  <td class="text-center">{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ formatFecha(contrato.fecha_alta) }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="contratosSeleccionados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 2: Configurar Periodo Inicial ({{ contratosSeleccionados.length }} seleccionados)</h5>
      </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-success">
            <font-awesome-icon icon="lightbulb" class="me-2" />
            <strong>Periodo Inicial:</strong> Es el periodo a partir del cual el contrato comenzará a generar obligaciones de pago.
            Se debe especificar en formato YYYYMM (Año + Mes).
          </div>

          <div class="row mb-3">
            <div class="col-md-3">
              <label class="municipal-form-label">Periodo Inicial *</label>
              <input type="text" class="municipal-form-control" v-model="periodoInicial"
                placeholder="YYYYMM (ej: 202401)" maxlength="6" />
              <small class="text-muted">Formato: Año (4 dígitos) + Mes (2 dígitos)</small>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">O Seleccionar Fecha</label>
              <input type="month" class="municipal-form-control" @change="actualizarDesdeFecha" />
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Opción de Inicio</label>
              <select class="municipal-form-control" v-model="opcionInicio">
                <option value="PERIODO">Desde periodo especificado</option>
                <option value="FECHA_ALTA">Desde fecha de alta del contrato</option>
                <option value="ACTUAL">Desde periodo actual</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Generar Adeudos Atrasados</label>
              <select class="municipal-form-control" v-model="generarAdeudos">
                <option value="NO">No, solo establecer periodo</option>
                <option value="SI">Sí, calcular adeudos desde periodo inicial</option>
              </select>
            </div>
          </div>

          <div v-if="periodoInicial && validarPeriodo()" class="row mb-3">
            <div class="col-md-12">
              <div class="municipal-alert municipal-alert-info">
                <strong>Periodo a establecer:</strong> {{ formatPeriodo(periodoInicial) }}
                <span v-if="generarAdeudos === 'SI'" class="ms-3">
                  <font-awesome-icon icon="exclamation-triangle" class="text-warning" />
                  Se generarán adeudos retroactivos desde este periodo hasta el actual
                </span>
              </div>
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-6">
              <label class="municipal-form-label">Observaciones</label>
              <textarea class="municipal-form-control" v-model="observaciones" rows="3"
                placeholder="Ej: Inicialización de contratos nuevos del mes"></textarea>
            </div>
          </div>

          <div class="d-flex justify-content-end">
            <button class="btn-municipal-secondary me-2" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-primary" @click="inicializarObligaciones"
              :disabled="!validarInicializacion()">
              <font-awesome-icon icon="check" /> Inicializar Obligaciones
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada && !cargando" class="alert alert-success text-center">
      <font-awesome-icon icon="check-circle" size="2x" class="mb-2" />
      <p class="mb-0">¡Excelente! Todos los contratos con los filtros especificados ya tienen periodo inicial establecido.</p>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Inicialización de Obligaciones">
      <h6>Descripción</h6>
      <p>Establece el periodo inicial de facturación para contratos que aún no lo tienen definido.</p>
      <h6>¿Qué es el Periodo Inicial?</h6>
      <p>Es el periodo (mes/año) a partir del cual el contrato comenzará a generar obligaciones de pago mensuales.</p>
      <h6>Formato del Periodo</h6>
      <p>El periodo debe ingresarse en formato <strong>YYYYMM</strong>:</p>
      <ul>
        <li>YYYY = Año (4 dígitos)</li>
        <li>MM = Mes (2 dígitos, 01-12)</li>
        <li>Ejemplo: 202401 = Enero 2024</li>
      </ul>
      <h6>Opciones de Inicio</h6>
      <ul>
        <li><strong>Desde periodo especificado:</strong> Usar el periodo que ingrese manualmente</li>
        <li><strong>Desde fecha de alta:</strong> Usar el mes/año de la fecha de alta del contrato</li>
        <li><strong>Desde periodo actual:</strong> Usar el periodo actual del sistema</li>
      </ul>
      <h6>Generación de Adeudos</h6>
      <ul>
        <li><strong>No:</strong> Solo establece el periodo, no calcula adeudos retroactivos</li>
        <li><strong>Sí:</strong> Calcula y registra todos los periodos adeudados desde el periodo inicial hasta el actual</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Upd_IniObl'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const contratos = ref([])
const zonas = ref([])
const empresas = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const busquedaRealizada = ref(false)
const periodoInicial = ref('')
const opcionInicio = ref('PERIODO')
const generarAdeudos = ref('NO')
const observaciones = ref('')

const filtros = ref({
  zona: '',
  tipoAseo: '',
  empresa: ''
})

const buscarContratos = async () => {
  cargando.value = true
  busquedaRealizada.value = true
  try {
    const params = {
      p_zona: filtros.value.zona || null,
      p_tipo_aseo: filtros.value.tipoAseo || null,
      p_empresa: filtros.value.empresa || null
    }
    const response = await execute('SP_ASEO_CONTRATOS_SIN_PERIODO_INICIAL', 'aseo_contratado', params)
    contratos.value = response || []
    contratosSeleccionados.value = []
    showToast(`${contratos.value.length} contrato(s) sin periodo inicial`, contratos.value.length > 0 ? 'warning' : 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contratos')
  } finally {
    cargando.value = false
  }
}

const seleccionarTodos = () => {
  contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
  seleccionarTodo.value = true
}

const limpiarSeleccion = () => {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
}

const toggleSeleccionTodos = () => {
  if (seleccionarTodo.value) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

const actualizarDesdeFecha = (event) => {
  const fecha = event.target.value
  if (fecha) {
    const [anio, mes] = fecha.split('-')
    periodoInicial.value = `${anio}${mes}`
  }
}

const validarPeriodo = () => {
  if (!periodoInicial.value || periodoInicial.value.length !== 6) return false
  const anio = parseInt(periodoInicial.value.substring(0, 4))
  const mes = parseInt(periodoInicial.value.substring(4, 6))
  return anio >= 2000 && anio <= 2099 && mes >= 1 && mes <= 12
}

const validarInicializacion = () => {
  if (contratosSeleccionados.value.length === 0) return false
  if (opcionInicio.value === 'PERIODO' && !validarPeriodo()) return false
  return true
}

const formatPeriodo = (periodo) => {
  if (!periodo || periodo.length !== 6) return periodo
  const anio = periodo.substring(0, 4)
  const mes = periodo.substring(4, 6)
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  const mesNombre = meses[parseInt(mes) - 1]
  return `${mesNombre} ${anio}`
}

const inicializarObligaciones = async () => {
  const result = await Swal.fire({
    title: '¿Inicializar Obligaciones?',
    html: `Se inicializarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s)<br>
           ${opcionInicio.value === 'PERIODO' ? `Periodo inicial: <strong>${formatPeriodo(periodoInicial.value)}</strong>` : ''}
           ${generarAdeudos.value === 'SI' ? '<br><span class="text-warning">Se generarán adeudos retroactivos</span>' : ''}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, inicializar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_contratos: contratosSeleccionados.value.join(','),
      p_periodo_inicial: opcionInicio.value === 'PERIODO' ? periodoInicial.value : null,
      p_opcion_inicio: opcionInicio.value,
      p_generar_adeudos: generarAdeudos.value,
      p_observaciones: observaciones.value || null
    }
    const response = await execute('SP_ASEO_INICIALIZAR_OBLIGACIONES', 'aseo_contratado', params)

    let mensaje = 'Las obligaciones han sido inicializadas correctamente'
    if (response && response.length > 0 && response[0].adeudos_generados) {
      mensaje += `<br><small>Adeudos generados: ${response[0].adeudos_generados}</small>`
    }

    await Swal.fire('¡Inicializado!', mensaje, 'success')

    await buscarContratos()
    cancelar()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al inicializar obligaciones')
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
  periodoInicial.value = ''
  opcionInicio.value = 'PERIODO'
  generarAdeudos.value = 'NO'
  observaciones.value = ''
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respZonas, respEmpresas] = await Promise.all([
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {})
    ])
    zonas.value = respZonas || []
    empresas.value = respEmpresas || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
