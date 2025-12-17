<template>
  <div class="acceso-page">
    <div class="acceso-form-container">
      <div class="acceso-header">
        <h2>Aseo Contratado</h2>
        <p class="subtitle">Sistema de Acceso</p>
      </div>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="usuario">Usuario</label>
          <input v-model="form.usuario" id="usuario" type="text" autocomplete="username" required />
        </div>
        <div class="form-group">
          <label for="contrasena">Contraseña</label>
          <input v-model="form.contrasena" id="contrasena" type="password" autocomplete="current-password" required />
        </div>
        <div class="form-group">
          <label for="ejercicio">Ejercicio</label>
          <input v-model.number="form.ejercicio" id="ejercicio" type="number" :min="minEjercicio" :max="maxEjercicio" required />
        </div>
        <div v-if="error" class="error-message">{{ error }}</div>
        <div v-if="loading" class="loading-message">Conectando al sistema...</div>
        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="loading">
            <span v-if="loading">Validando...</span>
            <span v-else>Iniciar sesión</span>
          </button>
        </div>
      </form>

      <div class="back-to-dashboard">
        <router-link to="/" class="back-link">
          <font-awesome-icon icon="arrow-left" />
          Volver al Dashboard
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import sessionService from '@/services/sessionService';

export default {
  name: 'AccesoAseoContratado',
  data() {
    return {
      form: {
        usuario: '',
        contrasena: '',
        ejercicio: new Date().getFullYear()
      },
      minEjercicio: 2003,
      maxEjercicio: new Date().getFullYear(),
      loading: false,
      error: '',
      intentos: 0
    };
  },
  mounted() {
    // Cargar rango de ejercicios desde el SP
    this.fetchEjercicioMinMax();

    // Cargar último usuario desde sessionService
    const lastUser = sessionService.getUltimoUsuario();
    if (lastUser) {
      this.form.usuario = lastUser;
    }
  },
  methods: {
    async fetchEjercicioMinMax() {
      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_acceso_ejercicio_minmax',
            Base: 'aseo_contratado',
            Parametros: []
          }
        });

        if (response.data.eResponse && response.data.eResponse.success) {
          const result = response.data.eResponse.data.result;
          if (result && result.length > 0) {
            this.minEjercicio = result[0].min_ejercicio || 2003;
            this.maxEjercicio = result[0].max_ejercicio || new Date().getFullYear();

            // Ajustar ejercicio si está fuera del rango
            if (this.form.ejercicio < this.minEjercicio) {
              this.form.ejercicio = this.minEjercicio;
            }
            if (this.form.ejercicio > this.maxEjercicio) {
              this.form.ejercicio = this.maxEjercicio;
            }
          }
        }
      } catch (error) {
        console.error('Error al cargar ejercicios:', error);
        // Usar valores por defecto si falla
        this.minEjercicio = 2003;
        this.maxEjercicio = new Date().getFullYear();
      }
    },
    async onSubmit() {
      if (this.loading) return;

      this.error = '';
      this.loading = true;
      this.intentos++;

      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_login_aseo_contratado',
            Base: 'aseo_contratado',
            Parametros: [
              { nombre: 'p_usuario', tipo: 'text', valor: this.form.usuario },
              { nombre: 'p_contrasena', tipo: 'text', valor: this.form.contrasena },
              { nombre: 'p_ejercicio', tipo: 'integer', valor: this.form.ejercicio }
            ]
          }
        });

        if (response.data?.eResponse?.success) {
          const result = response.data.eResponse.data?.result?.[0];
          if (result && result.exito) {
            // Guardar sesión
            sessionService.saveSession({
              usuario: this.form.usuario,
              nivel: result.nivel || 1,
              ejercicio: this.form.ejercicio,
              sistema: 'aseo_contratado',
              nombre: result.nombre || this.form.usuario
            });

            // Navegar al módulo
            this.$router.push('/aseo-contratado');
          } else {
            this.error = result?.mensaje || 'Credenciales incorrectas. Por favor, intente nuevamente.';
          }
        } else {
          this.error = 'Error en la respuesta del servidor';
        }
      } catch (err) {
        console.error('Error en login:', err);
        this.error = 'Error de conexión. Por favor, intente más tarde.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* =================================================================================
   LOGIN ASEO CONTRATADO - TEMA MUNICIPAL GUADALAJARA
   Usando variables CSS del municipal-theme.css
   ================================================================================= */

.acceso-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--gradient-guadalajara);
  padding: var(--space-lg);
}

.acceso-form-container {
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

.acceso-header {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.acceso-form-container h2 {
  color: var(--municipal-primary);
  font-size: 1.5rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  margin: 0 0 var(--space-sm) 0;
}

.subtitle {
  color: var(--slate-600);
  font-size: 0.95rem;
  font-family: var(--font-municipal);
  margin: 0;
}

.form-group {
  margin-bottom: var(--space-lg);
}

.form-group label {
  display: block;
  color: var(--slate-700);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--space-sm);
  font-family: var(--font-municipal);
}

.form-group input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--slate-300);
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
  color: var(--slate-700);
}

.form-group input:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
}

.form-group input:disabled {
  background-color: var(--slate-100);
  cursor: not-allowed;
  color: var(--slate-500);
}

.form-actions {
  display: flex;
  justify-content: center;
  margin-top: var(--space-xl);
}

.btn-primary {
  width: 100%;
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

.error-message {
  background-color: rgba(220, 53, 69, 0.1);
  color: var(--municipal-danger);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--municipal-danger);
  margin-bottom: var(--space-md);
  text-align: center;
  font-weight: var(--font-weight-regular);
  animation: shake 0.5s ease-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
}

.loading-message {
  color: var(--municipal-primary);
  padding: 12px 16px;
  margin-bottom: var(--space-md);
  text-align: center;
  font-weight: var(--font-weight-regular);
}

.back-to-dashboard {
  margin-top: var(--space-lg);
  text-align: center;
  padding-top: var(--space-lg);
  border-top: 1px solid var(--slate-200);
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
  .acceso-form-container {
    padding: var(--space-2xl) var(--space-lg);
    max-width: 100%;
  }

  .acceso-form-container h2 {
    font-size: 1.3rem;
  }
}
</style>
