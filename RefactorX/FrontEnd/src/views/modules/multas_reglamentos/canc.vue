<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Cancelación de Multas</h1>
        <p>canc.vue</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio (Número de Acta)</label>
              <input
                class="municipal-form-control"
                v-model.number="form.folio"
                type="number"
                placeholder="Ej: 12345"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año (Ejercicio)</label>
              <input
                class="municipal-form-control"
                v-model.number="form.ejercicio"
                type="number"
                placeholder="Ej: 2024"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-danger"
              :disabled="loading || !form.folio"
              @click="cancelar"
            >
              <font-awesome-icon icon="ban"/> Cancelar Multa
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="resultado">
        <div class="municipal-card-header">
          <h5>Resultado de la Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div :class="['alert', resultado.success ? 'alert-success' : 'alert-error']">
            <p><strong>{{ resultado.message }}</strong></p>
            <div v-if="resultado.success && resultado.data">
              <hr/>
              <p><strong>ID Multa:</strong> {{ resultado.data.id_multa }}</p>
              <p><strong>Folio:</strong> {{ resultado.data.num_acta }}</p>
              <p><strong>Ejercicio:</strong> {{ resultado.data.axo_acta }}</p>
              <p><strong>Contribuyente:</strong> {{ resultado.data.contribuyente }}</p>
              <p><strong>Total:</strong> ${{ resultado.data.total }}</p>
              <p><strong>Fecha de Cancelación:</strong> {{ resultado.data.fecha_cancelacion }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_CANCEL = 'RECAUDADORA_CANC'

const { loading, execute } = useApi()

const form = ref({
  folio: null,
  ejercicio: new Date().getFullYear()
})

const resultado = ref(null)

async function cancelar() {
  const params = [
    { nombre: 'p_folio', valor: Number(form.value.folio || 0), tipo: 'integer' },
    { nombre: 'p_ejercicio', valor: Number(form.value.ejercicio || 0), tipo: 'integer' }
  ]

  try {
    const data = await execute(OP_CANCEL, BASE_DB, params)

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
    } else {
      resultado.value = {
        success: false,
        message: 'No se recibió respuesta del servidor'
      }
    }
  } catch (e) {
    resultado.value = {
      success: false,
      message: e.message || 'Error al cancelar la multa'
    }
  }
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

.btn-municipal-danger {
  background-color: #dc3545;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

.btn-municipal-danger:hover:not(:disabled) {
  background-color: #c82333;
}

.btn-municipal-danger:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>

