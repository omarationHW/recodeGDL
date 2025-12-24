<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
          <div class="header-divider"></div>
          <h1>Sistema Municipal</h1>
          <p>Guadalajara, Jalisco</p>
        </div>

        <form v-if="!authenticated" @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label for="usuario">
              <font-awesome-icon icon="user" />
              <span>Usuario</span>
            </label>
            <div class="input-wrapper">
              <input
                v-model="form.usuario"
                id="usuario"
                type="text"
                placeholder="Ingrese su usuario"
                autocomplete="username"
                required
                :disabled="loading"
              />
            </div>
          </div>

          <div class="form-group">
            <label for="password">
              <font-awesome-icon icon="lock" />
              <span>Contrasena</span>
            </label>
            <div class="input-wrapper">
              <input
                v-model="form.password"
                id="password"
                type="password"
                placeholder="Ingrese su contrasena"
                autocomplete="current-password"
                required
                :disabled="loading"
              />
            </div>
          </div>

          <div v-if="error" class="error-box">
            <font-awesome-icon icon="exclamation-circle" />
            <span>{{ error }}</span>
          </div>

          <button type="submit" class="btn-login" :disabled="loading">
            <font-awesome-icon v-if="loading" icon="spinner" spin />
            <font-awesome-icon v-else icon="sign-in-alt" />
            <span>{{ loading ? 'Validando...' : 'Iniciar Sesion' }}</span>
          </button>

          <router-link to="/" class="back-link">
            <font-awesome-icon icon="arrow-left" />
            <span>Volver al inicio</span>
          </router-link>
        </form>

        <div v-else class="sistema-selection">
          <div class="welcome-box">
            <div class="welcome-avatar">
              <font-awesome-icon icon="user" />
            </div>
            <h2>Bienvenido</h2>
            <p class="user-name">{{ userData.nombre }}</p>
            <p class="user-hint">Seleccione el sistema al que desea acceder</p>
          </div>

          <div v-if="loadingSistemas" class="loading-box">
            <font-awesome-icon icon="spinner" spin size="2x" />
            <p>Cargando sistemas...</p>
          </div>

          <div v-else-if="sistemas.length === 0" class="empty-box">
            <font-awesome-icon icon="exclamation-triangle" size="2x" />
            <p>No tiene sistemas disponibles</p>
            <button @click="handleLogout" class="btn-back">Volver</button>
          </div>

          <div v-else class="sistemas-grid">
            <div
              v-for="sistema in sistemas"
              :key="sistema.id_sistema"
              class="sistema-card"
              @click="handleSistemaSelect(sistema)"
            >
              <div class="sistema-icon">
                <font-awesome-icon :icon="sistema.icono" />
              </div>
              <div class="sistema-info">
                <h3>{{ sistema.nombre_sistema }}</h3>
                <p>{{ sistema.descripcion }}</p>
              </div>
              <div class="sistema-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </div>
          </div>

          <button @click="handleLogout" class="btn-logout">
            <font-awesome-icon icon="sign-out-alt" />
            <span>Cambiar Usuario</span>
          </button>
        </div>
      </div>
    </div>
    <footer class="login-footer">
      <p>&copy; 2025 Ayuntamiento de Guadalajara</p>
    </footer>
  </div>
</template>

<script>
import axios from 'axios';
import sessionService from '@/services/sessionService';

