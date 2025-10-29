<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Registros</h1>
        <p>{{ tituloTabla }}</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tarjeta de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ etiquetaBusqueda }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarRegistro">
            <div class="form-row">
              <!-- Campo expediente (visible para tabla 1,2,4,5) -->
              <div class="form-group" v-if="tipoTabla !== '3'">
                <label class="municipal-form-label">
                  {{ etiquetaControl }} <span class="required">*</span>
                </label>
                <div style="display: flex; gap: 10px; align-items: center;">
                  <span v-if="etiquetas.abreviatura" style="font-weight: bold; font-size: 1.1rem;">
                    {{ etiquetas.abreviatura }}
                  </span>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="numExpediente"
                    placeholder="Número de expediente"
                    maxlength="6"
                    required
                    @keyup.enter="buscarRegistro"
                  >
                </div>
              </div>

              <!-- Campos para Mercados (tabla 3) -->
              <div class="form-group" v-if="tipoTabla === '3'">
                <label class="municipal-form-label">
                  Número de Local <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="numLocal"
                  placeholder="Número"
                  maxlength="3"
                  required
                  @keyup.enter="focusLetra"
                >
              </div>

              <div class="form-group" v-if="tipoTabla === '3'">
                <label class="municipal-form-label">Letra</label>
                <input
                  ref="letraInput"
                  type="text"
                  class="municipal-form-control"
                  v-model="letraLocal"
                  placeholder="Letra"
                  maxlength="1"
                  style="text-transform: uppercase;"
                  @keyup.enter="buscarRegistro"
                >
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                {{ loading ? 'Buscando...' : 'Buscar' }}
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Tarjeta de información del registro -->
      <div class="municipal-card" v-if="datosContrato">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Registro
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>Control:</label>
              <span>{{ datosContrato.control }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.concesionario || 'Concesionario' }}:</label>
              <span>{{ datosContrato.concesionario }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.ubicacion || 'Ubicación' }}:</label>
              <span>{{ datosContrato.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.nomcomercial">
              <label>{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}:</label>
              <span>{{ datosContrato.nomcomercial }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.lugar">
              <label>{{ etiquetas.lugar || 'Lugar' }}:</label>
              <span>{{ datosContrato.lugar }}</span>
            </div>
            <div class="info-item" v-if="tipoTabla !== '5' && datosContrato.superficie">
              <label>{{ etiquetas.superficie || 'Superficie' }}:</label>
              <span>{{ datosContrato.superficie }} m²</span>
            </div>
            <div class="info-item" v-if="datosContrato.unidades">
              <label>{{ etiquetas.unidad || 'Unidades' }}:</label>
              <span>{{ datosContrato.unidades }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.fecha_inicio || 'Fecha Inicio' }}:</label>
              <span>{{ formatDate(datosContrato.fechainicio) }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.fechafin">
              <label>{{ etiquetas.fecha_fin || 'Fecha Fin' }}:</label>
              <span>{{ formatDate(datosContrato.fechafin) }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.recaudadora || 'Oficina' }}:</label>
              <span>{{ datosContrato.recaudadora }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.sector">
              <label>{{ etiquetas.sector || 'Sector' }}:</label>
              <span>{{ datosContrato.sector }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.zona">
              <label>{{ etiquetas.zona || 'Zona' }}:</label>
              <span>{{ datosContrato.zona }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.licencia">
              <label>{{ etiquetas.licencia || 'Licencia' }}:</label>
              <span>{{ datosContrato.licencia }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.obs">
              <label>{{ etiquetas.obs || 'Observaciones' }}:</label>
              <span>{{ datosContrato.obs }}</span>
            </div>
            <div class="info-item">
              <label>Status:</label>
              <span class="badge" :class="getStatusClass(datosContrato.statusregistro)">
                {{ datosContrato.statusregistro }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones de acción -->
      <div class="municipal-card" v-if="datosContrato">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="verPagados"
              :disabled="!tienePagos || loading"
              v-if="tienePagos"
            >
              <font-awesome-icon icon="money-bill-wave" />
              Ver Pagos Realizados
            </button>
            <button
              class="btn-municipal-secondary"
              @click="verHistorico"
              :disabled="loading"
            >
              <font-awesome-icon icon="history" />
              Ver Histórico
            </button>
            <button
              class="btn-municipal-secondary"
              @click="verApremios"
              :disabled="loading"
            >
              <font-awesome-icon icon="exclamation-triangle" />
              Ver Apremios
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de adeudos pendientes -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Pendientes
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Año</th>
                  <th class="text-center">Mes</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Multa</th>
                  <th class="text-right">Descuento</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(adeudo, index) in adeudos"
                  :key="index"
                  class="row-hover"
                  @dblclick="expandirAdeudo(adeudo)"
                  style="cursor: pointer;"
                >
                  <td>{{ adeudo.concepto }}</td>
                  <td class="text-center">{{ adeudo.axo }}</td>
                  <td class="text-center">{{ getNombreMes(adeudo.mes) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.recargos_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.actualizacion_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.multa_pagar) }}</td>
                  <td class="text-right">
                    {{ formatCurrency(calcularDescuentos(adeudo)) }}
                  </td>
                  <td class="text-right font-weight-bold">
                    {{ formatCurrency(calcularTotalAdeudo(adeudo)) }}
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="3" class="font-weight-bold">TOTAL GENERAL:</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalImporte) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalRecargos) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalActualizacion) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalMulta) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalDescuentos) }}</td>
                  <td class="text-right font-weight-bold" style="font-size: 1.2rem;">
                    {{ formatCurrency(totalGeneral) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div class="alert-info" style="margin-top: 15px; padding: 10px; background: #e3f2fd; border-left: 4px solid #2196f3;">
            <p style="margin: 0; font-size: 0.9rem;">
              <font-awesome-icon icon="info-circle" />
              <strong>Nota:</strong> Haga doble clic en un adeudo para ver el detalle de periodos anteriores.
            </p>
          </div>
        </div>
      </div>

      <!-- Modal de pagos realizados -->
      <div v-if="showModalPagos" class="modal-overlay" @click.self="closeModalPagos">
        <div class="modal-container" style="max-width: 900px;">
          <div class="modal-header">
            <h3>
              <font-awesome-icon icon="money-bill-wave" />
              Pagos Realizados
            </h3>
            <button class="modal-close" @click="closeModalPagos">
              <font-awesome-icon icon="times" />
            </button>
          </div>

          <div class="modal-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Fecha/Hora Pago</th>
                    <th>Periodo</th>
                    <th class="text-right">Importe</th>
                    <th class="text-right">Recargo</th>
                    <th>Folio Recibo</th>
                    <th>Caja</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="pago in pagosRealizados" :key="pago.id_34_pagos" class="row-hover">
                    <td>{{ formatDateTime(pago.fecha_hora_pago) }}</td>
                    <td>{{ formatDate(pago.periodo) }}</td>
                    <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                    <td class="text-right">{{ formatCurrency(pago.recargo) }}</td>
                    <td>{{ pago.folio_recibo }}</td>
                    <td>{{ pago.caja }}</td>
                    <td>{{ pago.usuario }}</td>
                  </tr>
                </tbody>
                <tfoot class="municipal-table-footer">
                  <tr>
                    <td colspan="2" class="font-weight-bold">TOTAL PAGADO:</td>
                    <td class="text-right font-weight-bold">{{ formatCurrency(totalPagosImporte) }}</td>
                    <td class="text-right font-weight-bold">{{ formatCurrency(totalPagosRecargo) }}</td>
                    <td colspan="3"></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>

          <div class="modal-footer">
            <button class="btn-municipal-secondary" @click="closeModalPagos">
              Cerrar
            </button>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>{{ loadingMessage }}</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GConsulta'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const tipoTabla = ref(route.params.tabla || route.query.tabla || '1')
const etiquetas = ref({})
const infoTabla = ref({})
const numExpediente = ref('')
const numLocal = ref('')
const letraLocal = ref('')
const letraInput = ref(null)
const datosContrato = ref(null)
const adeudos = ref([])
const pagosRealizados = ref([])
const tienePagos = ref(false)
const showModalPagos = ref(false)
const loadingMessage = ref('Cargando...')

// Computed
const tituloTabla = computed(() => {
  if (infoTabla.value.nombre) {
    return `Consulta de: ${infoTabla.value.nombre}`
  }
  return 'Otras Obligaciones - Consulta de Registros'
})

const etiquetaBusqueda = computed(() => {
  return etiquetas.value.etiq_control || 'Búsqueda por Control'
})

const etiquetaControl = computed(() => {
  return etiquetas.value.etiq_control || 'Número de Expediente'
})

const totalImporte = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + (item.importe_pagar || 0), 0)
})

