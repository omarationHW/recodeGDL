<template>
  <div class="chgpass-container">
    <div class="chgpass-card">
      <div class="chgpass-header">
        <font-awesome-icon icon="key" />
        <h2>Cambiar Contraseña</h2>
        <p>Actualización de clave de acceso al sistema</p>
      </div>

      <div class="chgpass-body">
        <!-- Paso 1: Contraseña Actual -->
        <div v-if="paso === 1" class="step-container">
          <div class="step-indicator">
            <span class="step-number">1</span>
            <span class="step-label">Verificar contraseña actual</span>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="lock" />
              Contraseña Actual
            </label>
            <input
              v-model="formulario.password_actual"
              type="password"
              class="municipal-form-control"
              placeholder="Ingrese su contraseña actual"
              maxlength="20"
              autocomplete="current-password"
              @keyup.enter="validarPasswordActual"
              autofocus
              required
            />
          </div>

          <button @click="validarPasswordActual" class="btn-municipal-primary btn-block">
            <font-awesome-icon icon="check" />
            Validar Contraseña
          </button>
        </div>

        <!-- Paso 2: Nueva Contraseña -->
        <div v-if="paso === 2" class="step-container">
          <div class="step-indicator">
            <span class="step-number">2</span>
            <span class="step-label">Ingresar nueva contraseña</span>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="key" />
              Nueva Contraseña
            </label>
            <input
              v-model="formulario.password_nueva"
              type="password"
              class="municipal-form-control"
              placeholder="Ingrese su nueva contraseña"
              maxlength="20"
              autocomplete="new-password"
              @keyup.enter="validarPasswordNueva"
              required
            />
          </div>

          <div class="password-requirements">
            <p class="requirements-title">
              <font-awesome-icon icon="info-circle" />
              Requisitos de la contraseña:
            </p>
            <ul>
              <li :class="{ valid: cumpleRequisito('minLength') }">
                <i :class="cumpleRequisito('minLength') ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
                Mínimo 6 caracteres
              </li>
              <li :class="{ valid: cumpleRequisito('hasNumber') }">
                <i :class="cumpleRequisito('hasNumber') ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
                Contiene números
              </li>
              <li :class="{ valid: cumpleRequisito('hasLetter') }">
                <i :class="cumpleRequisito('hasLetter') ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
                Contiene letras
              </li>
              <li :class="{ valid: cumpleRequisito('different') }">
                <i :class="cumpleRequisito('different') ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
                Diferente a la actual
              </li>
            </ul>
          </div>

          <button @click="validarPasswordNueva" class="btn-municipal-primary btn-block">
            <font-awesome-icon icon="arrow-right" />
            Continuar
          </button>
        </div>

        <!-- Paso 3: Confirmar Contraseña -->
        <div v-if="paso === 3" class="step-container">
          <div class="step-indicator">
            <span class="step-number">3</span>
            <span class="step-label">Confirmar nueva contraseña</span>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="check-double" />
              Confirmar Contraseña
            </label>
            <input
              v-model="formulario.password_confirmar"
              type="password"
              class="municipal-form-control"
              placeholder="Confirme su nueva contraseña"
              maxlength="20"
              autocomplete="new-password"
              @keyup.enter="cambiarPassword"
              required
            />
          </div>

          <div v-if="formulario.password_confirmar && !passwordsCoinciden" class="alert-danger mb-3">
            <font-awesome-icon icon="exclamation-triangle" />
            Las contraseñas no coinciden
          </div>

          <div v-if="passwordsCoinciden" class="alert-success mb-3">
            <font-awesome-icon icon="check-circle" />
            Las contraseñas coinciden
          </div>

          <button @click="cambiarPassword" class="btn-municipal-primary btn-block" :disabled="!passwordsCoinciden">
            <font-awesome-icon icon="save" />
            Cambiar Contraseña
          </button>
        </div>

        <!-- Mensajes de Retroalimentación -->
        <div v-if="mensaje" class="mt-3">
          <div :class="exito ? 'alert-success' : 'alert-danger'">
            <i :class="exito ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
            {{ mensaje }}
          </div>
        </div>

        <!-- Botón Cancelar -->
        <button @click="cancelar" class="btn-municipal-secondary btn-block mt-3">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
      </div>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'sfrm_chgpass'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const router = useRouter()

const paso = ref(1)
const mensaje = ref('')
const exito = ref(false)

const formulario = reactive({
  password_actual: '',
  password_nueva: '',
  password_confirmar: ''
})

const passwordsCoinciden = computed(() => {
  return formulario.password_nueva === formulario.password_confirmar &&
         formulario.password_confirmar.length > 0
})

const cumpleRequisito = (tipo) => {
  const nueva = formulario.password_nueva

  if (!nueva) return false

  switch (tipo) {
    case 'minLength':
      return nueva.length >= 6
    case 'hasNumber':
      return /[0-9]/.test(nueva)
    case 'hasLetter':
      return /[a-zA-Z]/.test(nueva)
    case 'different':
      return nueva !== formulario.password_actual && nueva.substring(0, 3) !== formulario.password_actual.substring(0, 3)
    default:
      return false
  }
}

