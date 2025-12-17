<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h1 class="login-title">Sistema Municipal de Guadalajara</h1>
        <p class="login-subtitle">Acceso al Sistema</p>
      </div>

      <!-- Paso 1: Autenticación (Usuario y Contraseña) -->
      <form v-if="!authenticated" @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label for="usuario" class="form-label">
            <font-awesome-icon icon="user" class="input-icon" />
            Usuario
          </label>
          <input
            v-model="form.usuario"
            id="usuario"
            type="text"
            class="form-input"
            placeholder="Ingrese su usuario"
            autocomplete="username"
            required
            :disabled="loading"
          />
        </div>

        <div class="form-group">
          <label for="password" class="form-label">
            <font-awesome-icon icon="lock" class="input-icon" />
            Contraseña
          </label>
          <input
            v-model="form.password"
            id="password"
            type="password"
            class="form-input"
            placeholder="Ingrese su contraseña"
            autocomplete="current-password"
            required
            :disabled="loading"
          />
        </div>

        <div v-if="error" class="error-message">
          <font-awesome-icon icon="exclamation-circle" />
          {{ error }}
        </div>

        <button type="submit" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          <font-awesome-icon v-else icon="sign-in-alt" />
          {{ loading ? 'Validando...' : 'Continuar' }}
        </button>

        <div class="back-to-dashboard">
          <router-link to="/" class="back-link">
            <font-awesome-icon icon="arrow-left" />
            Volver al Dashboard
          </router-link>
        </div>
      </form>

      <!-- Paso 2: Selección de Sistema -->
      <div v-else class="sistema-selection">
        <div class="welcome-message">
          <font-awesome-icon icon="check-circle" class="success-icon" />
          <h2>Bienvenido, {{ userData.nombre }}</h2>
          <p>Seleccione el sistema al que desea acceder:</p>
        </div>

        <div v-if="loadingSistemas" class="loading-sistemas">
          <font-awesome-icon icon="spinner" spin size="2x" />
          <p>Cargando sistemas disponibles...</p>
        </div>

        <div v-else-if="sistemas.length === 0" class="no-sistemas">
          <font-awesome-icon icon="exclamation-triangle" size="2x" />
          <p>No tiene sistemas disponibles. Contacte al administrador.</p>
          <button @click="handleLogout" class="btn-secondary">
            <font-awesome-icon icon="arrow-left" />
            Volver
          </button>
        </div>

        <div v-else class="sistemas-grid">
          <div
            v-for="sistema in sistemas"
            :key="sistema.id_sistema"
            class="sistema-card"
            @click="handleSistemaSelect(sistema)"
          >
            <div class="sistema-icon">
              <font-awesome-icon :icon="sistema.icono" size="2x" />
            </div>
            <h3 class="sistema-nombre">{{ sistema.nombre_sistema }}</h3>
            <p class="sistema-descripcion">{{ sistema.descripcion }}</p>
          </div>
        </div>

        <button @click="handleLogout" class="btn-secondary btn-logout">
          <font-awesome-icon icon="arrow-left" />
          Cambiar Usuario
        </button>
      </div>
    </div>

    <div class="login-footer">
      <p>&copy; {{ currentYear }} Ayuntamiento de Guadalajara. Todos los derechos reservados.</p>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'LoginView',
  data() {
    return {
      form: {
        usuario: '',
        password: ''
      },
      authenticated: false,
      userData: null,
      sistemas: [],
      loading: false,
      loadingSistemas: false,
      error: '',
      intentos: 0,
      currentYear: new Date().getFullYear()
    };
  },
  mounted() {
    // Limpiar cualquier sesión previa
    this.clearSession();

    // Si hay usuario recordado, cargarlo
    const lastUser = localStorage.getItem('ultimo_usuario');
    if (lastUser) {
      this.form.usuario = lastUser;
    }
  },
  methods: {
    async handleLogin() {
      this.error = '';
      this.loading = true;

      try {
        // Llamar al stored procedure de login (pendiente de implementar en backend)
        const response = await axios.post('/api/execute', {
          eRequest: {
            action: 'mercados.login',
            params: {
              usuario: this.form.usuario,
              password: this.form.password
            }
          }
        });

        if (response.data.eResponse.success) {
          // Login exitoso
          this.authenticated = true;
          this.userData = response.data.eResponse.data;

          // Guardar usuario para la próxima vez
          localStorage.setItem('ultimo_usuario', this.form.usuario);

          // Cargar sistemas disponibles
          await this.loadSistemas();
        } else {
          // Login fallido
          this.intentos++;
          if (this.intentos >= 3) {
            this.error = 'Ha excedido el número de intentos permitidos. Contacte al administrador.';
            setTimeout(() => {
              this.form.usuario = '';
              this.form.password = '';
              this.intentos = 0;
              this.error = '';
            }, 3000);
          } else {
            this.error = response.data.eResponse.message || 'Usuario o contraseña incorrectos';
          }
        }
      } catch (error) {
        console.error('Error en login:', error);
        this.error = 'Error de conexión con el servidor. Intente nuevamente.';
      } finally {
        this.loading = false;
      }
    },

    async loadSistemas() {
      this.loadingSistemas = true;

      try {
        const response = await axios.post('/api/execute', {
          eRequest: {
            action: 'mercados.getSistemasUsuario',
            params: {
              usuario: this.form.usuario
            }
          }
        });

        if (response.data.eResponse.success) {
          this.sistemas = response.data.eResponse.data;

          // Si solo hay un sistema, seleccionarlo automáticamente
          if (this.sistemas.length === 1) {
            setTimeout(() => {
              this.handleSistemaSelect(this.sistemas[0]);
            }, 500);
          }
        } else {
          this.error = 'Error al cargar sistemas disponibles';
        }
      } catch (error) {
        console.error('Error cargando sistemas:', error);
        this.error = 'Error al cargar sistemas disponibles';
      } finally {
        this.loadingSistemas = false;
      }
    },

    handleSistemaSelect(sistema) {
      // Guardar sesión completa
      const sessionData = {
        usuario: this.form.usuario,
        nombre: this.userData.nombre,
        sistema: sistema.id_sistema,
        nombreSistema: sistema.nombre_sistema,
        timestamp: new Date().toISOString()
      };

      localStorage.setItem('session', JSON.stringify(sessionData));
      sessionStorage.setItem('sistema_activo', sistema.id_sistema);

      // Redirigir al módulo correspondiente
      const rutasSistemas = {
        'mercados': '/mercados',
        'estacionamiento_publico': '/estacionamiento-publico',
        'aseo_contratado': '/aseo-contratado',
        'cementerios': '/cementerios',
        'licencias': '/licencias',
        'multas_reglamentos': '/multas-reglamentos',
        'predial': '/predial',
        'distribucion': '/distribucion',
        'otras_obligaciones': '/otras-obligaciones'
      };

      const ruta = rutasSistemas[sistema.id_sistema] || '/';
      this.$router.push(ruta);
    },

    handleLogout() {
      this.authenticated = false;
      this.userData = null;
      this.sistemas = [];
      this.form.password = '';
      this.error = '';
      this.intentos = 0;
      this.clearSession();
    },

    clearSession() {
      sessionStorage.removeItem('sistema_activo');
      // No limpiamos localStorage.session para mantener el último usuario
    }
  }
};
</script>

