<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Contratos por Empresa</h1>
        <p>Aseo Contratado - Consulta de contratos agrupados por empresa prestadora del servicio</p>
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
        <h5>Filtros</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="empresaSeleccionada" @change="cargarContratos">
              <option value="">Seleccione empresa...</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="filtroStatus">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Inactivos</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtroTipo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="cargarContratos" :disabled="!empresaSeleccionada || cargando">
              <font-awesome-icon icon="search" /> Consultar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="empresaInfo" class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Información de la Empresa</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <strong>Empresa:</strong> {{ empresaInfo.nombre_empresa }}<br>
            <strong>RFC:</strong> {{ empresaInfo.rfc || 'N/A' }}
          </div>
          <div class="col-md-3">
            <strong>Teléfono:</strong> {{ empresaInfo.telefono || 'N/A' }}<br>
            <strong>Email:</strong> {{ empresaInfo.email || 'N/A' }}
          </div>
          <div class="col-md-6">
            <strong>Domicilio:</strong> {{ empresaInfo.domicilio || 'N/A' }}
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ contratosFiltrados.length }}</div>
            <div class="stat-label-mini">Total Contratos</div>
          </div>
        </div>
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ contratosActivos }}</div>
            <div class="stat-label-mini">Activos</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(ingresosMensuales) }}</div>
            <div class="stat-label-mini">Ingresos Mensuales</div>
          </div>
        </div>
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="exclamation-triangle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(adeudosPendientes) }}</div>
            <div class="stat-label-mini">Adeudos Pendientes</div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Detalle de Contratos ({{ contratosFiltrados.length }})</h6>
          <div class="btn-group btn-group-sm">
            <button class="btn-municipal-primary" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn-municipal-secondary" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
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
                  <th>Domicilio</th>
                  <th>Tipo</th>
                  <th>Zona</th>
                  <th class="text-end">Cuota Mensual</th>
                  <th>Fecha Alta</th>
                  <th>Status</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratosFiltrados" :key="contrato.control_contrato">
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.domicilio }}</td>
                  <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ contrato.zona }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                  <td>{{ formatFecha(contrato.fecha_alta) }}</td>
                  <td>
                    <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
                      {{ contrato.status === 'A' ? 'Activo' : 'Inactivo' }}
                    </span>
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
        </div>
      </div>
    </div>

    <div v-else-if="empresaSeleccionada && !cargando" class="alert alert-warning">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No se encontraron contratos para esta empresa con los filtros seleccionados.
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Contratos por Empresa">
      <p>Consulte todos los contratos asociados a una empresa prestadora del servicio de aseo.</p>
      <h6>Información Disponible</h6>
      <ul>
        <li>Total de contratos por empresa</li>
        <li>Ingresos mensuales proyectados</li>
        <li>Adeudos pendientes</li>
        <li>Detalle completo de cada contrato</li>
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
const empresaSeleccionada = ref('')
const empresaInfo = ref(null)
const contratos = ref([])
const filtroStatus = ref('')
const filtroTipo = ref('')

const contratosFiltrados = computed(() => {
  let resultado = [...contratos.value]
  if (filtroStatus.value) resultado = resultado.filter(c => c.status === filtroStatus.value)
  if (filtroTipo.value) resultado = resultado.filter(c => c.tipo_aseo === filtroTipo.value)
  return resultado
})

const contratosActivos = computed(() => contratosFiltrados.value.filter(c => c.status === 'A').length)
const ingresosMensuales = computed(() => {
  return contratosFiltrados.value
    .filter(c => c.status === 'A')
    .reduce((sum, c) => sum + parseFloat(c.cuota_mensual || 0), 0)
})
const adeudosPendientes = computed(() => {
  return contratosFiltrados.value.reduce((sum, c) => sum + parseFloat(c.saldo_pendiente || 0), 0)
})

const cargarContratos = async () => {
  if (!empresaSeleccionada.value) return
  cargando.value = true
  try {
    const [respEmpresa, respContratos] = await Promise.all([
      execute('SP_ASEO_EMPRESAS_GET', 'aseo_contratado', { p_num_empresa: empresaSeleccionada.value }),
      execute('SP_ASEO_CONTRATOS_POR_EMPRESA', 'aseo_contratado', { p_num_empresa: empresaSeleccionada.value })
    ])
    empresaInfo.value = respEmpresa?.[0] || null
    contratos.value = respContratos || []
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al cargar contratos')
  } finally {
    cargando.value = false
  }
}

const verDetalle = (contrato) => {
  showToast('Ver detalle: ' + contrato.num_contrato, 'info')
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
const formatFecha = (fecha) => fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const resp = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {})
    empresas.value = resp || []
  } catch (error) {
    handleError(error, 'Error al cargar empresas')
  }
})
</script>

