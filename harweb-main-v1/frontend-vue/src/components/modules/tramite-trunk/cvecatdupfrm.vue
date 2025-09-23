<template>
  <div class="cvecatdup-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Claves Catastrales Duplicadas</li>
      </ol>
    </nav>
    <h2>Claves Catastrales Duplicadas</h2>
    <div class="mb-3">
      <form @submit.prevent="fetchList">
        <div class="form-row align-items-end">
          <div class="col-auto">
            <label for="cvecatnva">Clave Catastral</label>
            <input v-model="filter.cvecatnva" id="cvecatnva" class="form-control" maxlength="11" placeholder="Buscar por clave...">
          </div>
          <div class="col-auto">
            <button type="submit" class="btn btn-primary">Buscar</button>
          </div>
          <div class="col-auto">
            <button type="button" class="btn btn-success" @click="showAdd = true">Agregar</button>
          </div>
        </div>
      </form>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-else>
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th class="text-center">Recaudadora</th>
            <th class="text-center">U/R</th>
            <th class="text-center">Cuenta</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.recaud + '-' + row.urbrus + '-' + row.cuenta">
            <td class="text-center">{{ row.recaud }}</td>
            <td class="text-center">{{ row.urbrus }}</td>
            <td class="text-center">{{ row.cuenta }}</td>
            <td class="text-center">
              <button class="btn btn-danger btn-sm" @click="deleteRow(row)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="rows.length === 0">
            <td colspan="4" class="text-center">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showAdd" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Agregar Clave Duplicada</h5>
            <button type="button" class="close" @click="showAdd = false">&times;</button>
          </div>
          <form @submit.prevent="addRow">
            <div class="modal-body">
              <div class="form-group">
                <label>Recaudadora</label>
                <input v-model.number="form.recaud" type="number" class="form-control" required min="1">
              </div>
              <div class="form-group">
                <label>U/R</label>
                <input v-model="form.urbrus" type="text" class="form-control" maxlength="1" required>
              </div>
              <div class="form-group">
                <label>Cuenta</label>
                <input v-model.number="form.cuenta" type="number" class="form-control" required min="1">
              </div>
              <div class="form-group">
                <label>Clave Catastral</label>
                <input v-model="form.cvecatnva" type="text" class="form-control" maxlength="11" required>
              </div>
            </div>
            <div class="modal-footer">
              <button type="submit" class="btn btn-success">Agregar</button>
              <button type="button" class="btn btn-secondary" @click="showAdd = false">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CveCatDupPage',
  data() {
    return {
      filter: { cvecatnva: '' },
      rows: [],
      loading: false,
      error: '',
      success: '',
      showAdd: false,
      form: {
        recaud: '',
        urbrus: '',
        cuenta: '',
        cvecatnva: ''
      }
    };
  },
  mounted() {
    this.fetchList();
  },
  methods: {
    async fetchList() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getCveCatDupList',
            params: { cvecatnva: this.filter.cvecatnva }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.rows = json.data;
        } else {
          this.error = json.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async addRow() {
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'addCveCatDup',
            params: { ...this.form }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.success = 'Registro agregado correctamente';
          this.showAdd = false;
          this.form = { recaud: '', urbrus: '', cuenta: '', cvecatnva: '' };
          this.fetchList();
        } else {
          this.error = json.message || 'Error al agregar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'deleteCveCatDup',
            params: {
              recaud: row.recaud,
              urbrus: row.urbrus,
              cuenta: row.cuenta,
              cvecatnva: this.filter.cvecatnva || ''
            }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.success = 'Registro eliminado correctamente';
          this.fetchList();
        } else {
          this.error = json.message || 'Error al eliminar';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.cvecatdup-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem 0;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-dialog {
  background: #fff;
  border-radius: 5px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  min-width: 350px;
}
</style>
