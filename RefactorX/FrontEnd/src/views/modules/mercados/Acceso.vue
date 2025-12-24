<template>
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
          <label for="contrasena">Contrasena</label>
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
    <DocumentationModal
      :show="showDocModal"
      :componentName="'Acceso'"
      :moduleName="'mercados'"
      :docType="docType"
      :title="'Mercados'"
      @close="showDocModal = false"
    />
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'Acceso'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Acceso'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Acceso'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Acceso'" @close="showDocumentacion = false" />
</template>

<script>
import sessionService from '@/services/sessionService';
import apiService from '@/services/apiService';
import DocumentationModal from '@/components/common/DocumentationModal.vue';

export default {
  name: 'AccesoPage',
  components: {
    DocumentationModal
  },
  data() {
    return {
      showAyuda: false,
      showDocumentacion: false,
      form: {
        usuario: '',
        contrasena: '',
        ejercicio: new Date().getFullYear()
      },
      minEjercicio: 2003,
      maxEjercicio: new Date().getFullYear(),
      loading: false,
      error: '',
      intentos: 0,
      showDocModal: false,
      docType: 'admin'
    };
  },
  mounted() {
    this.fetchEjercicioMinMax();
    const lastUser = sessionService.getUltimoUsuario();
    if (lastUser) {
      this.form.usuario = lastUser;
    }
  },
  methods: {
    async fetchEjercicioMinMax() {
      try {
        const response = await apiService.execute(
          'sp_acceso_ejercicio_minmax',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
        if (response.success && response.data && response.data.result) {
          const result = response.data.result;
          if (result && result.length > 0) {
            this.minEjercicio = result[0].min_ejercicio || 2003;
            this.maxEjercicio = result[0].max_ejercicio || new Date().getFullYear();
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
        this.minEjercicio = 2003;
        this.maxEjercicio = new Date().getFullYear();
      }
    },
    async onSubmit() {
      this.error = '';
      this.loading = true;
      try {
        const response = await apiService.execute(
          'sp_acceso_login',
          'mercados',
          [
            { nombre: 'p_usuario', valor: this.form.usuario, tipo: 'string' },
            { nombre: 'p_contrasena', valor: this.form.contrasena, tipo: 'string' },
            { nombre: 'p_ejercicio', valor: this.form.ejercicio, tipo: 'integer' }
          ],
          '',
          null,
          'publico'
        );
        if (response.success && response.data && response.data.result) {
          const result = response.data.result;
          if (result && result.length > 0 && result[0].success) {
            const userData = result[0];
            sessionService.setSession(
              {
                usuario: userData.usuario || this.form.usuario,
                id_usuario: userData.id_usuario,
                nivel: userData.nivel,
                sistema: 'mercados'
              },
              this.form.ejercicio
            );
            await this.cargarPermisos(userData.usuario || this.form.usuario);
            console.log('Login exitoso (Mercados):', sessionService.getSessionInfo());
            this.$router.push('/mercados');
          } else {
            this.intentos++;
            if (this.intentos >= 3) {
              this.error = 'Ha excedido el numero de intentos. Contacte al administrador.';
              setTimeout(() => {
                this.form.usuario = '';
                this.form.contrasena = '';
                this.intentos = 0;
                this.error = '';
              }, 3000);
            } else {
              const message = result && result[0] && result[0].message
                ? result[0].message
                : 'Usuario o contrasena incorrectos';
              this.error = message + ' (Intento ' + this.intentos + ' de 3)';
            }
          }
        } else {
          this.intentos++;
          this.error = response.message || 'Error al validar credenciales';
        }
      } catch (error) {
        console.error('Error en login:', error);
        if (error.statusCode) {
          this.error = error.message || 'Error al conectar con el servidor';
        } else if (error.originalError && error.originalError.request) {
          this.error = 'No se pudo conectar con el servidor. Verifique su conexion.';
        } else {
          this.error = error.message || 'Error al procesar la solicitud';
        }
        this.intentos++;
      } finally {
        this.loading = false;
      }
    },
    async cargarPermisos(usuario) {
      try {
        const response = await apiService.execute(
          'sp_get_permisos_mercados',
          'mercados',
          [{ nombre: 'p_usuario', valor: usuario, tipo: 'string' }],
          '',
          null,
          'publico'
        );
        if (response.success && response.data && response.data.result) {
          const permisos = response.data.result || [];
          sessionStorage.setItem('permisos_mercados', JSON.stringify(permisos));
          console.log('Permisos cargados: ' + permisos.length + ' modulos disponibles');
        }
      } catch (error) {
        console.error('Error al cargar permisos:', error);
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
