<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-excel" />
      </div>
      <div class="module-view-info">
        <h1>Trámite de Baja de Licencias</h1>
        <p>Padrón de Licencias - Gestión de bajas de licencias comerciales</p></div>
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
            <li>Busque la licencia por su número de registro</li>
            <li>Verifique la información completa y adeudos de la licencia</li>
            <li>Ingrese el año, folio, motivo y tipo de baja</li>
            <li>El sistema calculará el proporcional de baja automáticamente</li>
            <li>Se recalcularán los adeudos después del trámite</li>
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
          Buscar Licencia
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="hashtag" />
              Número de Licencia: <span class="required">*</span>
            </label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.numLicencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="buscarLicencia"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarLicencia"
            :disabled="loading || !searchForm.numLicencia"
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

    <!-- Información de la licencia -->
    <div v-if="licencia" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="clipboard-list" />
          Información de la Licencia
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
                <td class="label">Número Licencia:</td>
                <td><strong>{{ licencia.numero_licencia || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ licencia.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>{{ licencia.giro || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Ubicación:</td>
                <td>{{ licencia.ubicacion || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getStatusBadge(licencia.estado)">
                    {{ licencia.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Otorgamiento:</td>
                <td>{{ formatDate(licencia.fecha_otorgamiento) }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section" v-if="adeudos">
            <h6 class="section-title">
              <font-awesome-icon icon="dollar-sign" />
              Adeudos
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Adeudo Total:</td>
                <td>
                  <strong class="text-danger">
                    ${{ formatCurrency(adeudos.total_adeudo) }}
                  </strong>
                </td>
              </tr>
              <tr>
                <td class="label">Adeudo Vigente:</td>
                <td>${{ formatCurrency(adeudos.adeudo_vigente) }}</td>
              </tr>
              <tr>
                <td class="label">Recargos:</td>
                <td>${{ formatCurrency(adeudos.recargos) }}</td>
              </tr>
              <tr>
                <td class="label">Estado de Pago:</td>
                <td>
                  <span class="badge" :class="adeudos.total_adeudo > 0 ? 'badge-danger' : 'badge-success'">
                    {{ adeudos.total_adeudo > 0 ? 'Con adeudo' : 'Al corriente' }}
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
              <div class="form-group">
                <label class="municipal-form-label">
                  Tipo de Baja: <span class="required">*</span>
                </label>
                <select class="municipal-form-control" v-model="bajaForm.tipoBaja" required>
                  <option value="">Seleccionar...</option>
                  <option value="DEFINITIVA">Definitiva</option>
                  <option value="TEMPORAL">Temporal</option>
                  <option value="VOLUNTARIA">Voluntaria</option>
                  <option value="ADMINISTRATIVA">Administrativa</option>
                </select>
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
      :componentName="'TramiteBajaLic'"
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
const { showLoading, hideLoading } = useGlobalLoading()
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

// Estado
const searchForm = ref({
  numLicencia: null
})

const licencia = ref(null)
const adeudos = ref(null)

const bajaForm = ref({
  anio: new Date().getFullYear(),
  folio: null,
  tipoBaja: '',
  motivo: ''
})

const currentYear = new Date().getFullYear()

// Computed
const canSubmit = computed(() => {
  return licencia.value &&
         bajaForm.value.anio &&
         bajaForm.value.folio &&
         bajaForm.value.tipoBaja &&
         bajaForm.value.motivo.trim().length > 0
})

// Métodos
const buscarLicencia = async () => {
  if (!searchForm.value.numLicencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Número requerido',
      text: 'Por favor ingrese el número de licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Buscando licencia...', 'Consultando base de datos')

  try {
    // Buscar información de la licencia
    const licenciaResponse = await execute(
      'TramiteBajaLic_sp_tramite_baja_lic_consulta',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: searchForm.value.numLicencia, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    if (licenciaResponse && licenciaResponse.result && licenciaResponse.result.length > 0) {
      licencia.value = licenciaResponse.result[0]

      // Buscar adeudos de la licencia
      const id_licencia = licencia.value.id_licencia
      const adeudosResponse = await execute(
        'TramiteBajaLic_spget_lic_adeudos',
        'padron_licencias',
        [
          { nombre: 'v_id', valor: id_licencia, tipo: 'integer' },
          { nombre: 'v_tipo', valor: 'L', tipo: 'string' }
        ],
        'guadalajara',
        null,
        'comun'
      )

      if (adeudosResponse && adeudosResponse.result && adeudosResponse.result.length > 0) {
        adeudos.value = adeudosResponse.result[0]
      }

      showToast('success', 'Licencia encontrada')
    } else {
      licencia.value = null
      adeudos.value = null
      await Swal.fire({
        icon: 'info',
        title: 'No encontrada',
        text: 'No se encontró la licencia con el número especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licencia.value = null
    adeudos.value = null
  } finally {
    hideLoading()
  }
}

const tramitarBaja = async () => {
  // Validaciones
  if (!bajaForm.value.anio || !bajaForm.value.folio || !bajaForm.value.tipoBaja || !bajaForm.value.motivo.trim()) {
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
    title: '¿Confirmar baja de licencia?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se tramitará la baja de la licencia:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Número:</strong> ${licencia.value.numero_licencia}</li>
          <li style="margin: 5px 0;"><strong>Propietario:</strong> ${licencia.value.propietario || 'N/A'}</li>
          <li style="margin: 5px 0;"><strong>Giro:</strong> ${licencia.value.giro || 'N/A'}</li>
          <li style="margin: 5px 0;"><strong>Año:</strong> ${bajaForm.value.anio}</li>
          <li style="margin: 5px 0;"><strong>Folio:</strong> ${bajaForm.value.folio}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${bajaForm.value.tipoBaja}</li>
          <li style="margin: 5px 0;"><strong>Motivo:</strong> ${bajaForm.value.motivo}</li>
        </ul>
        <p style="margin-top: 15px; color: #dc3545; font-size: 0.9em;">
          <strong>IMPORTANTE:</strong> Se calculará el proporcional y se recalcularán los adeudos
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

  showLoading('Tramitando baja...', 'Procesando baja de licencia y recalculando saldos')

  try {
    // Fecha de baja administrativa
    const fechaBaja = new Date()
    const fechaBajaStr = fechaBaja.toISOString().split('T')[0]

    // Paso 1: Tramitar la baja
    const tramiteResponse = await execute(
      'TramiteBajaLic_sp_tramite_baja_lic_tramitar',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: searchForm.value.numLicencia, tipo: 'integer' },
        { nombre: 'p_motivo', valor: `${bajaForm.value.tipoBaja} - ${bajaForm.value.motivo.trim()}`, tipo: 'string' },
        { nombre: 'p_baja_admva', valor: fechaBajaStr, tipo: 'date' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    if (tramiteResponse && tramiteResponse.result && tramiteResponse.result[0]?.success) {
      // Paso 2: Calcular proporcional de baja
      await execute(
        'TramiteBajaLic_sp_recalcula_proporcional_baja',
        'padron_licencias',
        [
          { nombre: 'p_licencia', valor: searchForm.value.numLicencia, tipo: 'integer' }
        ],
        'guadalajara',
        null,
        'comun'
      )

      // Paso 3: Recalcular adeudos (NO-OP)
      await execute(
        'TramiteBajaLic_sp_tramite_baja_lic_recalcula',
        'padron_licencias',
        [
          { nombre: 'p_licencia', valor: searchForm.value.numLicencia, tipo: 'integer' }
        ],
        'guadalajara',
        null,
        'comun'
      )

      limpiarTodo()

      await Swal.fire({
        icon: 'success',
        title: '¡Baja tramitada!',
        html: `
          <p>La baja de la licencia ha sido procesada exitosamente</p>
          <p style="margin-top: 10px;"><strong>Folio:</strong> ${tramiteResponse.result[0].folio}</p>
          <p><strong>Total:</strong> $${tramiteResponse.result[0].total}</p>
        `,
        confirmButtonColor: '#ea8215',
        timer: 4000
      })

      showToast('success', 'Baja de licencia tramitada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al tramitar',
        text: tramiteResponse?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo tramitar la baja de la licencia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    hideLoading()
  }
}

const limpiarBusqueda = () => {
  searchForm.value.numLicencia = null
  licencia.value = null
  adeudos.value = null
  limpiarFormulario()
  showToast('info', 'Búsqueda limpiada')
}

const limpiarFormulario = () => {
  bajaForm.value = {
    anio: new Date().getFullYear(),
    folio: null,
    tipoBaja: '',
    motivo: ''
  }
}

const limpiarTodo = () => {
  searchForm.value.numLicencia = null
  licencia.value = null
  adeudos.value = null
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

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Lifecycle
onMounted(() => {
  // Inicializar con año actual
  bajaForm.value.anio = currentYear
})
</script>
