<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Administrativa de Contratos</h1>
        <p>Aseo Contratado - Vista administrativa completa con filtros avanzados y exportación</p>
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
        <h5>Filtros de Consulta Avanzada</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="filtros.status">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Cancelados</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Búsqueda</label>
            <input type="text" class="municipal-form-control" v-model="filtros.busqueda"
              placeholder="Contrato, RFC o contribuyente" />
          </div>
        </div>
        <div class="row">
          <div class="col-md-2">
            <label class="municipal-form-label">Cuota Mínima</label>
            <input type="number" class="municipal-form-control" v-model.number="filtros.cuotaMin" min="0" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Cuota Máxima</label>
            <input type="number" class="municipal-form-control" v-model.number="filtros.cuotaMax" min="0" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Con Adeudos</label>
            <select class="municipal-form-control" v-model="filtros.conAdeudos">
              <option value="">Todos</option>
              <option value="S">Sí</option>
              <option value="N">No</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Registros</label>
            <select class="municipal-form-control" v-model.number="filtros.limit">
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="500">500</option>
              <option :value="0">Todos</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="consultar" :disabled="cargando">
              <font-awesome-icon icon="search" /> Consultar
            </button>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-secondary w-100" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="row mb-3">
        <div class="col-md-2">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body p-3">
              <h6 class="card-title" style="font-size: 0.75rem;">Total Contratos</h6>
              <h3>{{ contratos.length }}</h3>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body p-3">
              <h6 class="card-title" style="font-size: 0.75rem;">Activos</h6>
              <h3>{{ contratosActivos }}</h3>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="municipal-card bg-danger text-white">
            <div class="municipal-card-body p-3">
              <h6 class="card-title" style="font-size: 0.75rem;">Cancelados</h6>
              <h3>{{ contratosCancelados }}</h3>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body p-3">
              <h6 class="card-title" style="font-size: 0.75rem;">Ingresos Mensuales</h6>
              <h3>${{ formatCurrency(ingresosMensuales) }}</h3>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body p-3">
              <h6 class="card-title" style="font-size: 0.75rem;">Cuota Promedio</h6>
              <h3>${{ formatCurrency(cuotaPromedio) }}</h3>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resultados ({{ contratos.length }})</h6>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> PDF
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>RFC</th>
                  <th>Domicilio</th>
                  <th>Tipo</th>
                  <th>Zona</th>
                  <th>Empresa</th>
                  <th class="text-end">Cuota</th>
                  <th>Fecha Alta</th>
                  <th>Status</th>
                  <th>Adeudos</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratosPaginados" :key="contrato.control_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.rfc || 'N/A' }}</td>
                  <td>{{ contrato.domicilio }}</td>
                  <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ contrato.zona }}</td>
                  <td>{{ contrato.empresa }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                  <td>{{ formatFecha(contrato.fecha_alta) }}</td>
                  <td>
                    <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
                      {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>
                    <span v-if="contrato.tiene_adeudos === 'S'" class="badge badge-warning">
                      {{ contrato.num_adeudos || 0 }}
                    </span>
                    <span v-else class="badge badge-secondary">0</span>
                  </td>
                  <td>
                    <button class="btn btn-sm btn-info" @click="verDetalle(contrato)">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-if="totalPaginas > 1" class="d-flex justify-content-between align-items-center mt-3">
            <div>
              Mostrando {{ ((paginaActual - 1) * itemsPorPagina) + 1 }} -
              {{ Math.min(paginaActual * itemsPorPagina, contratos.length) }}
              de {{ contratos.length }}
            </div>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <a class="page-link" @click="paginaActual--" href="#">Anterior</a>
                </li>
                <li class="page-item" v-for="p in paginasVisibles" :key="p"
                    :class="{ active: p === paginaActual }">
                  <a class="page-link" @click="paginaActual = p" href="#">{{ p }}</a>
                </li>
                <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                  <a class="page-link" @click="paginaActual++" href="#">Siguiente</a>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!cargando && consultaRealizada" class="alert alert-info">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No se encontraron contratos con los criterios especificados.
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta Administrativa de Contratos">
      <h6>Descripción</h6>
      <p>Vista administrativa completa para consulta y análisis de contratos con filtros avanzados.</p>
      <h6>Filtros Disponibles</h6>
      <ul>
        <li>Empresa prestadora del servicio</li>
        <li>Tipo de aseo (Doméstico, Comercial, Industrial, Servicios)</li>
        <li>Status (Activo/Cancelado)</li>
        <li>Zona geográfica</li>
        <li>Rango de cuota mensual</li>
        <li>Contratos con/sin adeudos</li>
        <li>Búsqueda por contrato, RFC o contribuyente</li>
      </ul>
      <h6>Funcionalidades</h6>
      <ul>
        <li>Estadísticas en tiempo real</li>
        <li>Paginación de resultados</li>
        <li>Exportación a Excel y PDF</li>
        <li>Vista detallada por contrato</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const consultaRealizada = ref(false)
const contratos = ref([])
const empresas = ref([])
const zonas = ref([])
const paginaActual = ref(1)
const itemsPorPagina = ref(50)

const filtros = ref({
  empresa: '',
  tipoAseo: '',
  status: '',
  zona: '',
  busqueda: '',
  cuotaMin: 0,
  cuotaMax: 0,
  conAdeudos: '',
  limit: 100
})

const contratosActivos = computed(() => contratos.value.filter(c => c.status === 'A').length)
const contratosCancelados = computed(() => contratos.value.filter(c => c.status === 'I').length)

const ingresosMensuales = computed(() => {
  return contratos.value
    .filter(c => c.status === 'A')
    .reduce((sum, c) => sum + parseFloat(c.cuota_mensual || 0), 0)
})

const cuotaPromedio = computed(() => {
  const activos = contratos.value.filter(c => c.status === 'A')
  return activos.length > 0 ? ingresosMensuales.value / activos.length : 0
})

const totalPaginas = computed(() => Math.ceil(contratos.value.length / itemsPorPagina.value))

const paginasVisibles = computed(() => {
  const maxVisible = 5
  let inicio = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let fin = Math.min(totalPaginas.value, inicio + maxVisible - 1)

  if (fin - inicio < maxVisible - 1) {
    inicio = Math.max(1, fin - maxVisible + 1)
  }

  const paginas = []
  for (let i = inicio; i <= fin; i++) {
    paginas.push(i)
  }
  return paginas
})

const contratosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * itemsPorPagina.value
  return contratos.value.slice(inicio, inicio + itemsPorPagina.value)
})