const todosRequisitos = computed(() => {
  return cumpleRequisito('minLength') &&
         cumpleRequisito('hasNumber') &&
         cumpleRequisito('hasLetter') &&
         cumpleRequisito('different')
})

const validarPasswordActual = async () => {
  if (!formulario.password_actual || formulario.password_actual.length < 2) {
    toast.warning('Ingrese su contraseña actual')
    return
  }

  mensaje.value = ''

  try {
    const params = [
      {
        nombre: 'p_password',
        valor: formulario.password_actual,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_validar_password_actual', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    if (response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.resultado === 'S') {
        paso.value = 2
        toast.success('Contraseña actual verificada')
      } else {
        mensaje.value = 'La contraseña actual es incorrecta'
        exito.value = false
        toast.error('Contraseña incorrecta')
      }
    } else {
      mensaje.value = 'La contraseña actual es incorrecta'
      exito.value = false
    }
  } catch (error) {
    console.error('Error al validar contraseña:', error)
    mensaje.value = 'Error de conexión con el servidor'
    exito.value = false
    toast.error('Error al validar contraseña')
  }
}

const validarPasswordNueva = () => {
  if (!formulario.password_nueva) {
    toast.warning('Ingrese la nueva contraseña')
    return
  }

  mensaje.value = ''

  if (formulario.password_nueva.length < 6) {
    mensaje.value = 'La contraseña debe tener al menos 6 caracteres'
    exito.value = false
    return
  }

  if (!/[0-9]/.test(formulario.password_nueva)) {
    mensaje.value = 'La contraseña debe contener al menos un número'
    exito.value = false
    return
  }

  if (!/[a-zA-Z]/.test(formulario.password_nueva)) {
    mensaje.value = 'La contraseña debe contener al menos una letra'
    exito.value = false
    return
  }

  if (formulario.password_nueva === formulario.password_actual) {
    mensaje.value = 'La nueva contraseña no puede ser igual a la actual'
    exito.value = false
    return
  }

  if (formulario.password_nueva.substring(0, 3) === formulario.password_actual.substring(0, 3)) {
    mensaje.value = 'Los primeros 3 caracteres deben ser diferentes a la contraseña actual'
    exito.value = false
    return
  }

  paso.value = 3
  toast.success('Ahora confirme su nueva contraseña')
}

const cambiarPassword = async () => {
  if (!passwordsCoinciden.value) {
    toast.warning('Las contraseñas no coinciden')
    return
  }

  mensaje.value = ''

  try {
    const params = [
      {
        nombre: 'p_password_actual',
        valor: formulario.password_actual,
        tipo: 'string'
      },
      {
        nombre: 'p_password_nueva',
        valor: formulario.password_nueva,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cambiar_password', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    if (response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.resultado === 'S') {
        mensaje.value = 'Contraseña cambiada exitosamente'
        exito.value = true
        toast.success('Contraseña actualizada correctamente')

        setTimeout(() => {
          router.push({ path: '/' })
        }, 2000)
      } else {
        mensaje.value = result.mensaje || 'Error al cambiar la contraseña'
        exito.value = false
        toast.error('No se pudo cambiar la contraseña')
      }
    } else {
      mensaje.value = 'Error al cambiar la contraseña'
      exito.value = false
    }
  } catch (error) {
    console.error('Error al cambiar contraseña:', error)
    mensaje.value = 'Error de conexión con el servidor'
    exito.value = false
    toast.error('Error al cambiar contraseña')
  }
}

const cancelar = () => {
  formulario.password_actual = ''
  formulario.password_nueva = ''
  formulario.password_confirmar = ''
  paso.value = 1
  mensaje.value = ''
  router.push({ path: '/' })
}
</script>

<style scoped>
.chgpass-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
}

.chgpass-card {
  width: 100%;
  max-width: 500px;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.chgpass-header {
  background: linear-gradient(135deg, var(--color-primary) 0%, #2c5aa0 100%);
  color: white;
  padding: 2.5rem 2rem;
  text-align: center;
}

.chgpass-header i {
  font-size: 3.5rem;
  margin-bottom: 1rem;
  opacity: 0.9;
}

.chgpass-header h2 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.chgpass-header p {
  font-size: 0.95rem;
  opacity: 0.9;
  margin: 0;
}

.chgpass-body {
  padding: 2rem;
}

.step-container {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.step-indicator {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--color-border);
}

.step-number {
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  background: var(--color-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.25rem;
}

.step-label {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.form-label i {
  color: var(--color-primary);
}

.form-control {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid var(--color-border);
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-control:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(33, 87, 155, 0.1);
}

.password-requirements {
  background: var(--color-bg-secondary);
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
}

.requirements-title {
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.password-requirements ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.password-requirements li {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0;
  color: var(--color-text-secondary);
  font-size: 0.95rem;
}

.password-requirements li.valid {
  color: var(--color-success);
  font-weight: 600;
}

.password-requirements li i.fa-check-circle {
  color: var(--color-success);
}

.password-requirements li i.fa-times-circle {
  color: var(--color-text-secondary);
}

.alert-danger,
.alert-success {
  padding: 0.875rem 1rem;
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.95rem;
}

.alert-danger {
  background-color: #fee;
  color: var(--color-danger);
  border: 1px solid var(--color-danger);
}

.alert-success {
  background-color: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}
</style>
