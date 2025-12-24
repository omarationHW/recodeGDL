<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Generar Adeudos</h1>
        <p>Aseo Contratado - Consulta y generación de nuevos adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contratos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <input type="number" v-model="searchParams.num_contrato" class="municipal-form-control"
                placeholder="Número de contrato" @keyup.enter="buscarContrato" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Número de Empresa</label>
              <input type="number" v-model="searchParams.num_empresa" class="municipal-form-control"
                placeholder="Número de empresa" @keyup.enter="buscarContrato" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nombre de Empresa</label>
              <input type="text" v-model="searchParams.nombre_empresa" class="municipal-form-control"
                placeholder="Buscar por nombre" @keyup.enter="buscarContrato" />
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

          <!-- Resultados -->
          <div v-if="contratos.length > 0" class="table-responsive mt-3">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Representante</th>
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
                  <td>{{ contrato.representante }}</td>
                  <td>{{ contrato.desc_aseo }}</td>
                  <td>{{ contrato.zona }}-{{ contrato.sub_zona }}</td>
                  <td>
                    <span :class="['badge', contrato.status_vigencia === 'V' ? 'badge-success' : 'badge-info']">
                      {{ getStatusLabel(contrato.status_vigencia) }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="seleccionarContrato(contrato)" title="Seleccionar">
                      <font-awesome-icon icon="check" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Información del Contrato Seleccionado -->
      <div v-if="contratoSeleccionado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-contract" /> Contrato #{{ contratoSeleccionado.num_contrato }}</h5>
        </div>
        <div class="municipal-card-body">
          <div class="detail-grid">
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
              <label class="detail-label">Unidades</label>
              <p class="detail-value">{{ contratoSeleccionado.cantidad_recolec }} - {{ contratoSeleccionado.desc_recolec }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Domicilio</label>
              <p class="detail-value">{{ contratoSeleccionado.domicilio }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Zona</label>
              <p class="detail-value">{{ contratoSeleccionado.nom_zona }}</p>
            </div>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-primary" @click="verEstadoCuenta">
              <font-awesome-icon icon="file-invoice-dollar" /> Ver Estado de Cuenta
            </button>
            <button class="btn-municipal-primary" @click="generarAdeudos">
              <font-awesome-icon icon="plus" /> Generar Adeudos
            </button>
            <button class="btn-municipal-secondary" @click="contratoSeleccionado = null">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Estado de Cuenta -->
      <div v-if="estadoCuenta.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-invoice" /> Estado de Cuenta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo</th>
                  <th>Concepto</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right">Recargo</th>
                  <th class="text-right">Multa</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Actualización</th>
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
                  <td class="text-right">{{ formatCurrency(edo.importe_actualizacion) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(edo.total_periodo) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="7" class="text-right"><strong>TOTAL ADEUDO:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalAdeudo) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Generar Adeudos">
      <h3>Generar Nuevos Adeudos</h3>
      <p>Este módulo permite buscar contratos y consultar o generar sus adeudos.</p>
      <h4>Procedimiento:</h4>
      <ol>
        <li>Busque el contrato por número, empresa o nombre</li>
        <li>Seleccione el contrato de la lista</li>
        <li>Revise el estado de cuenta actual</li>
        <li>Genere nuevos adeudos si es necesario</li>
      </ol>
      <h4>Notas:</h4>
      <ul>
        <li>Solo se muestran contratos con status Vigente (V) o Nuevo (N)</li>
        <li>El estado de cuenta muestra todos los movimientos pendientes</li>
        <li>Los adeudos se generan mensualmente según las unidades contratadas</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const searchParams = ref({ num_contrato: null, num_empresa: null, nombre_empresa: '' })
const contratos = ref([])
const contratoSeleccionado = ref(null)
const estadoCuenta = ref([])

const totalAdeudo = computed(() => {
  return estadoCuenta.value.reduce((sum, edo) => sum + parseFloat(edo.total_periodo || 0), 0)
})

const buscarContrato = async () => {
  if (!searchParams.value.num_contrato && !searchParams.value.num_empresa && !searchParams.value.nombre_empresa) {
    showToast('Ingrese al menos un criterio de búsqueda', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute('SP_ASEO_ADEUDOS_BUSCAR_CONTRATO', 'aseo_contratado', {
      p_num_contrato: searchParams.value.num_contrato || null,
      p_num_empresa: searchParams.value.num_empresa || null,
      p_nombre_empresa: searchParams.value.nombre_empresa || null
    })
    if (response && response.data) {
      contratos.value = response.data
      if (contratos.value.length === 0) {
        showToast('No se encontraron contratos', 'info')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al buscar contratos', 'error')
  } finally {
    loading.value = false
  }
}

const limpiarBusqueda = () => {
  searchParams.value = { num_contrato: null, num_empresa: null, nombre_empresa: '' }
  contratos.value = []
  contratoSeleccionado.value = null
  estadoCuenta.value = []
}

const seleccionarContrato = (contrato) => {
  contratoSeleccionado.value = contrato
  estadoCuenta.value = []
}

const verEstadoCuenta = async () => {
  if (!contratoSeleccionado.value) return

  loading.value = true
  try {
    const response = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_status_vigencia: 'D',
      p_fecha_hasta: null
    })
    if (response && response.data) {
      estadoCuenta.value = response.data
      if (estadoCuenta.value.length === 0) {
        showToast('No hay adeudos pendientes para este contrato', 'info')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al cargar estado de cuenta', 'error')
  } finally {
    loading.value = false
  }
}

const generarAdeudos = async () => {
  const result = await Swal.fire({
    title: '¿Generar Adeudos?',
    text: 'Se generarán los adeudos pendientes para este contrato',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    showToast('Funcionalidad en desarrollo', 'info')
  }
}

const getStatusLabel = (status) => {
  const labels = { V: 'Vigente', N: 'Nuevo', B: 'Baja', C: 'Cancelado' }
  return labels[status] || status
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>
