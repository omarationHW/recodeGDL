<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta por Tipo de Aseo y Num. de Contrato</h1>
        <p>Aseo Contratado - Consulta detallada de contrato con adeudos</p>
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
          <div class="search-row">
            <div class="search-field">
              <label class="municipal-label">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option value="">Seleccione...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo_id" :value="tipo.cve_tipo">
                  {{ tipo.cve_tipo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="search-field">
              <label class="municipal-label">Numero de Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Numero"
                @keyup.enter="buscarContrato"
              />
            </div>
            <div class="search-field search-field-buttons">
              <button type="button" class="btn-municipal-primary" @click="buscarContrato" :disabled="cargando">
                <font-awesome-icon :icon="cargando ? 'spinner' : 'search'" :spin="cargando" />
                Aceptar
              </button>
              <button type="button" class="btn-municipal-secondary" @click="salir">
                <font-awesome-icon icon="door-open" /> Salir
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel Total (visible cuando hay contrato) -->
      <div v-if="contrato" class="mt-3">
        <!-- Datos del Contrato -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="file-alt" />
              Control Contrato: <strong>{{ contrato.control_contrato }}</strong>
              <span class="ms-3">Status: <strong>{{ contrato.status_contrato }}</strong></span>
            </h5>
            <div v-if="convenio" class="ms-auto">
              <button type="button" class="btn-municipal-warning" @click="verConvenio">
                <font-awesome-icon icon="handshake" />
                Contrato Conveniado {{ convenio.convenio }}
              </button>
            </div>
          </div>
          <div class="municipal-card-body">
            <div class="info-grid info-grid-4">
              <div class="info-item">
                <span class="info-label">Num. Contrato</span>
                <span class="info-value">{{ contrato.num_contrato }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Domicilio</span>
                <span class="info-value">{{ contrato.calle }}</span>
              </div>
              <div class="info-item">
                <span class="info-label"># Ext.</span>
                <span class="info-value">{{ contrato.numext }}</span>
              </div>
              <div class="info-item">
                <span class="info-label"># Int.</span>
                <span class="info-value">{{ contrato.numint }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Colonia</span>
                <span class="info-value">{{ contrato.colonia }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Sector</span>
                <span class="info-value">{{ contrato.sector }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Codigo Postal</span>
                <span class="info-value">{{ contrato.cp }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">R.F.C.</span>
                <span class="info-value">{{ contrato.rfc }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Municipio</span>
                <span class="info-value">{{ contrato.municipio }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Estado</span>
                <span class="info-value">{{ contrato.estado }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">C.U.R.P.</span>
                <span class="info-value">{{ contrato.curp }}</span>
              </div>
            </div>

            <div class="info-grid info-grid-3 mt-3">
              <div class="info-item">
                <span class="info-label">Numero Empresa</span>
                <span class="info-value">{{ contrato.num_empresa }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Nombre Empresa</span>
                <span class="info-value">{{ contrato.nombre_empresa }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Representante Empresa</span>
                <span class="info-value">{{ contrato.representante_empresa }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Tipo Aseo</span>
                <span class="info-value">{{ contrato.tipo_aseo }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Tipo Aseo Descripcion</span>
                <span class="info-value">{{ contrato.tipo_aseo_descripcion }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Cve Recoleccion</span>
                <span class="info-value">{{ contrato.cve_recoleccion }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Unidad Recoleccion</span>
                <span class="info-value">{{ contrato.unidad_recoleccion }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Cantidad Recoleccion</span>
                <span class="info-value info-value-highlight">{{ contrato.cantidad_recoleccion }}</span>
              </div>
            </div>

            <!-- Licencias relacionadas -->
            <div v-if="licencias.length > 0" class="mt-3">
              <div class="municipal-alert municipal-alert-info">
                <font-awesome-icon icon="id-card" />
                <div>
                  <strong>Licencia:</strong> {{ licencias[0].num_licencia }} -
                  {{ licencias[0].actividad }} -
                  {{ licencias[0].propietario }}
                  <div v-if="licencias.length > 1" class="mt-2">
                    <button type="button" class="btn-municipal-link btn-sm" @click="irPrimerLicencia">
                      <font-awesome-icon icon="angle-double-left" />
                    </button>
                    <button type="button" class="btn-municipal-link btn-sm" @click="irAnteriorLicencia">
                      <font-awesome-icon icon="angle-left" />
                    </button>
                    <button type="button" class="btn-municipal-link btn-sm" @click="irSiguienteLicencia">
                      <font-awesome-icon icon="angle-right" />
                    </button>
                    <button type="button" class="btn-municipal-link btn-sm" @click="irUltimaLicencia">
                      <font-awesome-icon icon="angle-double-right" />
                    </button>
                    <span class="ms-2">{{ indiceLicencia + 1 }} de {{ licencias.length }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Panel Adeudos -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-body p-0">
            <div class="row g-0">
              <!-- Adeudos Detalle (izquierda) -->
              <div class="col-md-8">
                <div class="tabs-container">
                  <div class="tabs-header">
                    <button
                      type="button"
                      :class="['tab-button', tabActiva === 'aseo' ? 'active' : '']"
                      @click="tabActiva = 'aseo'"
                    >
                      Adeudos Aseo
                    </button>
                    <button
                      type="button"
                      :class="['tab-button', tabActiva === 'odoo' ? 'active' : '']"
                      @click="tabActiva = 'odoo'"
                    >
                      Adeudos Odoo
                    </button>
                  </div>
                  <div class="tabs-content">
                    <!-- Tab Adeudos Aseo -->
                    <div v-show="tabActiva === 'aseo'" class="tab-panel">
                      <div class="table-container table-sm">
                        <table class="municipal-table">
                          <thead>
                            <tr>
                              <th>Periodo</th>
                              <th>Concepto</th>
                              <th>Cant. Recolec</th>
                              <th>Adeudos</th>
                              <th>Recargos</th>
                              <th>Multa</th>
                              <th>Gastos</th>
                              <th>Actualiz.</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr
                              v-for="adeudo in adeudosAseo"
                              :key="adeudo.periodo"
                              @dblclick="filtrarPorPeriodo(adeudo.periodo)"
                              class="cursor-pointer"
                            >
                              <td>{{ adeudo.periodo }}</td>
                              <td>{{ adeudo.concepto }}</td>
                              <td class="text-center">{{ adeudo.cant_recolec }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.importe_adeudos) }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.importe_recargos) }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.importe_multa) }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.importe_gastos) }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.actualizacion) }}</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <!-- Tab Adeudos Odoo -->
                    <div v-show="tabActiva === 'odoo'" class="tab-panel">
                      <div class="table-container table-sm">
                        <table class="municipal-table">
                          <thead>
                            <tr>
                              <th>Referencia</th>
                              <th>Rubro</th>
                              <th>Concepto</th>
                              <th>Descripcion</th>
                              <th>Monto</th>
                              <th>Acumulado</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr
                              v-for="adeudo in adeudosOdoo"
                              :key="adeudo.referencia + '-' + adeudo.rubro"
                              @dblclick="filtrarPorReferencia(adeudo.referencia)"
                              class="cursor-pointer"
                            >
                              <td>{{ adeudo.referencia }}</td>
                              <td class="text-center">{{ adeudo.rubro }}</td>
                              <td class="text-center">{{ adeudo.concepto }}</td>
                              <td>{{ adeudo.descripcion }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.monto) }}</td>
                              <td class="text-right">${{ formatCurrency(adeudo.acumulado) }}</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Totales (derecha) -->
              <div class="col-md-4">
                <div class="p-3 bg-light h-100">
                  <h6 class="mb-3"><font-awesome-icon icon="calculator" /> Totales por Cuenta</h6>
                  <div class="table-container table-sm">
                    <table class="municipal-table">
                      <thead>
                        <tr>
                          <th>Cuenta</th>
                          <th>Referencia</th>
                          <th>Importe</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="total in totales" :key="total.cuenta_aplicacion">
                          <td>{{ total.cuenta_aplicacion }}</td>
                          <td>{{ total.referencia }}</td>
                          <td class="text-right">${{ formatCurrency(total.monto) }}</td>
                        </tr>
                      </tbody>
                      <tfoot v-if="totales.length > 0">
                        <tr>
                          <th colspan="2">TOTAL</th>
                          <th class="text-right">${{ formatCurrency(totalGeneral) }}</th>
                        </tr>
                      </tfoot>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje sin contrato -->
      <div v-if="buscado && !contrato" class="municipal-alert municipal-alert-warning mt-3">
        <font-awesome-icon icon="exclamation-triangle" />
        {{ mensajeError || 'No se encontro el contrato especificado.' }}
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Consulta de Contratos"
      componentName="Contratos_Consulta"
    >
      <h3>Consulta por Tipo de Aseo y Num. de Contrato</h3>
      <p>Este modulo permite consultar informacion detallada de un contrato de aseo incluyendo sus adeudos.</p>

      <h4>Uso:</h4>
      <ol>
        <li>Seleccione el tipo de aseo</li>
        <li>Ingrese el numero de contrato</li>
        <li>Presione "Aceptar"</li>
      </ol>

      <h4>Informacion Mostrada:</h4>
      <ul>
        <li><strong>Datos del Contrato:</strong> Domicilio, empresa, tipo aseo, unidades</li>
        <li><strong>Adeudos Aseo:</strong> Desglose por periodo (doble clic filtra)</li>
        <li><strong>Adeudos Odoo:</strong> Vista alternativa de adeudos</li>
        <li><strong>Totales:</strong> Suma por cuenta de aplicacion</li>
        <li><strong>Licencias:</strong> Licencias relacionadas al contrato</li>
        <li><strong>Convenio:</strong> Si existe convenio se muestra boton</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const cargando = ref(false)
const buscado = ref(false)
const tiposAseo = ref([])
const tipoAseoSeleccionado = ref('')
const numContrato = ref(null)
const contrato = ref(null)
const mensajeError = ref('')
const adeudosAseo = ref([])
const adeudosOdoo = ref([])
const totales = ref([])
const convenio = ref(null)
const licencias = ref([])
const indiceLicencia = ref(0)
const tabActiva = ref('aseo')
const filtroReferencia = ref('')

// Computed
const totalGeneral = computed(() => {
  return totales.value.reduce((sum, t) => sum + parseFloat(t.monto || 0), 0)
})

// Cargar tipos de aseo al montar
onMounted(async () => {
  await cargarTiposAseo()
})

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo', BASE_DB, [], '', null, SCHEMA)
    tiposAseo.value = data || []
    // Seleccionar el tercero por defecto (indice 2) como en Delphi
    if (tiposAseo.value.length > 2) {
      tipoAseoSeleccionado.value = tiposAseo.value[2].cve_tipo
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Buscar contrato
const buscarContrato = async () => {
  if (!tipoAseoSeleccionado.value) {
    showToast('Seleccione un tipo de aseo', 'warning')
    return
  }
  if (!numContrato.value || numContrato.value <= 0) {
    showToast('Ingrese un numero de contrato valido', 'warning')
    return
  }

  cargando.value = true
  buscado.value = true
  contrato.value = null
  mensajeError.value = ''
  filtroReferencia.value = ''
  showLoading()

  try {
    const params = [
      { nombre: 'p_tipo', valor: tipoAseoSeleccionado.value, tipo: 'string' },
      { nombre: 'p_numero', valor: numContrato.value, tipo: 'integer' }
    ]

    const data = await execute('sp16_contratos_ind', BASE_DB, params, '', null, SCHEMA)

    hideLoading()

    if (data && data.length > 0) {
      const resultado = data[0]

      if (resultado.status === -1) {
        // Contrato no encontrado
        mensajeError.value = resultado.leyenda || 'Contrato no encontrado'
        await Swal.fire({
          title: 'Contrato no encontrado',
          text: mensajeError.value,
          icon: 'warning'
        })
      } else {
        contrato.value = resultado

        // Cargar adeudos con referencia del año/mes actual
        const ahora = new Date()
        const refInicial = `${ahora.getFullYear()}/12`
        await cargarAdeudos(refInicial)

        // Cargar convenio
        await cargarConvenio(resultado.control_contrato)

        // Cargar licencias
        await cargarLicencias(resultado.control_contrato)
      }
    } else {
      mensajeError.value = 'No se obtuvo respuesta del servidor'
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  } finally {
    cargando.value = false
  }
}

// Cargar adeudos
const cargarAdeudos = async (referencia) => {
  if (!contrato.value) return

  filtroReferencia.value = referencia

  try {
    // Adeudos formato F02
    const paramsF02 = [
      { nombre: 'p_tipo', valor: contrato.value.tipo_aseo, tipo: 'string' },
      { nombre: 'p_numero', valor: contrato.value.num_contrato, tipo: 'integer' },
      { nombre: 'p_rep', valor: 'A', tipo: 'string' },
      { nombre: 'pref', valor: referencia, tipo: 'string' }
    ]
    const dataF02 = await execute('sp16_adeudos_f02', BASE_DB, paramsF02, '', null, SCHEMA)
    adeudosAseo.value = dataF02 || []

    // Adeudos formato Odoo
    const paramsOdoo = [
      { nombre: 'p_tipo', valor: contrato.value.tipo_aseo, tipo: 'string' },
      { nombre: 'p_numero', valor: contrato.value.num_contrato, tipo: 'integer' },
      { nombre: 'pref', valor: referencia, tipo: 'string' }
    ]
    const dataOdoo = await execute('admin_adeudos_detalle_18', BASE_DB, paramsOdoo, '', null, SCHEMA)
    adeudosOdoo.value = dataOdoo || []

    // Totales
    const dataTot = await execute('admin_adeudos_detalle_18_tot', BASE_DB, paramsOdoo, '', null, SCHEMA)
    totales.value = dataTot || []

  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar adeudos')
  }
}

// Cargar convenio
const cargarConvenio = async (controlContrato) => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_convenio_contrato', BASE_DB, params, '', null, SCHEMA)
    convenio.value = data && data.length > 0 ? data[0] : null
  } catch (error) {
    hideLoading()
    // Ignorar error si no existe el SP
    convenio.value = null
  }
}

// Cargar licencias
const cargarLicencias = async (controlContrato) => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_licencias_contrato', BASE_DB, params, '', null, SCHEMA)
    licencias.value = data || []
    indiceLicencia.value = 0
  } catch (error) {
    hideLoading()
    // Ignorar error si no existe el SP
    licencias.value = []
  }
}

// Filtrar por periodo (doble clic en grid aseo)
const filtrarPorPeriodo = (periodo) => {
  cargarAdeudos(periodo)
}

// Filtrar por referencia (doble clic en grid odoo)
const filtrarPorReferencia = (referencia) => {
  cargarAdeudos(referencia)
}

// Ver convenio
const verConvenio = () => {
  if (convenio.value) {
    Swal.fire({
      title: 'Convenio',
      html: `
        <p><strong>Convenio:</strong> ${convenio.value.convenio}</p>
        <p><strong>ID:</strong> ${convenio.value.id_conv_resto}</p>
      `,
      icon: 'info'
    })
  }
}

// Navegacion licencias
const irPrimerLicencia = () => { indiceLicencia.value = 0 }
const irAnteriorLicencia = () => { if (indiceLicencia.value > 0) indiceLicencia.value-- }
const irSiguienteLicencia = () => { if (indiceLicencia.value < licencias.value.length - 1) indiceLicencia.value++ }
const irUltimaLicencia = () => { indiceLicencia.value = licencias.value.length - 1 }

// Formateo
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

// Salir
const salir = () => {
  router.push('/aseo-contratado')
}
</script>