<style scoped>
/* =================================================================================
   LOGIN - TEMA MUNICIPAL GUADALAJARA
   Usando variables CSS del municipal-theme.css
   ================================================================================= */

.login-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: var(--gradient-guadalajara);
  padding: var(--space-lg);
}

.login-card {
  background: white;
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  padding: var(--space-3xl);
  max-width: 450px;
  width: 100%;
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.login-title {
  color: var(--municipal-primary);
  font-size: 1.5rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  margin: 0 0 var(--space-sm) 0;
}

.login-subtitle {
  color: var(--slate-600);
  font-size: 1rem;
  font-weight: var(--font-weight-regular);
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-lg);
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-label {
  color: var(--slate-700);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--space-sm);
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.input-icon {
  color: var(--municipal-primary);
}

.form-input {
  padding: 12px 16px;
  border: 2px solid var(--slate-300);
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
  color: var(--slate-700);
}

.form-input:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
}

.form-input:disabled {
  background-color: var(--slate-100);
  cursor: not-allowed;
  color: var(--slate-500);
}

.error-message {
  background-color: rgba(220, 53, 69, 0.1);
  color: var(--municipal-danger);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--municipal-danger);
  display: flex;
  align-items: center;
  gap: var(--space-sm);
  animation: shake 0.5s ease-out;
  font-weight: var(--font-weight-regular);
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
}

