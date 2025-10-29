<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Cancelación de Contratos</h1>
        <p>Aseo Contratado - Cancelación y gestión de contratos de aseo contratado</p>
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
      <div class="municipal-card-header municipal-header-danger">
        <h6 class="mb-0">Paso 1: Búsqueda de Contrato</h6>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <input type="text" class="municipal-form-control" v-model="busqueda" @keyup.enter="buscarContrato"
              placeholder="Número de contrato o cuenta predial" />
          </div>
          <div class="col-md-2">
            <button class="btn-municipal-secondary w-100" @click="buscarContrato" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratoSeleccionado">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header">
        <h5>Información del Contrato</h5>
      </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
              <strong>Fecha Alta:</strong> {{ formatFecha(contratoSeleccionado.fecha_alta) }}
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
          <div class="row mt-3">
            <div class="col-md-12">
              <strong>Status Actual:</strong>
              <span class="badge ms-2" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                {{ contratoSeleccionado.status === 'A' ? 'ACTIVO' : 'CANCELADO' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div v-if="contratoSeleccionado.status === 'A'" class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header">
        <h5>Verificación de Adeudos Pendientes</h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="cargandoAdeudos" class="text-center py-3">
            <div class="spinner-border text-warning" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-2">Verificando adeudos...</p>
          </div>

          <div v-else>
            <div class="stats-dashboard mb-4">
              <div class="stat-item" :class="adeudosPendientes.length > 0 ? 'stat-danger' : 'stat-success'">
                <div class="stat-icon-mini">
                  <font-awesome-icon icon="exclamation-circle" />
                </div>
                <div class="stat-details">
                  <div class="stat-value-mini">{{ adeudosPendientes.length }}</div>
                  <div class="stat-label-mini">Adeudos Pendientes</div>
                </div>
              </div>
              <div class="stat-item stat-warning">
                <div class="stat-icon-mini">
                  <font-awesome-icon icon="money-bill-wave" />
                </div>
                <div class="stat-details">
                  <div class="stat-value-mini">${{ formatCurrency(montoAdeudado) }}</div>
                  <div class="stat-label-mini">Monto Adeudado</div>
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
              <div class="stat-item stat-primary">
                <div class="stat-icon-mini">
                  <font-awesome-icon icon="calendar-check" />
                </div>
                <div class="stat-details">
                  <div class="stat-value-mini">{{ formatFecha(ultimoPago) }}</div>
                  <div class="stat-label-mini">Último Pago</div>
                </div>
              </div>
            </div>

            <div v-if="adeudosPendientes.length > 0" class="alert alert-danger">
              <font-awesome-icon icon="exclamation-circle" class="me-2" />
              <strong>Atención:</strong> El contrato tiene {{ adeudosPendientes.length }} adeudo(s) pendiente(s)
              por un monto total de ${{ formatCurrency(montoAdeudado) }}.
              <br><strong>Se debe regularizar el adeudo antes de cancelar o proceder con la cancelación con adeudo.</strong>
            </div>

            <div v-else class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              El contrato no tiene adeudos pendientes. Puede proceder con la cancelación.
            </div>
          </div>
        </div>
      </div>

      <div v-if="contratoSeleccionado.status === 'A'" class="municipal-card">
        <div class="municipal-card-header municipal-header-danger">
          <h6 class="mb-0">Paso 2: Datos de Cancelación</h6>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            <strong>ADVERTENCIA:</strong> La cancelación de un contrato es una operación irreversible.
            Asegúrese de contar con la autorización correspondiente.
          </div>

          <div class="row mb-3">
            <div class="col-md-4">
              <label class="municipal-form-label">Motivo de Cancelación *</label>
              <select class="municipal-form-control" v-model="cancelacion.motivo">
                <option value="">Seleccione...</option>
                <option value="SOLICITUD_CONTRIBUYENTE">Solicitud del Contribuyente</option>
                <option value="CAMBIO_EMPRESA">Cambio de Empresa Prestadora</option>
                <option value="CIERRE_NEGOCIO">Cierre de Negocio</option>
                <option value="VENTA_INMUEBLE">Venta del Inmueble</option>
                <option value="INCUMPLIMIENTO">Incumplimiento de Contrato</option>
                <option value="DUPLICADO">Contrato Duplicado</option>
                <option value="ERROR_CAPTURA">Error en Captura</option>
                <option value="OTRO">Otro Motivo</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Fecha de Cancelación *</label>
              <input type="date" class="municipal-form-control" v-model="cancelacion.fecha"
                :max="fechaActual" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Documento de Autorización</label>
              <input type="text" class="municipal-form-control" v-model="cancelacion.documento"
                placeholder="Número de oficio o solicitud" />
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-12">
              <label class="municipal-form-label">Observaciones *</label>
              <textarea class="municipal-form-control" v-model="cancelacion.observaciones" rows="3"
                placeholder="Describa detalladamente el motivo de la cancelación..."></textarea>
            </div>
          </div>

          <div v-if="adeudosPendientes.length > 0" class="mb-3">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" v-model="cancelacion.condonarAdeudos"
                id="condonarAdeudos" />
              <label class="form-check-label" for="condonarAdeudos">
                <strong class="text-danger">Condonar adeudos pendientes (requiere autorización especial)</strong>
              </label>
            </div>
            <small class="text-muted">
              Al activar esta opción, los {{ adeudosPendientes.length }} adeudo(s) pendiente(s) serán condonados
              automáticamente al cancelar el contrato.
            </small>

            <div v-if="cancelacion.condonarAdeudos" class="mt-2">
              <input type="text" class="municipal-form-control" v-model="cancelacion.autorizacionCondonacion"
                placeholder="Documento de autorización para condonación *" />
            </div>
          </div>

          <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" v-model="cancelacion.confirmar" id="confirmar" />
            <label class="form-check-label" for="confirmar">
              <strong>Confirmo que cuento con la autorización correspondiente para cancelar este contrato</strong>
            </label>
          </div>

          <div class="d-flex justify-content-end">
            <button class="btn-municipal-secondary me-2" @click="limpiar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-secondary" @click="cancelarContrato"
              :disabled="!validarCancelacion()">
              <font-awesome-icon icon="ban" /> Cancelar Contrato
            </button>
          </div>
        </div>
      </div>

      <div v-else class="alert alert-warning">
        <font-awesome-icon icon="info-circle" class="me-2" />
        Este contrato ya se encuentra <strong>CANCELADO</strong>.
        Fecha de cancelación: {{ formatFecha(contratoSeleccionado.fecha_cancelacion) }}
        <br>Motivo: {{ contratoSeleccionado.motivo_cancelacion || 'No especificado' }}
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Cancelación de Contratos">
      <h6>Descripción</h6>
      <p>Permite cancelar contratos de servicio de aseo contratado de manera definitiva.</p>
      <h6>Motivos de Cancelación</h6>
      <ul>
        <li><strong>Solicitud del Contribuyente:</strong> Baja voluntaria del servicio</li>
        <li><strong>Cambio de Empresa:</strong> Cambio a otra empresa prestadora</li>
        <li><strong>Cierre de Negocio:</strong> Clausura del establecimiento</li>
        <li><strong>Venta del Inmueble:</strong> Transferencia de propiedad</li>
        <li><strong>Incumplimiento:</strong> Violación de términos del contrato</li>
        <li><strong>Duplicado:</strong> Contrato capturado por error</li>
      </ul>
      <h6>Requisitos</h6>
      <ul>
        <li>Verificación de adeudos pendientes</li>
        <li>Autorización oficial para cancelación</li>
        <li>Si hay adeudos: Liquidación o condonación autorizada</li>
        <li>Documentación que respalde la cancelación</li>
      </ul>
      <h6>Importante</h6>
      <p class="text-danger"><strong>La cancelación es irreversible.</strong> Una vez cancelado, el contrato no puede reactivarse.</p>
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
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const cargandoAdeudos = ref(false)
const mostrarAyuda = ref(false)
const busqueda = ref('')
const contratoSeleccionado = ref(null)
const adeudosPendientes = ref([])
const pagosRealizados = ref(0)
const ultimoPago = ref(null)

const cancelacion = ref({
  motivo: '',
  fecha: new Date().toISOString().split('T')[0],
  documento: '',
  observaciones: '',
  condonarAdeudos: false,
  autorizacionCondonacion: '',
  confirmar: false
})

const fechaActual = computed(() => new Date().toISOString().split('T')[0])

const montoAdeudado = computed(() => {
  return adeudosPendientes.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const buscarContrato = async () => {
  if (!busqueda.value) {
    return showToast('Ingrese un número de contrato', 'warning')
  }

  cargando.value = true
  try {
    const [respContrato] = await Promise.all([
      execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
        p_num_contrato: busqueda.value
      })
    ])
    if (respContrato?.length > 0) {
      contratoSeleccionado.value = respContrato[0]
      if (contratoSeleccionado.value.status === 'A') {
        await cargarAdeudos()
      }
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
    }
  } catch (error) {
    handleError(error, 'Error al buscar contrato')
  } finally {
    cargando.value = false
  }
}

const cargarAdeudos = async () => {
  cargandoAdeudos.value = true
  try {
    const [respAdeudos, respPagos] = await Promise.all([
      execute('SP_ASEO_ADEUDOS_POR_CONTRATO', 'aseo_contratado', {
        p_control_contrato: contratoSeleccionado.value.control_contrato
      }),
      execute('SP_ASEO_PAGOS_POR_CONTRATO', 'aseo_contratado', {
        p_control_contrato: contratoSeleccionado.value.control_contrato,
        p_fecha_desde: null,
        p_fecha_hasta: new Date().toISOString().split('T')[0]
      })
    ])

    adeudosPendientes.value = (respAdeudos || []).filter(a => a.status === 'P')
    const pagosList = respPagos || []
    pagosRealizados.value = pagosList.length
    ultimoPago.value = pagosList[0]?.fecha_pago || null
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
  } finally {
    cargandoAdeudos.value = false
  }
}

const validarCancelacion = () => {
  if (!cancelacion.value.motivo) return false
  if (!cancelacion.value.fecha) return false
  if (!cancelacion.value.observaciones.trim()) return false
  if (!cancelacion.value.confirmar) return false
  if (adeudosPendientes.value.length > 0 && cancelacion.value.condonarAdeudos) {
    if (!cancelacion.value.autorizacionCondonacion.trim()) return false
  }
  return true
}

const cancelarContrato = async () => {
  let htmlContent = `
    <p><strong>Contrato:</strong> ${contratoSeleccionado.value.num_contrato}</p>
    <p><strong>Contribuyente:</strong> ${contratoSeleccionado.value.contribuyente}</p>
    <p><strong>Motivo:</strong> ${cancelacion.value.motivo}</p>
  `

  if (adeudosPendientes.value.length > 0) {
    if (cancelacion.value.condonarAdeudos) {
      htmlContent += `<p class="text-danger"><strong>Se condonarán ${adeudosPendientes.value.length} adeudo(s) por $${formatCurrency(montoAdeudado.value)}</strong></p>`
    } else {
      htmlContent += `<p class="text-warning"><strong>Advertencia: Existen ${adeudosPendientes.value.length} adeudo(s) pendiente(s)</strong></p>`
    }
  }

  htmlContent += '<p class="text-danger mt-3"><strong>Esta operación NO se puede deshacer.</strong></p>'

  const result = await Swal.fire({
    title: '¿Cancelar Contrato?',
    html: htmlContent,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, volver'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_motivo: cancelacion.value.motivo,
      p_fecha_cancelacion: cancelacion.value.fecha,
      p_documento: cancelacion.value.documento,
      p_observaciones: cancelacion.value.observaciones,
      p_condonar_adeudos: cancelacion.value.condonarAdeudos ? 'S' : 'N',
      p_autorizacion_condonacion: cancelacion.value.autorizacionCondonacion
    }
    await execute('SP_ASEO_CONTRATO_CANCELAR', 'aseo_contratado', params)

    await Swal.fire(
      '¡Contrato Cancelado!',
      'El contrato ha sido cancelado exitosamente',
      'success'
    )

    // Recargar contrato para mostrar estado actualizado
    await buscarContrato()
    limpiarFormulario()
  } catch (error) {
    handleError(error, 'Error al cancelar contrato')
  } finally {
    cargando.value = false
  }
}

const limpiar = () => {
  contratoSeleccionado.value = null
  adeudosPendientes.value = []
  busqueda.value = ''
  limpiarFormulario()
}

const limpiarFormulario = () => {
  cancelacion.value = {
    motivo: '',
    fecha: new Date().toISOString().split('T')[0],
    documento: '',
    observaciones: '',
    condonarAdeudos: false,
    autorizacionCondonacion: '',
    confirmar: false
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
</script>

