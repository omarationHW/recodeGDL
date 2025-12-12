<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Adeudos</h1>
        <p>Aseo Contratado - Administración de adeudos, pagos y estado de cuenta</p>
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
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Tabs de navegación -->
      <div class="municipal-tabs">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          :class="['municipal-tab', { active: activeTab === tab.id }]"
          @click="activeTab = tab.id"
        >
          <font-awesome-icon :icon="tab.icon" />
          {{ tab.label }}
        </button>
      </div>

      <!-- Tab: Buscar Contrato -->
      <div v-if="activeTab === 'buscar'" class="tab-content">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <input type="number" v-model="searchParams.num_contrato" class="municipal-form-control"
                  placeholder="Ingrese número de contrato" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Número de Empresa</label>
                <input type="number" v-model="searchParams.num_empresa" class="municipal-form-control"
                  placeholder="Ingrese número de empresa" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Nombre de Empresa</label>
                <input type="text" v-model="searchParams.nombre_empresa" class="municipal-form-control"
                  placeholder="Buscar por nombre" />
              </div>
            </div>
            <div class="button-group">
              <button class="btn-municipal-primary" @click="buscarContrato" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiarBusqueda">
                <font-awesome-icon icon="times" /> Limpiar
              </button>
            </div>

            <!-- Resultados de búsqueda -->
            <div v-if="contratos.length > 0" class="table-responsive mt-3">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Contrato</th>
                    <th>Empresa</th>
                    <th>Tipo Aseo</th>
                    <th>Zona</th>
                    <th>Status</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="contrato in contratos" :key="contrato.control_contrato" class="row-hover">
                    <td><strong>{{ contrato.num_contrato }}</strong></td>
                    <td>{{ contrato.nom_emp }}</td>
                    <td>{{ contrato.desc_aseo }}</td>
                    <td>{{ contrato.zona }}-{{ contrato.sub_zona }}</td>
                    <td>
                      <span :class="['badge', contrato.status_vigencia === 'V' ? 'badge-success' : 'badge-info']">
                        {{ contrato.status_vigencia === 'V' ? 'Vigente' : 'Nuevo' }}
                      </span>
                    </td>
                    <td>
                      <div class="button-group button-group-sm">
                        <button class="btn-municipal-info btn-sm" @click="verEstadoCuenta(contrato)" title="Ver Estado de Cuenta">
                          <font-awesome-icon icon="file-invoice" />
                        </button>
                        <button class="btn-municipal-primary btn-sm" @click="registrarPago(contrato)" title="Registrar Pago">
                          <font-awesome-icon icon="dollar-sign" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Carga Masiva -->
      <div v-if="activeTab === 'carga'" class="tab-content">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="upload" /> Carga Masiva de Adeudos</h5>
          </div>
          <div class="municipal-card-body">
            <div class="municipal-alert municipal-alert-warning">
              <font-awesome-icon icon="exclamation-triangle" />
              Esta operación generará adeudos para todos los contratos vigentes del ejercicio seleccionado.
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Ejercicio Fiscal</label>
                <input type="number" v-model="cargaMasiva.ejercicio" class="municipal-form-control"
                  :placeholder="new Date().getFullYear()" min="2020" :max="new Date().getFullYear() + 1" />
              </div>
            </div>
            <button class="btn-municipal-primary" @click="ejecutarCargaMasiva" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" />
              Ejecutar Carga Masiva
            </button>

            <!-- Resultado de carga -->
            <div v-if="cargaMasiva.resultado" class="mt-3 alert" :class="cargaMasiva.resultado.success ? 'alert-success' : 'alert-danger'">
              <strong>{{ cargaMasiva.resultado.message }}</strong>
              <p v-if="cargaMasiva.resultado.success">
                Contratos procesados: {{ cargaMasiva.resultado.contratos_procesados }}<br />
                Adeudos generados: {{ cargaMasiva.resultado.adeudos_generados }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Estado de Cuenta -->
      <div v-if="activeTab === 'estado'" class="tab-content">
        <div v-if="contratoSeleccionado" class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="file-invoice" />
              Estado de Cuenta - Contrato #{{ contratoSeleccionado.num_contrato }}
            </h5>
          </div>
          <div class="municipal-card-body">
            <!-- Información del contrato -->
            <div class="detail-grid mb-3">
              <div class="detail-item">
                <label class="detail-label">Empresa</label>
                <p class="detail-value">{{ contratoSeleccionado.nom_emp }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Representante</label>
                <p class="detail-value">{{ contratoSeleccionado.representante }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Tipo de Aseo</label>
                <p class="detail-value">{{ contratoSeleccionado.desc_aseo }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Zona</label>
                <p class="detail-value">{{ contratoSeleccionado.nom_zona }}</p>
              </div>
            </div>

            <!-- Estado de cuenta -->
            <div class="table-responsive" v-if="estadoCuenta.length > 0">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Periodo</th>
                    <th>Concepto</th>
                    <th class="text-right">Adeudo</th>
                    <th class="text-right">Recargo</th>
                    <th class="text-right">Multa</th>
                    <th class="text-right">Gastos</th>
                    <th class="text-right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(edo, idx) in estadoCuenta" :key="idx">
                    <td>{{ edo.periodo }}</td>
                    <td>{{ edo.concepto }}</td>
                    <td class="text-right">{{ formatCurrency(edo.importe_adeudo) }}</td>
                    <td class="text-right">{{ formatCurrency(edo.importe_recargo) }}</td>
                    <td class="text-right">{{ formatCurrency(edo.importe_multa) }}</td>
                    <td class="text-right">{{ formatCurrency(edo.importe_gastos) }}</td>
                    <td class="text-right"><strong>{{ formatCurrency(edo.total_periodo) }}</strong></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="table-total">
                    <td colspan="6" class="text-right"><strong>TOTAL ADEUDO:</strong></td>
                    <td class="text-right"><strong>{{ formatCurrency(totalAdeudo) }}</strong></td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div class="button-group mt-3">
              <button class="btn-municipal-secondary" @click="cerrarEstadoCuenta">
                <font-awesome-icon icon="arrow-left" /> Regresar
              </button>
              <button class="btn-municipal-primary" @click="imprimirEstadoCuenta">
                <font-awesome-icon icon="print" /> Imprimir
              </button>
            </div>
          </div>
        </div>
        <div v-else class="municipal-card">
          <div class="municipal-card-body text-center text-muted">
            <font-awesome-icon icon="search" size="3x" class="mb-3" />
            <p>Seleccione un contrato de la búsqueda para ver su estado de cuenta</p>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Gestión de Adeudos">
      <h3>Gestión de Adeudos</h3>
      <p>Módulo para administración completa de adeudos del servicio de aseo contratado.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Buscar Contrato:</strong> Localice contratos por número, empresa o nombre</li>
        <li><strong>Carga Masiva:</strong> Genere adeudos automáticamente para un ejercicio fiscal completo</li>
        <li><strong>Estado de Cuenta:</strong> Consulte el detalle de adeudos, recargos y pagos por contrato</li>
      </ul>
      <h4>Proceso Recomendado:</h4>
      <ol>
        <li>Al inicio del ejercicio fiscal, ejecutar Carga Masiva</li>
        <li>Usar Buscar Contrato para localizar contribuyentes</li>
        <li>Consultar Estado de Cuenta para verificar saldos</li>
        <li>Registrar pagos conforme se realicen</li>
      </ol>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const activeTab = ref('buscar')
const showDocumentation = ref(false)

const tabs = [
  { id: 'buscar', label: 'Buscar Contrato', icon: 'search' },
  { id: 'carga', label: 'Carga Masiva', icon: 'upload' },
  { id: 'estado', label: 'Estado de Cuenta', icon: 'file-invoice' }
]

const searchParams = ref({
  num_contrato: null,
  num_empresa: null,
  nombre_empresa: ''
})

const contratos = ref([])
const contratoSeleccionado = ref(null)
const estadoCuenta = ref([])

const cargaMasiva = ref({
  ejercicio: new Date().getFullYear(),
  resultado: null
})

const totalAdeudo = computed(() => {
  return estadoCuenta.value.reduce((sum, edo) => sum + parseFloat(edo.total_periodo || 0), 0)
})

const buscarContrato = async () => {
  if (!searchParams.value.num_contrato && !searchParams.value.num_empresa && !searchParams.value.nombre_empresa) {
    showToast('Ingrese al menos un criterio de búsqueda', 'warning')
    return
  }

  showLoading()
  try {
    const response = await execute('SP_ASEO_ADEUDOS_BUSCAR_CONTRATO', 'aseo_contratado', {
      p_num_contrato: searchParams.value.num_contrato || null,
      p_num_empresa: searchParams.value.num_empresa || null,
      p_nombre_empresa: searchParams.value.nombre_empresa || null
    })
    if (response) {
      contratos.value = response
      if (contratos.value.length === 0) {
        showToast('No se encontraron contratos', 'info')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al buscar contratos', 'error')
  } finally {
    hideLoading()
  }
}

const limpiarBusqueda = () => {
  searchParams.value = { num_contrato: null, num_empresa: null, nombre_empresa: '' }
  contratos.value = []
}

const verEstadoCuenta = async (contrato) => {
  contratoSeleccionado.value = contrato
  activeTab.value = 'estado'
  showLoading()

  try {
    const response = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contrato.control_contrato,
      p_status_vigencia: 'D',
      p_fecha_hasta: null
    })
    if (response) {
      estadoCuenta.value = response
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al cargar estado de cuenta', 'error')
  } finally {
    hideLoading()
  }
}

const cerrarEstadoCuenta = () => {
  contratoSeleccionado.value = null
  estadoCuenta.value = []
  activeTab.value = 'buscar'
}

const registrarPago = (contrato) => {
  showToast('Funcionalidad de registro de pagos en desarrollo', 'info')
}

const ejecutarCargaMasiva = async () => {
  if (!cargaMasiva.value.ejercicio) {
    showToast('Ingrese el ejercicio fiscal', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Ejecutar Carga Masiva?',
    html: `<p>Se generarán adeudos para todos los contratos vigentes del ejercicio <strong>${cargaMasiva.value.ejercicio}</strong></p>
           <p class="text-warning">Esta operación puede tardar varios minutos.</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, ejecutar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading()
  cargaMasiva.value.resultado = null

  try {
    const response = await execute('SP_ASEO_ADEUDOS_CARGA_MASIVA', 'aseo_contratado', {
      p_ejercicio: cargaMasiva.value.ejercicio,
      p_usuario_id: 1
    })
    if (response && response[0]) {
      cargaMasiva.value.resultado = response[0]
      if (cargaMasiva.value.resultado.success) {
        showToast('Carga masiva completada exitosamente', 'success')
      } else {
        showToast(cargaMasiva.value.resultado.message, 'error')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al ejecutar carga masiva', 'error')
  } finally {
    hideLoading()
  }
}

const imprimirEstadoCuenta = () => {
  window.print()
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  // Inicialización si es necesaria
})
</script>

