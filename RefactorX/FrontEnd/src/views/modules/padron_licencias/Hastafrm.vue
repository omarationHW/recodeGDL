<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Formulario "Pagar Hasta"</h1>
        <p>Padrón de Licencias - Validación de Periodo de Pago (Bimestre y Año)</p></div>
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

    <!-- Información del Formulario -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Información
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="info-box">
          <font-awesome-icon icon="lightbulb" class="info-icon" />
          <div class="info-content">
            <h6>Acerca de este formulario</h6>
            <p>
              Este formulario permite validar y establecer el periodo de pago hasta el cual un contribuyente
              desea realizar su liquidación de adeudos. El sistema valida que el bimestre esté entre 1 y 6,
              y que el año sea válido (entre 1970 y el año actual).
            </p>
            <ul>
              <li><strong>Bimestre:</strong> Valor entre 1 y 6 (cada bimestre representa 2 meses del año)</li>
              <li><strong>Año:</strong> Año fiscal válido entre 1970 y {{ currentYear }}</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulario de Validación -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calendar-alt" />
          Configuración de Periodo
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="validateForm">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Bimestre: <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="formData.bimestre" required>
                <option value="">Seleccionar bimestre...</option>
                <option value="1">1er Bimestre (Enero - Febrero)</option>
                <option value="2">2do Bimestre (Marzo - Abril)</option>
                <option value="3">3er Bimestre (Mayo - Junio)</option>
                <option value="4">4to Bimestre (Julio - Agosto)</option>
                <option value="5">5to Bimestre (Septiembre - Octubre)</option>
                <option value="6">6to Bimestre (Noviembre - Diciembre)</option>
              </select>
              <small class="form-text">
                Seleccione el bimestre hasta el cual desea pagar
              </small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año: <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.anio"
                :min="1970"
                :max="currentYear"
                placeholder="Ej: 2025"
                required
              >
              <small class="form-text">
                Ingrese el año fiscal ({{ 1970 }} - {{ currentYear }})
              </small>
            </div>
          </div>

          <div class="button-group">
            <button
              type="submit"
              class="btn-municipal-primary"
              :disabled="loading || !formData.bimestre || !formData.anio"
            >
              <font-awesome-icon icon="check-circle" />
              Validar Periodo
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="clearForm"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
            <button
              type="button"
              class="btn-municipal-info"
              @click="setCurrentPeriod"
              :disabled="loading"
            >
              <font-awesome-icon icon="calendar-day" />
              Usar Periodo Actual
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Resultado de Validación -->
    <div class="municipal-card" v-if="validationResult">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon :icon="validationResult.success ? 'check-circle' : 'exclamation-triangle'" />
          Resultado de Validación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="validation-result" :class="validationResult.success ? 'success' : 'error'">
          <div class="validation-icon">
            <font-awesome-icon
              :icon="validationResult.success ? 'check-circle' : 'times-circle'"
              size="3x"
            />
          </div>
          <div class="validation-content">
            <h4>{{ validationResult.success ? 'Validación Exitosa' : 'Error de Validación' }}</h4>
            <p>{{ validationResult.message }}</p>

            <div v-if="validationResult.success" class="validated-data">
              <h6>Periodo Validado:</h6>
              <div class="data-grid">
                <div class="data-item">
                  <label>Bimestre:</label>
                  <span class="badge-info">{{ getBimestreLabel(formData.bimestre) }}</span>
                </div>
                <div class="data-item">
                  <label>Año:</label>
                  <span class="badge-primary">{{ formData.anio }}</span>
                </div>
                <div class="data-item">
                  <label>Periodo Completo:</label>
                  <span class="badge-success">{{ getPeriodoCompleto() }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de Validaciones -->
    <div class="municipal-card" v-if="validationHistory.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Validaciones
          <span class="badge-purple">{{ validationHistory.length }} registros</span>
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="clearHistory"
          :disabled="loading"
        >
          <font-awesome-icon icon="trash" />
          Limpiar Historial
        </button>
      </div>

      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>#</th>
                <th>Bimestre</th>
                <th>Año</th>
                <th>Periodo</th>
                <th>Estado</th>
                <th>Mensaje</th>
                <th>Fecha/Hora</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in validationHistory" :key="index" class="clickable-row">
                <td>{{ validationHistory.length - index }}</td>
                <td><span class="badge-purple">{{ getBimestreLabel(item.bimestre) }}</span></td>
                <td><strong>{{ item.anio }}</strong></td>
                <td><code>{{ item.periodo }}</code></td>
                <td>
                  <span class="badge" :class="item.success ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="item.success ? 'check-circle' : 'times-circle'" />
                    {{ item.success ? 'Válido' : 'Inválido' }}
                  </span>
                </td>
                <td>{{ item.message }}</td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="clock" />
                    {{ formatDateTime(item.timestamp) }}
                  </small>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Validando periodo...</p>
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
      :componentName="'Hastafrm'"
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
const currentYear = new Date().getFullYear()

const formData = ref({
  bimestre: '',
  anio: null
})

const validationResult = ref(null)
const validationHistory = ref([])

// Computed
const bimestresMeses = {
  1: 'Enero - Febrero',
  2: 'Marzo - Abril',
  3: 'Mayo - Junio',
  4: 'Julio - Agosto',
  5: 'Septiembre - Octubre',
  6: 'Noviembre - Diciembre'
}

// Métodos
const validateForm = async () => {
  if (!formData.value.bimestre || !formData.value.anio) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Validando periodo...')

  try {
    const response = await execute(
      'sp_validate_hasta_form',
      'padron_licencias',
      [
        { nombre: 'p_bimestre', valor: parseInt(formData.value.bimestre), tipo: 'integer' },
        { nombre: 'p_anio', valor: parseInt(formData.value.anio), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]

      validationResult.value = {
        success: result.success,
        message: result.message
      }

      // Agregar al historial
      validationHistory.value.unshift({
        bimestre: formData.value.bimestre,
        anio: formData.value.anio,
        periodo: getPeriodoCompleto(),
        success: result.success,
        message: result.message,
        timestamp: new Date()
      })

      if (result.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Validación Exitosa',
          html: `
            <div style="text-align: left; padding: 0 20px;">
              <p style="margin-bottom: 10px;">${result.message}</p>
              <ul style="list-style: none; padding: 0;">
                <li style="margin: 5px 0;"><strong>Bimestre:</strong> ${getBimestreLabel(formData.value.bimestre)}</li>
                <li style="margin: 5px 0;"><strong>Año:</strong> ${formData.value.anio}</li>
                <li style="margin: 5px 0;"><strong>Periodo:</strong> ${getPeriodoCompleto()}</li>
              </ul>
            </div>
          `,
          confirmButtonColor: '#ea8215'
        })

        showToast('success', 'Periodo validado correctamente')
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error de Validación',
          text: result.message,
          confirmButtonColor: '#ea8215'
        })

        showToast('error', result.message)
      }
    } else {
      validationResult.value = {
        success: false,
        message: 'Error al validar el periodo'
      }
      showToast('error', 'Error al validar el periodo')
    }
  } catch (error) {
    handleApiError(error)
    validationResult.value = {
      success: false,
      message: 'Error de conexión al validar el periodo'
    }
  } finally {
    setLoading(false)
  }
}

