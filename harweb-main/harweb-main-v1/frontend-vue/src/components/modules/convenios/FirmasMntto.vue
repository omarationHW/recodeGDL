<template>
  <div class="firmas-mntto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mantenimiento de Firmas</li>
      </ol>
    </nav>
    <h2>Mantenimiento de Firmas</h2>
    <div v-if="!editing">
      <button class="btn btn-primary mb-2" @click="startCreate">Agregar Firma</button>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Recaudadora</th>
            <th>Letras</th>
            <th>Titular</th>
            <th>Cargo Titular</th>
            <th>Recaudador</th>
            <th>Cargo Recaudador</th>
            <th>Testigo 1</th>
            <th>Testigo 2</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="firma in firmas" :key="firma.recaudadora">
            <td>{{ firma.recaudadora }}</td>
            <td>{{ firma.letras }}</td>
            <td>{{ firma.titular }}</td>
            <td>{{ firma.cargotitular }}</td>
            <td>{{ firma.recaudador }}</td>
            <td>{{ firma.cargorecaudador }}</td>
            <td>{{ firma.testigo1 }}</td>
            <td>{{ firma.testigo2 }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="startEdit(firma)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteFirma(firma.recaudadora)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else>
      <form @submit.prevent="saveFirma">
        <div class="row">
          <div class="col-md-2">
            <label>Recaudadora</label>
            <input type="number" class="form-control" v-model.number="form.recaudadora" :readonly="editingMode==='edit'" required />
          </div>
          <div class="col-md-2">
            <label>Letras</label>
            <input type="text" class="form-control" v-model="form.letras" maxlength="3" required />
          </div>
          <div class="col-md-4">
            <label>Titular</label>
            <input type="text" class="form-control" v-model="form.titular" maxlength="100" required />
          </div>
          <div class="col-md-4">
            <label>Cargo Titular</label>
            <input type="text" class="form-control" v-model="form.cargotitular" maxlength="100" required />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-4">
            <label>Recaudador</label>
            <input type="text" class="form-control" v-model="form.recaudador" maxlength="100" required />
          </div>
          <div class="col-md-4">
            <label>Cargo Recaudador</label>
            <input type="text" class="form-control" v-model="form.cargorecaudador" maxlength="100" required />
          </div>
          <div class="col-md-4">
            <label>Primer Testigo</label>
            <input type="text" class="form-control" v-model="form.testigo1" maxlength="100" required />
          </div>
          <div class="col-md-4">
            <label>Segundo Testigo</label>
            <input type="text" class="form-control" v-model="form.testigo2" maxlength="100" required />
          </div>
        </div>
        <div class="mt-3">
          <button type="submit" class="btn btn-success">Guardar</button>
          <button type="button" class="btn btn-secondary" @click="cancelEdit">Cancelar</button>
        </div>
      </form>
    </div>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'FirmasMnttoPage',
  data() {
    return {
      firmas: [],
      editing: false,
      editingMode: 'create', // 'create' or 'edit'
      form: {
        recaudadora: '',
        letras: '',
        titular: '',
        cargotitular: '',
        recaudador: '',
        cargorecaudador: '',
        testigo1: '',
        testigo2: ''
      },
      message: '',
      success: true
    };
  },
  created() {
    this.loadFirmas();
  },
  methods: {
    async loadFirmas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'firmas.list' })
      });
      const data = await res.json();
      if (data.success) {
        this.firmas = data.data;
      } else {
        this.message = data.message;
        this.success = false;
      }
    },
    startCreate() {
      this.editing = true;
      this.editingMode = 'create';
      this.form = {
        recaudadora: '',
        letras: '',
        titular: '',
        cargotitular: '',
        recaudador: '',
        cargorecaudador: '',
        testigo1: '',
        testigo2: ''
      };
      this.message = '';
    },
    startEdit(firma) {
      this.editing = true;
      this.editingMode = 'edit';
      this.form = { ...firma };
      this.message = '';
    },
    async saveFirma() {
      // Validación básica
      for (const k of ['recaudadora','letras','titular','cargotitular','recaudador','cargorecaudador','testigo1','testigo2']) {
        if (!this.form[k]) {
          this.message = 'Todos los campos son obligatorios';
          this.success = false;
          return;
        }
      }
      let action = this.editingMode === 'create' ? 'firmas.create' : 'firmas.update';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params: this.form })
      });
      const data = await res.json();
      this.message = data.message;
      this.success = data.success;
      if (data.success) {
        this.editing = false;
        this.loadFirmas();
      }
    },
    async deleteFirma(recaudadora) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'firmas.delete', params: { recaudadora } })
      });
      const data = await res.json();
      this.message = data.message;
      this.success = data.success;
      if (data.success) {
        this.loadFirmas();
      }
    },
    cancelEdit() {
      this.editing = false;
      this.message = '';
    }
  }
};
</script>

<style scoped>
.firmas-mntto-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
