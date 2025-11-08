<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Trámite de Baja de Anuncios</h1>
        <p>Padrón de Licencias - Gestión de bajas de anuncios publicitarios</p></div>
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

    <!-- Instrucciones -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Instrucciones
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="instructions-box">
          <ul>
            <li>Busque el anuncio por su número de registro</li>
            <li>Verifique la información completa del anuncio</li>
            <li>Ingrese el año, folio y motivo de la baja</li>
            <li>El sistema recalculará automáticamente los saldos</li>
            <li>Confirme la operación antes de tramitar</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Anuncio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="hashtag" />
              Número de Anuncio: <span class="required">*</span>
            </label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.numAnuncio"
              placeholder="Ingrese número de anuncio"
              @keyup.enter="buscarAnuncio"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarAnuncio"
            :disabled="loading || !searchForm.numAnuncio"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarBusqueda"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información del anuncio -->
    <div v-if="anuncio" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="clipboard-list" />
          Información del Anuncio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Datos Generales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número Anuncio:</td>
                <td><strong>{{ anuncio.numero_anuncio || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ anuncio.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Ubicación:</td>
                <td>{{ anuncio.ubicacion || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>{{ anuncio.tipo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getStatusBadge(anuncio.estado)">
                    {{ anuncio.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Formulario de baja -->
        <div class="form-section">
          <h6 class="section-title">
            <font-awesome-icon icon="file-alt" />
            Datos del Trámite de Baja
          </h6>
          <form @submit.prevent="tramitarBaja">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  Año: <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="bajaForm.anio"
                  placeholder="Año"
                  required
                  min="2000"
                  :max="currentYear"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  Folio: <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="bajaForm.folio"
                  placeholder="Folio del trámite"
                  required
                  min="1"
                >
              </div>
            </div>
            <div class="form-group full-width">
              <label class="municipal-form-label">
                Motivo de Baja: <span class="required">*</span>
              </label>
              <textarea
                class="municipal-form-control"
                v-model="bajaForm.motivo"
                placeholder="Describa el motivo de la baja"
                rows="3"
                required
                maxlength="500"
              ></textarea>
              <small class="form-text">
                {{ bajaForm.motivo.length }}/500 caracteres
              </small>
            </div>
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading || !canSubmit"
              >
                <font-awesome-icon icon="check" />
                Tramitar Baja
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar Formulario
              </button>
            </div>
          </form>
        </div>
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
      :componentName="'TramiteBajaAnun'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
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
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const searchForm = ref({
  numAnuncio: null
})

const anuncio = ref(null)

const bajaForm = ref({
  anio: new Date().getFullYear(),
  folio: null,
  motivo: ''
})

const currentYear = new Date().getFullYear()

// Computed
const canSubmit = computed(() => {
  return anuncio.value &&
         bajaForm.value.anio &&
         bajaForm.value.folio &&
         bajaForm.value.motivo.trim().length > 0
})

// Métodos
const buscarAnuncio = async () => {
  if (!searchForm.value.numAnuncio) {
    await Swal.fire({
      icon: 'warning',
      title: 'Número requerido',
      text: 'Por favor ingrese el número de anuncio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Buscando anuncio...', 'Consultando base de datos')
  setLoading(true, 'Buscando anuncio...')

  try {
    const response = await execute(
      'TramiteBajaAnun_sp_tramite_baja_anun_buscar',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchForm.value.numAnuncio, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      anuncio.value = response.result[0]
      showToast('success', 'Anuncio encontrado')
    } else {
      anuncio.value = null
      await Swal.fire({
        icon: 'info',
        title: 'No encontrado',
        text: 'No se encontró el anuncio con el número especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    anuncio.value = null
  } finally {
    hideLoading()
    setLoading(false)
  }
}

const tramitarBaja = async () => {
  // Validaciones
  if (!bajaForm.value.anio || !bajaForm.value.folio || !bajaForm.value.motivo.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    title: '¿Confirmar baja de anuncio?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se tramitará la baja del anuncio:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Número:</strong> ${anuncio.value.numero_anuncio}</li>
          <li style="margin: 5px 0;"><strong>Propietario:</strong> ${anuncio.value.propietario || 'N/A'}</li>
          <li style="margin: 5px 0;"><strong>Año:</strong> ${bajaForm.value.anio}</li>
          <li style="margin: 5px 0;"><strong>Folio:</strong> ${bajaForm.value.folio}</li>
          <li style="margin: 5px 0;"><strong>Motivo:</strong> ${bajaForm.value.motivo}</li>
        </ul>
        <p style="margin-top: 15px; color: #dc3545; font-size: 0.9em;">
          <strong>IMPORTANTE:</strong> Esta acción recalculará los saldos automáticamente
        </p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, tramitar baja',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) {
    return
  }

  showLoading('Tramitando baja...', 'Procesando baja de anuncio y recalculando saldos')
  setLoading(true, 'Tramitando baja de anuncio...')

  try {
    // Tramitar la baja (el SP ya recalcula saldos internamente)
    const tramiteResponse = await execute(
      'TramiteBajaAnun_sp_tramite_baja_anun_tramitar',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchForm.value.numAnuncio, tipo: 'integer' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' },
        { nombre: 'p_axo_baja', valor: bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio_baja', valor: bajaForm.value.folio, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    hideLoading()

    if (tramiteResponse && tramiteResponse.result && tramiteResponse.result[0]?.success) {
      // El SP ya recalculó los saldos internamente

      limpiarTodo()

      await Swal.fire({
        icon: 'success',
        title: '¡Baja tramitada!',
        text: 'La baja del anuncio ha sido procesada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', 'Baja de anuncio tramitada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al tramitar',
        text: tramiteResponse?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo tramitar la baja del anuncio',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
  }
}

const limpiarBusqueda = () => {
  searchForm.value.numAnuncio = null
  anuncio.value = null
  limpiarFormulario()
  showToast('info', 'Búsqueda limpiada')
}

const limpiarFormulario = () => {
  bajaForm.value = {
    anio: new Date().getFullYear(),
    folio: null,
    motivo: ''
  }
}

const limpiarTodo = () => {
  searchForm.value.numAnuncio = null
  anuncio.value = null
  limpiarFormulario()
}

const getStatusBadge = (estado) => {
  const estados = {
    'VIGENTE': 'badge-success',
    'SUSPENDIDO': 'badge-warning',
    'CANCELADO': 'badge-danger',
    'BAJA': 'badge-secondary'
  }
  return estados[estado?.toUpperCase()] || 'badge-info'
}

// Lifecycle
onMounted(() => {
  // Inicializar con año actual
  bajaForm.value.anio = currentYear
})
</script>

<style scoped>
.instructions-box {
  background: #fff3cd;
  border-left: 4px solid #ffc107;
  padding: 16px;
  border-radius: 4px;
}

.instructions-box ul {
  margin: 0;
  padding-left: 20px;
}

.instructions-box li {
  margin: 8px 0;
  color: #495057;
}

.details-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
  margin-bottom: 24px;
}

.detail-section {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.section-title {
  color: #495057;
  font-weight: 600;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 2px solid #dee2e6;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table tr {
  border-bottom: 1px solid #e9ecef;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 8px 0;
}

.detail-table td.label {
  font-weight: 500;
  color: #6c757d;
  width: 40%;
}

.form-section {
  background: #e7f3ff;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #b3d9ff;
  margin-top: 20px;
}

.required {
  color: #dc3545;
}

.full-width {
  grid-column: 1 / -1;
}

.form-text {
  display: block;
  margin-top: 4px;
  color: #6c757d;
  font-size: 0.875em;
}
</style>
