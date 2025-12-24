<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" >
      <div class="module-view-icon">
        <font-awesome-icon icon="receipt" />
      </div>
      <div class="module-view-info">
        <h1>Impresión de Recibos</h1>
        <p>Padrón de Licencias - Impresión de Recibos de Pago de Licencias</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de licencia -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Búsqueda de Licencia para Recibo
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
            <label class="municipal-form-label">Folio de Pago</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.folioPago"
              placeholder="Folio del pago"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Recibo</label>
            <select class="municipal-form-control" v-model="filters.tipoRecibo">
              <option value="">Seleccionar...</option>
              <option value="PAGO_INICIAL">Pago Inicial</option>
              <option value="PAGO_ANUAL">Pago Anual</option>
              <option value="PAGO_RENOVACION">Renovación</option>
              <option value="PAGO_ADEUDO">Adeudo</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencia"
            :disabled="!filters.numeroLicencia"
          >
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
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
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos de la Licencia
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número Licencia:</td>
                <td><strong>{{ licenciaData.numerolicencia }}</strong></td>
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
                <td class="label">Giro:</td>
                <td>
                  <span class="badge-purple">{{ licenciaData.giro || 'N/A' }}</span>
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
              Información de Pago
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Monto a Pagar:</td>
                <td>
                  <strong class="text-success fs-5">
                    {{ formatCurrency(reciboData?.monto) }}
                  </strong>
                </td>
              </tr>
              <tr>
                <td class="label">Concepto:</td>
                <td>{{ reciboData?.concepto || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Periodo:</td>
                <td>{{ reciboData?.periodo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Límite:</td>
                <td>
                  <font-awesome-icon icon="calendar-alt" class="text-danger" />
                  {{ formatDate(reciboData?.fechalimite) }}
                </td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Monto en letra -->
        <div v-if="montoEnLetras" class="alert alert-info mt-3">
          <strong>Monto en letra:</strong> {{ montoEnLetras }}
        </div>

        <!-- Botones de acción -->
        <div class="button-group mt-3">
          <button
            class="btn-municipal-primary"
            @click="generateReciboPreview"
          >
            <font-awesome-icon icon="eye" />
            Vista Previa
          </button>
          <button
            class="btn-municipal-success"
            @click="printRecibo"
          >
            <font-awesome-icon icon="print" />
            Imprimir Recibo
          </button>
        </div>
      </div>
    </div>

    <!-- Vista previa del recibo -->
    <div class="municipal-card" v-if="showPreview && previewContent">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-invoice-dollar" />
          Vista Previa del Recibo
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="preview-container">
          <div class="recibo-preview" v-html="previewContent"></div>
        </div>
      </div>
    </div>

    <!-- Parámetros del sistema -->
    <div class="municipal-card" v-if="parametrosRecibo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="cog" />
          Parámetros de Configuración
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="param-grid">
          <div class="param-item">
            <label>Leyenda Recibo:</label>
            <p>{{ parametrosRecibo.leyenda || 'N/A' }}</p>
          </div>
          <div class="param-item">
            <label>Cuenta Bancaria:</label>
            <p>{{ parametrosRecibo.cuentabancaria || 'N/A' }}</p>
          </div>
          <div class="param-item">
            <label>Vigencia Recibo:</label>
            <p>{{ parametrosRecibo.vigenciarecibo || 'N/A' }} días</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ImpRecibofrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Impresión de Recibos'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const licenciaData = ref(null)
const reciboData = ref(null)
const parametrosRecibo = ref(null)
const showPreview = ref(false)
const previewContent = ref('')
const montoEnLetras = ref('')
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const filters = ref({
  numeroLicencia: '',
  folioPago: '',
  tipoRecibo: ''
})

// Métodos
const searchLicencia = async () => {
  if (!filters.value.numeroLicencia) {
    showToast('warning', 'Ingrese un número de licencia')
    return
  }

  showLoading('Buscando licencia...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null

  try {
    // SP_BUSCAR_LICENCIA
    const response = await execute(
      'sp_buscar_licencia',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]
      showToast('success', 'Licencia encontrada')

      // Obtener información del recibo
      await getReciboInfo()

      // Obtener parámetros del recibo
      await getParametrosRecibo()
    } else {
      licenciaData.value = null
      reciboData.value = null
      showToast('warning', 'No se encontró la licencia')
    }
  } catch (error) {
    handleApiError(error)
    licenciaData.value = null
    reciboData.value = null
  } finally {
    hideLoading()
  }
}

const getReciboInfo = async () => {
  try {
    // SP_GET_LICENCIA_RECIBO
    const response = await execute(
      'sp_get_licencia_recibo',
      'padron_licencias',
      [
        { nombre: 'p_numerolicencia', valor: filters.value.numeroLicencia, tipo: 'string' },
        { nombre: 'p_tiporecibo', valor: filters.value.tipoRecibo || 'NORMAL', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      reciboData.value = response.result[0]

      // Convertir monto a letras
      if (reciboData.value.monto) {
        await convertirMontoALetras(reciboData.value.monto)
      }
    }
  } catch (error) {
  }
}

const getParametrosRecibo = async () => {
  try {
    // SP_GET_PARAMETROS_RECIBO
    const response = await execute(
      'sp_get_parametros_recibo',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      parametrosRecibo.value = response.result[0]
    }
  } catch (error) {
  }
}

const convertirMontoALetras = async (monto) => {
  try {
    // SP_NUMERO_A_LETRAS
    const response = await execute(
      'sp_numero_a_letras',
      'padron_licencias',
      [
        { nombre: 'p_numero', valor: monto, tipo: 'decimal' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      montoEnLetras.value = response.result[0].letras || ''
    }
  } catch (error) {
    montoEnLetras.value = ''
  }
}

const generateReciboPreview = () => {
  if (!licenciaData.value || !reciboData.value) return

  const numeroRecibo = `REC-${licenciaData.value.numerolicencia}-${new Date().getFullYear()}`
  const fechaEmision = new Date().toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  previewContent.value = `
    <div style="font-family: Arial, sans-serif; padding: 30px; background: white; border: 2px solid #ea8215;">
      <!-- Encabezado del recibo -->
      <div style="text-align: center; border-bottom: 3px solid #ea8215; padding-bottom: 15px; margin-bottom: 20px;">
        <h2 style="color: #ea8215; margin: 0;">RECIBO DE PAGO</h2>
        <h3 style="margin: 5px 0;">GOBIERNO MUNICIPAL DE GUADALAJARA</h3>
        <p style="margin: 5px 0; font-size: 14px;">Padrón de Licencias y Reglamentos</p>
      </div>

      <!-- Información del recibo -->
      <div style="display: flex; justify-content: space-between; margin-bottom: 20px; padding: 10px; background: #f8f9fa;">
        <div>
          <p style="margin: 5px 0;"><strong>No. Recibo:</strong> ${numeroRecibo}</p>
          <p style="margin: 5px 0;"><strong>Fecha de Emisión:</strong> ${fechaEmision}</p>
        </div>
        <div style="text-align: right;">
          <p style="margin: 5px 0;"><strong>Folio Pago:</strong> ${filters.value.folioPago || 'POR ASIGNAR'}</p>
          <p style="margin: 5px 0;"><strong>Tipo:</strong> ${filters.value.tipoRecibo || 'NORMAL'}</p>
        </div>
      </div>

      <!-- Datos del contribuyente -->
      <div style="margin-bottom: 20px; padding: 15px; border: 1px solid #dee2e6;">
        <h4 style="color: #ea8215; margin-top: 0; border-bottom: 2px solid #ea8215; padding-bottom: 5px;">DATOS DEL CONTRIBUYENTE</h4>
        <table style="width: 100%; border-collapse: collapse;">
          <tr>
            <td style="padding: 5px; width: 30%;"><strong>Nombre/Razón Social:</strong></td>
            <td style="padding: 5px;">${licenciaData.value.propietario || 'N/A'}</td>
          </tr>
          <tr>
            <td style="padding: 5px;"><strong>No. Licencia:</strong></td>
            <td style="padding: 5px;">${licenciaData.value.numerolicencia}</td>
          </tr>
          <tr>
            <td style="padding: 5px;"><strong>Domicilio:</strong></td>
            <td style="padding: 5px;">${licenciaData.value.domicilio || 'N/A'}</td>
          </tr>
          <tr>
            <td style="padding: 5px;"><strong>Giro:</strong></td>
            <td style="padding: 5px;">${licenciaData.value.giro || 'N/A'}</td>
          </tr>
        </table>
      </div>

      <!-- Conceptos de pago -->
      <div style="margin-bottom: 20px;">
        <h4 style="color: #ea8215; margin-top: 0; border-bottom: 2px solid #ea8215; padding-bottom: 5px;">CONCEPTOS DE PAGO</h4>
        <table style="width: 100%; border-collapse: collapse; border: 1px solid #dee2e6;">
          <thead>
            <tr style="background: #f8f9fa;">
              <th style="padding: 10px; border: 1px solid #dee2e6; text-align: left;">Concepto</th>
              <th style="padding: 10px; border: 1px solid #dee2e6; text-align: left;">Periodo</th>
              <th style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 10px; border: 1px solid #dee2e6;">${reciboData.value.concepto || 'Pago de Licencia'}</td>
              <td style="padding: 10px; border: 1px solid #dee2e6;">${reciboData.value.periodo || 'Anual'}</td>
              <td style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">${formatCurrency(reciboData.value.monto)}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background: #f8f9fa;">
              <td colspan="2" style="padding: 10px; border: 1px solid #dee2e6; text-align: right;"><strong>TOTAL A PAGAR:</strong></td>
              <td style="padding: 10px; border: 1px solid #dee2e6; text-align: right;"><strong style="font-size: 1.2em; color: #ea8215;">${formatCurrency(reciboData.value.monto)}</strong></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Monto en letra -->
      <div style="margin-bottom: 20px; padding: 10px; background: #f8f9fa; border-left: 4px solid #ea8215;">
        <p style="margin: 0;"><strong>IMPORTE CON LETRA:</strong></p>
        <p style="margin: 5px 0 0 0; font-style: italic;">${montoEnLetras.value || 'N/A'}</p>
      </div>

      <!-- Información bancaria -->
      ${parametrosRecibo.value?.cuentabancaria ? `
      <div style="margin-bottom: 20px; padding: 10px; border: 1px solid #dee2e6;">
        <p style="margin: 5px 0;"><strong>DATOS BANCARIOS PARA PAGO:</strong></p>
        <p style="margin: 5px 0;">${parametrosRecibo.value.cuentabancaria}</p>
      </div>
      ` : ''}

      <!-- Leyenda -->
      <div style="margin-bottom: 20px; padding: 10px; background: #fff3cd; border: 1px solid #ffc107;">
        <p style="margin: 0; font-size: 12px;">
          <strong>NOTA IMPORTANTE:</strong> ${parametrosRecibo.value?.leyenda || 'Este recibo es válido únicamente con el sello de la caja correspondiente.'}
        </p>
        <p style="margin: 5px 0 0 0; font-size: 12px;">
          <strong>VIGENCIA:</strong> Este recibo tiene una vigencia de ${parametrosRecibo.value?.vigenciarecibo || '30'} días a partir de su emisión.
          Fecha límite de pago: ${formatDate(reciboData.value.fechalimite)}
        </p>
      </div>

      <!-- Línea de corte -->
      <div style="border-top: 2px dashed #999; margin: 20px 0; padding-top: 20px;">
        <p style="text-align: center; font-size: 11px; color: #666;">
          COPIA PARA EL CONTRIBUYENTE - Documento generado el ${new Date().toLocaleDateString('es-ES')} a las ${new Date().toLocaleTimeString('es-ES')}
        </p>
      </div>

      <!-- Código de barras simulado (para propósitos de diseño) -->
      <div style="text-align: center; margin-top: 20px;">
        <div style="display: inline-block; padding: 10px; border: 1px solid #000;">
          <svg width="200" height="60">
            <rect width="3" height="60" x="0" fill="#000"/>
            <rect width="2" height="60" x="5" fill="#000"/>
            <rect width="3" height="60" x="10" fill="#000"/>
            <rect width="2" height="60" x="15" fill="#000"/>
            <rect width="4" height="60" x="20" fill="#000"/>
            <rect width="2" height="60" x="26" fill="#000"/>
            <rect width="3" height="60" x="30" fill="#000"/>
            <rect width="2" height="60" x="35" fill="#000"/>
            <rect width="3" height="60" x="40" fill="#000"/>
            <rect width="4" height="60" x="45" fill="#000"/>
          </svg>
        </div>
        <p style="font-size: 10px; margin: 5px 0;">${numeroRecibo}</p>
      </div>
    </div>
  `
  showPreview.value = true
  showToast('success', 'Vista previa del recibo generada')
}

const printRecibo = async () => {
  const result = await Swal.fire({
    title: '¿Imprimir recibo?',
    text: '¿Desea imprimir el recibo de pago?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    generateReciboPreview()
    setTimeout(() => {
      window.print()
      showToast('success', 'Recibo enviado a impresión')
    }, 500)
  }
}

const clearFilters = () => {
  filters.value = {
    numeroLicencia: '',
    folioPago: '',
    tipoRecibo: ''
  }
  licenciaData.value = null
  reciboData.value = null
  parametrosRecibo.value = null
  showPreview.value = false
  previewContent.value = ''
  montoEnLetras.value = ''
  hasSearched.value = false
  selectedRow.value = null
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

.recibo-preview {
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  min-height: 600px;
}

.param-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.param-item {
  padding: 15px;
  background: #f8f9fa;
  border-radius: 5px;
  border-left: 4px solid #ea8215;
}

.param-item label {
  display: block;
  font-weight: 600;
  color: #495057;
  margin-bottom: 5px;
}

.param-item p {
  margin: 0;
  color: #6c757d;
}

.alert-info {
  padding: 15px;
  background: #d1ecf1;
  border: 1px solid #bee5eb;
  border-radius: 5px;
  color: #0c5460;
}

.mt-3 {
  margin-top: 20px;
}

.fs-5 {
  font-size: 1.2em;
}

@media print {
  .module-view-header,
  .button-group,
  .toast-notification,
  .municipal-card-header,
  .param-grid {
    display: none !important;
  }

  .recibo-preview {
    box-shadow: none;
  }

  .preview-container {
    border: none;
    padding: 0;
    background: white;
  }
}
</style>