const clearForm = () => {
  formData.value = {
    bimestre: '',
    anio: null
  }
  validationResult.value = null
  showToast('info', 'Formulario limpiado')
}

const setCurrentPeriod = () => {
  const now = new Date()
  const currentMonth = now.getMonth() + 1 // 1-12
  const currentBimestre = Math.ceil(currentMonth / 2) // 1-6

  formData.value = {
    bimestre: currentBimestre.toString(),
    anio: currentYear
  }

  showToast('info', `Periodo actual establecido: Bimestre ${currentBimestre}, Año ${currentYear}`)
}

const clearHistory = () => {
  validationHistory.value = []
  showToast('info', 'Historial limpiado')
}

// Utilidades
const getBimestreLabel = (bimestre) => {
  if (!bimestre) return 'N/A'
  const num = parseInt(bimestre)
  return `${num}° Bimestre (${bimestresMeses[num] || 'N/A'})`
}

const getPeriodoCompleto = () => {
  if (!formData.value.bimestre || !formData.value.anio) return 'N/A'
  const num = parseInt(formData.value.bimestre)
  return `${formData.value.anio}-B${num} (${bimestresMeses[num] || 'N/A'})`
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return 'N/A'
  try {
    const date = new Date(dateTime)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch {
    return 'Fecha inválida'
  }
}
</script>

