<template>
  <div class="aut-carga-pagos-page">
    <h1>Autorizar Carga de Pagos</h1>
    <div class="breadcrumbs">
      <router-link to="/">Inicio</router-link> /
      <span>Autorizar Carga de Pagos</span>
    </div>
    <div class="actions mb-3">
      <button class="btn btn-primary" @click="openAdd" :disabled="loading">Agregar</button>
      <button class="btn btn-secondary" @click="openEdit" :disabled="!selectedRow || loading">Modificar</button>
      <button class="btn btn-danger" @click="fetchData" :disabled="loading">Refrescar</button>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
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
            @click="selectRow(row)">
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
      <textarea class="form-control" rows="3" v-model="selectedRow.comentarios" readonly></textarea>
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
                <input type="date" v-model="form.fecha_ingreso" required class="form-control" />
              </div>
              <div class="mb-2">
                <label>Oficina:</label>
                <input type="number" v-model="form.oficina" required class="form-control" />
              </div>
              <div class="mb-2">
                <label>Autorizar:</label>
                <select v-model="form.autorizar" required class="form-control">
                  <option value="S">Sí</option>
                  <option value="N">No</option>
                </select>
              </div>
              <div class="mb-2">
                <label>Fecha Límite:</label>
                <input type="date" v-model="form.fecha_limite" required class="form-control" />
              </div>
              <div class="mb-2">
                <label>Usuario Permiso (ID):</label>
                <input type="number" v-model="form.id_usupermiso" required class="form-control" />
              </div>
              <div class="mb-2">
                <label>Comentarios:</label>
                <textarea v-model="form.comentarios" class="form-control"></textarea>
              </div>
              <div class="modal-footer">
                <button class="btn btn-success" type="submit">Guardar</button>
                <button class="btn btn-secondary" type="button" @click="closeModal">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
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
        comentarios: ''
      }
    };
  },
  created() {
    this.fetchData();
  },
  methods: {
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
.aut-carga-pagos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumbs {
  font-size: 0.95em;
  margin-bottom: 1rem;
}
.selected {
  background: #e6f7ff;
}
.actions {
  margin-bottom: 1rem;
}
</style>
