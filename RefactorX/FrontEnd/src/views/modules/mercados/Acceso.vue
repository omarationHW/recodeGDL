<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Acceso</h1>
        <p>Mercados - Módulo de Mercados</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="acceso-page">
          <div class="breadcrumb">
            <span>Inicio</span> &gt; <span>Acceso</span>
          </div>
          <div class="acceso-form-container">
            <h2>Acceso al Sistema</h2>
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
                <button type="submit" :disabled="loading">Aceptar</button>
                <button type="button" @click="onCancel" :disabled="loading">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Acceso'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'AccesoPage',
  data() {
    return {
      form: {
        usuario: '',
        contrasena: '',
        ejercicio: new Date().getFullYear(),
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      minEjercicio: 2003,
      maxEjercicio: new Date().getFullYear(),
      loading: false,
      error: '',
      intentos: 0
    };
  },
  mounted() {
    // Opcional: cargar min/max ejercicio desde API
    this.fetchEjercicioMinMax();
    // Opcional: cargar usuario recordado de localStorage
    const lastUser = localStorage.getItem('usuario');
    if (lastUser) this.form.usuario = lastUser;
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async fetchEjercicioMinMax() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.getEjercicioMinMax',
          payload: {}
        });
        if (res.data.status === 'success' && res.data.data) {
          this.minEjercicio = res.data.data.min_ejercicio;
          this.maxEjercicio = res.data.data.max_ejercicio;
          if (this.form.ejercicio < this.minEjercicio) this.form.ejercicio = this.minEjercicio;
          if (this.form.ejercicio > this.maxEjercicio) this.form.ejercicio = this.maxEjercicio;
        }
      } catch (error) {}
    },
    async onSubmit() {
      this.error = '';
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.login',
          payload: {
            usuario: this.form.usuario,
            contrasena: this.form.contrasena,
            ejercicio: this.form.ejercicio
          }
        });
        if (res.data.status === 'success') {
          localStorage.setItem('usuario', this.form.usuario);
          this.$router.push({ name: 'menu' });
        } else {
          this.intentos++;
          if (this.intentos >= 3) {
            this.error = 'No está autorizado para ingresar al sistema, verifique su acceso';
            setTimeout(() => window.location.reload(), 2000);
          } else {
            this.error = res.data.message || 'Usuario o contraseña incorrectos';
          }
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.form.usuario = '';
      this.form.contrasena = '';
      this.error = '';
      this.intentos = 0;
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