export default {
  name: 'LoginView',
  data() {
    return {
      form: { usuario: '', password: '' },
      authenticated: false,
      userData: null,
      sistemas: [],
      loading: false,
      loadingSistemas: false,
      error: '',
      intentos: 0
    };
  },
  mounted() {
    sessionService.clearSession();
    const lastUser = localStorage.getItem('ultimo_usuario');
    if (lastUser) this.form.usuario = lastUser;
  },
  methods: {
    async handleLogin() {
      this.error = '';
      this.loading = true;
      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_validar_usuario',
            Base: 'cementerios',
            Parametros: [
              { nombre: 'p_usuario', valor: this.form.usuario, tipo: 'string' },
              { nombre: 'p_password', valor: this.form.password, tipo: 'string' }
            ]
          }
        });
        const data = response.data.eResponse;
        if (data.success && data.data && data.data.result && data.data.result.length > 0) {
          const userData = data.data.result[0];
          if (userData.success === true || userData.success === "t") {
            this.authenticated = true;
            this.userData = {
              id_usuario: userData.id_usuario || 1,
              nombre: userData.nombre || this.form.usuario,
              usuario: this.form.usuario
            };
            localStorage.setItem('ultimo_usuario', this.form.usuario);
            await this.loadSistemas();
          } else {
            this.handleLoginError(userData.message || 'Usuario o contrasena incorrectos');
          }
        } else {
          this.handleLoginError(data.message || 'Error en la validacion');
        }
      } catch (error) {
        console.error('Error en login:', error);
        this.error = 'Error de conexion. Intente nuevamente.';
      } finally {
        this.loading = false;
      }
    },
    handleLoginError(message) {
      this.intentos++;
      if (this.intentos >= 3) {
        this.error = 'Demasiados intentos. Contacte al administrador.';
        setTimeout(() => { this.form = { usuario: '', password: '' }; this.intentos = 0; this.error = ''; }, 3000);
      } else {
        this.error = message;
      }
    },
    async loadSistemas() {
      this.loadingSistemas = true;
      this.sistemas = [
        { id_sistema: 'mercados', nombre_sistema: 'Mercados', descripcion: 'Mercados municipales', icono: 'store' },
        { id_sistema: 'cementerios', nombre_sistema: 'Cementerios', descripcion: 'Servicios funerarios', icono: 'cross' },
        { id_sistema: 'estacionamiento_publico', nombre_sistema: 'Est. Publico', descripcion: 'Parquimetros', icono: 'car' },
        { id_sistema: 'estacionamiento_exclusivo', nombre_sistema: 'Est. Exclusivo', descripcion: 'Zonas reservadas', icono: 'parking' },
        { id_sistema: 'aseo_contratado', nombre_sistema: 'Aseo Contratado', descripcion: 'Recoleccion', icono: 'broom' },
        { id_sistema: 'multas_reglamentos', nombre_sistema: 'Multas', descripcion: 'Infracciones', icono: 'gavel' },
        { id_sistema: 'otras_obligaciones', nombre_sistema: 'Otras Obligaciones', descripcion: 'Obligaciones fiscales', icono: 'file-alt' },
        { id_sistema: 'padron_licencias', nombre_sistema: 'Licencias', descripcion: 'Permisos comerciales', icono: 'id-card' }
      ];
      this.loadingSistemas = false;
      if (this.sistemas.length === 1) setTimeout(() => this.handleSistemaSelect(this.sistemas[0]), 500);
    },
    handleSistemaSelect(sistema) {
      sessionService.setSession({
        usuario: this.form.usuario,
        id_usuario: this.userData.id_usuario || 1,
        nombre: this.userData.nombre,
        sistema: sistema.id_sistema,
        nivel: 1
      });
      const rutas = {
        'mercados': '/mercados',
        'estacionamiento_publico': '/estacionamiento-publico',
        'aseo_contratado': '/aseo-contratado',
        'cementerios': '/cementerios',
        'padron_licencias': '/padron-licencias',
        'multas_reglamentos': '/multas-reglamentos',
        'otras_obligaciones': '/otras-obligaciones',
        'estacionamiento_exclusivo': '/estacionamiento-exclusivo'
      };
      this.$router.push(rutas[sistema.id_sistema] || '/');
    },
    handleLogout() {
      this.authenticated = false;
      this.userData = null;
      this.sistemas = [];
      this.form.password = '';
      this.error = '';
      this.intentos = 0;
      sessionService.clearSession();
    }
  }
};
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(145deg, #f1f5f9 0%, #e2e8f0 100%);
}

.login-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.login-card {
  background: white;
  border-radius: 1.25rem;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.04);
  padding: 2.5rem;
  width: 100%;
  max-width: 400px;
  animation: fadeIn 0.4s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

.login-header {
  text-align: center;
  margin-bottom: 1.75rem;
}

.header-logo {
  height: 50px;
  width: auto;
  margin-bottom: 0.75rem;
}

