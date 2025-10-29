<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-cog"></i>
        Módulo General del Sistema
      </h1>
      <DocumentationModal
        title="Ayuda - Módulo General"
        :sections="helpSections"
      />
    </div>

    <!-- Validar Usuario -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-user-check"></i>
        Validar Usuario
      </div>
      <div class="card-body">
        <form @submit.prevent="validarUsuario">
          <div class="form-grid-two">
            <div class="form-group">
              <label class="form-label required">Usuario</label>
              <input
                v-model="formUsuario.usuario"
                type="text"
                class="form-control"
                placeholder="Nombre de usuario"
                required
              />
            </div>
            <div class="form-group">
              <label class="form-label required">Contraseña</label>
              <input
                v-model="formUsuario.clave"
                type="password"
                class="form-control"
                placeholder="Contraseña"
                required
              />
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn-municipal-primary">
              <i class="fas fa-check"></i>
              Validar
            </button>
          </div>
        </form>

        <div v-if="resultadoUsuario" class="mt-3">
          <div :class="resultadoUsuario.success ? 'alert-success' : 'alert-danger'">
            <i :class="resultadoUsuario.success ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
            {{ resultadoUsuario.mensaje }}
          </div>
        </div>
      </div>
    </div>

    <!-- Consultar Hora del Servidor -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-clock"></i>
        Hora del Servidor
      </div>
      <div class="card-body">
        <button @click="consultarHora" class="btn-municipal-secondary">
          <i class="fas fa-sync-alt"></i>
          Obtener Hora Actual
        </button>

        <div v-if="horaServidor" class="server-time-display">
          <i class="fas fa-server"></i>
          <div class="time-info">
            <span class="time-label">Hora del Servidor:</span>
            <span class="time-value">{{ horaServidor }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Verificar Versión del Sistema -->
    <div class="card">
      <div class="card-header">
        <i class="fas fa-code-branch"></i>
        Verificar Versión del Sistema
      </div>
      <div class="card-body">
        <form @submit.prevent="verificarVersion">
          <div class="form-grid-two">
            <div class="form-group">
              <label class="form-label required">Proyecto</label>
              <input
                v-model="formVersion.proyecto"
                type="text"
                class="form-control"
                placeholder="Nombre del proyecto"
                required
              />
            </div>
            <div class="form-group">
              <label class="form-label required">Versión Actual</label>
              <input
                v-model="formVersion.version"
                type="text"
                class="form-control"
                placeholder="Ej: 1.0.0"
                required
              />
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Verificar
            </button>
          </div>
        </form>

        <div v-if="resultadoVersion" class="mt-3">
          <div :class="resultadoVersion.hayNueva ? 'alert-warning' : 'alert-success'">
            <i :class="resultadoVersion.hayNueva ? 'fas fa-exclamation-triangle' : 'fas fa-check-circle'"></i>
            {{ resultadoVersion.mensaje }}
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Sistema -->
    <div class="card mt-3">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información del Sistema
      </div>
      <div class="card-body">
        <div class="system-info-grid">
          <div class="info-item">
            <span class="info-label">Módulo:</span>
            <span class="info-value">Cementerios</span>
          </div>
          <div class="info-item">
            <span class="info-label">Versión:</span>
            <span class="info-value">2.0.0</span>
          </div>
          <div class="info-item">
            <span class="info-label">Base de Datos:</span>
            <span class="info-value">Informix</span>
          </div>
          <div class="info-item">
            <span class="info-label">Framework:</span>
            <span class="info-value">Vue 3</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const formUsuario = reactive({
  usuario: '',
  clave: ''
})

const formVersion = reactive({
  proyecto: 'CEMENTERIOS',
  version: '2.0.0'
})

const resultadoUsuario = ref(null)
const horaServidor = ref('')
const resultadoVersion = ref(null)

const helpSections = [
  {
    title: 'Módulo General del Sistema',
    content: `
      <p>Funciones generales y utilitarias del sistema.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Validar Usuario:</strong> Verifica credenciales de usuario en el sistema</li>
        <li><strong>Hora del Servidor:</strong> Consulta la hora actual del servidor de base de datos</li>
        <li><strong>Verificar Versión:</strong> Comprueba si existe una nueva versión disponible</li>
      </ul>
    `
  }
]

const validarUsuario = async () => {
  if (!formUsuario.usuario || !formUsuario.clave) {
    toast.warning('Complete todos los campos')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_VALIDAR_USUARIO', {
      p_usuario: formUsuario.usuario,
      p_password: formUsuario.clave
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'S') {
        resultadoUsuario.value = {
          success: true,
          mensaje: `Usuario válido. ID: ${result.id_usuario} - ${result.nombre || formUsuario.usuario}`
        }
        toast.success('Usuario válido')
      } else {
        resultadoUsuario.value = {
          success: false,
          mensaje: result.mensaje || 'Usuario o contraseña incorrectos'
        }
        toast.error('Credenciales inválidas')
      }
    } else {
      resultadoUsuario.value = {
        success: false,
        mensaje: 'Usuario o contraseña incorrectos'
      }
    }
  } catch (error) {
    console.error('Error al validar usuario:', error)
    resultadoUsuario.value = {
      success: false,
      mensaje: 'Error de conexión con el servidor'
    }
    toast.error('Error al validar usuario')
  }
}

