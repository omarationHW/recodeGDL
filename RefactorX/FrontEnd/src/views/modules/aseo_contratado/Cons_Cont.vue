<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Contratos</h1>
        <p>Aseo Contratado - Búsqueda y visualización detallada de contratos</p>
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
        <h5>Criterios de Búsqueda</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Número de Contrato</label>
            <input type="text" class="municipal-form-control" v-model="filtros.numContrato"
              placeholder="Ej: 12345" @keyup.enter="buscar" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Cuenta Catastral</label>
            <input type="text" class="municipal-form-control" v-model="filtros.cuentaCatastral"
              placeholder="Ej: 123456789012" @keyup.enter="buscar" />
          </div>
          <div class="col-md-4">
            <label class="municipal-form-label">Contribuyente</label>
            <input type="text" class="municipal-form-control" v-model="filtros.contribuyente"
              placeholder="Nombre o RFC" @keyup.enter="buscar" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscar" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
        <div class="row">
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
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
          <div class="col-md-3">
            <label class="municipal-form-label">Domicilio</label>
            <input type="text" class="municipal-form-control" v-model="filtros.domicilio"
              placeholder="Calle, número..." @keyup.enter="buscar" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-secondary w-100" @click="limpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resultados ({{ contratos.length }})</h6>
          <button class="btn btn-sm btn-success" @click="exportar">
            <font-awesome-icon icon="file-excel" /> Exportar
          </button>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="municipal-table-hover table-sm mb-0">
              <thead>
                <tr>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Cuenta Catastral</th>
                  <th>Domicilio</th>
                  <th>Zona</th>
                  <th>Tipo</th>
                  <th>Status</th>
                  <th class="text-end">Cuota</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato">
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.cuenta_catastral }}</td>
                  <td>{{ contrato.domicilio_corto }}</td>
                  <td class="text-center">{{ contrato.zona }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getBadgeTipo(contrato.tipo_aseo)">
                      {{ formatTipoAseo(contrato.tipo_aseo) }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
                      {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                    </span>
                  </td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                  <td>
                    <button class="btn btn-sm btn-info" @click="verDetalle(contrato)">
                      <font-awesome-icon icon="eye" /> Ver
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada && !cargando" class="alert alert-info text-center">
      <font-awesome-icon icon="info-circle" size="2x" class="mb-2" />
      <p class="mb-0">No se encontraron contratos con los criterios especificados</p>
    </div>

    <!-- Modal de Detalle -->
    <div v-if="contratoSeleccionado" class="modal fade show d-block" tabindex="-1" style="background: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title">
              <font-awesome-icon icon="file-contract" class="me-2" />
              Detalle del Contrato #{{ contratoSeleccionado.num_contrato }}
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarDetalle"></button>
          </div>
          <div class="modal-body">
            <div class="row mb-3">
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
        <h5>Información General</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="municipal-table-sm table-borderless">
                      <tr>
                        <th style="width: 40%;">Número de Contrato:</th>
                        <td><strong>{{ contratoSeleccionado.num_contrato }}</strong></td>
                      </tr>
                      <tr>
                        <th>Cuenta Catastral:</th>
                        <td>{{ contratoSeleccionado.cuenta_catastral }}</td>
                      </tr>
                      <tr>
                        <th>Fecha de Alta:</th>
                        <td>{{ formatFecha(contratoSeleccionado.fecha_alta) }}</td>
                      </tr>
                      <tr>
                        <th>Status:</th>
                        <td>
                          <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                            {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Cancelado' }}
                          </span>
                        </td>
                      </tr>
                      <tr v-if="contratoSeleccionado.status === 'I'">
                        <th>Fecha de Cancelación:</th>
                        <td>{{ formatFecha(contratoSeleccionado.fecha_cancelacion) }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
        <h5>Contribuyente</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="municipal-table-sm table-borderless">
                      <tr>
                        <th style="width: 40%;">Nombre:</th>
                        <td>{{ contratoSeleccionado.contribuyente }}</td>
                      </tr>
                      <tr>
                        <th>RFC:</th>
                        <td>{{ contratoSeleccionado.rfc || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <th>CURP:</th>
                        <td>{{ contratoSeleccionado.curp || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <th>Teléfono:</th>
                        <td>{{ contratoSeleccionado.telefono || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <th>Email:</th>
                        <td>{{ contratoSeleccionado.email || 'N/A' }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <div class="row mb-3">
              <div class="col-md-12">
                <div class="municipal-card">
                  <div class="municipal-card-header">
        <h5>Ubicación del Servicio</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="municipal-table-sm table-borderless">
                      <tr>
                        <th style="width: 20%;">Domicilio:</th>
                        <td>{{ contratoSeleccionado.domicilio_completo }}</td>
                      </tr>
                      <tr>
                        <th>Colonia:</th>
                        <td>{{ contratoSeleccionado.colonia }}</td>
                      </tr>
                      <tr>
                        <th>Zona:</th>
                        <td>{{ contratoSeleccionado.zona }}</td>
                      </tr>
                      <tr>
                        <th>Referencias:</th>
                        <td>{{ contratoSeleccionado.referencias || 'N/A' }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
        <h5>Detalles del Servicio</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="municipal-table-sm table-borderless">
                      <tr>
                        <th style="width: 40%;">Tipo de Aseo:</th>
                        <td>
                          <span class="badge" :class="getBadgeTipo(contratoSeleccionado.tipo_aseo)">
                            {{ formatTipoAseoCompleto(contratoSeleccionado.tipo_aseo) }}
                          </span>
                        </td>
                      </tr>
                      <tr>
                        <th>Cuota Mensual:</th>
                        <td><strong class="text-success">${{ formatCurrency(contratoSeleccionado.cuota_mensual) }}</strong></td>
                      </tr>
                      <tr>
                        <th>Periodo Actual:</th>
                        <td>{{ contratoSeleccionado.periodo_actual || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <th>Unidad Recolectora:</th>
                        <td>{{ contratoSeleccionado.unidad_recolectora || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <th>Empresa:</th>
                        <td>{{ contratoSeleccionado.nombre_empresa }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="municipal-card">
                  <div class="municipal-card-header">
        <h5>Estado de Cuenta</h5>
                  </div>
                  <div class="municipal-card-body">
                    <table class="municipal-table-sm table-borderless">
                      <tr>
                        <th style="width: 40%;">Adeudo Actual:</th>
                        <td>
                          <strong :class="contratoSeleccionado.adeudo > 0 ? 'text-danger' : 'text-success'">
                            ${{ formatCurrency(contratoSeleccionado.adeudo || 0) }}
                          </strong>
                        </td>
                      </tr>
                      <tr>
                        <th>Periodos Adeudados:</th>
                        <td>{{ contratoSeleccionado.periodos_adeudados || 0 }}</td>
                      </tr>
                      <tr>
                        <th>Último Pago:</th>
                        <td>{{ contratoSeleccionado.fecha_ultimo_pago ? formatFecha(contratoSeleccionado.fecha_ultimo_pago) : 'Sin pagos' }}</td>
                      </tr>
                      <tr>
                        <th>Monto Último Pago:</th>
                        <td>${{ formatCurrency(contratoSeleccionado.monto_ultimo_pago || 0) }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="contratoSeleccionado.observaciones" class="row mt-3">
              <div class="col-md-12">
                <div class="alert alert-info">
                  <strong>Observaciones:</strong> {{ contratoSeleccionado.observaciones }}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarDetalle">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta de Contratos">
      <h6>Descripción</h6>
      <p>Permite buscar contratos utilizando diferentes criterios y visualizar su información completa.</p>
      <h6>Criterios de Búsqueda</h6>
      <ul>
        <li>Número de contrato</li>
        <li>Cuenta catastral</li>
        <li>Nombre o RFC del contribuyente</li>
        <li>Domicilio del servicio</li>
        <li>Zona, tipo de aseo y status</li>
      </ul>
      <h6>Detalle del Contrato</h6>
      <p>Haga clic en el botón "Ver" para consultar toda la información del contrato, incluyendo:</p>
      <ul>
        <li>Datos del contribuyente</li>
        <li>Ubicación del servicio</li>
        <li>Detalles del servicio contratado</li>
        <li>Estado de cuenta y adeudos</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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
const contratos = ref([])
const zonas = ref([])
const busquedaRealizada = ref(false)
const contratoSeleccionado = ref(null)

const filtros = ref({
  numContrato: '',
  cuentaCatastral: '',
  contribuyente: '',
  zona: '',
  tipoAseo: '',
  status: '',
  domicilio: ''
})

const buscar = async () => {
  if (!filtros.value.numContrato && !filtros.value.cuentaCatastral &&
      !filtros.value.contribuyente && !filtros.value.domicilio &&
      !filtros.value.zona && !filtros.value.tipoAseo) {
    return showToast('Ingrese al menos un criterio de búsqueda', 'warning')
  }

  cargando.value = true
  busquedaRealizada.value = true
  try {
    const params = {
      p_num_contrato: filtros.value.numContrato || null,
      p_cuenta_catastral: filtros.value.cuentaCatastral || null,
      p_contribuyente: filtros.value.contribuyente || null,
      p_zona: filtros.value.zona || null,
      p_tipo_aseo: filtros.value.tipoAseo || null,
      p_status: filtros.value.status || null,
      p_domicilio: filtros.value.domicilio || null
    }
    const response = await execute('SP_ASEO_CONSULTA_CONTRATOS', 'aseo_contratado', params)
    contratos.value = response || []
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al buscar contratos')
  } finally {
    cargando.value = false
  }
}

const verDetalle = async (contrato) => {
  cargando.value = true
  try {
    const params = { p_control_contrato: contrato.control_contrato }
    const response = await execute('SP_ASEO_DETALLE_CONTRATO', 'aseo_contratado', params)
    if (response && response.length > 0) {
      contratoSeleccionado.value = response[0]
    }
  } catch (error) {
    handleError(error, 'Error al cargar detalle del contrato')
  } finally {
    cargando.value = false
  }
}

const cerrarDetalle = () => {
  contratoSeleccionado.value = null
}

const limpiar = () => {
  filtros.value = {
    numContrato: '',
    cuentaCatastral: '',
    contribuyente: '',
    zona: '',
    tipoAseo: '',
    status: '',
    domicilio: ''
  }
  contratos.value = []
  busquedaRealizada.value = false
}

const exportar = () => showToast('Exportando resultados...', 'info')

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

const formatTipoAseoCompleto = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

const getBadgeTipo = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    zonas.value = response || []
  } catch (error) {
    console.error('Error al cargar zonas:', error)
  }
})
</script>

