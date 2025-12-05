<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="keyboard" />
      </div>
      <div class="module-view-info">
        <h1>Captura de Diferencias Prediales</h1>
        <p>Registro de diferencias en formato JSON</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Datos de la Diferencia</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                Datos en formato JSON
                <small style="color: #666; display: block; margin-top: 4px;">
                  Campos requeridos: axo (año), cvecuenta, monto. Opcional: status (default: "A")
                </small>
              </label>
              <textarea
                class="municipal-form-control"
                rows="10"
                v-model="jsonPayload"
                placeholder='Ejemplo:
{
  "axo": 2024,
  "cvecuenta": 123456,
  "monto": 1500.50,
  "status": "A"
}'
                style="font-family: monospace;"
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" /> Guardar Diferencia
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="resultado">
        <div class="municipal-card-header">
          <h5>Resultado</h5>
        </div>
        <div class="municipal-card-body">
          <div :class="['alert', resultado.success ? 'alert-success' : 'alert-error']">
            <p><strong>{{ resultado.message }}</strong></p>
            <div v-if="resultado.success && resultado.data">
              <hr/>
              <p><strong>ID Generado:</strong> {{ resultado.data.id_insertado }}</p>
              <p><strong>Año:</strong> {{ resultado.data.axo }}</p>
              <p><strong>Cve Cuenta:</strong> {{ resultado.data.cvecuenta }}</p>
              <p><strong>Monto:</strong> ${{ resultado.data.monto }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_SAVE = 'RECAUDADORA_CAPTURA_DIF'

const { loading, execute } = useApi()

const jsonPayload = ref('')
const resultado = ref(null)

async function guardar() {
  const params = [
    { nombre: 'p_datos', valor: jsonPayload.value, tipo: 'string' }
  ]

  try {
    const data = await execute(OP_SAVE, BASE_DB, params)

    // El SP devuelve un array con un solo registro
    const row = Array.isArray(data?.result) && data.result.length > 0
      ? data.result[0]
      : null

    if (row) {
      resultado.value = {
        success: row.success,
        message: row.message,
        data: row.success ? row : null
      }

      // Si fue exitoso, limpiar el formulario
      if (row.success) {
        jsonPayload.value = ''
      }
    } else {
      resultado.value = {
        success: false,
        message: 'No se recibió respuesta del servidor'
      }
    }
  } catch (e) {
    resultado.value = {
      success: false,
      message: e.message || 'Error al guardar la diferencia'
    }
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
}
</script>

<style scoped>
.alert {
  padding: 1rem;
  border-radius: 4px;
  margin-top: 1rem;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-error {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.btn-municipal-secondary {
  background-color: #6c757d;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  margin-left: 0.5rem;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #5a6268;
}

.btn-municipal-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

small {
  font-weight: normal;
}
</style>

