<template>
  <div class="subtipo-mntto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Catálogo de SubTipos</li>
      </ol>
    </nav>
    <h2>Catálogo de SubTipos</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="tipo">Tipo</label>
              <select v-model="form.tipo" class="form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="t in catalogos.tipos" :key="t.tipo" :value="t.tipo">{{ t.tipo }} - {{ t.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-3">
              <label for="subtipo">SubTipo</label>
              <input v-model.number="form.subtipo" type="number" class="form-control" required :disabled="isEdit" />
            </div>
            <div class="col-md-6">
              <label for="desc_subtipo">Descripción</label>
              <input v-model="form.desc_subtipo" type="text" class="form-control" maxlength="50" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="cuenta_ingreso">Cuenta Ingreso</label>
              <select v-model="form.cuenta_ingreso" class="form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="c in catalogos.cuentas" :key="c.cta_aplicacion" :value="c.cta_aplicacion">{{ c.cta_aplicacion }} - {{ c.descripcion }}</option>
              </select>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <button type="submit" class="btn btn-primary mr-2">{{ isEdit ? 'Actualizar' : 'Agregar' }}</button>
              <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <h5 class="card-title">Listado de SubTipos</h5>
        <table class="table table-striped table-bordered">
          <thead>
            <tr>
              <th>Tipo</th>
              <th>SubTipo</th>
              <th>Descripción</th>
              <th>Cuenta Ingreso</th>
              <th>Usuario</th>
              <th>Fecha Actualización</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.tipo + '-' + row.subtipo">
              <td>{{ row.tipo }}</td>
              <td>{{ row.subtipo }}</td>
              <td>{{ row.desc_subtipo }}</td>
              <td>{{ row.cuenta_ingreso }}</td>
              <td>{{ row.id_usuario }}</td>
              <td>{{ row.fecha_actual | formatDate }}</td>
              <td>
                <button class="btn btn-sm btn-info" @click="editRow(row)">Editar</button>
              </td>
            </tr>
            <tr v-if="rows.length === 0">
              <td colspan="7" class="text-center">Sin registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger']" role="alert" style="margin-top: 1rem;">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'SubTipoMnttoPage',
  data() {
    return {
      rows: [],
      catalogos: {
        tipos: [],
        cuentas: []
      },
      form: {
        tipo: '',
        subtipo: '',
        desc_subtipo: '',
        cuenta_ingreso: '',
        id_usuario: 1 // Simulación, debe venir del login
      },
      isEdit: false,
      alert: {
        message: '',
        success: true
      }
    };
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    }
  },
  created() {
    this.loadCatalogos();
    this.loadRows();
  },
  methods: {
    async api(action, data = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, data } })
      });
      const json = await res.json();
      return json.eResponse;
    },
    async loadCatalogos() {
      const tipos = await this.api('catalog_tipos');
      const cuentas = await this.api('catalog_cuentas');
      this.catalogos.tipos = tipos.data || [];
      this.catalogos.cuentas = cuentas.data || [];
    },
    async loadRows() {
      const resp = await this.api('list');
      this.rows = resp.data || [];
    },
    async onSubmit() {
      this.alert.message = '';
      const action = this.isEdit ? 'update' : 'create';
      const resp = await this.api(action, this.form);
      this.alert.message = resp.message;
      this.alert.success = resp.success;
      if (resp.success) {
        this.loadRows();
        this.resetForm();
      }
    },
    editRow(row) {
      this.form = {
        tipo: row.tipo,
        subtipo: row.subtipo,
        desc_subtipo: row.desc_subtipo,
        cuenta_ingreso: row.cuenta_ingreso,
        id_usuario: row.id_usuario
      };
      this.isEdit = true;
    },
    resetForm() {
      this.form = {
        tipo: '',
        subtipo: '',
        desc_subtipo: '',
        cuenta_ingreso: '',
        id_usuario: 1
      };
      this.isEdit = false;
    }
  }
};
</script>

<style scoped>
.subtipo-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
