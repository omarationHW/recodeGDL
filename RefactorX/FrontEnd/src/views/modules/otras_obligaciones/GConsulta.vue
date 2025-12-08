<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Registros</h1>
        <p>{{ tituloTabla }}</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-info"
          @click="cargarConfiguracion"
          :disabled="loading"
          title="Actualizar"
        >
          <font-awesome-icon icon="sync" :spin="loading" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
            <span class="badge badge-purple ms-2" v-if="datosContrato">
              Registro encontrado
            </span>
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
                <div class="d-flex gap-2 align-items-center">
                  <span v-if="etiquetas.abreviatura" class="fw-bold fs-5">
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
                  class="municipal-form-control text-uppercase"
                  v-model="letraLocal"
                  placeholder="Letra"
                  maxlength="1"
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
              v-if="tieneGastosOMultas"
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
      <div class="municipal-card" v-if="datosContrato">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Pendientes
            <span class="badge badge-purple ms-2" v-if="adeudos.length > 0">
              {{ adeudos.length }} {{ adeudos.length === 1 ? 'adeudo' : 'adeudos' }}
            </span>
          </h5>
        </div>

        <div class="municipal-card-body">
          <!-- Empty state cuando no hay adeudos -->
          <div v-if="adeudos.length === 0" class="empty-state">
            <font-awesome-icon icon="check-circle" size="3x" class="text-success" />
            <h3>Sin Adeudos Pendientes</h3>
            <p>Este registro no tiene adeudos pendientes de pago</p>
          </div>

          <!-- Tabla con adeudos -->
          <div v-else class="table-responsive">
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
                  class="row-hover cursor-pointer"
                  @dblclick="expandirAdeudo(adeudo)"
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
                  <td class="text-right fw-bold">
                    {{ formatCurrency(calcularTotalAdeudo(adeudo)) }}
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="3" class="fw-bold">TOTAL GENERAL:</td>
                  <td class="text-right fw-bold">{{ formatCurrency(totalImporte) }}</td>
                  <td class="text-right fw-bold">{{ formatCurrency(totalRecargos) }}</td>
                  <td class="text-right fw-bold">{{ formatCurrency(totalActualizacion) }}</td>
                  <td class="text-right fw-bold">{{ formatCurrency(totalMulta) }}</td>
                  <td class="text-right fw-bold">{{ formatCurrency(totalDescuentos) }}</td>
                  <td class="text-right fw-bold fs-5">
                    {{ formatCurrency(totalGeneral) }}
                  </td>
                </tr>
              </tfoot>
            </table>

            <div class="alert alert-info mt-3 border-start border-info border-4">
              <p class="mb-0 small">
                <font-awesome-icon icon="info-circle" />
                <strong>Nota:</strong> Haga doble clic en un adeudo para ver el detalle de periodos anteriores.
              </p>
            </div>
          </div>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
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
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local para loading
const loading = ref(false)

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

