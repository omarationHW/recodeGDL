<template>
  <div class="module-view">
    <!-- Header -->
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill-wave" />
      </div>
      <div class="module-view-info">
        <h1>Pago Múltiple de Adeudos</h1>
        <p>Aseo Contratado - Registro de pagos masivos para múltiples adeudos</p>
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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <!-- Proceso de 3 pasos -->
    <div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-body">
        <div class="steps-progress">
          <div class="step" :class="{ active: paso >= 1, completed: paso > 1 }">
            <div class="step-number">1</div>
            <div class="step-label">Búsqueda de Contrato</div>
          </div>
          <div class="step-line" :class="{ active: paso > 1 }"></div>
          <div class="step" :class="{ active: paso >= 2, completed: paso > 2 }">
            <div class="step-number">2</div>
            <div class="step-label">Selección de Adeudos</div>
          </div>
          <div class="step-line" :class="{ active: paso > 2 }"></div>
          <div class="step" :class="{ active: paso >= 3 }">
            <div class="step-number">3</div>
            <div class="step-label">Registro de Pago</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 1: Búsqueda de Contrato -->
    <div v-if="paso === 1" class="municipal-card">
      <div class="municipal-card-header">
        <h5>Paso 1: Búsqueda de Contrato</h5>
      </div>