const totalRecargos = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + (item.recargos_pagar || 0), 0)
})

const totalActualizacion = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + (item.actualizacion_pagar || 0), 0)
})

const totalMulta = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + (item.multa_pagar || 0), 0)
})

const totalDescuentos = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + calcularDescuentos(item), 0)
})

const totalGeneral = computed(() => {
  return adeudos.value.reduce((sum, item) => sum + calcularTotalAdeudo(item), 0)
})

const totalPagosImporte = computed(() => {
  return pagosRealizados.value.reduce((sum, item) => sum + (item.importe || 0), 0)
})

const totalPagosRecargo = computed(() => {
  return pagosRealizados.value.reduce((sum, item) => sum + (item.recargo || 0), 0)
})

// Métodos
const calcularDescuentos = (adeudo) => {
  return (adeudo.dscto_importe || 0) +
         (adeudo.dscto_recargos || 0) +
         (adeudo.dscto_multa || 0)
}

const calcularTotalAdeudo = (adeudo) => {
  return (adeudo.importe_pagar || 0) +
         (adeudo.recargos_pagar || 0) +
         (adeudo.actualizacion_pagar || 0) +
         (adeudo.multa_pagar || 0) -
         calcularDescuentos(adeudo)
}

const getNombreMes = (mes) => {
  const meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ]
  return meses[mes - 1] || mes
}