const consultarHora = async () => {
  try {
    const response = await api.callStoredProcedure('SP_OBTENER_HORA_SERVIDOR', {})

    if (response.data && response.data.length > 0) {
      const hora = response.data[0].hora_actual
      horaServidor.value = new Date(hora).toLocaleString('es-MX', {
        dateStyle: 'full',
        timeStyle: 'long'
      })
      toast.success('Hora del servidor obtenida')
    } else {
      // Fallback a hora local
      horaServidor.value = new Date().toLocaleString('es-MX', {
        dateStyle: 'full',
        timeStyle: 'long'
      })
    }
  } catch (error) {
    console.error('Error al obtener hora:', error)
    // Fallback a hora local
    horaServidor.value = new Date().toLocaleString('es-MX', {
      dateStyle: 'full',
      timeStyle: 'long'
    }) + ' (hora local)'
    toast.warning('Usando hora local del navegador')
  }
}

const verificarVersion = async () => {
  if (!formVersion.proyecto || !formVersion.version) {
    toast.warning('Complete todos los campos')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_VERIFICAR_VERSION', {
      p_proyecto: formVersion.proyecto,
      p_version_actual: formVersion.version
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      resultadoVersion.value = {
        hayNueva: result.hay_nueva_version === 1 || result.hay_nueva_version === true,
        mensaje: result.hay_nueva_version
          ? `Nueva versión disponible: ${result.version_nueva || 'N/A'}`
          : 'El sistema está actualizado'
      }
    } else {
      resultadoVersion.value = {
        hayNueva: false,
        mensaje: 'El sistema está actualizado'
      }
    }

    toast.info(resultadoVersion.value.mensaje)
  } catch (error) {
    console.error('Error al verificar versión:', error)
    resultadoVersion.value = {
      hayNueva: false,
      mensaje: 'No se pudo verificar la versión'
    }
    toast.error('Error al verificar versión')
  }
}
</script>

<style scoped>
.server-time-display {
  margin-top: 1.5rem;
  padding: 1.5rem;
  background: var(--color-bg-secondary);
  border-radius: 0.5rem;
  border-left: 4px solid var(--color-primary);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.server-time-display i {
  font-size: 2rem;
  color: var(--color-primary);
}

.time-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.time-label {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  font-weight: 500;
}

.time-value {
  font-size: 1.25rem;
  color: var(--color-primary);
  font-weight: 700;
}

.system-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 1rem;
  background: var(--color-bg-secondary);
  border-radius: 0.375rem;
}

.info-label {
  font-weight: 600;
  color: var(--color-text-secondary);
}

.info-value {
  font-weight: 700;
  color: var(--color-primary);
}

.alert-success,
.alert-danger,
.alert-warning {
  padding: 1rem;
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 500;
}

.alert-success {
  background-color: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.alert-danger {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.alert-warning {
  background-color: #fff3cd;
  color: #856404;
  border: 1px solid #ffeaa7;
}
</style>
