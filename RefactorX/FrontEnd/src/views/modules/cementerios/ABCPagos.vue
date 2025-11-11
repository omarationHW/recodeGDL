<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill-wave" />
      </div>
      <div class="module-view-info">
        <h1>Registro de Pagos</h1>
        <p>Cementerios - Alta y baja de pagos por folio/cuenta RCM</p>
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

    <div class="module-view-content">
      <!-- Búsqueda de Folio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Folio (Control RCM)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="folioABuscar"
                @keyup.enter="buscarFolio"
                placeholder="Número de folio..."
                :disabled="modoOperacion !== null"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarFolio"
              :disabled="loading || !folioABuscar || modoOperacion !== null"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Datos del Folio -->
      <div class="municipal-card" v-if="datosFolio">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Folio {{ datosFolio.control_rcm }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cementerio</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="`${datosFolio.cementerio} - ${datosFolio.nombre_cementerio}`"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ubicación</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="`Clase: ${datosFolio.clase_alfa}, Sección: ${datosFolio.seccion_alfa}, Línea: ${datosFolio.linea_alfa}, Fosa: ${datosFolio.fosa_alfa}`"
                readonly
              />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosFolio.nombre"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Último Año Pagado</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosFolio.axo_pagado || 'N/A'"
                readonly
              />
            </div>
          </div>

          <div class="button-group" v-if="modoOperacion === null">
            <button
              class="btn-municipal-primary"
              @click="iniciarAltaPago"
              :disabled="loading"
            >
              <font-awesome-icon icon="plus" />
              Registrar Pago
            </button>
            <button
              class="btn-municipal-warning"
              @click="iniciarBajaPago"
              :disabled="loading"
            >
              <font-awesome-icon icon="list" />
              Dar de Baja Pago
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Formulario de Alta de Pago -->
      <div class="municipal-card" v-if="modoOperacion === 'alta'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="plus-circle" />
            Registrar Nuevo Pago
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Fecha</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formPago.fecha"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Recaudadora</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formPago.recaudadora"
                placeholder="ID Recaudadora..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Caja</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formPago.caja"
                placeholder="Caja..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Operación</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formPago.operacion"
                placeholder="Número de operación..."
              />
            </div>
          </div>

          <!-- Listado de Adeudos Pendientes -->
          <h6 class="section-title">Seleccionar Adeudos a Pagar</h6>
          <div class="table-responsive" v-if="adeudosPendientes.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 50px">
                    <input
                      type="checkbox"
                      @change="toggleTodosAdeudos"
                      :checked="todosAdeudosSeleccionados"
                    />
                  </th>
                  <th>Año</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Descuento</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudosPendientes" :key="adeudo.id_adeudo">
                  <td>
                    <input
                      type="checkbox"
                      v-model="adeudosSeleccionados"
                      :value="adeudo.id_adeudo"
                      @change="calcularTotalPago"
                    />
                  </td>
                  <td><strong>{{ adeudo.axo_adeudo }}</strong></td>
                  <td class="text-end">${{ formatNumber(adeudo.importe) }}</td>
                  <td class="text-end">${{ formatNumber(adeudo.importe_recargos) }}</td>
                  <td class="text-end">${{ formatNumber(adeudo.descto_importe) }}</td>
                  <td class="text-end"><strong>${{ formatNumber(adeudo.total) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="5" class="text-end"><strong>Total a Pagar:</strong></td>
                  <td class="text-end"><strong>${{ formatNumber(totalPagoCalculado) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div v-else class="alert alert-warning">
            No hay adeudos pendientes para este folio
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-success"
              @click="guardarPago"
              :disabled="loading || adeudosSeleccionados.length === 0"
            >
              <font-awesome-icon icon="check" />
              Guardar Pago
            </button>
            <button
              class="btn-municipal-secondary"
              @click="cancelarOperacion"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Listado de Pagos para Baja -->
      <div class="municipal-card" v-if="modoOperacion === 'baja'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos Registrados - Seleccione para Dar de Baja
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" v-if="pagosRegistrados.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 50px">Sel</th>
                  <th>Fecha</th>
                  <th>Recaudadora</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Años</th>
                  <th>Importe</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagosRegistrados" :key="pago.control_id">
                  <td>
                    <input
                      type="radio"
                      name="pagoSeleccionado"
                      :value="pago.control_id"
                      v-model="pagoSeleccionadoId"
                      :disabled="pago.vigencia !== 'A'"
                    />
                  </td>
                  <td>{{ formatDate(pago.fecing) }}</td>
                  <td>{{ pago.recing }}</td>
                  <td>{{ pago.cajing }}</td>
                  <td><strong>{{ pago.opcaja }}</strong></td>
                  <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                  <td class="text-end"><strong>${{ formatNumber(pago.total) }}</strong></td>
                  <td>
                    <span v-if="pago.vigencia === 'A'" class="badge badge-success">Activo</span>
                    <span v-else class="badge badge-danger">Baja</span>
                  </td>
                  <td>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmarBajaPago(pago)"
                      :disabled="pago.vigencia !== 'A'"
                      title="Dar de baja"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="alert alert-info">
            No hay pagos registrados para este folio
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-secondary"
              @click="cancelarOperacion"
              :disabled="loading"
            >
              <font-awesome-icon icon="arrow-left" />
              Volver
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Registro de Pagos"
    >
      <h6>Descripción</h6>
      <p>Módulo para registrar pagos de cuentas RCM y gestionar bajas de pagos registrados.</p>

      <h6>Funcionalidades</h6>
      <ul>
        <li>Búsqueda de folio por control RCM</li>
        <li>Visualización de datos del folio y propietario</li>
        <li>Registro de pagos seleccionando adeudos pendientes</li>
        <li>Cálculo automático de totales con descuentos</li>
        <li>Baja de pagos registrados</li>
        <li>Actualización automática de último año pagado</li>
      </ul>

      <h6>Instrucciones - Alta de Pago</h6>
      <ol>
        <li>Ingrese el número de folio (control RCM) y busque</li>
        <li>Verifique los datos del folio</li>
        <li>Haga clic en "Registrar Pago"</li>
        <li>Complete los datos: fecha, recaudadora, caja y operación</li>
        <li>Seleccione los adeudos a pagar (puede seleccionar varios años)</li>
        <li>Verifique el total calculado</li>
        <li>Haga clic en "Guardar Pago"</li>
      </ol>

      <h6>Instrucciones - Baja de Pago</h6>
      <ol>
        <li>Ingrese el número de folio y busque</li>
        <li>Haga clic en "Dar de Baja Pago"</li>
        <li>Seleccione el pago a dar de baja</li>
        <li>Confirme la operación</li>
      </ol>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const folioABuscar = ref(null)
const datosFolio = ref(null)
const adeudosPendientes = ref([])
const pagosRegistrados = ref([])
const mostrarAyuda = ref(false)
const modoOperacion = ref(null) // null, 'alta', 'baja'
const adeudosSeleccionados = ref([])
const pagoSeleccionadoId = ref(null)
const totalPagoCalculado = ref(0)

const formPago = ref({
  fecha: new Date().toISOString().split('T')[0],
  recaudadora: null,
  caja: '',
  operacion: null
})

// Computed
const todosAdeudosSeleccionados = computed(() => {
  return adeudosPendientes.value.length > 0 &&
         adeudosSeleccionados.value.length === adeudosPendientes.value.length
})

// Métodos
const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('Debe ingresar un número de folio', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'sp_cem_buscar_folio_pagos',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      datosFolio.value = response.result[0]
      showToast('Folio encontrado', 'success')
    } else {
      showToast('Folio no encontrado', 'error')
      datosFolio.value = null
    }
  } catch (error) {
    showToast('Error al buscar folio: ' + error.message, 'error')
    datosFolio.value = null
  } finally {
    loading.value = false
  }
}

const iniciarAltaPago = async () => {
  modoOperacion.value = 'alta'
  await cargarAdeudosPendientes()
}

const iniciarBajaPago = async () => {
  modoOperacion.value = 'baja'
  await cargarPagosRegistrados()
}

const cargarAdeudosPendientes = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_cem_obtener_adeudos_pendientes',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    adeudosPendientes.value = response || []
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudosPendientes.value = []
  } finally {
    loading.value = false
  }
}

const cargarPagosRegistrados = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_cem_listar_pagos_folio',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    pagosRegistrados.value = response || []
  } catch (error) {
    console.error('Error al cargar pagos:', error)
    pagosRegistrados.value = []
  } finally {
    loading.value = false
  }
}

