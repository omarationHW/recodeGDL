<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Aut Carga Pagos Mtto</h1>
        <p>Mercados - Gestión de Pagos</p>
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
      <div class="aut-carga-pagos-mtto-page">
          <h1>Autorizar Fecha de Ingreso</h1>
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Autorizar Fecha de Ingreso
          </div>
          <form @submit.prevent="onSubmit">
            <div class="form-group">
              <label for="fecha_ingreso">Fecha Ingreso</label>
              <input type="date" v-model="form.fecha_ingreso" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label for="autorizar">Permiso</label>
              <select v-model="form.autorizar" class="municipal-form-control" required>
                <option value="S">AUTORIZAR FECHA</option>
                <option value="N">BLOQUEAR FECHA</option>
              </select>
            </div>
            <div class="form-group">
              <label for="fecha_limite">Fecha Límite</label>
              <input type="date" v-model="form.fecha_limite" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label for="id_usupermiso">Usuario Permiso</label>
              <select v-model="form.id_usupermiso" class="municipal-form-control" required>
                <option value="">Seleccione un usuario...</option>
                <option v-for="user in users" :key="user.id_usuario" :value="user.id_usuario">
                  {{ user.nombre }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="comentarios">Comentario</label>
              <textarea v-model="form.comentarios" @input="toUpperCase" rows="4" class="municipal-form-control"></textarea>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn-municipal-primary">Aceptar</button>
              <button type="button" class="btn-municipal-secondary" @click="onCancel">Cancelar</button>
            </div>
          </form>
          <hr />
          <h2>Fechas Autorizadas</h2>
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Fecha Ingreso</th>
                <th>Permiso</th>
                <th>Fecha Límite</th>
                <th>Usuario Permiso</th>
                <th>Comentario</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in fechas" :key="item.fecha_ingreso" class="row-hover">
                <td>{{ item.fecha_ingreso }}</td>
                <td>{{ item.autorizar === 'S' ? 'AUTORIZAR' : 'BLOQUEAR' }}</td>
                <td>{{ item.fecha_limite }}</td>
                <td>{{ item.nombre }}</td>
                <td>{{ item.comentarios }}</td>
                <td>
                  <button @click="onEdit(item)" class="btn btn-sm btn-warning">Editar</button>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
          <div v-if="success" class="alert alert-success">{{ success }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'AutCargaPagosMtto'"
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
  name: 'AutCargaPagosMttoPage',
  data() {
    return {
      form: {
        fecha_ingreso: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      users: [],
      fechas: [],
      editing: false,
      oficina: null, // Puede venir de store o props
      error: '',
      success: ''
    };
  },
  created() {
    // Suponiendo que la oficina viene del usuario autenticado
    this.oficina = 1; // Valor por defecto sin store
    this.loadUsers();
    this.loadFechas();
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
    async loadUsers() {
      // Simulamos datos de usuarios
      setTimeout(() => {
        this.users = [
          { id_usuario: 1, nombre: 'Juan Pérez' },
          { id_usuario: 2, nombre: 'María García' },
          { id_usuario: 3, nombre: 'Carlos López' }
        ];
      }, 200);
    },
    async loadFechas() {
      // Simulamos datos de fechas autorizadas
      setTimeout(() => {
        this.fechas = [
          {
            fecha_ingreso: '2024-01-15',
            autorizar: 'S',
            fecha_limite: '2024-01-30',
            nombre: 'Juan Pérez',
            comentarios: 'AUTORIZACIÓN MENSUAL PARA PAGOS DE LOCALES'
          },
          {
            fecha_ingreso: '2024-01-10',
            autorizar: 'N', 
            fecha_limite: '2024-01-25',
            nombre: 'María García',
            comentarios: 'FECHA BLOQUEADA PARA REVISIÓN'
          }
        ];
      }, 300);
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      // Validación básica
      if (!this.form.fecha_ingreso || !this.form.fecha_limite || !this.form.id_usupermiso) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      
      // Simulamos el envío
      setTimeout(() => {
        const userName = this.users.find(u => u.id_usuario == this.form.id_usupermiso)?.nombre || 'Usuario';
        
        if (this.editing) {
          // Actualizar registro existente
          const index = this.fechas.findIndex(f => f.fecha_ingreso === this.form.fecha_ingreso);
          if (index !== -1) {
            this.fechas[index] = {
              ...this.form,
              nombre: userName
            };
          }
          this.success = 'Actualizado correctamente';
        } else {
          // Agregar nuevo registro
          this.fechas.push({
            ...this.form,
            nombre: userName
          });
          this.success = 'Registrado correctamente';
        }
        
        this.onCancel();
      }, 500);
    },
    onEdit(item) {
      this.form = {
        fecha_ingreso: item.fecha_ingreso,
        autorizar: item.autorizar,
        fecha_limite: item.fecha_limite,
        id_usupermiso: item.id_usupermiso,
        comentarios: item.comentarios
      };
      this.editing = true;
      this.success = '';
      this.error = '';
    },
    onCancel() {
      this.form = {
        fecha_ingreso: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: ''
      };
      this.editing = false;
      this.error = '';
      this.success = '';
    },
    toUpperCase(e) {
      this.form.comentarios = this.form.comentarios.toUpperCase();
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
