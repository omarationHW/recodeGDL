<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-xmark" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Vencidos</h1>
        <p>Aseo Contratado - Consulta y gestión de adeudos con fecha vencida</p>
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
<div class="municipal-card">
      <div class="municipal-card-header municipal-header-danger">
        <h6 class="mb-0">Filtros de Búsqueda</h6>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Vencimiento Desde</label>
            <input type="date" class="municipal-form-control" v-model="filtros.fecha_desde" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Vencimiento Hasta</label>
            <input type="date" class="municipal-form-control" v-model="filtros.fecha_hasta" :max="fechaActual" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipo_aseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-secondary w-100" @click="consultarVencidos" :disabled="cargando">
              <font-awesome-icon icon="search" class="me-1" />
              Consultar
            </button>
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Días de Vencimiento</label>
            <select class="municipal-form-control" v-model="filtros.dias_vencimiento">
              <option value="">Todos</option>
              <option value="30">Más de 30 días</option>
              <option value="60">Más de 60 días</option>
              <option value="90">Más de 90 días</option>
              <option value="180">Más de 180 días</option>
              <option value="360">Más de 1 año</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                {{ z.descripcion }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Monto Mínimo</label>
            <input type="number" class="municipal-form-control" v-model.number="filtros.monto_min" min="0" placeholder="0.00" />
          </div>
          <div class="col-md-3">
            <div class="form-check mt-4">
              <input class="form-check-input" type="checkbox" v-model="filtros.incluir_recargos" id="incluirRecargos" />
              <label class="form-check-label" for="incluirRecargos">
                Incluir recargos calculados
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="adeudosVencidos.length > 0" class="mt-4">
      <div class="row mb-3">
        <div class="col-md-3">
          <div class="municipal-card bg-danger text-white">
            <div class="municipal-card-body">
              <h6 class="card-title">Total Vencidos</h6>
              <h2>{{ adeudosVencidos.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body">
              <h6 class="card-title">Monto Total</h6>
              <h2>${{ formatCurrency(montoTotal) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6 class="card-title">Días Promedio Venc.</h6>
              <h2>{{ diasPromedioVencimiento }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-secondary text-white">
            <div class="municipal-card-body">
              <h6 class="card-title">Contratos Afectados</h6>
              <h2>{{ contratosAfectados }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between align-items-center">
          <h6 class="mb-0">Detalle de Adeudos Vencidos</h6>
          <div class="btn-group">
            <button class="btn btn-sm btn-success" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" class="me-1" />
              Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" class="me-1" />
              PDF
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
                  <th>Periodo</th>
                  <th>Fecha Venc.</th>
                  <th>Días Venc.</th>
                  <th class="text-end">Cuota Base</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total</th>
                  <th>Tipo</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudosPaginados" :key="adeudo.folio"
                    :class="{ 'table-danger': adeudo.dias_vencido > 90 }">
                  <td>{{ adeudo.num_contrato }}</td>
                  <td>{{ adeudo.contribuyente }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ formatFecha(adeudo.fecha_vencimiento) }}</td>
                  <td>
                    <span class="badge" :class="{
                      'bg-warning': adeudo.dias_vencido <= 30,
                      'bg-danger': adeudo.dias_vencido > 30 && adeudo.dias_vencido <= 90,
                      'bg-dark': adeudo.dias_vencido > 90
                    }">
                      {{ adeudo.dias_vencido }} días
                    </span>
                  </td>
                  <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                  <td>{{ formatTipoAseo(adeudo.tipo_aseo) }}</td>
                  <td>
                    <button class="btn btn-sm btn-info" @click="verDetalle(adeudo)" title="Ver detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="d-flex justify-content-between align-items-center mt-3">
            <div>
              Mostrando {{ ((paginaActual - 1) * itemsPorPagina) + 1 }} -
              {{ Math.min(paginaActual * itemsPorPagina, adeudosVencidos.length) }}
              de {{ adeudosVencidos.length }}
            </div>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <a class="page-link" @click="paginaActual--" href="#">Anterior</a>
                </li>
                <li class="page-item" v-for="p in totalPaginas" :key="p" :class="{ active: p === paginaActual }">
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

    <div v-else-if="!cargando" class="alert alert-info mt-4">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No se encontraron adeudos vencidos con los criterios especificados.
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Adeudos Vencidos - Ayuda">
      <h6>Descripción</h6>
      <p>Módulo para consultar y gestionar adeudos que han superado su fecha de vencimiento.</p>
      <h6>Filtros Disponibles</h6>
      <ul>
        <li>Rango de fechas de vencimiento</li>
        <li>Tipo de aseo y empresa</li>
        <li>Días de vencimiento (30, 60, 90, 180, 360+ días)</li>
        <li>Zona y monto mínimo</li>
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
const empresas = ref([])
const zonas = ref([])
const adeudosVencidos = ref([])
const paginaActual = ref(1)
const itemsPorPagina = ref(20)

const filtros = ref({
  fecha_desde: '',
  fecha_hasta: new Date().toISOString().split('T')[0],
  tipo_aseo: '',
  empresa: '',
  dias_vencimiento: '',
  zona: '',
  monto_min: 0,
  incluir_recargos: true
})

const fechaActual = computed(() => new Date().toISOString().split('T')[0])

const montoTotal = computed(() => {
  return adeudosVencidos.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const diasPromedioVencimiento = computed(() => {
  if (adeudosVencidos.value.length === 0) return 0
  const total = adeudosVencidos.value.reduce((sum, a) => sum + a.dias_vencido, 0)
  return Math.round(total / adeudosVencidos.value.length)
})

const contratosAfectados = computed(() => {
  return new Set(adeudosVencidos.value.map(a => a.num_contrato)).size
})

const totalPaginas = computed(() => Math.ceil(adeudosVencidos.value.length / itemsPorPagina.value))

const adeudosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * itemsPorPagina.value
  return adeudosVencidos.value.slice(inicio, inicio + itemsPorPagina.value)
})

const consultarVencidos = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_ADEUDOS_VENCIDOS', 'aseo_contratado', {
      p_fecha_desde: filtros.value.fecha_desde || null,
      p_fecha_hasta: filtros.value.fecha_hasta,
      p_tipo_aseo: filtros.value.tipo_aseo || null,
      p_empresa: filtros.value.empresa || null,
      p_dias_vencimiento: filtros.value.dias_vencimiento || null,
      p_zona: filtros.value.zona || null,
      p_monto_min: filtros.value.monto_min || 0,
      p_incluir_recargos: filtros.value.incluir_recargos ? 'S' : 'N'
    })
    adeudosVencidos.value = response || []
    paginaActual.value = 1
    showToast(`${adeudosVencidos.value.length} adeudo(s) vencido(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar adeudos vencidos')
    adeudosVencidos.value = []
  } finally {
    cargando.value = false
  }
}

const verDetalle = async (adeudo) => {
  // Implementar modal de detalle
  showToast('Funcionalidad en desarrollo', 'info')
}

const exportarExcel = () => {
  showToast('Exportando a Excel...', 'info')
}

const exportarPDF = () => {
  showToast('Exportando a PDF...', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
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