const tieneGastosOMultas = computed(() => {
  return adeudos.value.some(adeudo => {
    const conceptoLower = (adeudo.concepto || '').toLowerCase()
    return conceptoLower.includes('gastos') ||
           conceptoLower.includes('multa') ||
           (adeudo.multa_pagar && adeudo.multa_pagar > 0)
  })
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
  return 'badge-purple'
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const cargarConfiguracion = async () => {
  loading.value = true
  showLoading('Cargando configuración...')

  try {
    // Cargar etiquetas
    const responseEtiq = await execute(
      'sp_gconsulta_get_etiquetas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'public'
    )

    if (responseEtiq && responseEtiq.result && responseEtiq.result.length > 0) {
      etiquetas.value = responseEtiq.result[0]
    }

    // Cargar información de la tabla
    const responseTabla = await execute(
      'sp_gconsulta_get_tabla_info',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (responseTabla && responseTabla.result && responseTabla.result.length > 0) {
      infoTabla.value = responseTabla.result[0]
    }

    showToast('success', 'Configuración cargada')

  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
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

  const startTime = performance.now()
  loading.value = true
  showLoading('Buscando registro...')

  try {
    // Buscar datos del contrato
    const responseDatos = await execute(
      'sp_gconsulta_buscar_registro',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      '',
      null,
      'public'
    )

    if (!responseDatos || !responseDatos.result || responseDatos.result[0]?.status === -1) {
      loading.value = false
      hideLoading()
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

    loading.value = false
    hideLoading()

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
    showToast('success', `Registro cargado correctamente (${timeMessage})`)

  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    datosContrato.value = null
    adeudos.value = []
    pagosRealizados.value = []
    tienePagos.value = false
  }
}

const cargarAdeudos = async (idDatos, ano, mes) => {
  try {
    const responseAdeudos = await execute(
      'sp_gconsulta_get_adeudos',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_id_datos', valor: idDatos, tipo: 'integer' },
        { nombre: 'par_ano', valor: ano, tipo: 'integer' },
        { nombre: 'par_mes', valor: mes, tipo: 'integer' }
      ],
      '',
      null,
      'public'
    )

    if (responseAdeudos && responseAdeudos.result) {
      adeudos.value = responseAdeudos.result
    } else {
      adeudos.value = []
    }

  } catch (error) {
    handleApiError(error)
    adeudos.value = []
  }
}

const verificarPagos = async (idDatos) => {
  try {
    const responsePagos = await execute(
      'sp_gconsulta_get_pagados',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: idDatos, tipo: 'integer' }],
      '',
      null,
      'public'
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
      <div class="text-start">
        <p><strong>Concepto:</strong> ${adeudo.concepto}</p>
        <p><strong>Periodo:</strong> ${getNombreMes(adeudo.mes)} ${adeudo.axo}</p>
        <hr>
        <p><strong>Importe:</strong> ${formatCurrency(adeudo.importe_pagar)}</p>
        <p><strong>Recargos:</strong> ${formatCurrency(adeudo.recargos_pagar)}</p>
        <p><strong>Actualización:</strong> ${formatCurrency(adeudo.actualizacion_pagar)}</p>
        <p><strong>Multa:</strong> ${formatCurrency(adeudo.multa_pagar)}</p>
        ${calcularDescuentos(adeudo) > 0 ? `<p><strong>Descuentos:</strong> ${formatCurrency(calcularDescuentos(adeudo))}</p>` : ''}
        <hr>
        <p class="fs-5"><strong>Total:</strong> ${formatCurrency(calcularTotalAdeudo(adeudo))}</p>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    confirmButtonText: 'Cerrar'
  })

  // Recargar adeudos hasta ese periodo específico
  await cargarAdeudos(datosContrato.value.id_datos, adeudo.axo, adeudo.mes)
}

const verPagados = async () => {
  if (!datosContrato.value) return

  loading.value = true
  showLoading('Cargando pagos realizados...')

  try {
    const response = await execute(
      'sp_gconsulta_get_pagados',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' }],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const pagos = response.result

      // Calcular totales
      const totalImporte = pagos.reduce((sum, p) => sum + (p.importe || 0), 0)
      const totalRecargo = pagos.reduce((sum, p) => sum + (p.recargo || 0), 0)

      // Construir tabla HTML
      let tablaHtml = `
        <div style="max-height: 400px; overflow-y: auto;">
          <table class="swal2-table" style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background: #ea8215; color: white;">
                <th style="padding: 8px; text-align: left;">Fecha/Hora</th>
                <th style="padding: 8px; text-align: left;">Periodo</th>
                <th style="padding: 8px; text-align: right;">Importe</th>
                <th style="padding: 8px; text-align: right;">Recargo</th>
                <th style="padding: 8px; text-align: left;">Recibo</th>
              </tr>
            </thead>
            <tbody>
      `

      pagos.forEach((pago, index) => {
        const bgColor = index % 2 === 0 ? '#fff' : '#f8f9fa'
        tablaHtml += `
          <tr style="background: ${bgColor};">
            <td style="padding: 6px 8px;">${formatDateTime(pago.fecha_hora_pago)}</td>
            <td style="padding: 6px 8px;">${formatDate(pago.periodo)}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(pago.importe)}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(pago.recargo)}</td>
            <td style="padding: 6px 8px;">${pago.folio_recibo || 'S/N'}</td>
          </tr>
        `
      })

      tablaHtml += `
            </tbody>
            <tfoot>
              <tr style="background: #343a40; color: white; font-weight: bold;">
                <td colspan="2" style="padding: 8px;">TOTAL:</td>
                <td style="padding: 8px; text-align: right;">${formatCurrency(totalImporte)}</td>
                <td style="padding: 8px; text-align: right;">${formatCurrency(totalRecargo)}</td>
                <td style="padding: 8px;"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      `

      await Swal.fire({
        title: '💰 Pagos Realizados',
        html: tablaHtml,
        width: '800px',
        confirmButtonColor: '#ea8215',
        confirmButtonText: 'Cerrar'
      })
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'Sin pagos',
        text: 'No se encontraron pagos realizados para este registro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
}

const verHistorico = async () => {
  if (!datosContrato.value) return

  loading.value = true
  showLoading('Cargando histórico...')

  try {
    const response = await execute(
      'sp_gconsulta_get_historico',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' }],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const movimientos = response.result

      // Construir tabla HTML
      let tablaHtml = `
        <div style="max-height: 400px; overflow-y: auto;">
          <table class="swal2-table" style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background: #6f42c1; color: white;">
                <th style="padding: 8px; text-align: left;">Fecha</th>
                <th style="padding: 8px; text-align: center;">Tipo</th>
                <th style="padding: 8px; text-align: left;">Descripción</th>
                <th style="padding: 8px; text-align: right;">Importe</th>
              </tr>
            </thead>
            <tbody>
      `

      movimientos.forEach((mov, index) => {
        const bgColor = index % 2 === 0 ? '#fff' : '#f8f9fa'
        const tipoBadge = mov.tipo_movimiento === 'PAGO'
          ? '<span style="background: #28a745; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">PAGO</span>'
          : '<span style="background: #17a2b8; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">ADEUDO</span>'

        tablaHtml += `
          <tr style="background: ${bgColor};">
            <td style="padding: 6px 8px;">${formatDateTime(mov.fecha)}</td>
            <td style="padding: 6px 8px; text-align: center;">${tipoBadge}</td>
            <td style="padding: 6px 8px;">${mov.descripcion}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(mov.importe)}</td>
          </tr>
        `
      })

      tablaHtml += `
            </tbody>
          </table>
        </div>
        <p style="margin-top: 10px; font-size: 12px; color: #666;">
          Total de movimientos: <strong>${movimientos.length}</strong>
        </p>
      `

      await Swal.fire({
        title: '📋 Histórico de Movimientos',
        html: tablaHtml,
        width: '850px',
        confirmButtonColor: '#ea8215',
        confirmButtonText: 'Cerrar'
      })
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'Sin histórico',
        text: 'No se encontraron movimientos en el histórico para este registro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
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
