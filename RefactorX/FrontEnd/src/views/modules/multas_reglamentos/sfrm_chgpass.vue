<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Cambio de Password</h1>
        <p>Actualización de contraseñas de usuario</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de cambio de password -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Información del Usuario</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Mensajes de éxito/error -->
          <div v-if="message.text" :class="['alert', message.type === 'success' ? 'alert-success' : 'alert-error']">
            <font-awesome-icon :icon="message.type === 'success' ? 'check-circle' : 'exclamation-circle'" />
            {{ message.text }}
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="form.usuario"
                placeholder="Nombre de usuario"
                @keyup.enter="cambiar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Password</label>
              <input
                type="password"
                class="municipal-form-control"
                v-model="form.password"
                placeholder="Nueva contraseña"
                @keyup.enter="cambiar"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !isFormValid"
              @click="cambiar"
            >
              <font-awesome-icon icon="key" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Cambiando...' : 'Cambiar Password' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
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
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_SFRM_CHGPASS'

const { loading, execute } = useApi()

const form = ref({
  usuario: '',
  password: ''
})

const message = ref({
  text: '',
  type: '' // 'success' o 'error'
})

// Validación del formulario
const isFormValid = computed(() => {
  return form.value.usuario.trim() !== '' && form.value.password.trim() !== ''
})

async function cambiar() {
  // Limpiar mensaje anterior
  message.value = { text: '', type: '' }

  // IMPORTANTE: Usar formato español (nombre/tipo/valor)
  const params = [
    { nombre: 'p_usuario', tipo: 'string', valor: String(form.value.usuario || '') },
    { nombre: 'p_password', tipo: 'string', valor: String(form.value.password || '') }
  ]

  try {
    const response = await execute(OP, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta (el SP retorna: success, message, usuario)
    let result = null
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      result = response.eResponse.data.result[0]
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      result = response.data.result[0]
    } else if (response?.result && Array.isArray(response.result)) {
      result = response.result[0]
    } else if (Array.isArray(response)) {
      result = response[0]
    }

    console.log('Resultado extraído:', result)

    if (result) {
      if (result.success) {
        message.value = {
          text: result.message || 'Password actualizado exitosamente',
          type: 'success'
        }
        // Limpiar solo el password, mantener el usuario
        form.value.password = ''
      } else {
        message.value = {
          text: 'Error al actualizar el password',
          type: 'error'
        }
      }
    } else {
      message.value = {
        text: 'Error al actualizar el password',
        type: 'error'
      }
    }
  } catch (e) {
    console.error('Error al cambiar password:', e)
    message.value = {
      text: 'Error al actualizar el password',
      type: 'error'
    }
  }
}

function limpiar() {
  form.value = {
    usuario: '',
    password: ''
  }
  message.value = { text: '', type: '' }
}
</script>

<style scoped>
.form-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
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

.alert {
  padding: 1rem;
  margin-bottom: 1.5rem;
  border-radius: 0.25rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 500;
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

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }

  .button-group {
    flex-direction: column;
  }
}
</style>