.btn-primary {
  background: var(--gradient-municipal) !important;
  border: 2px solid var(--municipal-primary);
  color: white;
  padding: 14px 24px;
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  cursor: pointer;
  transition: var(--transition-normal);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
  margin-top: var(--space-md);
}

.btn-primary:hover:not(:disabled) {
  background: var(--municipal-secondary) !important;
  border-color: var(--municipal-secondary);
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.sistema-selection {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.welcome-message {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.success-icon {
  color: var(--municipal-success);
  font-size: 3rem;
  margin-bottom: var(--space-md);
}

.welcome-message h2 {
  color: var(--municipal-primary);
  font-size: 1.5rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  margin: var(--space-md) 0;
}

.welcome-message p {
  color: var(--slate-600);
  margin: var(--space-xs) 0 0 0;
}

.loading-sistemas,
.no-sistemas {
  text-align: center;
  padding: var(--space-3xl) var(--space-lg);
  color: var(--slate-600);
}

.loading-sistemas svg {
  color: var(--municipal-primary);
  margin-bottom: var(--space-lg);
}

.no-sistemas svg {
  color: var(--municipal-warning);
  margin-bottom: var(--space-lg);
}

.sistemas-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-lg);
  margin-bottom: var(--space-lg);
  max-height: 400px;
  overflow-y: auto;
  padding: var(--space-xs);
}

.sistema-card {
  background: linear-gradient(135deg, var(--slate-50) 0%, var(--slate-100) 100%);
  border: 2px solid var(--slate-200);
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  cursor: pointer;
  transition: var(--transition-normal);
  text-align: center;
}

.sistema-card:hover {
  transform: translateY(-5px);
  border-color: var(--municipal-primary);
  box-shadow: var(--shadow-lg);
  background: linear-gradient(135deg, white 0%, var(--slate-50) 100%);
}

.sistema-icon {
  color: var(--municipal-primary);
  margin-bottom: var(--space-lg);
}

.sistema-nombre {
  color: var(--municipal-primary);
  font-size: 1.1rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  margin: 0 0 var(--space-sm) 0;
}

.sistema-descripcion {
  color: var(--slate-600);
  font-size: 0.9rem;
  margin: 0;
  line-height: 1.4;
}

.btn-secondary {
  background: var(--slate-600);
  color: white;
  border: 2px solid var(--slate-600);
  padding: 12px 20px;
  border-radius: var(--radius-md);
  font-size: 0.95rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  cursor: pointer;
  transition: var(--transition-normal);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
  width: 100%;
}

.btn-secondary:hover {
  background: var(--slate-700);
  border-color: var(--slate-700);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn-logout {
  margin-top: var(--space-md);
}

.login-footer {
  margin-top: var(--space-2xl);
  text-align: center;
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
}

.login-footer p {
  margin: 0;
}

.back-to-dashboard {
  margin-top: var(--space-lg);
  text-align: center;
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs);
  color: var(--municipal-primary);
  font-size: 0.95rem;
  font-weight: var(--font-weight-regular);
  text-decoration: none;
  transition: var(--transition-normal);
}

.back-link:hover {
  color: var(--municipal-secondary);
  text-decoration: underline;
}

/* Responsive */
@media (max-width: 768px) {
  .login-card {
    padding: var(--space-2xl) var(--space-lg);
    max-width: 100%;
  }

  .login-title {
    font-size: 1.3rem;
  }

  .sistemas-grid {
    max-height: 350px;
  }
}
</style>
