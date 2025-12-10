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
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
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

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ABCPagos'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Toast State (Manual system like reference)
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Toast Methods
const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const loading = ref(false)
const folioABuscar = ref(null)
const datosFolio = ref(null)
const adeudosPendientes = ref([])
const pagosRegistrados = ref([])
const showDocumentation = ref(false)
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

// Métodos de ayuda
const mostrarAyuda = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

// Métodos
const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('warning', 'Debe ingresar un número de folio')
    return
  }

  loading.value = true
  showLoading()
  try {
    // Usar SP: sp_pagos_buscar_folio
    // Base: cementerio.public (según 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_pagos_buscar_folio',
      'cementerio',
      [folioABuscar.value],
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT
        a.control_rcm,
        a.*,
        c.nombre as nombre_cementerio
    FROM padron_licencias.comun.ta_13_datosrcm a
    LEFT JOIN cementerio.public.tc_13_cementerios c ON a.cementerio = c.cementerio
    WHERE a.control_rcm = [folioABuscar]
      AND a.vigencia = 'A'
    */

    if (response && response.length > 0) {
      datosFolio.value = response[0]
      showToast('success', 'Folio encontrado')
    } else {
      showToast('error', 'Folio no encontrado')
      datosFolio.value = null
    }
  } catch (error) {
    showToast('error', 'Error al buscar folio: ' + error.message)
    datosFolio.value = null
  } finally {
    loading.value = false
    hideLoading()
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
  showLoading()
  try {
    // Usar SP: sp_pagos_adeudos_pendientes
    // Base: cementerio.public (según 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_pagos_adeudos_pendientes',
      'cementerio',
      [folioABuscar.value],
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT
        id_adeudo,
        control_rcm,
        axo_adeudo,
        importe,
        importe_recargos,
        COALESCE(descto_impote, 0) as descto_importe,
        COALESCE(descto_recargos, 0) as descto_recargos,
        vigencia,
        (importe - COALESCE(descto_impote, 0) + importe_recargos - COALESCE(descto_recargos, 0)) as total
    FROM cementerio.public.ta_13_adeudosrcm
    WHERE control_rcm = [folioABuscar]
      AND id_pago IS NULL
      AND vigencia = 'A'
    ORDER BY axo_adeudo
    */

    adeudosPendientes.value = response || []
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudosPendientes.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const cargarPagosRegistrados = async () => {
  loading.value = true
  showLoading()
  try {
    // Usar SP: sp_pagos_listar_por_folio
    // Base: cementerio.public (según 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_pagos_listar_por_folio',
      'cementerio',
      [folioABuscar.value],
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT
        control_id,
        control_rcm,
        fecing,
        recing,
        cajing,
        opcaja,
        axo_pago_desde,
        axo_pago_hasta,
        importe_anual,
        importe_recargos,
        vigencia,
        usuario,
        fecha_mov,
        (importe_anual + COALESCE(importe_recargos, 0)) as total
    FROM cementerio.public.ta_13_pagosrcm
    WHERE control_rcm = [folioABuscar]
    ORDER BY fecing DESC
    */

    pagosRegistrados.value = response || []
  } catch (error) {
    console.error('Error al cargar pagos:', error)
    pagosRegistrados.value = []
  } finally {
    loading.value = false
    hideLoading()
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
    showToast('warning', 'Debe completar todos los campos requeridos')
    return
  }

  if (adeudosSeleccionados.value.length === 0) {
    showToast('warning', 'Debe seleccionar al menos un adeudo')
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
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  loading.value = true
  showLoading()
  try {
    // Usar SP: sp_pagos_registrar
    // Base: cementerio.public (según 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_pagos_registrar',
      'cementerio',
      {
        p_control_rcm: folioABuscar.value,
        p_cementerio: datosFolio.value.cementerio,
        p_clase: datosFolio.value.clase,
        p_clase_alfa: datosFolio.value.clase_alfa,
        p_seccion: datosFolio.value.seccion,
        p_seccion_alfa: datosFolio.value.seccion_alfa,
        p_linea: datosFolio.value.linea,
        p_linea_alfa: datosFolio.value.linea_alfa,
        p_fosa: datosFolio.value.fosa,
        p_fosa_alfa: datosFolio.value.fosa_alfa,
        p_fecha: formPago.value.fecha,
        p_recaudadora: formPago.value.recaudadora,
        p_caja: formPago.value.caja,
        p_operacion: formPago.value.operacion,
        p_axo_desde: axoDesde,
        p_axo_hasta: axoHasta,
        p_importe_total: totalPagoCalculado.value,
        p_adeudos_ids: adeudosSeleccionados.value,
        p_usuario: 1 // TODO: Obtener del contexto
      },
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Queries SQL originales (comentadas - ahora usa SP transaccional)
    -- 1. INSERT en ta_13_pagosrcm
    INSERT INTO cementerio.public.ta_13_pagosrcm (
        control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa,
        linea, linea_alfa, fosa, fosa_alfa, fecing, recing, cajing, opcaja,
        axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos,
        vigencia, usuario, fecha_mov
    ) VALUES (...) RETURNING control_id;

    -- 2. UPDATE adeudos relacionados
    UPDATE cementerio.public.ta_13_adeudosrcm
    SET id_pago = [pagoId], usuario = [usuario], fecha_mov = CURRENT_DATE
    WHERE id_adeudo IN ([adeudosSeleccionados]);

    -- 3. UPDATE último año pagado
    UPDATE padron_licencias.comun.ta_13_datosrcm
    SET axo_pagado = [axoHasta], usuario = [usuario], fecha_mov = CURRENT_DATE
    WHERE control_rcm = [folioABuscar];
    */

    if (response && response.length > 0) {
      const resultado = response[0]

      if (resultado.p_error) {
        showToast('error', 'Error al registrar pago: ' + resultado.p_error)
        return
      }

      showToast('success', 'Pago registrado exitosamente')
      cancelarOperacion()
      await buscarFolio() // Recargar datos del folio
    }
  } catch (error) {
    showToast('error', 'Error al registrar pago: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
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
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  loading.value = true
  showLoading()
  try {
    // Usar SP: sp_pagos_dar_baja
    // Base: cementerio.public (según 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_pagos_dar_baja',
      'cementerio',
      {
        p_control_id: pago.control_id,
        p_control_rcm: folioABuscar.value,
        p_usuario: 1 // TODO: Obtener del contexto
      },
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Queries SQL originales (comentadas - ahora usa SP transaccional)
    -- 1. UPDATE vigencia a 'B'
    UPDATE cementerio.public.ta_13_pagosrcm
    SET vigencia = 'B', usuario = [usuario], fecha_mov = CURRENT_DATE
    WHERE control_id = [control_id];

    -- 2. Liberar adeudos (id_pago = NULL)
    UPDATE cementerio.public.ta_13_adeudosrcm
    SET id_pago = NULL, usuario = [usuario], fecha_mov = CURRENT_DATE
    WHERE id_pago = [control_id];

    -- 3. Recalcular último año pagado
    SELECT MAX(axo_pago_hasta) as ultimo_axo
    FROM cementerio.public.ta_13_pagosrcm
    WHERE control_rcm = [folioABuscar] AND vigencia = 'A';

    -- 4. UPDATE último año pagado
    UPDATE padron_licencias.comun.ta_13_datosrcm
    SET axo_pagado = [ultimoAxo], usuario = [usuario], fecha_mov = CURRENT_DATE
    WHERE control_rcm = [folioABuscar];
    */

    if (response && response.length > 0) {
      const resultado = response[0]

      if (resultado.p_error) {
        showToast('error', 'Error al dar de baja: ' + resultado.p_error)
        return
      }
    }

    showToast('success', 'Pago dado de baja exitosamente')
    await cargarPagosRegistrados() // Recargar listado
    await buscarFolio() // Recargar datos del folio
  } catch (error) {
    showToast('error', 'Error al dar de baja pago: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
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
