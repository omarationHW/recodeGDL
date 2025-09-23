<template>
  <div class="elaboro-convenio-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Quien elaboró convenio</li>
      </ol>
    </nav>
    <h2>Quien elaboró convenio</h2>
    <div class="mb-3">
      <button class="btn btn-primary me-2" @click="showCreateForm = true">Agregar</button>
      <button class="btn btn-secondary me-2" :disabled="!selectedRow" @click="editSelected">Modificar</button>
      <button class="btn btn-danger" :disabled="!selectedRow" @click="deleteSelected">Eliminar</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Recaudadora</th>
          <th>Titular</th>
          <th>Iniciales Titular</th>
          <th>Elaboró</th>
          <th>Iniciales Elaboró</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.id_control" :class="{selected: selectedRow && selectedRow.id_control === row.id_control}" @click="selectRow(row)">
          <td>{{ row.id_rec }}</td>
          <td>{{ row.titular }}</td>
          <td>{{ row.iniciales_titular }}</td>
          <td>{{ row.elaboro }}</td>
          <td>{{ row.iniciales_elaboro }}</td>
        </tr>
      </tbody>
    </table>

    <!-- Create/Edit Modal -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showCreateForm ? 'Agregar' : 'Modificar' }} Elaboro Convenio</h3>
          <form @submit.prevent="showCreateForm ? create() : update()">
            <div class="mb-2">
              <label>Recaudadora (ID)</label>
              <input type="number" v-model.number="form.id_rec" class="form-control" required />
            </div>
            <div class="mb-2">
              <label>ID Usuario Titular</label>
              <input type="number" v-model.number="form.id_usu_titular" class="form-control" required />
            </div>
            <div class="mb-2">
              <label>Iniciales Titular</label>
              <input type="text" v-model="form.iniciales_titular" class="form-control" maxlength="10" required />
            </div>
            <div class="mb-2">
              <label>ID Usuario Elaboró</label>
              <input type="number" v-model.number="form.id_usu_elaboro" class="form-control" required />
            </div>
            <div class="mb-2">
              <label>Iniciales Elaboró</label>
              <input type="text" v-model="form.iniciales_elaboro" class="form-control" maxlength="10" required />
            </div>
            <div class="mt-3">
              <button type="submit" class="btn btn-success me-2">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ElaboroConvenioPage',
  data() {
    return {
      rows: [],
      selectedRow: null,
      showCreateForm: false,
      showEditForm: false,
      form: {
        id_control: null,
        id_rec: '',
        id_usu_titular: '',
        iniciales_titular: '',
        id_usu_elaboro: '',
        iniciales_elaboro: ''
      },
      loading: false,
      error: ''
    };
  },
  mounted() {
    this.fetchRows();
  },
  methods: {
    async fetchRows() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'list', params: {} })
        });
        const data = await res.json();
        if (data.success) {
          this.rows = data.data;
        } else {
          this.error = data.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    editSelected() {
      if (!this.selectedRow) return;
      this.form = { ...this.selectedRow };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    deleteSelected() {
      if (!this.selectedRow) return;
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', params: { id_control: this.selectedRow.id_control } })
      })
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            this.fetchRows();
            this.selectedRow = null;
          } else {
            this.error = data.message || 'Error al eliminar';
          }
        })
        .catch(e => { this.error = e.message; })
        .finally(() => { this.loading = false; });
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = {
        id_control: null,
        id_rec: '',
        id_usu_titular: '',
        iniciales_titular: '',
        id_usu_elaboro: '',
        iniciales_elaboro: ''
      };
    },
    create() {
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create',
          params: {
            id_rec: this.form.id_rec,
            id_usu_titular: this.form.id_usu_titular,
            iniciales_titular: this.form.iniciales_titular,
            id_usu_elaboro: this.form.id_usu_elaboro,
            iniciales_elaboro: this.form.iniciales_elaboro
          }
        })
      })
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            this.fetchRows();
            this.closeForm();
          } else {
            this.error = data.message || 'Error al crear';
          }
        })
        .catch(e => { this.error = e.message; })
        .finally(() => { this.loading = false; });
    },
    update() {
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'update',
          params: {
            id_control: this.form.id_control,
            id_rec: this.form.id_rec,
            id_usu_titular: this.form.id_usu_titular,
            iniciales_titular: this.form.iniciales_titular,
            id_usu_elaboro: this.form.id_usu_elaboro,
            iniciales_elaboro: this.form.iniciales_elaboro
          }
        })
      })
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            this.fetchRows();
            this.closeForm();
          } else {
            this.error = data.message || 'Error al modificar';
          }
        })
        .catch(e => { this.error = e.message; })
        .finally(() => { this.loading = false; });
    }
  }
};
</script>

<style scoped>
.elaboro-convenio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.selected {
  background: #e3f2fd;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.loading-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255,255,255,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  z-index: 10000;
}
</style>
