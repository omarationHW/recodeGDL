<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Administrativa de Contratos</h1>
        <p>Aseo Contratado - Vista administrativa con detalle de adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Busqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="search-form-inline">
            <div class="search-field">
              <label class="municipal-form-label required">No. Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ej: 12345"
                @keyup.enter="buscarContrato"
              />
            </div>
            <div class="search-field search-field-large">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option value="">-- Seleccione tipo de aseo --</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.tipo_aseo">
                  {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="search-field-button">
              <button type="button" class="btn-municipal-primary" @click="buscarContrato">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Contribuyente (Encabezado) -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="user" /> Datos del Contribuyente</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item info-item-wide">
              <span class="info-label">Propietario</span>
              <span class="info-value info-value-highlight">{{ encabezado.propietario || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">RFC</span>
              <span class="info-value">{{ encabezado.rfc || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">CURP</span>
              <span class="info-value">{{ encabezado.curp || '-' }}</span>
            </div>
          </div>

          <!-- Domicilio -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="map-marker-alt" /> Domicilio</h6>
            <div class="info-grid">
              <div class="info-item info-item-wide">
                <span class="info-label">Calle</span>
                <span class="info-value">{{ encabezado.calle || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">No. Ext.</span>
                <span class="info-value">{{ encabezado.numext || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">No. Int.</span>
                <span class="info-value">{{ encabezado.numint || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Colonia</span>
                <span class="info-value">{{ encabezado.colonia || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">C.P.</span>
                <span class="info-value">{{ encabezado.cp || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Municipio</span>
                <span class="info-value">{{ encabezado.municipio || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Estado</span>
                <span class="info-value">{{ encabezado.estado || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- Leyendas -->
          <div v-if="encabezado.leyenda" class="municipal-alert municipal-alert-info mt-3">
            <font-awesome-icon icon="info-circle" />
            <span>{{ encabezado.leyenda }}</span>
          </div>

          <div v-if="encabezado.leyendarecibo" class="municipal-alert municipal-alert-warning mt-2">
            <font-awesome-icon icon="receipt" />
            <span>{{ encabezado.leyendarecibo }}</span>
          </div>

          <div v-if="encabezado.impidecobro === 1" class="municipal-alert municipal-alert-danger mt-2">
            <font-awesome-icon icon="ban" />
            <span><strong>COBRO IMPEDIDO</strong></span>
          </div>
        </div>
      </div>

      <!-- Tabs: Datos Varios y Detalle Adeudos -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <div class="tab-buttons">
            <button
              type="button"
              :class="['tab-button', { active: tabActiva === 'datos' }]"
              @click="tabActiva = 'datos'"
            >
              <font-awesome-icon icon="list" /> Datos Varios
            </button>
            <button
              type="button"
              :class="['tab-button', { active: tabActiva === 'adeudos' }]"
              @click="tabActiva = 'adeudos'"
            >
              <font-awesome-icon icon="money-bill-wave" /> Detalle Adeudos
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <!-- Tab Datos Varios -->
          <div v-if="tabActiva === 'datos'">
            <div v-if="datosVarios.length > 0" class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Dato</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(dato, idx) in datosVarios" :key="idx">
                    <td>{{ dato.datovario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="empty-state">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p>No hay datos varios para este contrato</p>
            </div>
          </div>

          <!-- Tab Detalle Adeudos -->
          <div v-if="tabActiva === 'adeudos'">
            <div v-if="detalleAdeudos.length > 0">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead>
                    <tr>
                      <th>Rubro</th>
                      <th>Concepto</th>
                      <th>Cta. Aplicacion</th>
                      <th>Referencia</th>
                      <th>Descripcion</th>
                      <th class="text-right">Monto</th>
                      <th class="text-right">Acumulado</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(adeudo, idx) in detalleAdeudos"
                      :key="idx"
                      @dblclick="filtrarPorReferencia(adeudo.referencia)"
                      class="cursor-pointer"
                    >
                      <td>{{ adeudo.rubro }}</td>
                      <td>{{ adeudo.concepto }}</td>
                      <td>{{ adeudo.cuenta_aplicacion }}</td>
                      <td>{{ adeudo.referencia }}</td>
                      <td>{{ adeudo.descripcion }}</td>
                      <td class="text-right">{{ formatCurrency(adeudo.monto) }}</td>
                      <td class="text-right">{{ formatCurrency(adeudo.acumulado) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <p class="text-muted mt-2">
                <font-awesome-icon icon="info-circle" /> Doble clic en una fila para filtrar por referencia
              </p>

              <!-- Totales -->
              <div v-if="totalesAdeudos.length > 0" class="mt-3">
                <h6><font-awesome-icon icon="calculator" /> Totales por Cuenta</h6>
                <div class="table-responsive">
                  <table class="municipal-table">
                    <thead>
                      <tr>
                        <th>Cta. Aplicacion</th>
                        <th>Referencia</th>
                        <th class="text-right">Monto Total</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(total, idx) in totalesAdeudos" :key="idx">
                        <td>{{ total.cuenta_aplicacion }}</td>
                        <td>{{ total.referencia }}</td>
                        <td class="text-right font-weight-bold">{{ formatCurrency(total.monto) }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
            <div v-else class="empty-state">
              <font-awesome-icon icon="check-circle" class="empty-state-icon text-success" />
              <p>No hay adeudos para este contrato</p>
            </div>

            <!-- Boton limpiar filtro -->
            <div v-if="filtroReferencia" class="mt-3">
              <button type="button" class="btn-municipal-secondary" @click="limpiarFiltroReferencia">
                <font-awesome-icon icon="times" /> Limpiar filtro ({{ filtroReferencia }})
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button type="button" class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="salir">
              <font-awesome-icon icon="door-open" /> Salir
            </button>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="empty-state">
            <font-awesome-icon icon="search" class="empty-state-icon" />
            <h4>No se encontro el contrato</h4>
            <p>No existe contrato con el numero y tipo de aseo especificados.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Consulta Administrativa"
      componentName="Contratos_Cons_Admin"
    >
      <h3>Consulta Administrativa de Contratos</h3>
      <p>Vista administrativa completa con datos del contribuyente y detalle de adeudos.</p>

      <h4>Procedimiento:</h4>
      <ol>
        <li>Ingrese el numero de contrato</li>
        <li>Seleccione el tipo de aseo</li>
        <li>Presione Buscar</li>
        <li>Revise los datos del contribuyente en el encabezado</li>
        <li>Use las pestanas para ver Datos Varios o Detalle de Adeudos</li>
      </ol>

      <h4>Pestanas:</h4>
      <ul>
        <li><strong>Datos Varios:</strong> Informacion adicional del contrato</li>
        <li><strong>Detalle Adeudos:</strong> Lista de adeudos con rubros, conceptos y montos</li>
      </ul>

      <h4>Funcionalidades:</h4>
      <ul>
        <li>Doble clic en un adeudo para filtrar por referencia</li>
        <li>Totales por cuenta de aplicacion</li>
        <li>Leyendas y alertas de cobro</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const tiposAseo = ref([])
const numContrato = ref(null)
const tipoAseoSeleccionado = ref('')
const contratoEncontrado = ref(false)
const busquedaRealizada = ref(false)
const tabActiva = ref('datos')
const filtroReferencia = ref('')

// Datos
const encabezado = ref({})
const datosVarios = ref([])
const detalleAdeudos = ref([])
const totalesAdeudos = ref([])

// Formatear moneda
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      tiposAseo.value = data
      if (data.length >= 3) {
        tipoAseoSeleccionado.value = data[2].tipo_aseo
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Buscar contrato
const buscarContrato = async () => {
  if (!numContrato.value || numContrato.value === 0) {
    showToast('Ingrese un numero de contrato', 'warning')
    return
  }
  if (!tipoAseoSeleccionado.value) {
    showToast('Seleccione un tipo de aseo', 'warning')
    return
  }

  showLoading()
  busquedaRealizada.value = true
  contratoEncontrado.value = false
  encabezado.value = {}
  datosVarios.value = []
  detalleAdeudos.value = []
  totalesAdeudos.value = []
  filtroReferencia.value = ''

  try {
    // 1. Cargar encabezado
    const paramsEnc = [
      { nombre: 'p_tipo', valor: tipoAseoSeleccionado.value, tipo: 'string' },
      { nombre: 'p_numero', valor: numContrato.value, tipo: 'integer' }
    ]
    const dataEnc = await execute('admin_encabezados_18z', BASE_DB, paramsEnc, '', null, SCHEMA)

    if (dataEnc && dataEnc.length > 0 && dataEnc[0].propietario && dataEnc[0].propietario.trim() !== '') {
      encabezado.value = dataEnc[0]
      contratoEncontrado.value = true

      // Mostrar leyenda si existe
      if (encabezado.value.leyenda) {
        hideLoading()
        await Swal.fire({
          title: 'Informacion',
          text: encabezado.value.leyenda,
          icon: 'info'
        })
        showLoading()
      }

      // 2. Cargar datos varios
      await cargarDatosVarios()

      // 3. Cargar detalle adeudos
      await cargarDetalleAdeudos('')

    } else {
      hideLoading()
      showToast('No se encontro contrato con esos datos', 'warning')
      return
    }

  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  } finally {
    hideLoading()
  }
}

// Cargar datos varios
const cargarDatosVarios = async () => {
  try {
    const params = [
      { nombre: 'p_tipo', valor: tipoAseoSeleccionado.value, tipo: 'string' },
      { nombre: 'p_numero', valor: numContrato.value, tipo: 'integer' }
    ]
    const data = await execute('admin_datos_varios_18', BASE_DB, params, '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      datosVarios.value = data
    }
  } catch (error) {
    hideLoading()
    console.error('Error al cargar datos varios:', error)
  }
}

// Cargar detalle adeudos
const cargarDetalleAdeudos = async (pref) => {
  try {
    const params = [
      { nombre: 'p_tipo', valor: tipoAseoSeleccionado.value, tipo: 'string' },
      { nombre: 'p_numero', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'pref', valor: pref || '', tipo: 'string' }
    ]

    // Detalle
    const dataDetalle = await execute('admin_adeudos_detalle_18', BASE_DB, params, '', null, SCHEMA)
    if (dataDetalle && Array.isArray(dataDetalle)) {
      detalleAdeudos.value = dataDetalle
    }

    // Totales
    const dataTotales = await execute('admin_adeudos_detalle_18_tot', BASE_DB, params, '', null, SCHEMA)
    if (dataTotales && Array.isArray(dataTotales)) {
      totalesAdeudos.value = dataTotales
    }

  } catch (error) {
    hideLoading()
    console.error('Error al cargar adeudos:', error)
  }
}

// Filtrar por referencia (doble clic)
const filtrarPorReferencia = async (referencia) => {
  if (!referencia) return
  filtroReferencia.value = referencia
  showLoading()
  try {
    await cargarDetalleAdeudos(referencia)
  } finally {
    hideLoading()
  }
}

// Limpiar filtro referencia
const limpiarFiltroReferencia = async () => {
  filtroReferencia.value = ''
  showLoading()
  try {
    await cargarDetalleAdeudos('')
  } finally {
    hideLoading()
  }
}

// Limpiar
const limpiar = () => {
  numContrato.value = null
  contratoEncontrado.value = false
  busquedaRealizada.value = false
  encabezado.value = {}
  datosVarios.value = []
  detalleAdeudos.value = []
  totalesAdeudos.value = []
  filtroReferencia.value = ''
  tabActiva.value = 'datos'
}

// Salir
const salir = () => {
  router.push('/aseo-contratado')
}

// Inicializar
onMounted(async () => {
  showLoading()
  try {
    await cargarTiposAseo()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al inicializar')
  } finally {
    hideLoading()
  }
})
</script>
