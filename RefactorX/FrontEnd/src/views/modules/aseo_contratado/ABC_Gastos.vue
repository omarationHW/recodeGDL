<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="receipt" />
      </div>
      <div class="module-view-info">
        <h1>Configuración de Gastos</h1>
        <p>Aseo Contratado - Porcentajes de Gastos para Cobranza</p>
      </div>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="loadGastos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de configuración -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Parámetros de Gastos de Cobranza
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="config-form">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="dollar-sign" />
                  Salario Mínimo (SDZMG): <span class="required">*</span>
                </label>
                <div class="input-group">
                  <span class="input-prefix">$</span>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.sdzmg"
                    step="0.01"
                    min="0.01"
                    placeholder="0.00"
                  />
                </div>
                <small class="form-hint">Salario Diario Zona Metropolitana de Guadalajara</small>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="percentage" />
                  % Requerimiento: <span class="required">*</span>
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.porc1_req"
                    step="0.01"
                    min="0"
                    max="100"
                    placeholder="0.00"
                  />
                  <span class="input-suffix">%</span>
                </div>
                <small class="form-hint">Porcentaje aplicado en requerimientos</small>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="percentage" />
                  % Embargo: <span class="required">*</span>
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.porc2_embargo"
                    step="0.01"
                    min="0"
                    max="100"
                    placeholder="0.00"
                  />
                  <span class="input-suffix">%</span>
                </div>
                <small class="form-hint">Porcentaje aplicado en embargos</small>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="percentage" />
                  % Secuestro: <span class="required">*</span>
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.porc3_secuestro"
                    step="0.01"
                    min="0"
                    max="100"
                    placeholder="0.00"
                  />
                  <span class="input-suffix">%</span>
                </div>
                <small class="form-hint">Porcentaje aplicado en secuestros</small>
              </div>
            </div>

            <div class="form-actions">
              <button
                class="btn-municipal-primary"
                @click="guardarConfiguracion"
                :disabled="guardando"
              >
                <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
                {{ guardando ? 'Guardando...' : 'Guardar Configuración' }}
              </button>
              <button
                class="btn-municipal-danger"
                @click="eliminarConfiguracion"
                :disabled="!tieneConfiguracion || guardando"
              >
                <font-awesome-icon icon="trash" />
                Eliminar Configuración
              </button>
            </div>
          </div>

          <!-- Resumen actual -->
          <div class="config-summary" v-if="tieneConfiguracion">
            <h6>
              <font-awesome-icon icon="info-circle" />
              Configuración Actual
            </h6>
            <div class="summary-grid">
              <div class="summary-item">
                <span class="summary-label">Salario Mínimo:</span>
                <span class="summary-value">${{ formatMonto(configActual.sdzmg) }}</span>
              </div>
              <div class="summary-item">
                <span class="summary-label">% Requerimiento:</span>
                <span class="summary-value">{{ configActual.porc1_req }}%</span>
              </div>
              <div class="summary-item">
                <span class="summary-label">% Embargo:</span>
                <span class="summary-value">{{ configActual.porc2_embargo }}%</span>
              </div>
              <div class="summary-item">
                <span class="summary-label">% Secuestro:</span>
                <span class="summary-value">{{ configActual.porc3_secuestro }}%</span>
              </div>
            </div>
          </div>

          <div class="config-empty" v-else>
            <font-awesome-icon icon="exclamation-triangle" size="2x" />
            <p>No hay configuración de gastos registrada</p>
            <small>Complete los campos y guarde para establecer la configuración</small>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Gastos'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Composables
const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado
const guardando = ref(false)
const configActual = ref({
  sdzmg: 0,
  porc1_req: 0,
  porc2_embargo: 0,
  porc3_secuestro: 0
})

// Formulario
const formData = ref({
  sdzmg: null,
  porc1_req: null,
  porc2_embargo: null,
  porc3_secuestro: null
})

// Computed
const tieneConfiguracion = computed(() => {
  return configActual.value.sdzmg > 0
})