<div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="busqueda.num_contrato"
                  @keyup.enter="buscarContrato"
                  placeholder="Ingrese número de contrato"
                />
                <button class="btn-municipal-primary" @click="buscarContrato" :disabled="cargando">
                  <font-awesome-icon icon="search" class="me-1" />
                  Buscar
                </button>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta Predial</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="busqueda.cuenta_predial"
                  @keyup.enter="buscarPorPredial"
                  placeholder="Ingrese cuenta predial"
                />
                <button class="btn-municipal-primary" @click="buscarPorPredial" :disabled="cargando">
                  <font-awesome-icon icon="search" class="me-1" />
                  Buscar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Datos del Contrato -->
        <div v-if="contratoSeleccionado" class="municipal-alert municipal-alert-success">
          <h6 class="alert-heading">
            <font-awesome-icon icon="check-circle" class="me-2" />
            Contrato Encontrado
          </h6>
          <div class="row">
            <div class="col-md-4">
              <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
              <strong>Control:</strong> {{ contratoSeleccionado.control_contrato }}
            </div>
            <div class="col-md-4">
              <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}<br>
              <strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}
            </div>
            <div class="col-md-4">
              <strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}<br>
              <strong>Status:</strong>
              <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Inactivo' }}
              </span>
            </div>
          </div>
          <div class="mt-3">
            <button class="btn-municipal-primary" @click="cargarAdeudos">
              <font-awesome-icon icon="arrow-right" class="me-1" />
              Continuar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Selección de Adeudos -->
    <div v-if="paso === 2" class="municipal-card">
      <div class="municipal-card-header">
        <h5>Paso 2: Selección de Adeudos a Pagar</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Resumen del Contrato -->
        <div class="alert alert-info mb-3">
          <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }} -
          <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
        </div>

        <!-- Filtros de búsqueda -->
        <div class="row mb-3">
          <div class="col-md-3">
            <div class="form-group">
              <label class="municipal-form-label">Filtrar por Año</label>
              <select class="municipal-form-control form-select-sm" v-model="filtros.ejercicio">
                <option value="">Todos</option>
                <option v-for="year in ejerciciosDisponibles" :key="year" :value="year">
                  {{ year }}
                </option>
              </select>
            </div>
          </div>
          <div class="col-md-3">
            <div class="form-group">
              <label class="municipal-form-label">Filtrar por Operación</label>
              <select class="municipal-form-control form-select-sm" v-model="filtros.operacion">
                <option value="">Todas</option>
                <option value="C">Cuota</option>
                <option value="R">Recargo</option>
                <option value="M">Multa</option>
                <option value="G">Gastos</option>
              </select>
            </div>
          </div>
          <div class="col-md-3">
            <div class="form-check mt-4">
              <input
                class="form-check-input"
                type="checkbox"
                v-model="filtros.solo_vencidos"
                id="soloVencidos"
              />
              <label class="form-check-label" for="soloVencidos">
                Solo adeudos vencidos
              </label>
            </div>
          </div>
          <div class="col-md-3 text-end mt-4">
            <button class="btn btn-sm btn-outline-primary" @click="toggleTodos">
              <font-awesome-icon :icon="todosMarcados ? 'square-check' : 'square'" class="me-1" />
              {{ todosMarcados ? 'Desmarcar' : 'Marcar' }} Todos
            </button>
          </div>
        </div>

        <!-- Tabla de Adeudos -->
        <div v-if="adeudosFiltrados.length > 0" class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 40px">
                  <input
                    type="checkbox"
                    v-model="todosMarcados"
                    @change="toggleTodos"
                  />
                </th>
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
                <td>
                  <input
                    type="checkbox"
                    :value="adeudo.folio"
                    v-model="adeudosSeleccionados"
                  />
                </td>
                <td>{{ adeudo.folio }}</td>
                <td>{{ adeudo.periodo }}</td>
                <td>{{ formatOperacion(adeudo.cve_operacion) }}</td>
                <td>{{ formatFecha(adeudo.fecha_vencimiento) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                <td>
                  <span class="badge" :class="{
                    'bg-danger': esVencido(adeudo.fecha_vencimiento),
                    'bg-warning': !esVencido(adeudo.fecha_vencimiento)
                  }">
                    {{ esVencido(adeudo.fecha_vencimiento) ? 'Vencido' : 'Vigente' }}
                  </span>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="8" class="text-end"><strong>Total Seleccionado:</strong></td>
                <td class="text-end"><strong>${{ formatCurrency(totalSeleccionado) }}</strong></td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>

        <div v-else class="municipal-alert municipal-alert-warning">
          <font-awesome-icon icon="info-circle" class="me-2" />
          No hay adeudos pendientes con los filtros seleccionados.
        </div>

        <!-- Resumen de Selección -->
        <div v-if="adeudosSeleccionados.length > 0" class="alert alert-success mt-3">
          <div class="row">
            <div class="col-md-4">
              <strong>Adeudos Seleccionados:</strong> {{ adeudosSeleccionados.length }}
            </div>
            <div class="col-md-4">
              <strong>Total a Pagar:</strong> ${{ formatCurrency(totalSeleccionado) }}
            </div>
            <div class="col-md-4 text-end">
              <button class="btn-municipal-primary" @click="paso = 3" :disabled="adeudosSeleccionados.length === 0">
                <font-awesome-icon icon="arrow-right" class="me-1" />
                Continuar al Pago
              </button>
            </div>
          </div>
        </div>

        <div class="mt-3">
          <button class="btn-municipal-secondary" @click="paso = 1">
            <font-awesome-icon icon="arrow-left" class="me-1" />
            Regresar
          </button>
        </div>
      </div>
    </div>

    <!-- Paso 3: Registro de Pago -->
    <div v-if="paso === 3" class="municipal-card">
      <div class="municipal-card-header">
        <h5>Paso 3: Registro de Pago Múltiple</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Resumen -->
        <div class="row mb-4">
          <div class="col-md-6">
            <div class="municipal-card bg-light">
              <div class="municipal-card-body">
                <h6>Datos del Pago</h6>
                <p class="mb-1"><strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}</p>
                <p class="mb-1"><strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}</p>
                <p class="mb-0"><strong>Adeudos a Pagar:</strong> {{ adeudosSeleccionados.length }}</p>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="municipal-card bg-success text-white">
              <div class="municipal-card-body">
                <h6>Total del Pago</h6>
                <div class="display-4">${{ formatCurrency(totalSeleccionado) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Formulario de Pago -->
        <div class="row">
          <div class="col-md-6">
            <div class="form-group">
              <label class="municipal-form-label">Forma de Pago <span class="text-danger">*</span></label>
              <select class="municipal-form-control" v-model="datosPago.forma_pago">
                <option value="">Seleccione...</option>
                <option value="EFECTIVO">Efectivo</option>
                <option value="CHEQUE">Cheque</option>
                <option value="TRANSFERENCIA">Transferencia</option>
                <option value="TARJETA">Tarjeta</option>
                <option value="DEPOSITO">Depósito</option>
              </select>
            </div>
          </div>
          <div class="col-md-6">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago <span class="text-danger">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="datosPago.fecha_pago"
                :max="fechaActual"
              />
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-md-6">
            <div class="form-group">
              <label class="municipal-form-label">Referencia/Número de Documento</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="datosPago.referencia"
                placeholder="Número de cheque, transferencia, etc."
              />
            </div>
          </div>
          <div class="col-md-6">
            <div class="form-group">
              <label class="municipal-form-label">Recibo Número</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="datosPago.num_recibo"
                placeholder="Número de recibo de pago"
              />
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="municipal-form-label">Observaciones</label>
          <textarea
            class="municipal-form-control"
            v-model="datosPago.observaciones"
            rows="2"
            placeholder="Observaciones del pago..."
          ></textarea>
        </div>

        <!-- Desglose de Adeudos -->
        <div class="municipal-card mb-3">
          <div class="municipal-card-header">
            <strong>Desglose de Adeudos a Pagar ({{ adeudosSeleccionados.length }})</strong>
          </div>
          <div class="municipal-card-body" style="max-height: 300px; overflow-y: auto;">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Folio</th>
                    <th>Periodo</th>
                    <th>Operación</th>
                    <th class="text-end">Monto</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudosAPagar" :key="adeudo.folio">
                    <td>{{ adeudo.folio }}</td>
                    <td>{{ adeudo.periodo }}</td>
                    <td>{{ formatOperacion(adeudo.cve_operacion) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.total_periodo) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Acciones -->
        <div class="d-flex gap-2">
          <button class="btn-municipal-secondary" @click="paso = 2">
            <font-awesome-icon icon="arrow-left" class="me-1" />
            Regresar
          </button>
          <button
            class="btn-municipal-primary btn-lg"
            @click="confirmarPago"
            :disabled="!validarDatosPago || registrando"
          >
            <font-awesome-icon icon="check" class="me-1" />
            <span v-if="!registrando">Registrar Pago de ${{ formatCurrency(totalSeleccionado) }}</span>
            <span v-else>
              <span class="spinner-border spinner-border-sm me-1"></span>
              Registrando Pago...
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->

    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Pago Múltiple de Adeudos - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite registrar el pago de múltiples adeudos simultáneamente para un contrato,
        agilizando el proceso de cobranza y reduciendo el tiempo de captura.
      </p>

      <h6>Proceso de Pago Múltiple</h6>
      <ol>
        <li><strong>Búsqueda:</strong> Localizar el contrato por número o cuenta predial</li>
        <li><strong>Selección:</strong> Elegir los adeudos a pagar usando filtros y checkboxes</li>
        <li><strong>Registro:</strong> Capturar datos del pago y confirmar operación</li>
      </ol>

      <h6>Filtros Disponibles</h6>
      <ul>
        <li><strong>Por Año:</strong> Filtrar adeudos de un ejercicio fiscal específico</li>
        <li><strong>Por Operación:</strong> Filtrar por tipo (Cuota, Recargo, Multa, Gastos)</li>
        <li><strong>Solo Vencidos:</strong> Mostrar únicamente adeudos con fecha vencida</li>
      </ul>

      <h6>Formas de Pago</h6>
      <ul>
        <li>Efectivo</li>
        <li>Cheque (capturar número)</li>
        <li>Transferencia bancaria (capturar referencia)</li>
        <li>Tarjeta de débito/crédito</li>
        <li>Depósito bancario</li>
      </ul>

      <h6>Consideraciones</h6>
      <ul>
        <li>El pago se aplica a todos los adeudos seleccionados en una sola transacción</li>
        <li>Se genera un comprobante único para todos los adeudos</li>
        <li>Los adeudos pagados se marcan automáticamente como liquidados</li>
        <li>Es recomendable pagar primero los adeudos más antiguos</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos_PagMult'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const paso = ref(1)
const cargando = ref(false)
const registrando = ref(false)
const mostrarAyuda = ref(false)

// Búsqueda
const busqueda = ref({
  num_contrato: '',
  cuenta_predial: ''
})

// Contrato
const contratoSeleccionado = ref(null)

// Adeudos
const adeudosDisponibles = ref([])
const adeudosSeleccionados = ref([])
const todosMarcados = ref(false)

// Filtros
const filtros = ref({
  ejercicio: '',
  operacion: '',
  solo_vencidos: false
})

// Datos del Pago
const datosPago = ref({
  forma_pago: '',
  fecha_pago: new Date().toISOString().split('T')[0],
  referencia: '',
  num_recibo: '',
  observaciones: ''
})

// Computed
const fechaActual = computed(() => {
  return new Date().toISOString().split('T')[0]
})

const ejerciciosDisponibles = computed(() => {
  const ejercicios = [...new Set(adeudosDisponibles.value.map(a => {
    const periodo = a.periodo || ''
    return periodo.substring(0, 4)
  }))]
  return ejercicios.filter(e => e).sort().reverse()
})

const adeudosFiltrados = computed(() => {
  let resultado = [...adeudosDisponibles.value]

  if (filtros.value.ejercicio) {
    resultado = resultado.filter(a => a.periodo && a.periodo.startsWith(filtros.value.ejercicio))
  }

  if (filtros.value.operacion) {
    resultado = resultado.filter(a => a.cve_operacion === filtros.value.operacion)
  }

  if (filtros.value.solo_vencidos) {
    resultado = resultado.filter(a => esVencido(a.fecha_vencimiento))
  }

  return resultado
})

const totalSeleccionado = computed(() => {
  return adeudosDisponibles.value
    .filter(a => adeudosSeleccionados.value.includes(a.folio))
    .reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const adeudosAPagar = computed(() => {
  return adeudosDisponibles.value.filter(a => adeudosSeleccionados.value.includes(a.folio))
})

const validarDatosPago = computed(() => {
  return datosPago.value.forma_pago && datosPago.value.fecha_pago
})

// Métodos
const buscarContrato = async () => {
  if (!busqueda.value.num_contrato) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
      p_num_contrato: busqueda.value.num_contrato
    })

    if (response && response.length > 0) {
      contratoSeleccionado.value = response[0]
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
      contratoSeleccionado.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
    contratoSeleccionado.value = null
  } finally {
    cargando.value = false
  }
}

const buscarPorPredial = async () => {
  if (!busqueda.value.cuenta_predial) {
    showToast('Ingrese una cuenta predial', 'warning')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_POR_PREDIAL', 'aseo_contratado', {
      p_cuenta_predial: busqueda.value.cuenta_predial
    })

    if (response && response.length > 0) {
      contratoSeleccionado.value = response[0]
      busqueda.value.num_contrato = response[0].num_contrato
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('No se encontró contrato con esa cuenta predial', 'error')
      contratoSeleccionado.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar por cuenta predial')
    contratoSeleccionado.value = null
  } finally {
    cargando.value = false
  }
}

const cargarAdeudos = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_ADEUDOS_PENDIENTES', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato
    })

    adeudosDisponibles.value = response || []

    if (adeudosDisponibles.value.length === 0) {
      showToast('Este contrato no tiene adeudos pendientes', 'info')
      return
    }

    paso.value = 2
    showToast(`${adeudosDisponibles.value.length} adeudo(s) encontrado(s)`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar adeudos')
    adeudosDisponibles.value = []
  } finally {
    cargando.value = false
  }
}

