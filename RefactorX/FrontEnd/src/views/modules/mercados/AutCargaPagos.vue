<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Aut Carga Pagos</h1>
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
      <div class="aut-carga-pagos-page">
          <h1>Autorizar Carga de Pagos</h1>
          <div class="breadcrumbs">
            <router-link to="/">Inicio</router-link> /
            <span>Autorizar Carga de Pagos</span>
          </div>
          <div class="actions mb-3">
            <button class="btn-municipal-primary" @click="openAdd" :disabled="loading">Agregar</button>
            <button class="btn-municipal-secondary" @click="openEdit" :disabled="!selectedRow || loading">Modificar</button>
            <button class="btn btn-danger" @click="fetchData" :disabled="loading">Refrescar</button>
          </div>
          <div v-if="loading" class="alert alert-info">Cargando...</div>
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Fecha Ingreso</th>
                <th>Autorizar</th>
                <th>Fecha Límite</th>
                <th>Usuario Permiso</th>
                <th>Usuario</th>
                <th>Actualización</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.fecha_ingreso + '-' + row.oficina"
                  :class="{selected: selectedRow && selectedRow.fecha_ingreso === row.fecha_ingreso && selectedRow.oficina === row.oficina}"
                  @click="selectRow(row)" class="row-hover">
                <td>{{ row.fecha_ingreso }}</td>
                <td>{{ row.autorizar === 'S' ? 'Sí' : 'No' }}</td>
                <td>{{ row.fecha_limite }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ row.actualizacion }}</td>
              </tr>
            </tbody>
          </table>
          <div v-if="selectedRow">
            <label>Comentarios:</label>
            <textarea class="municipal-form-control" rows="3" v-model="selectedRow.comentarios" readonly></textarea>
          </div>
          <!-- Modal Bootstrap -->
          <div v-if="showModal" class="modal d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <h5 class="modal-title">{{ modalMode === 'add' ? 'Agregar Autorización' : 'Modificar Autorización' }}</h5>
                  <button type="button" class="btn-close" @click="closeModal"></button>
                </div>
                <div class="modal-body">
                  <form @submit.prevent="submitForm">
                    <div class="mb-2">
                      <label>Fecha Ingreso:</label>
                      <input type="date" v-model="form.fecha_ingreso" required class="municipal-form-control" />
                    </div>
                    <div class="mb-2">
                      <label>Oficina:</label>
                      <input type="number" v-model="form.oficina" required class="municipal-form-control" />
                    </div>
                    <div class="mb-2">
                      <label>Autorizar:</label>
                      <select v-model="form.autorizar" required class="municipal-form-control">
                        <option value="S">Sí</option>
                        <option value="N">No</option>
                      </select>
                    </div>
                    <div class="mb-2">
                      <label>Fecha Límite:</label>
                      <input type="date" v-model="form.fecha_limite" required class="municipal-form-control" />
                    </div>
                    <div class="mb-2">
                      <label>Usuario Permiso (ID):</label>
                      <input type="number" v-model="form.id_usupermiso" required class="municipal-form-control" />
                    </div>
                    <div class="mb-2">
                      <label>Comentarios:</label>
                      <textarea v-model="form.comentarios" class="municipal-form-control"></textarea>
                    </div>
                    <div class="modal-footer">
                      <button class="btn btn-success" type="submit">Guardar</button>
                      <button class="btn-municipal-secondary" type="button" @click="closeModal">Cancelar</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'AutCargaPagos'"
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
  name: 'AutCargaPagosPage',
  data() {
    return {
      rows: [],
      loading: false,
      selectedRow: null,
      showModal: false,
      modalMode: 'add',
      form: {
        fecha_ingreso: '',
        oficina: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }}
    };
  },
  created() {
    this.fetchData();
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
    fetchData() {
      this.loading = true;
      this.selectedRow = null;
      // Simulamos datos para demostrar la funcionalidad
      setTimeout(() => {
        this.rows = [
          {
            fecha_ingreso: '2024-01-15',
            autorizar: 'S',
            fecha_limite: '2024-01-30',
            nombre: 'Juan Pérez',
            usuario: 'jperez',
            actualizacion: '2024-01-15 09:30:00',
            oficina: 1,
            comentarios: 'Autorización para carga mensual de pagos'
          },
          {
            fecha_ingreso: '2024-01-10', 
            autorizar: 'N',
            fecha_limite: '2024-01-25',
            nombre: 'María García',
            usuario: 'mgarcia',
            actualizacion: '2024-01-10 14:15:00',
            oficina: 2,
            comentarios: 'Pendiente de validación de documentos'
          }
        ];
        this.loading = false;
      }, 500);
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    openAdd() {
      this.modalMode = 'add';
      this.form = {
        fecha_ingreso: '',
        oficina: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: ''
      };
      this.showModal = true;
    },
    openEdit() {
      if (!this.selectedRow) return;
      this.modalMode = 'edit';
      this.form = { ...this.selectedRow };
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
    },
    submitForm() {
      this.loading = true;
      // Simulamos la operación
      setTimeout(() => {
        console.log(`${this.modalMode} autorización:`, this.form);
        this.fetchData();
        this.showModal = false;
        this.loading = false;
      }, 1000);
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