const consultar = async () => {
  cargando.value = true
  consultaRealizada.value = false
  try {
    const params = {
      p_empresa: filtros.value.empresa || null,
      p_tipo_aseo: filtros.value.tipoAseo || null,
      p_status: filtros.value.status || null,
      p_zona: filtros.value.zona || null,
      p_busqueda: filtros.value.busqueda || null,
      p_cuota_min: filtros.value.cuotaMin || 0,
      p_cuota_max: filtros.value.cuotaMax || 0,
      p_con_adeudos: filtros.value.conAdeudos || null,
      p_limit: filtros.value.limit || 0
    }
    const response = await execute('SP_ASEO_CONTRATOS_CONSULTA_ADMIN', 'aseo_contratado', params)
    contratos.value = response || []
    consultaRealizada.value = true
    paginaActual.value = 1
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar contratos')
  } finally {
    cargando.value = false
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    empresa: '',
    tipoAseo: '',
    status: '',
    zona: '',
    busqueda: '',
    cuotaMin: 0,
    cuotaMax: 0,
    conAdeudos: '',
    limit: 100
  }
  contratos.value = []
  consultaRealizada.value = false
}

const verDetalle = (contrato) => {
  showToast(`Ver detalle de contrato: ${contrato.num_contrato}`, 'info')
}

const exportarExcel = () => showToast('Exportando a Excel...', 'info')
const exportarPDF = () => showToast('Exportando a PDF...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respEmpresas, respZonas] = await Promise.all([
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    ])
    empresas.value = respEmpresas || []
    zonas.value = respZonas || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>