const toggleTodos = () => {
  if (todosMarcados.value) {
    adeudosSeleccionados.value = adeudosFiltrados.value.map(a => a.folio)
  } else {
    adeudosSeleccionados.value = []
  }
}

const confirmarPago = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Registro de Pago?',
    html: `
      <p>Se registrará un pago de <strong>$${formatCurrency(totalSeleccionado.value)}</strong></p>
      <p>para <strong>${adeudosSeleccionados.value.length}</strong> adeudo(s)</p>
      <p>Forma de pago: <strong>${datosPago.value.forma_pago}</strong></p>
      <p class="text-muted mt-2">Esta acción quedará registrada en el sistema.</p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, Registrar Pago',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await registrarPago()
  }
}

const registrarPago = async () => {
  registrando.value = true
  try {
    await execute('SP_ASEO_PAGO_MULTIPLE', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_adeudos: adeudosSeleccionados.value.join(','),
      p_forma_pago: datosPago.value.forma_pago,
      p_fecha_pago: datosPago.value.fecha_pago,
      p_monto_total: totalSeleccionado.value,
      p_referencia: datosPago.value.referencia || null,
      p_num_recibo: datosPago.value.num_recibo || null,
      p_observaciones: datosPago.value.observaciones || null
    })

    await Swal.fire({
      title: 'Pago Registrado',
      html: `
        <p>El pago de <strong>$${formatCurrency(totalSeleccionado.value)}</strong> ha sido registrado exitosamente</p>
        <p>${adeudosSeleccionados.value.length} adeudo(s) han sido liquidados</p>
      `,
      icon: 'success',
      confirmButtonColor: '#28a745'
    })

    // Reiniciar
    contratoSeleccionado.value = null
    adeudosDisponibles.value = []
    adeudosSeleccionados.value = []
    datosPago.value = {
      forma_pago: '',
      fecha_pago: new Date().toISOString().split('T')[0],
      referencia: '',
      num_recibo: '',
      observaciones: ''
    }
    busqueda.value = { num_contrato: '', cuenta_predial: '' }
    paso.value = 1

  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al registrar pago')
  } finally {
    registrando.value = false
  }
}

// Utilidades
const esVencido = (fechaVencimiento) => {
  if (!fechaVencimiento) return false
  return new Date(fechaVencimiento) < new Date()
}

const formatOperacion = (cve) => {
  const operaciones = {
    'C': 'Cuota',
    'R': 'Recargo',
    'M': 'Multa',
    'G': 'Gastos',
    'A': 'Actualización'
  }
  return operaciones[cve] || cve
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
