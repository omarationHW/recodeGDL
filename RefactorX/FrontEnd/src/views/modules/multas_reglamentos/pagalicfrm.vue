<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="credit-card" />
      </div>
      <div class="module-view-info">
        <h1>Paga Licencias</h1>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Licencia</label>
              <input
                class="municipal-form-control"
                v-model="filters.licencia"
                @keyup.enter="pagar"
                placeholder="Ej: 100, 00150, LC-2024-001"
              />
              <div v-if="errorMessage" class="alert-error">
                <font-awesome-icon icon="exclamation-triangle" />
                {{ errorMessage }}
              </div>
              <div v-if="successMessage" class="alert-success">
                <font-awesome-icon icon="check-circle" />
                {{ successMessage }}
              </div>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="pagar">
              <font-awesome-icon icon="credit-card" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Procesando...' : 'Pagar' }}
            </button>
            <button class="btn-municipal-secondary" :disabled="loading" @click="limpiar">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando pago...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useApi } from '@/composables/useApi';

const { loading, execute } = useApi();
const BASE_DB = 'multas_reglamentos';
const OP = 'RECAUDADORA_PAGALICFRM';

const filters = ref({
  licencia: ''
});

const errorMessage = ref('');
const successMessage = ref('');

async function pagar() {
  // Validar que el campo no esté vacío
  const licencia = String(filters.value.licencia || '').trim();

  if (!licencia) {
    errorMessage.value = 'Por favor ingrese un número de licencia';
    setTimeout(() => {
      errorMessage.value = '';
    }, 3000);
    return;
  }

  // Limpiar mensajes previos
  errorMessage.value = '';
  successMessage.value = '';

  try {
    // Crear una promesa con timeout de 10 segundos
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('TIMEOUT')), 10000);
    });

    // Ejecutar la petición con timeout
    const executePromise = execute(OP, BASE_DB, [
      { name: 'licencia', type: 'C', value: licencia }
    ]);

    // Race entre la petición y el timeout
    const response = await Promise.race([executePromise, timeoutPromise]);

    // Si la operación fue exitosa
    successMessage.value = 'Pago procesado exitosamente';
    setTimeout(() => {
      successMessage.value = '';
    }, 3000);

    console.log('Respuesta del pago:', response);
  } catch (e) {
    console.error('Error al procesar el pago:', e);

    if (e.message === 'TIMEOUT') {
      errorMessage.value = 'La operación está tardando demasiado. Por favor contacte al administrador para optimizar la base de datos.';
    } else {
      errorMessage.value = 'Error al procesar el pago. Por favor intente nuevamente.';
    }

    setTimeout(() => {
      errorMessage.value = '';
    }, 8000);
  }
}

function limpiar() {
  filters.value = { licencia: '' };
  errorMessage.value = '';
  successMessage.value = '';
}
</script>

<style scoped>
.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 1rem;
}

.municipal-form-label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.municipal-form-control {
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  font-size: 1rem;
  transition: border-color 0.15s ease-in-out;
}

.municipal-form-control:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.alert-error {
  margin-top: 0.5rem;
  padding: 0.75rem;
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 0.25rem;
  color: #721c24;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  animation: slideDown 0.3s ease-out;
}

.alert-success {
  margin-top: 0.5rem;
  padding: 0.75rem;
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 0.25rem;
  color: #155724;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.button-group {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn-municipal-primary {
  padding: 0.5rem 1rem;
  border: 1px solid #007bff;
  border-radius: 0.25rem;
  background-color: #007bff;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-primary:hover:not(:disabled) {
  background-color: #0056b3;
  border-color: #0056b3;
}

.btn-municipal-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-municipal-secondary {
  padding: 0.5rem 1rem;
  border: 1px solid #6c757d;
  border-radius: 0.25rem;
  background-color: #6c757d;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #5a6268;
  border-color: #545b62;
}

.btn-municipal-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .button-group {
    flex-direction: column;
  }
}
</style>