const toggleTodosAdeudos = (event) => {
  if (event.target.checked) {
    adeudosSeleccionados.value = adeudosPendientes.value.map(a => a.id_adeudo)
  } else {
    adeudosSeleccionados.value = []
  }
  calcularTotalPago()
}

const calcularTotalPago = () => {
  totalPagoCalculado.value = adeudosPendientes.value
    .filter(a => adeudosSeleccionados.value.includes(a.id_adeudo))
    .reduce((sum, a) => sum + a.total, 0)
}

const guardarPago = async () => {
  if (!formPago.value.fecha || !formPago.value.recaudadora ||
      !formPago.value.caja || !formPago.value.operacion) {
    showToast('Debe completar todos los campos requeridos', 'warning')
    return
  }

  if (adeudosSeleccionados.value.length === 0) {
    showToast('Debe seleccionar al menos un adeudo', 'warning')
    return
  }

  const adeudosOrdenados = adeudosPendientes.value
    .filter(a => adeudosSeleccionados.value.includes(a.id_adeudo))
    .map(a => a.axo_adeudo)
    .sort((a, b) => a - b)

  const axoDesde = adeudosOrdenados[0]
  const axoHasta = adeudosOrdenados[adeudosOrdenados.length - 1]

  const result = await Swal.fire({
    title: '¿Confirmar registro de pago?',
    html: `
      <div style="text-align: left">
        <p><strong>Folio:</strong> ${folioABuscar.value}</p>
        <p><strong>Años:</strong> ${axoDesde} - ${axoHasta}</p>
        <p><strong>Total:</strong> $${formatNumber(totalPagoCalculado.value)}</p>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  loading.value = true
  try {
    const response = await execute(
      'sp_cem_registrar_pago',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value,
        p_fecha: formPago.value.fecha,
        p_recaudadora: formPago.value.recaudadora,
        p_caja: formPago.value.caja,
        p_operacion: formPago.value.operacion,
        p_axo_desde: axoDesde,
        p_axo_hasta: axoHasta,
        p_importe: totalPagoCalculado.value,
        p_id_usuario: 1, // TODO: Obtener del contexto de usuario
        p_operacion_tipo: 1, // Alta
        p_control_id: null
      },
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.par_ok === 1) {
        showToast(result.par_observ, 'success')
        cancelarOperacion()
        await buscarFolio() // Recargar datos del folio
      } else {
        showToast(result.par_observ, 'error')
      }
    }
  } catch (error) {
    showToast('Error al registrar pago: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

const confirmarBajaPago = async (pago) => {
  const result = await Swal.fire({
    title: '¿Dar de baja este pago?',
    html: `
      <div style="text-align: left">
        <p><strong>Fecha:</strong> ${formatDate(pago.fecing)}</p>
        <p><strong>Operación:</strong> ${pago.opcaja}</p>
        <p><strong>Años:</strong> ${pago.axo_pago_desde} - ${pago.axo_pago_hasta}</p>
        <p><strong>Importe:</strong> $${formatNumber(pago.total)}</p>
        <p style="color: red; margin-top: 10px"><strong>Esta acción liberará los adeudos asociados</strong></p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33'
  })

  if (!result.isConfirmed) return

  loading.value = true
  try {
    const response = await execute(
      'sp_cem_registrar_pago',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value,
        p_fecha: pago.fecing,
        p_recaudadora: pago.recing,
        p_caja: pago.cajing,
        p_operacion: pago.opcaja,
        p_axo_desde: pago.axo_pago_desde,
        p_axo_hasta: pago.axo_pago_hasta,
        p_importe: pago.importe_anual,
        p_id_usuario: 1, // TODO: Obtener del contexto de usuario
        p_operacion_tipo: 2, // Baja
        p_control_id: pago.control_id
      },
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.par_ok === 1) {
        showToast(result.par_observ, 'success')
        await cargarPagosRegistrados() // Recargar listado
        await buscarFolio() // Recargar datos del folio
      } else {
        showToast(result.par_observ, 'error')
      }
    }
  } catch (error) {
    showToast('Error al dar de baja pago: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

const cancelarOperacion = () => {
  modoOperacion.value = null
  adeudosSeleccionados.value = []
  pagoSeleccionadoId.value = null
  totalPagoCalculado.value = 0
  formPago.value = {
    fecha: new Date().toISOString().split('T')[0],
    recaudadora: null,
    caja: '',
    operacion: null
  }
}

const limpiar = () => {
  folioABuscar.value = null
  datosFolio.value = null
  adeudosPendientes.value = []
  pagosRegistrados.value = []
  cancelarOperacion()
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

const formatNumber = (number) => {
  if (!number) return '0.00'
  return Number(number).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>
