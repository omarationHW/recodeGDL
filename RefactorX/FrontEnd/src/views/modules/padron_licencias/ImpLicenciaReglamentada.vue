<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="print" />
      </div>
      <div class="module-view-info">
        <h1>Impresión Licencia Reglamentada</h1>
        <p>Padrón de Licencias - Impresión de Licencias Reglamentadas</p></div>
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
          class="btn-municipal-primary"
          @click="printLicense"
          :disabled="loading || !licenseData"
        >
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
      </div>
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
            <label class="municipal-form-label">Número de Licencia: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="licenseNumber"
              @keyup.enter="searchLicense"
              placeholder="Ingrese el número de licencia"
              :disabled="loading"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Formato de Impresión:</label>
            <select class="municipal-form-control" v-model="printFormat">
              <option value="CARTA">Carta (Letter)</option>
              <option value="OFICIO">Oficio (Legal)</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicense"
            :disabled="loading || !licenseNumber"
          >
            <font-awesome-icon icon="search" />
            Buscar Licencia
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

    <!-- Vista previa de la licencia -->
    <div class="municipal-card" v-if="licenseData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="eye" />
          Vista Previa de la Licencia
        </h5>
        <div class="header-actions">
          <span class="badge-success" v-if="licenseData.activa">
            <font-awesome-icon icon="check-circle" />
            Licencia Activa
          </span>
          <span class="badge-danger" v-else>
            <font-awesome-icon icon="times-circle" />
            Licencia Inactiva
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <!-- Información de la licencia -->
        <div class="license-info-grid">
          <div class="info-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos de la Licencia
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número de Licencia:</td>
                <td><strong class="text-primary">{{ licenseData.numero_licencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>{{ licenseData.tipo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Expedición:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-info" />
                  {{ formatDate(licenseData.fecha_expedicion) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Vencimiento:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-warning" />
                  {{ formatDate(licenseData.fecha_vencimiento) }}
                </td>
              </tr>
              <tr>
                <td class="label">Vigencia:</td>
                <td>
                  <span class="badge" :class="getVigenciaBadgeClass(licenseData.fecha_vencimiento)">
                    {{ getVigenciaText(licenseData.fecha_vencimiento) }}
                  </span>
                </td>
              </tr>
            </table>
          </div>

          <div class="info-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Titular
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre/Razón Social:</td>
                <td><strong>{{ licenseData.titular_nombre || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ licenseData.titular_rfc || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ licenseData.titular_domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ licenseData.titular_telefono || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="info-section full-width">
            <h6 class="section-title">
              <font-awesome-icon icon="building" />
              Datos del Establecimiento
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre Comercial:</td>
                <td><strong>{{ licenseData.establecimiento_nombre || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>{{ licenseData.giro || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ licenseData.establecimiento_domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Superficie:</td>
                <td>{{ licenseData.superficie || 'N/A' }} m²</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Vista previa del documento -->
        <div class="print-preview" :class="`format-${printFormat.toLowerCase()}`">
          <div class="preview-header">
            <div class="preview-logo">
              <font-awesome-icon icon="building" size="3x" />
            </div>
            <div class="preview-title">
              <h3>Gobierno Municipal de Guadalajara</h3>
              <h4>Padrón de Licencias Municipales</h4>
              <h5>Licencia Reglamentada</h5>
            </div>
          </div>

          <div class="preview-body">
            <div class="license-number-banner">
              <strong>No. de Licencia:</strong>
              <span class="license-number">{{ licenseData.numero_licencia }}</span>
            </div>

            <div class="preview-section">
              <h6>TITULAR</h6>
              <p><strong>{{ licenseData.titular_nombre }}</strong></p>
              <p>RFC: {{ licenseData.titular_rfc }}</p>
              <p>{{ licenseData.titular_domicilio }}</p>
            </div>

            <div class="preview-section">
              <h6>ESTABLECIMIENTO</h6>
              <p><strong>{{ licenseData.establecimiento_nombre }}</strong></p>
              <p>Giro: {{ licenseData.giro }}</p>
              <p>{{ licenseData.establecimiento_domicilio }}</p>
              <p>Superficie: {{ licenseData.superficie }} m²</p>
            </div>

            <div class="preview-section">
              <h6>VIGENCIA</h6>
              <p>Expedición: {{ formatDate(licenseData.fecha_expedicion) }}</p>
              <p>Vencimiento: {{ formatDate(licenseData.fecha_vencimiento) }}</p>
            </div>
          </div>

          <div class="preview-footer">
            <div class="signature-line">
              <div class="signature-box">
                <div class="signature-name">_________________________________</div>
                <p>Firma del Titular</p>
              </div>
              <div class="signature-box">
                <div class="signature-name">_________________________________</div>
                <p>Autoridad Municipal</p>
              </div>
            </div>
            <p class="preview-note">
              <small>Este documento es válido únicamente con sello y firma de la autoridad competente.</small>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Estado vacío -->
    <div class="municipal-card" v-if="!licenseData && !loading">
      <div class="municipal-card-body">
        <div class="empty-state">
          <font-awesome-icon icon="search" size="3x" class="empty-icon" />
          <h4>Buscar Licencia para Imprimir</h4>
          <p>Ingrese el número de licencia en el campo superior y haga clic en "Buscar Licencia".</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando datos de la licencia...</p>
      </div>
    </div>

    <!-- Toast Notification -->
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
      :componentName="'ImpLicenciaReglamentada'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
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
const licenseNumber = ref('')
const licenseData = ref(null)
const printFormat = ref('CARTA')

// Métodos
const searchLicense = async () => {
  if (!licenseNumber.value || licenseNumber.value.trim() === '') {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el número de licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando licencia...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'implicenciareglamentada_sp_get_license_data',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: licenseNumber.value.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]) {
      licenseData.value = response.result[0]
      showToast('success', 'Licencia encontrada')
      toast.value.duration = durationText
    } else {
      licenseData.value = null
      await Swal.fire({
        icon: 'error',
        title: 'Licencia no encontrada',
        text: `No se encontró ninguna licencia con el número: ${licenseNumber.value}`,
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licenseData.value = null
  } finally {
    setLoading(false)
  }
}

const clearSearch = () => {
  licenseNumber.value = ''
  licenseData.value = null
}

const printLicense = async () => {
  if (!licenseData.value) {
    showToast('error', 'No hay licencia para imprimir')
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar impresión?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se imprimirá la licencia:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Número:</strong> ${licenseData.value.numero_licencia}</li>
          <li style="margin: 5px 0;"><strong>Titular:</strong> ${licenseData.value.titular_nombre}</li>
          <li style="margin: 5px 0;"><strong>Formato:</strong> ${printFormat.value}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  try {
    const usuario = localStorage.getItem('usuario') || 'sistema'
    const response = await execute(
      'implicenciareglamentada_sp_print_license',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: licenseData.value.numero_licencia, tipo: 'string' },
        { nombre: 'p_formato', valor: printFormat.value, tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Registro de impresión guardado')
      toast.value.duration = durationText

      setTimeout(() => {
        window.print()
      }, 500)
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al registrar impresión',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getVigenciaBadgeClass = (fechaVencimiento) => {
  if (!fechaVencimiento) return 'badge-secondary'

  const today = new Date()
  const vencimiento = new Date(fechaVencimiento)
  const diffTime = vencimiento - today
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays < 0) return 'badge-danger'
  if (diffDays <= 30) return 'badge-warning'
  return 'badge-success'
}

const getVigenciaText = (fechaVencimiento) => {
  if (!fechaVencimiento) return 'Sin fecha'

  const today = new Date()
  const vencimiento = new Date(fechaVencimiento)
  const diffTime = vencimiento - today
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays < 0) return 'Vencida'
  if (diffDays === 0) return 'Vence hoy'
  if (diffDays <= 30) return `Vence en ${diffDays} días`
  return 'Vigente'
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
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  // Inicialización si es necesaria
})

onBeforeUnmount(() => {
  licenseData.value = null
})
</script>

