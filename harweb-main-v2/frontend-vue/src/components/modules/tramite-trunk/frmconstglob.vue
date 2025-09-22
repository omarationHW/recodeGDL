<template>
  <div class="frmconstglob-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Construcciones Globales</li>
      </ol>
    </nav>
    <h2>Construcciones Globales</h2>
    <div class="mb-3">
      <label for="cvecatnva">Clave Catastral</label>
      <input v-model="cvecatnva" id="cvecatnva" class="form-control" maxlength="11" @keyup.enter="fetchList" />
      <button class="btn btn-primary mt-2" @click="fetchList">Buscar</button>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="records.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Clave Catastral</th>
            <th>Sub Predio</th>
            <th>No. Bloque</th>
            <th>Año Construcción</th>
            <th>Área Const.</th>
            <th>Clasificación</th>
            <th>Cuenta</th>
            <th>Estructura</th>
            <th>Factor Ajus.</th>
            <th>No. Pisos</th>
            <th>Importe</th>
            <th>Cve. Avalúo</th>
            <th>Vigencia</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in records" :key="row.cvebloque">
            <td>{{ row.cvecatnva }}</td>
            <td>{{ row.subpredio }}</td>
            <td>{{ row.cvebloque }}</td>
            <td>{{ row.axoconst }}</td>
            <td>{{ row.areaconst }}</td>
            <td>{{ row.cveclasif }}</td>
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.estructura }}</td>
            <td>{{ row.factorajus }}</td>
            <td>{{ row.numpisos }}</td>
            <td>{{ row.importe }}</td>
            <td>{{ row.cveavaluo }}</td>
            <td>{{ row.axovig }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="editRow(row)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteRow(row)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showForm">
      <h4>{{ formMode === 'create' ? 'Agregar' : 'Editar' }} Construcción Global</h4>
      <form @submit.prevent="submitForm">
        <div class="row">
          <div class="col-md-4 mb-2">
            <label>No. Bloque</label>
            <input v-model.number="form.cvebloque" type="number" class="form-control" required :readonly="formMode==='update'" />
          </div>
          <div class="col-md-4 mb-2">
            <label>Año Construcción</label>
            <input v-model.number="form.axoconst" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Área Const.</label>
            <input v-model.number="form.areaconst" type="number" class="form-control" required step="0.01" />
          </div>
        </div>
        <div class="row">
          <div class="col-md-4 mb-2">
            <label>Clasificación</label>
            <input v-model.number="form.cveclasif" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Cuenta</label>
            <input v-model.number="form.cvecuenta" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Estructura</label>
            <input v-model.number="form.estructura" type="number" class="form-control" required />
          </div>
        </div>
        <div class="row">
          <div class="col-md-4 mb-2">
            <label>Factor Ajus.</label>
            <input v-model.number="form.factorajus" type="number" class="form-control" required step="0.01" />
          </div>
          <div class="col-md-4 mb-2">
            <label>No. Pisos</label>
            <input v-model.number="form.numpisos" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Importe</label>
            <input v-model.number="form.importe" type="number" class="form-control" required step="0.01" />
          </div>
        </div>
        <div class="row">
          <div class="col-md-4 mb-2">
            <label>Cve. Avalúo</label>
            <input v-model.number="form.cveavaluo" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Vigencia</label>
            <input v-model.number="form.axovig" type="number" class="form-control" required />
          </div>
          <div class="col-md-4 mb-2">
            <label>Estado</label>
            <select v-model="form.vigente" class="form-control" required>
              <option value="V">Vigente</option>
              <option value="C">Cancelado</option>
            </select>
          </div>
        </div>
        <div class="mt-3">
          <button class="btn btn-success" type="submit">Guardar</button>
          <button class="btn btn-secondary" type="button" @click="cancelForm">Cancelar</button>
        </div>
      </form>
    </div>
    <div class="mt-4">
      <button class="btn btn-primary" @click="addNew">Agregar Nueva Construcción</button>
      <button class="btn btn-secondary ml-2" @click="fetchList">Refrescar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FrmConstGlobPage',
  data() {
    return {
      cvecatnva: '',
      records: [],
      loading: false,
      error: '',
      showForm: false,
      formMode: 'create',
      form: {
        cvecatnva: '',
        subpredio: 0,
        cvebloque: '',
        axoconst: '',
        areaconst: '',
        cveclasif: '',
        cvecuenta: '',
        estructura: '',
        factorajus: '',
        numpisos: '',
        importe: '',
        cveavaluo: '',
        axovig: '',
        vigente: 'V'
      }
    };
  },
  methods: {
    fetchList() {
      if (!this.cvecatnva || this.cvecatnva.length < 8) {
        this.error = 'Ingrese una clave catastral válida';
        return;
      }
      this.loading = true;
      this.error = '';
      this.showForm = false;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: 'list',
            params: { cvecatnva: this.cvecatnva }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.records = json.eResponse.data;
          } else {
            this.error = json.eResponse.message;
            this.records = [];
          }
        })
        .catch(e => {
          this.error = e.message;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    addNew() {
      this.formMode = 'create';
      this.form = {
        cvecatnva: this.cvecatnva,
        subpredio: 0,
        cvebloque: '',
        axoconst: '',
        areaconst: '',
        cveclasif: '',
        cvecuenta: '',
        estructura: '',
        factorajus: '',
        numpisos: '',
        importe: '',
        cveavaluo: '',
        axovig: '',
        vigente: 'V'
      };
      this.showForm = true;
    },
    editRow(row) {
      this.formMode = 'update';
      this.form = { ...row };
      this.showForm = true;
    },
    deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: 'delete',
            params: { cvebloque: row.cvebloque }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.fetchList();
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(e => {
          this.error = e.message;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    submitForm() {
      this.loading = true;
      const op = this.formMode === 'create' ? 'create' : 'update';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: op,
            params: this.form
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.showForm = false;
            this.fetchList();
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(e => {
          this.error = e.message;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    cancelForm() {
      this.showForm = false;
    }
  }
};
</script>

<style scoped>
.frmconstglob-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