// Métodos
async function loadGastos() {
  showLoading('Cargando configuración...', 'Obteniendo datos')
  try {
    const response = await execute('sp_gastos_list', BASE_DB, [], '', null, SCHEMA)

    if (response?.result && response.result.length > 0) {
      const config = response.result[0]
      configActual.value = {
        sdzmg: parseFloat(config.sdzmg) || 0,
        porc1_req: parseFloat(config.porc1_req) || 0,
        porc2_embargo: parseFloat(config.porc2_embargo) || 0,
        porc3_secuestro: parseFloat(config.porc3_secuestro) || 0
      }
      formData.value = { ...configActual.value }
    } else {
      configActual.value = {
        sdzmg: 0,
        porc1_req: 0,
        porc2_embargo: 0,
        porc3_secuestro: 0
      }
      formData.value = {
        sdzmg: null,
        porc1_req: null,
        porc2_embargo: null,
        porc3_secuestro: null
      }
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

async function guardarConfiguracion() {
  // Validaciones
  if (!formData.value.sdzmg || formData.value.sdzmg <= 0) {
    showToast('El Salario Mínimo debe ser mayor a cero', 'warning')
    return
  }
  if (formData.value.porc1_req === null || formData.value.porc1_req <= 0) {
    showToast('El porcentaje de Requerimiento debe ser mayor a cero', 'warning')
    return
  }
  if (formData.value.porc2_embargo === null || formData.value.porc2_embargo <= 0) {
    showToast('El porcentaje de Embargo debe ser mayor a cero', 'warning')
    return
  }
  if (formData.value.porc3_secuestro === null || formData.value.porc3_secuestro <= 0) {
    showToast('El porcentaje de Secuestro debe ser mayor a cero', 'warning')
    return
  }

  // SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Guardar Configuración',
    html: `
      <p>¿Desea guardar la siguiente configuración de gastos?</p>
      <table style="text-align: left; margin: 10px auto;">
        <tr><td><strong>Salario Mínimo:</strong></td><td>$${formatMonto(formData.value.sdzmg)}</td></tr>
        <tr><td><strong>% Requerimiento:</strong></td><td>${formData.value.porc1_req}%</td></tr>
        <tr><td><strong>% Embargo:</strong></td><td>${formData.value.porc2_embargo}%</td></tr>
        <tr><td><strong>% Secuestro:</strong></td><td>${formData.value.porc3_secuestro}%</td></tr>
      </table>
      <p class="text-warning"><small>Esta acción reemplazará la configuración existente</small></p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // Loading
  showLoading('Guardando configuración...', 'Procesando')
  guardando.value = true

  try {
    // Primero eliminar todo
    await execute('sp_gastos_delete_all', BASE_DB, [], '', null, SCHEMA)

    // Luego insertar el nuevo registro
    const params = [
      { nombre: 'p_sdzmg', valor: parseFloat(formData.value.sdzmg), tipo: 'numeric' },
      { nombre: 'p_porc1_req', valor: parseFloat(formData.value.porc1_req), tipo: 'numeric' },
      { nombre: 'p_porc2_embargo', valor: parseFloat(formData.value.porc2_embargo), tipo: 'numeric' },
      { nombre: 'p_porc3_secuestro', valor: parseFloat(formData.value.porc3_secuestro), tipo: 'numeric' }
    ]

    await execute('sp_gastos_insert', BASE_DB, params, '', null, SCHEMA)

    showToast('Configuración guardada correctamente', 'success')
    await loadGastos()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function eliminarConfiguracion() {
  // SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Eliminar Configuración',
    html: `
      <p>¿Está seguro de eliminar la configuración de gastos?</p>
      <p class="text-danger"><small>Esta acción no se puede deshacer</small></p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // Loading
  showLoading('Eliminando configuración...', 'Procesando')

  try {
    await execute('sp_gastos_delete_all', BASE_DB, [], '', null, SCHEMA)

    showToast('Configuración eliminada correctamente', 'success')
    await loadGastos()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Utilidades
function formatMonto(monto) {
  if (!monto) return '0.00'
  return parseFloat(monto).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

// Lifecycle
onMounted(() => {
  loadGastos()
})
</script>
