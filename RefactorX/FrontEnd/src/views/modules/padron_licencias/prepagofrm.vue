<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="percent" />
      </div>
      <div class="module-view-info">
        <h1>Prepago de Licencias</h1>
        <p>Padrón de Licencias - Sistema de Prepago con Cálculo de Descuentos por Pronto Pago</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de Cuenta Catastral -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Cuenta Catastral
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Cuenta Catastral: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.cvecuenta"
              placeholder="Ingrese cuenta catastral"
              @keyup.enter="searchCuenta"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchCuenta"
            :disabled="loading || !searchForm.cvecuenta"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSearch"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información del Contribuyente -->
    <div class="municipal-card" v-if="cuentaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="user" />
          Información del Contribuyente
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre Completo:</td>
                <td><strong>{{ cuentaData.ncompleto || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Dirección:</td>
                <td>{{ formatDireccion() }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información de Pago
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Último Complemento:</td>
                <td><span class="badge-purple">{{ cuentaData.ultcomp || 'N/A' }}</span></td>
              </tr>
              <tr>
                <td class="label">Año Último Complemento:</td>
                <td><span class="badge-secondary">{{ cuentaData.axoultcomp || 'N/A' }}</span></td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Calculadora de Descuentos -->
    <div class="municipal-card" v-if="cuentaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calculator" />
          Calculadora de Descuentos por Pronto Pago
        </h5>
        <button
          class="btn-municipal-success btn-sm"
          @click="recalcularDescuentos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Recalcular Descuentos
        </button>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Periodo Desde:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="descuentosForm.periodo_desde"
              placeholder="Ej: 202301"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Periodo Hasta:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="descuentosForm.periodo_hasta"
              placeholder="Ej: 202306"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Porcentaje Descuento:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="descuentosForm.porcentaje_descuento"
              placeholder="Ej: 15"
              step="0.01"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="calcularDescuentos"
            :disabled="loading"
          >
            <font-awesome-icon icon="calculator" />
            Calcular Descuentos
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de Descuentos -->
    <div class="municipal-card" v-if="descuentos.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list-alt" />
          Descuentos Calculados
          <span class="badge-purple">{{ descuentos.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Periodo</th>
                <th>Concepto</th>
                <th>Base</th>
                <th>% Descuento</th>
                <th>Descuento</th>
                <th>Total a Pagar</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(desc, index) in descuentos" :key="index" class="clickable-row">
                <td>{{ desc.periodo || 'N/A' }}</td>
                <td>{{ desc.concepto || 'N/A' }}</td>
                <td class="text-end">${{ formatCurrency(desc.base) }}</td>
                <td class="text-end">{{ desc.porcentaje }}%</td>
                <td class="text-end text-success">-${{ formatCurrency(desc.descuento) }}</td>
                <td class="text-end">
                  <strong>${{ formatCurrency(desc.total_pagar) }}</strong>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="table-total">
                <td colspan="2"><strong>TOTAL GENERAL</strong></td>
                <td class="text-end"><strong>${{ formatCurrency(totales.base) }}</strong></td>
                <td></td>
                <td class="text-end text-success"><strong>-${{ formatCurrency(totales.descuento) }}</strong></td>
                <td class="text-end"><strong>${{ formatCurrency(totales.total) }}</strong></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Liquidación Parcial -->
    <div class="municipal-card" v-if="descuentos.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="money-bill-wave" />
          Liquidación Parcial
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Monto a Pagar:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="liquidacionForm.monto"
              placeholder="Ingrese monto"
              step="0.01"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Forma de Pago:</label>
            <select class="municipal-form-control" v-model="liquidacionForm.forma_pago">
              <option value="">Seleccionar...</option>
              <option value="EFECTIVO">Efectivo</option>
              <option value="TARJETA">Tarjeta</option>
              <option value="TRANSFERENCIA">Transferencia</option>
              <option value="CHEQUE">Cheque</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-success"
            @click="procesarLiquidacion"
            :disabled="loading || !liquidacionForm.monto || !liquidacionForm.forma_pago"
          >
            <font-awesome-icon icon="check-circle" />
            Procesar Liquidación
          </button>
          <button
            class="btn-municipal-danger"
            @click="eliminarDescuentos"
            :disabled="loading"
          >
            <font-awesome-icon icon="trash" />
            Eliminar Descuentos
          </button>
        </div>
      </div>
    </div>

    <!-- Último Requerimiento -->
    <div class="municipal-card" v-if="ultimoRequerimiento">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Último Requerimiento
        </h5>
      </div>
      <div class="municipal-card-body">
        <table class="detail-table">
          <tr>
            <td class="label">Número:</td>
            <td>{{ ultimoRequerimiento.numero || 'N/A' }}</td>
          </tr>
          <tr>
            <td class="label">Fecha:</td>
            <td>{{ formatDate(ultimoRequerimiento.fecha) }}</td>
          </tr>
          <tr>
            <td class="label">Estado:</td>
            <td>
              <span class="badge" :class="getEstadoBadgeClass(ultimoRequerimiento.estado)">
                {{ ultimoRequerimiento.estado || 'N/A' }}
              </span>
            </td>
          </tr>
        </table>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando información...</p>
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
      :componentName="'prepagofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

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
const searchForm = ref({
  cvecuenta: null
})

const cuentaData = ref(null)
const descuentos = ref([])
const ultimoRequerimiento = ref(null)

const descuentosForm = ref({
  periodo_desde: null,
  periodo_hasta: null,
  porcentaje_descuento: 15
})

const liquidacionForm = ref({
  monto: null,
  forma_pago: ''
})

// Computed
const totales = computed(() => {
  return descuentos.value.reduce((acc, desc) => {
    return {
      base: acc.base + parseFloat(desc.base || 0),
      descuento: acc.descuento + parseFloat(desc.descuento || 0),
      total: acc.total + parseFloat(desc.total_pagar || 0)
    }
  }, { base: 0, descuento: 0, total: 0 })
})

// Métodos
const searchCuenta = async () => {
  if (!searchForm.value.cvecuenta) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese la cuenta catastral',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando cuenta...')

  try {
    const response = await execute(
      'sp_prepago_get_data',
      'padron_licencias',
      [
        { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      cuentaData.value = response.result[0]
      await loadUltimoRequerimiento()
      showToast('success', 'Cuenta encontrada correctamente')
    } else {
      cuentaData.value = null
      descuentos.value = []
      ultimoRequerimiento.value = null
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No se encontró la cuenta catastral especificada',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    cuentaData.value = null
    descuentos.value = []
    ultimoRequerimiento.value = null
  } finally {
    setLoading(false)
  }
}

const loadUltimoRequerimiento = async () => {
  try {
    const response = await execute(
      'sp_prepago_get_ultimo_requerimiento',
      'padron_licencias',
      [
        { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      ultimoRequerimiento.value = response.result[0]
    } else {
      ultimoRequerimiento.value = null
    }
  } catch (error) {
    ultimoRequerimiento.value = null
  }
}

const calcularDescuentos = async () => {
  setLoading(true, 'Calculando descuentos...')

  try {
    const response = await execute(
      'sp_prepago_calcular_descpred',
      'padron_licencias',
      [
        { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' },
        { nombre: 'p_periodo_desde', valor: descuentosForm.value.periodo_desde, tipo: 'integer' },
        { nombre: 'p_periodo_hasta', valor: descuentosForm.value.periodo_hasta, tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: descuentosForm.value.porcentaje_descuento, tipo: 'numeric' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      descuentos.value = response.result
      showToast('success', 'Descuentos calculados correctamente')
    } else {
      descuentos.value = []
      showToast('warning', 'No se encontraron descuentos aplicables')
    }
  } catch (error) {
    handleApiError(error)
    descuentos.value = []
  } finally {
    setLoading(false)
  }
}

const recalcularDescuentos = async () => {
  const result = await Swal.fire({
    title: 'Recalcular Descuentos',
    text: '¿Está seguro de recalcular los descuentos?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, recalcular',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    setLoading(true, 'Recalculando descuentos...')

    try {
      const response = await execute(
        'sp_prepago_recalcular_dpp',
        'padron_licencias',
        [
          { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' }
        ],
        'guadalajara'
      )

      await calcularDescuentos()

      await Swal.fire({
        icon: 'success',
        title: 'Descuentos Recalculados',
        text: 'Los descuentos han sido recalculados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Descuentos recalculados exitosamente')
    } catch (error) {
      handleApiError(error)
    } finally {
      setLoading(false)
    }
  }
}

const procesarLiquidacion = async () => {
  const result = await Swal.fire({
    title: 'Procesar Liquidación Parcial',
    html: `
      <div class="swal-selection-content">
        <p class="swal-confirmation-text">Se procesará la liquidación con los siguientes datos:</p>
        <ul class="swal-list">
          <li><strong>Monto:</strong> $${formatCurrency(liquidacionForm.value.monto)}</li>
          <li><strong>Forma de Pago:</strong> ${liquidacionForm.value.forma_pago}</li>
        </ul>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, procesar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    setLoading(true, 'Procesando liquidación...')

    try {
      const response = await execute(
        'sp_prepago_liquidacion_parcial',
        'padron_licencias',
        [
          { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' },
          { nombre: 'p_monto', valor: liquidacionForm.value.monto, tipo: 'numeric' },
          { nombre: 'p_forma_pago', valor: liquidacionForm.value.forma_pago, tipo: 'string' }
        ],
        'guadalajara'
      )

      await Swal.fire({
        icon: 'success',
        title: 'Liquidación Procesada',
        text: 'La liquidación parcial ha sido procesada correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Liquidación procesada exitosamente')

      // Limpiar formulario
      liquidacionForm.value = {
        monto: null,
        forma_pago: ''
      }

      // Recargar datos
      await calcularDescuentos()
    } catch (error) {
      handleApiError(error)
    } finally {
      setLoading(false)
    }
  }
}

const eliminarDescuentos = async () => {
  const result = await Swal.fire({
    title: 'Eliminar Descuentos',
    text: '¿Está seguro de eliminar los descuentos calculados?',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    setLoading(true, 'Eliminando descuentos...')

    try {
      const response = await execute(
        'sp_prepago_eliminar_dpp',
        'padron_licencias',
        [
          { nombre: 'p_cvecuenta', valor: searchForm.value.cvecuenta, tipo: 'integer' }
        ],
        'guadalajara'
      )

      descuentos.value = []

      await Swal.fire({
        icon: 'success',
        title: 'Descuentos Eliminados',
        text: 'Los descuentos han sido eliminados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Descuentos eliminados exitosamente')
    } catch (error) {
      handleApiError(error)
    } finally {
      setLoading(false)
    }
  }
}

const clearSearch = () => {
  searchForm.value = {
    cvecuenta: null
  }
  cuentaData.value = null
  descuentos.value = []
  ultimoRequerimiento.value = null
  descuentosForm.value = {
    periodo_desde: null,
    periodo_hasta: null,
    porcentaje_descuento: 15
  }
  liquidacionForm.value = {
    monto: null,
    forma_pago: ''
  }
  showToast('info', 'Búsqueda limpiada')
}

// Utilidades
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch {
    return 'Fecha inválida'
  }
}

const formatDireccion = () => {
  if (!cuentaData.value) return 'N/A'

  const partes = []
  if (cuentaData.value.calle) partes.push(cuentaData.value.calle)
  if (cuentaData.value.noexterior) partes.push(`#${cuentaData.value.noexterior}`)
  if (cuentaData.value.interior) partes.push(`Int. ${cuentaData.value.interior}`)

  return partes.length > 0 ? partes.join(' ') : 'N/A'
}

const getEstadoBadgeClass = (estado) => {
  const classes = {
    'ACTIVO': 'badge-success',
    'PENDIENTE': 'badge-warning',
    'CANCELADO': 'badge-danger',
    'PROCESADO': 'badge-info'
  }
  return classes[estado] || 'badge-secondary'
}
</script>

