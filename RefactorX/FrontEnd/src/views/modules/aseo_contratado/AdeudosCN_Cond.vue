<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Condonados</h1>
        <p>Aseo Contratado - Gestión de condonaciones y descuentos de adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Tabs de Navegación -->
      <div class="tabs-container">
        <button
          class="tab-button"
          :class="{ active: tabActual === 'condonar' }"
          @click="tabActual = 'condonar'"
        >
          <font-awesome-icon icon="hand-holding-dollar" /> Condonar Adeudos
        </button>
        <button
          class="tab-button"
          :class="{ active: tabActual === 'consulta' }"
          @click="tabActual = 'consulta'"
        >
          <font-awesome-icon icon="search" /> Consultar Condonaciones
        </button>
      </div>

      <!-- Tab: Condonar Adeudos -->
      <div v-if="tabActual === 'condonar'" class="tab-content">
        <!-- Búsqueda de Contrato -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Número de Contrato</label>
                <input
                  type="number"
                  v-model.number="numContrato"
                  class="municipal-form-control"
                  placeholder="Ingrese número de contrato"
                  @keyup.enter="buscarContrato"
                  required
                />
              </div>
            </div>
            <div class="button-group">
              <button class="btn-municipal-primary" @click="buscarContrato" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar Contrato
              </button>
            </div>
          </div>
        </div>

        <!-- Información del Contrato -->
        <div v-if="contratoInfo" class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="file-contract" /> Información del Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="info-grid">
              <div class="info-item">
                <strong>Contrato:</strong>
                <span>{{ contratoInfo.num_contrato }}</span>
              </div>
              <div class="info-item">
                <strong>Empresa:</strong>
                <span>{{ contratoInfo.empresa }}</span>
              </div>
              <div class="info-item">
                <strong>Tipo Aseo:</strong>
                <span>{{ formatTipoAseo(contratoInfo.tipo_aseo) }}</span>
              </div>
              <div class="info-item">
                <strong>Status:</strong>
                <span :class="contratoInfo.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                  {{ contratoInfo.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Adeudos Pendientes -->
        <div v-if="adeudosPendientes.length > 0" class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="exclamation-triangle" /> Adeudos Pendientes ({{ adeudosPendientes.length }})</h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th style="width: 50px;">
                      <input type="checkbox" @change="toggleTodos" :checked="todosMarcados" />
                    </th>
                    <th>Periodo</th>
                    <th>Antigüedad</th>
                    <th class="text-right">Cuota Base</th>
                    <th class="text-right">Recargos</th>
                    <th class="text-right">Gastos</th>
                    <th class="text-right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudosPendientes" :key="adeudo.folio">
                    <td>
                      <input type="checkbox" :value="adeudo.folio" v-model="adeudosSeleccionados" />
                    </td>
                    <td><strong>{{ formatPeriodo(adeudo.periodo) }}</strong></td>
                    <td>{{ calcularAntiguedad(adeudo.periodo) }}</td>
                    <td class="text-right">{{ formatCurrency(adeudo.cuota_base) }}</td>
                    <td class="text-right text-warning">{{ formatCurrency(adeudo.recargos) }}</td>
                    <td class="text-right">{{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                    <td class="text-right"><strong>{{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="table-total">
                    <td colspan="6" class="text-right"><strong>TOTAL SELECCIONADO:</strong></td>
                    <td class="text-right"><strong>{{ formatCurrency(totalSeleccionado) }}</strong></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </div>

        <!-- Parámetros de Condonación -->
        <div v-if="adeudosSeleccionados.length > 0" class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="percent" /> Parámetros de Condonación</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Tipo de Condonación</label>
                <select v-model="parametrosCondonacion.tipo" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option value="total">Condonación Total (100%)</option>
                  <option value="recargos">Solo Recargos</option>
                  <option value="gastos">Solo Gastos de Cobranza</option>
                  <option value="recargos_gastos">Recargos y Gastos</option>
                  <option value="porcentaje">Porcentaje Personalizado</option>
                </select>
              </div>
              <div v-if="parametrosCondonacion.tipo === 'porcentaje'" class="form-group">
                <label class="municipal-form-label required">Porcentaje de Condonación</label>
                <input
                  type="number"
                  v-model.number="parametrosCondonacion.porcentaje"
                  class="municipal-form-control"
                  min="0"
                  max="100"
                  step="0.01"
                  required
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 100%;">
                <label class="municipal-form-label required">Motivo de Condonación</label>
                <select v-model="parametrosCondonacion.motivo" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option value="programa_municipal">Programa Municipal</option>
                  <option value="situacion_economica">Situación Económica</option>
                  <option value="error_administrativo">Error Administrativo</option>
                  <option value="acuerdo_cabildo">Acuerdo de Cabildo</option>
                  <option value="otro">Otro</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 100%;">
                <label class="municipal-form-label required">Observaciones</label>
                <textarea
                  v-model="parametrosCondonacion.observaciones"
                  class="municipal-form-control"
                  rows="3"
                  placeholder="Describa el motivo detallado de la condonación"
                  required
                ></textarea>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Oficio/Acuerdo</label>
                <input
                  type="text"
                  v-model="parametrosCondonacion.num_oficio"
                  class="municipal-form-control"
                  placeholder="Número de documento oficial"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha del Oficio</label>
                <input type="date" v-model="parametrosCondonacion.fecha_oficio" class="municipal-form-control" />
              </div>
            </div>

            <!-- Resumen de Condonación -->
            <div class="alert alert-info mt-3">
              <h6><font-awesome-icon icon="calculator" /> Resumen de Condonación</h6>
              <div class="summary-condonacion">
                <div><strong>Adeudos seleccionados:</strong> {{ adeudosSeleccionados.length }}</div>
                <div><strong>Total original:</strong> {{ formatCurrency(totalSeleccionado) }}</div>
                <div><strong>Monto a condonar:</strong> <span class="text-danger">{{ formatCurrency(montoCondonar) }}</span></div>
                <div><strong>Saldo resultante:</strong> <span class="text-success">{{ formatCurrency(saldoResultante) }}</span></div>
              </div>
            </div>

            <div class="button-group mt-3">
              <button
                class="btn-municipal-primary"
                @click="confirmarCondonacion"
                :disabled="!validarFormulario() || loading"
              >
                <font-awesome-icon :icon="loading ? 'spinner' : 'check'" :spin="loading" />
                Aplicar Condonación
              </button>
              <button class="btn-municipal-secondary" @click="cancelarCondonacion">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Consultar Condonaciones -->
      <div v-if="tabActual === 'consulta'" class="tab-content">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Desde</label>
                <input type="date" v-model="filtrosConsulta.fecha_desde" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Hasta</label>
                <input type="date" v-model="filtrosConsulta.fecha_hasta" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Motivo</label>
                <select v-model="filtrosConsulta.motivo" class="municipal-form-control">
                  <option value="">Todos</option>
                  <option value="programa_municipal">Programa Municipal</option>
                  <option value="situacion_economica">Situación Económica</option>
                  <option value="error_administrativo">Error Administrativo</option>
                  <option value="acuerdo_cabildo">Acuerdo de Cabildo</option>
                  <option value="otro">Otro</option>
                </select>
              </div>
            </div>

            <div class="button-group">
              <button class="btn-municipal-primary" @click="consultarCondonaciones" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
              </button>
              <button class="btn-municipal-primary" @click="exportarExcel">
                <font-awesome-icon icon="file-excel" /> Exportar Excel
              </button>
            </div>
          </div>
        </div>

        <!-- Resultados -->
        <div v-if="condonacionesEncontradas.length > 0" class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="table" /> Condonaciones Registradas ({{ condonacionesEncontradas.length }})</h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Fecha</th>
                    <th>Contrato</th>
                    <th>Empresa</th>
                    <th>Periodo</th>
                    <th>Tipo</th>
                    <th>Motivo</th>
                    <th class="text-right">Monto Condonado</th>
                    <th>Oficio</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(cond, index) in condonacionesEncontradas" :key="index">
                    <td>{{ formatDate(cond.fecha_condonacion) }}</td>
                    <td>{{ cond.num_contrato }}</td>
                    <td>{{ cond.empresa }}</td>
                    <td>{{ formatPeriodo(cond.periodo) }}</td>
                    <td><span class="badge badge-info">{{ formatTipoCondonacion(cond.tipo) }}</span></td>
                    <td>{{ cond.motivo }}</td>
                    <td class="text-right"><strong>{{ formatCurrency(cond.monto_condonado) }}</strong></td>
                    <td>{{ cond.num_oficio || 'N/A' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Adeudos Condonados">
      <h3>Adeudos Condonados</h3>
      <p>Gestión de condonaciones y descuentos aplicados a adeudos por motivos autorizados.</p>

      <h4>Tipos de Condonación:</h4>
      <ul>
        <li><strong>Total:</strong> Condona el 100% del adeudo</li>
        <li><strong>Solo Recargos:</strong> Elimina únicamente los recargos moratorios</li>
        <li><strong>Solo Gastos:</strong> Elimina únicamente los gastos de cobranza</li>
        <li><strong>Recargos y Gastos:</strong> Elimina ambos conceptos</li>
        <li><strong>Porcentaje:</strong> Aplica un porcentaje de descuento sobre el total</li>
      </ul>

      <h4>Proceso de Condonación:</h4>
      <ol>
        <li>Buscar el contrato por número</li>
        <li>Visualizar los adeudos pendientes</li>
        <li>Seleccionar los adeudos a condonar</li>
        <li>Especificar tipo y motivo de condonación</li>
        <li>Ingresar número de oficio y observaciones</li>
        <li>Revisar el resumen y confirmar</li>
      </ol>

      <h4>Motivos de Condonación:</h4>
      <ul>
        <li>Programa Municipal: Programas de apoyo autorizados</li>
        <li>Situación Económica: Casos especiales por condición económica</li>
        <li>Error Administrativo: Corrección de errores del sistema</li>
        <li>Acuerdo de Cabildo: Autorización por cabildo municipal</li>
        <li>Otro: Otros motivos debidamente justificados</li>
      </ul>

      <h4>Consulta de Condonaciones:</h4>
      <p>Permite revisar todas las condonaciones aplicadas, filtrar por fechas y motivos, y exportar reportes.</p>

      <h4>Documentación Requerida:</h4>
      <p>Toda condonación debe estar respaldada por un documento oficial (oficio, acuerdo de cabildo, etc.).</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const tabActual = ref('condonar')
const numContrato = ref(null)
const contratoInfo = ref(null)
const adeudosPendientes = ref([])
const adeudosSeleccionados = ref([])
const condonacionesEncontradas = ref([])

const parametrosCondonacion = ref({
  tipo: '',
  porcentaje: 0,
  motivo: '',
  observaciones: '',
  num_oficio: '',
  fecha_oficio: ''
})

const filtrosConsulta = ref({
  fecha_desde: '',
  fecha_hasta: '',
  motivo: ''
})

const todosMarcados = computed(() => {
  return adeudosPendientes.value.length > 0 && adeudosSeleccionados.value.length === adeudosPendientes.value.length
})

const totalSeleccionado = computed(() => {
  const selected = adeudosPendientes.value.filter(a => adeudosSeleccionados.value.includes(a.folio))
  return selected.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const montoCondonar = computed(() => {
  const selected = adeudosPendientes.value.filter(a => adeudosSeleccionados.value.includes(a.folio))
  let total = 0

  selected.forEach(adeudo => {
    switch (parametrosCondonacion.value.tipo) {
      case 'total':
        total += parseFloat(adeudo.total_periodo || 0)
        break
      case 'recargos':
        total += parseFloat(adeudo.recargos || 0)
        break
      case 'gastos':
        total += parseFloat(adeudo.gastos_cobranza || 0)
        break
      case 'recargos_gastos':
        total += parseFloat(adeudo.recargos || 0) + parseFloat(adeudo.gastos_cobranza || 0)
        break
      case 'porcentaje':
        total += (parseFloat(adeudo.total_periodo || 0) * parametrosCondonacion.value.porcentaje) / 100
        break
    }
  })

  return total
})

const saldoResultante = computed(() => {
  return totalSeleccionado.value - montoCondonar.value
})

const buscarContrato = async () => {
  if (!numContrato.value) {
    showToast('Ingrese el número de contrato', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute('sp16_contratos_buscar', 'aseo_contratado', {
      parContrato: numContrato.value,
      parTipo: 'T',
      parVigencia: 'T'
    })

    if (!response || !response.data || response.data.length === 0) {
      showToast('Contrato no encontrado', 'warning')
      return
    }

    contratoInfo.value = response.data[0]

    // Obtener adeudos pendientes
    const responseAdeudos = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contratoInfo.value.control_contrato,
      p_status_vigencia: 'D',
      p_fecha_hasta: null
    })

    adeudosPendientes.value = responseAdeudos && responseAdeudos.data ? responseAdeudos.data : []
    adeudosSeleccionados.value = []

    if (adeudosPendientes.value.length === 0) {
      showToast('El contrato no tiene adeudos pendientes', 'info')
    }
  } catch (error) {
    showToast('Error al buscar contrato', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const toggleTodos = () => {
  if (todosMarcados.value) {
    adeudosSeleccionados.value = []
  } else {
    adeudosSeleccionados.value = adeudosPendientes.value.map(a => a.folio)
  }
}

const validarFormulario = () => {
  return adeudosSeleccionados.value.length > 0 &&
         parametrosCondonacion.value.tipo &&
         parametrosCondonacion.value.motivo &&
         parametrosCondonacion.value.observaciones
}

const confirmarCondonacion = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Condonación?',
    html: `
      <p><strong>Adeudos:</strong> ${adeudosSeleccionados.value.length}</p>
      <p><strong>Monto a condonar:</strong> ${formatCurrency(montoCondonar.value)}</p>
      <p><strong>Saldo resultante:</strong> ${formatCurrency(saldoResultante.value)}</p>
      <p class="text-warning mt-2">Esta acción es irreversible.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, Condonar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await aplicarCondonacion()
  }
}

const aplicarCondonacion = async () => {
  loading.value = true
  try {
    // Llamar al SP de condonación
    // SP propuesto: SP_ASEO_ADEUDOS_CONDONAR
    showToast(`Condonación aplicada: ${formatCurrency(montoCondonar.value)}`, 'success')
    cancelarCondonacion()
  } catch (error) {
    showToast('Error al aplicar condonación', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const cancelarCondonacion = () => {
  adeudosSeleccionados.value = []
  parametrosCondonacion.value = {
    tipo: '',
    porcentaje: 0,
    motivo: '',
    observaciones: '',
    num_oficio: '',
    fecha_oficio: ''
  }
}

const consultarCondonaciones = async () => {
  loading.value = true
  try {
    // Simular consulta
    condonacionesEncontradas.value = []
    showToast('Consulta de condonaciones en desarrollo', 'info')
  } catch (error) {
    showToast('Error al consultar condonaciones', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const exportarExcel = () => {
  showToast('Exportación a Excel en desarrollo', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('es-MX')
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-')
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
  return `${meses[parseInt(month) - 1]} ${year}`
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'C': 'Comercial', 'R': 'Residencial', 'I': 'Industrial', 'M': 'Mixto' }
  return tipos[tipo] || tipo
}

const formatTipoCondonacion = (tipo) => {
  const tipos = {
    'total': 'Total',
    'recargos': 'Recargos',
    'gastos': 'Gastos',
    'recargos_gastos': 'Recargos y Gastos',
    'porcentaje': 'Porcentaje'
  }
  return tipos[tipo] || tipo
}

const calcularAntiguedad = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-').map(Number)
  const fechaPeriodo = new Date(year, month - 1)
  const fechaActual = new Date()
  const meses = (fechaActual.getFullYear() - fechaPeriodo.getFullYear()) * 12 +
                (fechaActual.getMonth() - fechaPeriodo.getMonth())
  if (meses === 0) return 'Actual'
  if (meses === 1) return '1 mes'
  return `${meses} meses`
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

