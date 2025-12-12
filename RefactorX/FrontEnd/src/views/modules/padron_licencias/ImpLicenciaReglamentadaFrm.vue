<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" >
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Impresión de Licencia Reglamentada</h1>
        <p>Padrón de Licencias - Impresión de Licencias Reglamentadas con Cálculo de Adeudos</p></div>
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

    <!-- Búsqueda de licencia -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Búsqueda de Licencia
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.numeroLicencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="searchLicencia"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.folio"
              placeholder="Folio de trámite"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencia"
            :disabled="loading || !filters.numeroLicencia"
          >
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información de la licencia -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Información de la Licencia
          <span
            class="badge"
            :class="licenciaData.bloqueada ? 'badge-danger' : 'badge-success'"
          >
            {{ licenciaData.bloqueada ? 'BLOQUEADA' : 'ACTIVA' }}
          </span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos Generales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número Licencia:</td>
                <td><strong>{{ licenciaData.numerolicencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ licenciaData.folio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge-purple">{{ licenciaData.tipo || 'N/A' }}</span>
                </td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ licenciaData.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ licenciaData.domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Expedición:</td>
                <td>
                  <font-awesome-icon icon="calendar" />
                  {{ formatDate(licenciaData.fechaexpedicion) }}
                </td>
              </tr>
              <tr>
                <td class="label">Vigencia:</td>
                <td>{{ formatDate(licenciaData.vigencia) }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="dollar-sign" />
              Información de Adeudos
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Adeudo Total:</td>
                <td>
                  <strong class="text-danger" style="font-size: 1.2em;">
                    {{ formatCurrency(adeudoInfo?.total) }}
                  </strong>
                </td>
              </tr>
              <tr>
                <td class="label">Saldo Pendiente:</td>
                <td>{{ formatCurrency(saldoInfo?.saldo) }}</td>
              </tr>
              <tr>
                <td class="label">Recargos:</td>
                <td>{{ formatCurrency(adeudoInfo?.recargos) }}</td>
              </tr>
              <tr>
                <td class="label">Último Pago:</td>
                <td>{{ formatDate(saldoInfo?.ultimopago) }}</td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span
                    class="badge"
                    :class="adeudoInfo?.total > 0 ? 'badge-warning' : 'badge-success'"
                  >
                    <font-awesome-icon
                      :icon="adeudoInfo?.total > 0 ? 'exclamation-triangle' : 'check-circle'"
                    />
                    {{ adeudoInfo?.total > 0 ? 'Con Adeudo' : 'Al Corriente' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Botón de impresión -->
        <div class="button-group" style="margin-top: 20px;">
          <button
            class="btn-municipal-primary"
            @click="generatePreview"
            :disabled="loading || licenciaData.bloqueada"
          >
            <font-awesome-icon icon="eye" />
            Vista Previa
          </button>
          <button
            class="btn-municipal-success"
            @click="printLicencia"
            :disabled="loading || licenciaData.bloqueada"
          >
            <font-awesome-icon icon="print" />
            Imprimir Licencia
          </button>
        </div>
      </div>
    </div>

    <!-- Vista previa del documento -->
    <div class="municipal-card" v-if="showPreview && previewContent">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-pdf" />
          Vista Previa del Documento
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="preview-container">
          <div class="document-preview" v-html="previewContent"></div>
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

    <!-- Toast Notifications -->
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
      :componentName="'ImpLicenciaReglamentadaFrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'


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
const licenciaData = ref(null)
const adeudoInfo = ref(null)
const saldoInfo = ref(null)
const showPreview = ref(false)
const previewContent = ref('')
const loadingMessage = ref('Cargando...')

// Filtros
const filters = ref({
  numeroLicencia: '',
  folio: ''
})

// Métodos
const searchLicencia = async () => {
  if (!filters.value.numeroLicencia) {
    showToast('warning', 'Ingrese un número de licencia')
    return
  }

  setLoading(true)
  loadingMessage.value = 'Buscando licencia...'

  try {
    // GETLICENCIAREGLAMENTADA
    const response = await execute(
      'sp_get_licencia_reglamentada',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]
      showToast('success', 'Licencia encontrada')

      // Verificar si está bloqueada
      await checkLicenciaBloqueada()

      if (!licenciaData.value.bloqueada) {
        // Calcular adeudo
        await calcularAdeudo()
        // Obtener saldo
        await obtenerSaldo()
      }
    } else {
      licenciaData.value = null
      showToast('warning', 'No se encontró la licencia')
    }
  } catch (error) {
    handleApiError(error)
    licenciaData.value = null
  } finally {
    setLoading(false)
  }
}

const checkLicenciaBloqueada = async () => {
  try {
    // CHECKLICENCIABLOQUEADA
    const response = await execute(
      'sp_check_licencia_bloqueada',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaData.value.bloqueada = response.result[0].bloqueada || false
      if (licenciaData.value.bloqueada) {
        showToast('warning', 'Esta licencia se encuentra bloqueada')
      }
    }
  } catch (error) {
  }
}

const calcularAdeudo = async () => {
  try {
    // CALC_ADEUDOLIC
    const response = await execute(
      'sp_calcular_adeudo_licencia',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      adeudoInfo.value = response.result[0]
    }
  } catch (error) {
  }
}

const obtenerSaldo = async () => {
  try {
    // DETSALDO_LICENCIA
    const response = await execute(
      'sp_detalle_saldo_licencia',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      saldoInfo.value = response.result[0]
    }
  } catch (error) {
  }
}

const generatePreview = () => {
  if (!licenciaData.value) return

  previewContent.value = `
    <div style="font-family: Arial, sans-serif; padding: 30px; background: white;">
      <div style="text-align: center; border-bottom: 3px solid #ea8215; padding-bottom: 20px; margin-bottom: 30px;">
        <h2 style="color: #ea8215; margin: 0;">LICENCIA REGLAMENTADA</h2>
        <p style="margin: 5px 0;">Gobierno Municipal de Guadalajara</p>
      </div>

      <div style="margin-bottom: 20px;">
        <p><strong>Número de Licencia:</strong> ${licenciaData.value.numerolicencia}</p>
        <p><strong>Folio:</strong> ${licenciaData.value.folio || 'N/A'}</p>
        <p><strong>Tipo:</strong> ${licenciaData.value.tipo || 'N/A'}</p>
        <p><strong>Fecha de Expedición:</strong> ${formatDate(licenciaData.value.fechaexpedicion)}</p>
        <p><strong>Vigencia:</strong> ${formatDate(licenciaData.value.vigencia)}</p>
      </div>

      <div style="margin-bottom: 20px;">
        <h4 style="color: #ea8215; border-bottom: 2px solid #ea8215; padding-bottom: 5px;">PROPIETARIO</h4>
        <p><strong>Nombre:</strong> ${licenciaData.value.propietario || 'N/A'}</p>
        <p><strong>Domicilio:</strong> ${licenciaData.value.domicilio || 'N/A'}</p>
      </div>

      <div style="margin-bottom: 20px;">
        <h4 style="color: #ea8215; border-bottom: 2px solid #ea8215; padding-bottom: 5px;">INFORMACIÓN DE ADEUDOS</h4>
        <p><strong>Adeudo Total:</strong> ${formatCurrency(adeudoInfo.value?.total)}</p>
        <p><strong>Recargos:</strong> ${formatCurrency(adeudoInfo.value?.recargos)}</p>
        <p><strong>Saldo Pendiente:</strong> ${formatCurrency(saldoInfo.value?.saldo)}</p>
      </div>

      <div style="margin-top: 50px; text-align: center;">
        <p style="font-size: 12px; color: #666;">
          Documento generado el ${new Date().toLocaleDateString('es-ES')}
        </p>
      </div>
    </div>
  `
  showPreview.value = true
  showToast('success', 'Vista previa generada')
}

const printLicencia = async () => {
  const result = await Swal.fire({
    title: '¿Imprimir licencia?',
    text: '¿Desea imprimir la licencia reglamentada?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    generatePreview()
    setTimeout(() => {
      window.print()
      showToast('success', 'Documento enviado a impresión')
    }, 500)
  }
}

const clearFilters = () => {
  filters.value = {
    numeroLicencia: '',
    folio: ''
  }
  licenciaData.value = null
  adeudoInfo.value = null
  saldoInfo.value = null
  showPreview.value = false
  previewContent.value = ''
}

// Utilidades
const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  } catch {
    return 'Fecha inválida'
  }
}
</script>

<style scoped>
.preview-container {
  border: 1px solid #dee2e6;
  border-radius: 5px;
  padding: 20px;
  background: #f8f9fa;
}

.document-preview {
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  min-height: 500px;
}

@media print {
  .module-view-header,
  .button-group,
  .toast-notification {
    display: none !important;
  }

  .document-preview {
    box-shadow: none;
  }
}
</style>
