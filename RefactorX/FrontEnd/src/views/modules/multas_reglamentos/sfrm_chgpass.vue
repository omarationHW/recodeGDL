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
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'sfrm_chgpass'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Cambio de Password'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'sfrm_chgpass'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Cambio de Password'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_SFRM_CHGPASS'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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

  showLoading('Cambiando contraseña...', 'Por favor espere')
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
  } finally {
    hideLoading()
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