const getStatusClass = (status) => {
  if (!status) return 'badge-secondary'
  const statusLower = status.toLowerCase()
  if (statusLower.includes('activ')) return 'badge-success'
  if (statusLower.includes('suspend') || statusLower.includes('cancel')) return 'badge-danger'
  return 'badge-info'
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const cargarConfiguracion = async () => {
  setLoading(true, 'Cargando configuración...')

  try {
    // Cargar etiquetas (reutiliza SP de GAdeudos)
    const responseEtiq = await execute(
      'SP_GADEUDOS_ETIQUETAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (responseEtiq && responseEtiq.result && responseEtiq.result.length > 0) {
      etiquetas.value = responseEtiq.result[0]
    }

    // Cargar información de la tabla (reutiliza SP de GAdeudos)
    const responseTabla = await execute(
      'SP_GADEUDOS_TABLAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (responseTabla && responseTabla.result && responseTabla.result.length > 0) {
      infoTabla.value = responseTabla.result[0]
    }

  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const buscarRegistro = async () => {
  // Validar campos
  if (tipoTabla.value === '3') {
    if (!numLocal.value) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE LOCAL, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
  } else {
    if (!numExpediente.value) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE EXPEDIENTE, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
  }

  // Construir número de control
  let control = ''
  if (tipoTabla.value === '3') {
    control = letraLocal.value ? `${numLocal.value}-${letraLocal.value}` : String(numLocal.value)
  } else {
    control = `${etiquetas.value.abreviatura || ''}${numExpediente.value}`
  }

  setLoading(true, 'Buscando registro...')

  try {
    // Buscar datos del contrato
    const responseDatos = await execute(
      'SP_GCONSULTA_DATOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (!responseDatos || !responseDatos.result || responseDatos.result[0]?.status === -1) {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No existe REGISTRO ALGUNO con este dato, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      datosContrato.value = null
      adeudos.value = []
      pagosRealizados.value = []
      tienePagos.value = false
      return
    }

    datosContrato.value = responseDatos.result[0]

    // Cargar adeudos (por defecto, hasta el mes actual)
    const now = new Date()
    const anoActual = now.getFullYear()
    const mesActual = 12 // Diciembre - para mostrar todo el año

    await cargarAdeudos(datosContrato.value.id_datos, anoActual, mesActual)

    // Verificar si tiene pagos
    await verificarPagos(datosContrato.value.id_datos)

    showToast('success', 'Registro cargado correctamente')

  } catch (error) {
    handleApiError(error)
    datosContrato.value = null
    adeudos.value = []
    pagosRealizados.value = []
    tienePagos.value = false
  } finally {
    setLoading(false)
  }
}

const cargarAdeudos = async (idDatos, ano, mes) => {
  setLoading(true, 'Cargando adeudos...')

  try {
    const responseAdeudos = await execute(
      'SP_GCONSULTA_ADEUDOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tipoTabla.value, tipo: 'string' },
        { nombre: 'par_id_datos', valor: idDatos, tipo: 'integer' },
        { nombre: 'par_aso', valor: ano, tipo: 'integer' },
        { nombre: 'par_mes', valor: mes, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (responseAdeudos && responseAdeudos.result) {
      adeudos.value = responseAdeudos.result
    } else {
      adeudos.value = []
    }

  } catch (error) {
    handleApiError(error)
    adeudos.value = []
  } finally {
    setLoading(false)
  }
}

const verificarPagos = async (idDatos) => {
  try {
    const responsePagos = await execute(
      'SP_GCONSULTA_PAGADOS_GET',
      'otras_obligaciones',
      [{ nombre: 'p_Control', valor: idDatos, tipo: 'integer' }],
      'guadalajara'
    )

    if (responsePagos && responsePagos.result && responsePagos.result.length > 0) {
      pagosRealizados.value = responsePagos.result
      tienePagos.value = true
    } else {
      pagosRealizados.value = []
      tienePagos.value = false
    }

  } catch (error) {
    pagosRealizados.value = []
    tienePagos.value = false
  }
}

const expandirAdeudo = async (adeudo) => {
  if (!datosContrato.value) return

  await Swal.fire({
    icon: 'info',
    title: 'Detalle de Adeudo',
    html: `
      <div style="text-align: left;">
        <p><strong>Concepto:</strong> ${adeudo.concepto}</p>
        <p><strong>Periodo:</strong> ${getNombreMes(adeudo.mes)} ${adeudo.axo}</p>
        <hr>
        <p><strong>Importe:</strong> ${formatCurrency(adeudo.importe_pagar)}</p>
        <p><strong>Recargos:</strong> ${formatCurrency(adeudo.recargos_pagar)}</p>
        <p><strong>Actualización:</strong> ${formatCurrency(adeudo.actualizacion_pagar)}</p>
        <p><strong>Multa:</strong> ${formatCurrency(adeudo.multa_pagar)}</p>
        ${calcularDescuentos(adeudo) > 0 ? `<p><strong>Descuentos:</strong> ${formatCurrency(calcularDescuentos(adeudo))}</p>` : ''}
        <hr>
        <p style="font-size: 1.2rem;"><strong>Total:</strong> ${formatCurrency(calcularTotalAdeudo(adeudo))}</p>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    confirmButtonText: 'Cerrar'
  })

  // Recargar adeudos hasta ese periodo específico
  await cargarAdeudos(datosContrato.value.id_datos, adeudo.axo, adeudo.mes)
}

const verPagados = () => {
  showModalPagos.value = true
}

const closeModalPagos = () => {
  showModalPagos.value = false
}

const verHistorico = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Histórico',
    text: 'La funcionalidad de histórico estará disponible próximamente',
    confirmButtonColor: '#ea8215'
  })
}

const verApremios = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Apremios',
    text: 'La funcionalidad de apremios estará disponible próximamente',
    confirmButtonColor: '#ea8215'
  })
}

const limpiarFormulario = () => {
  numExpediente.value = ''
  numLocal.value = ''
  letraLocal.value = ''
  datosContrato.value = null
  adeudos.value = []
  pagosRealizados.value = []
  tienePagos.value = false
  showModalPagos.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

const formatDateTime = (dateTimeString) => {
  if (!dateTimeString) return ''
  try {
    const date = new Date(dateTimeString)
    return date.toLocaleString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return dateTimeString
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

// Lifecycle
onMounted(() => {
  cargarConfiguracion()
})
</script>