.header-divider {
  width: 40px;
  height: 3px;
  background: linear-gradient(90deg, #f59e0b, #ea8215);
  margin: 0 auto 0.75rem;
  border-radius: 2px;
}

.login-header h1 {
  color: #1e293b;
  font-size: 1.35rem;
  font-weight: 700;
  margin: 0 0 0.2rem 0;
}

.login-header p {
  color: #64748b;
  font-size: 0.85rem;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  color: #475569;
  font-weight: 600;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-group label svg { color: #f59e0b; font-size: 0.8rem; }

.input-wrapper { position: relative; }

.form-group input {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 0.625rem;
  font-size: 0.95rem;
  color: #1e293b;
  transition: all 0.2s ease;
  background: #f8fafc;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #f59e0b;
  background: white;
  box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
}

.form-group input::placeholder { color: #94a3b8; }
.form-group input:disabled { background: #f1f5f9; color: #94a3b8; }

.error-box {
  background: linear-gradient(135deg, #fef2f2, #fee2e2);
  color: #dc2626;
  padding: 0.75rem 1rem;
  border-radius: 0.625rem;
  border: 1px solid #fecaca;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
}

.btn-login {
  background: linear-gradient(135deg, #f59e0b, #ea8215);
  color: white;
  border: none;
  padding: 0.875rem 1.5rem;
  border-radius: 0.625rem;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(234, 130, 21, 0.25);
  margin-top: 0.5rem;
}

.btn-login:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(234, 130, 21, 0.35);
}

.btn-login:active:not(:disabled) { transform: translateY(0); }
.btn-login:disabled { opacity: 0.7; cursor: not-allowed; }

.back-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  color: #64748b;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 500;
  margin-top: 0.5rem;
  padding: 0.5rem;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
}

.back-link:hover { color: #f59e0b; }

.sistema-selection { animation: fadeIn 0.4s ease-out; }

.welcome-box {
  text-align: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
}

.welcome-avatar {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #22c55e, #16a34a);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 0.75rem;
  font-size: 1.25rem;
  color: white;
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

.welcome-box h2 {
  color: #64748b;
  font-size: 0.85rem;
  font-weight: 500;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.user-name {
  color: #1e293b;
  font-size: 1.25rem;
  font-weight: 700;
  margin: 0.25rem 0 0.5rem 0;
}

.user-hint {
  color: #94a3b8;
  font-size: 0.8rem;
  margin: 0;
}

.loading-box, .empty-box {
  text-align: center;
  padding: 2rem;
  color: #64748b;
}

.loading-box svg { color: #f59e0b; }
.empty-box svg { color: #f59e0b; margin-bottom: 0.5rem; }

.sistemas-grid {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
  max-height: 280px;
  overflow-y: auto;
}

.sistema-card {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.75rem;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 0.625rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sistema-card:hover {
  border-color: #f59e0b;
  background: #fffbf5;
}

.sistema-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #f59e0b, #ea8215);
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
  flex-shrink: 0;
}

.sistema-info { flex: 1; min-width: 0; }
.sistema-info h3 { color: #1e293b; font-size: 0.9rem; font-weight: 600; margin: 0; }
.sistema-info p { color: #64748b; font-size: 0.75rem; margin: 0; }

.sistema-arrow {
  color: #cbd5e1;
  font-size: 0.75rem;
  transition: all 0.2s ease;
}

.sistema-card:hover .sistema-arrow { color: #f59e0b; transform: translateX(2px); }

.btn-logout, .btn-back {
  width: 100%;
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
  padding: 0.75rem;
  border-radius: 0.625rem;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.2s ease;
}

.btn-logout:hover, .btn-back:hover { background: #e2e8f0; }

.login-footer {
  text-align: center;
  padding: 1rem;
  color: #94a3b8;
  font-size: 0.8rem;
  background: white;
  border-top: 1px solid #e2e8f0;
}

.login-footer p { margin: 0; }

@media (max-width: 480px) {
  .login-card { padding: 2rem 1.5rem; }
  .header-logo { height: 40px; }
  .login-header h1 { font-size: 1.2rem; }
}
</style>
