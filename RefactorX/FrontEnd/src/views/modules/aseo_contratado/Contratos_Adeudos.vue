<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos por Contrato</h1>
        <p>Aseo Contratado - Consulta detallada de adeudos por contrato</p>
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
        <h5>Búsqueda de Contrato</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-6">
            <div class="input-group">
              <input type="text" class="municipal-form-control" v-model="busqueda" @keyup.enter="buscar"
                placeholder="Número de contrato o cuenta predial" />
              <button class="btn-municipal-primary" @click="buscar" :disabled="cargando">
                <font-awesome-icon icon="search" class="me-1" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratoSeleccionado">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header">
        <h5>Datos del Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
              <strong>Status:</strong>
              <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Inactivo' }}
              </span>
            </div>
            <div class="col-md-3">
              <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}<br>
              <strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}
            </div>
            <div class="col-md-3">
              <strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}<br>
              <strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}
            </div>
            <div class="col-md-3">
              <strong>Empresa:</strong> {{ contratoSeleccionado.empresa }}<br>
              <strong>Cuota Mensual:</strong> ${{ formatCurrency(contratoSeleccionado.cuota_mensual) }}
            </div>
          </div>
        </div>
      </div>

      <div class="stats-dashboard mb-4">
        <div class="stat-item" :class="totalAdeudos > 0 ? 'stat-danger' : 'stat-success'">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="exclamation-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ adeudos.length }}</div>
            <div class="stat-label-mini">Total Adeudos</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="money-bill-wave" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(totalAdeudos) }}</div>
            <div class="stat-label-mini">Monto Total</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="receipt" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ pagosRealizados }}</div>
            <div class="stat-label-mini">Pagos Realizados</div>
          </div>
        </div>
        <div class="stat-item stat-secondary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="wallet" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(totalAdeudos) }}</div>
            <div class="stat-label-mini">Saldo</div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Detalle de Adeudos</h6>
          <div>
            <select class="municipal-form-control form-select-sm" v-model="filtroEjercicio" style="width: 150px;">
              <option value="">Todos los años</option>
              <option v-for="year in ejercicios" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Folio</th>
                  <th>Periodo</th>
                  <th>Operación</th>
                  <th>Vencimiento</th>
                  <th class="text-end">Cuota Base</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Gastos</th>
                  <th class="text-end">Total</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudosFiltrados" :key="adeudo.folio">
                  <td>{{ adeudo.folio }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ formatOperacion(adeudo.cve_operacion) }}</td>
                  <td>{{ formatFecha(adeudo.fecha_vencimiento) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                  <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                  <td>
                    <span class="badge" :class="adeudo.status === 'P' ? 'bg-danger' : 'bg-success'">
                      {{ adeudo.status === 'P' ? 'Pendiente' : 'Pagado' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Adeudos por Contrato - Ayuda">
      <h6>Descripción</h6>
      <p>Consulta todos los adeudos asociados a un contrato específico.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
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
const busqueda = ref('')
const contratoSeleccionado = ref(null)
const adeudos = ref([])
const filtroEjercicio = ref('')

const ejercicios = computed(() => {
  return [...new Set(adeudos.value.map(a => a.periodo?.substring(0, 4)))].filter(Boolean).sort().reverse()
})

const adeudosFiltrados = computed(() => {
  if (!filtroEjercicio.value) return adeudos.value
  return adeudos.value.filter(a => a.periodo?.startsWith(filtroEjercicio.value))
})

const totalAdeudos = computed(() => {
  return adeudosFiltrados.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const pagosRealizados = computed(() => {
  return adeudos.value.filter(a => a.status !== 'P').length
})

const buscar = async () => {
  if (!busqueda.value) {
    showToast('Ingrese un número de contrato o cuenta predial', 'warning')
    return
  }
  cargando.value = true
  try {
    const [respContrato] = await Promise.all([
      execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', { p_num_contrato: busqueda.value })
    ])
    if (respContrato?.length > 0) {
      contratoSeleccionado.value = respContrato[0]
      const respAdeudos = await execute('SP_ASEO_ADEUDOS_POR_CONTRATO', 'aseo_contratado', {
        p_control_contrato: respContrato[0].control_contrato
      })
      adeudos.value = respAdeudos || []
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
    }
  } catch (error) {
    handleError(error, 'Error al buscar')
  } finally {
    cargando.value = false
  }
}

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

const formatOperacion = (cve) => {
  const ops = { 'C': 'Cuota', 'R': 'Recargo', 'M': 'Multa', 'G': 'Gastos' }
  return ops[cve] || cve
}
</script>

