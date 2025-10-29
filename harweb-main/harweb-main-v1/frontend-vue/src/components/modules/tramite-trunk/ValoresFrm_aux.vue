<template>
  <div class="valores-aux-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Valores Auxiliares</li>
      </ol>
    </nav>
    <h2>Valores Auxiliares</h2>
    <form @submit.prevent="onSubmit" class="mb-4">
      <div class="row mb-2">
        <div class="col-md-2">
          <label class="form-label"><b>Año efectos</b></label>
          <input type="number" class="form-control" v-model="form.axoefec" :disabled="isEditing" required />
        </div>
        <div class="col-md-2">
          <label class="form-label"><b>Bimestre efectos</b></label>
          <input type="number" class="form-control" v-model="form.bimefec" :disabled="isEditing" required />
        </div>
        <div class="col-md-2">
          <label class="form-label"><b>Valor Fiscal</b></label>
          <input type="number" step="0.01" class="form-control" v-model="form.valfiscal" required />
        </div>
        <div class="col-md-1">
          <label class="form-label"><b>Tasa</b></label>
          <input type="number" step="0.01" class="form-control" v-model="form.tasa" required />
        </div>
        <div class="col-md-2">
          <label class="form-label"><b>Año sobretasa</b></label>
          <input type="number" class="form-control" v-model="form.axosobre" />
        </div>
        <div class="col-md-1">
          <label class="form-label"><b>Año hasta</b></label>
          <input type="number" class="form-control" v-model="form.ahasta" />
        </div>
        <div class="col-md-1">
          <label class="form-label"><b>Bim hasta</b></label>
          <input type="number" class="form-control" v-model="form.bhasta" />
        </div>
      </div>
      <div class="mb-2">
        <label class="form-label"><b>Observaciones</b></label>
        <textarea class="form-control" v-model="form.observacion" rows="2"></textarea>
      </div>
      <div class="mb-2">
        <button type="submit" class="btn btn-primary me-2">{{ isEditing ? 'Actualizar' : 'Crear' }}</button>
        <button type="button" class="btn btn-secondary me-2" @click="resetForm">Limpiar</button>
        <button v-if="isEditing" type="button" class="btn btn-danger" @click="onDelete">Eliminar</button>
      </div>
    </form>
    <div class="row mb-2">
      <div class="col-md-6">
        <label><b>Valores modificados</b></label>
        <input type="checkbox" v-model="showModified" class="ms-2" />
      </div>
      <div class="col-md-6">
        <label><b>Valores nuevos</b></label>
        <input type="checkbox" v-model="showNew" class="ms-2" />
      </div>
    </div>
    <div class="table-responsive">
      <table class="table table-bordered table-hover">
        <thead>
          <tr>
            <th>ID</th>
            <th>Año efectos</th>
            <th>Bimestre efectos</th>
            <th>Valor Fiscal</th>
            <th>Tasa</th>
            <th>Año sobretasa</th>
            <th>Año hasta</th>
            <th>Bim hasta</th>
            <th>Observaciones</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in filteredValores" :key="item.id">
            <td>{{ item.id }}</td>
            <td>{{ item.axoefec }}</td>
            <td>{{ item.bimefec }}</td>
            <td>{{ item.valfiscal }}</td>
            <td>{{ item.tasa }}</td>
            <td>{{ item.axosobre }}</td>
            <td>{{ item.ahasta }}</td>
            <td>{{ item.bhasta }}</td>
            <td>{{ item.observacion }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="editItem(item)">Editar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'ValoresAuxPage',
  data() {
    return {
      valores: [],
      form: {
        id: null,
        axoefec: '',
        bimefec: '',
        valfiscal: '',
        tasa: '',
        axosobre: '',
        ahasta: '',
        bhasta: '',
        observacion: ''
      },
      isEditing: false,
      error: '',
      success: '',
      showModified: false,
      showNew: false
    };
  },
  computed: {
    filteredValores() {
      // Simulación de filtros por "modificados" y "nuevos"
      if (this.showModified) {
        return this.valores.filter(v => v.is_modified);
      }
      if (this.showNew) {
        return this.valores.filter(v => v.is_new);
      }
      return this.valores;
    }
  },
  methods: {
    fetchValores() {
      this.error = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'getValoresAuxList',
            params: {}
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.valores = json.eResponse.data.map(v => ({
              ...v,
              is_modified: false, // Simulación
              is_new: false // Simulación
            }));
          } else {
            this.error = json.eResponse.message || 'Error al cargar datos';
          }
        })
        .catch(() => {
          this.error = 'Error de red al cargar valores auxiliares';
        });
    },
    onSubmit() {
      this.error = '';
      this.success = '';
      const action = this.isEditing ? 'updateValoresAux' : 'createValoresAux';
      const params = this.isEditing
        ? { id: this.form.id, data: this.form }
        : { data: this.form };
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action,
            params
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.success = this.isEditing ? 'Registro actualizado' : 'Registro creado';
            this.fetchValores();
            this.resetForm();
          } else {
            this.error = json.eResponse.message || 'Error al guardar';
          }
        })
        .catch(() => {
          this.error = 'Error de red al guardar';
        });
    },
    editItem(item) {
      this.form = { ...item };
      this.isEditing = true;
      this.success = '';
      this.error = '';
    },
    resetForm() {
      this.form = {
        id: null,
        axoefec: '',
        bimefec: '',
        valfiscal: '',
        tasa: '',
        axosobre: '',
        ahasta: '',
        bhasta: '',
        observacion: ''
      };
      this.isEditing = false;
      this.success = '';
      this.error = '';
    },
    onDelete() {
      if (!this.form.id) return;
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'deleteValoresAux',
            params: { id: this.form.id }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.success = 'Registro eliminado';
            this.fetchValores();
            this.resetForm();
          } else {
            this.error = json.eResponse.message || 'Error al eliminar';
          }
        })
        .catch(() => {
          this.error = 'Error de red al eliminar';
        });
    }
  },
  mounted() {
    this.fetchValores();
  }
};
</script>

<style scoped>
.valores-aux-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
