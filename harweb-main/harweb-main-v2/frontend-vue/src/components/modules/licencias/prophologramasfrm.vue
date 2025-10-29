<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Propietarios de Hologramas</li>
      </ol>
    </nav>
    <h2 class="mb-4">Propietarios de Hologramas</h2>
    <div v-if="!showForm">
      <div class="mb-2">
        <button class="btn btn-primary mr-2" @click="onAdd">Agregar</button>
        <button class="btn btn-secondary mr-2" :disabled="!selectedRow" @click="onEdit">Modificar</button>
        <button class="btn btn-danger mr-2" :disabled="!selectedRow" @click="onDelete">Borrar</button>
      </div>
      <table class="table table-bordered table-hover">
        <thead class="thead-light">
          <tr>
            <th>Clave</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Colonia</th>
            <th>Telefono(s)</th>
            <th>RFC</th>
            <th>CURP</th>
            <th>E-mail</th>
            <th>Fecha</th>
            <th>Capturista</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.idcontrib" :class="{ 'table-active': selectedRow && selectedRow.idcontrib === row.idcontrib }" @click="selectRow(row)">
            <td>{{ row.idcontrib }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.colonia }}</td>
            <td>{{ row.telefono }}</td>
            <td>{{ row.rfc }}</td>
            <td>{{ row.curp }}</td>
            <td>{{ row.email }}</td>
            <td>{{ formatDate(row.feccap) }}</td>
            <td>{{ row.capturista }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>
    </div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="form-row">
          <div class="form-group col-md-12">
            <label>Nombre</label>
            <input type="text" class="form-control" v-model="form.nombre" required @input="toUpper('nombre')">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-12">
            <label>Domicilio</label>
            <input type="text" class="form-control" v-model="form.domicilio" required @input="toUpper('domicilio')">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-12">
            <label>Colonia</label>
            <input type="text" class="form-control" v-model="form.colonia" @input="toUpper('colonia')">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-4">
            <label>Telefono(s)</label>
            <input type="text" class="form-control" v-model="form.telefono" @input="toUpper('telefono')">
          </div>
          <div class="form-group col-md-4">
            <label>RFC</label>
            <input type="text" class="form-control" v-model="form.rfc" @input="toUpper('rfc')">
          </div>
          <div class="form-group col-md-4">
            <label>CURP</label>
            <input type="text" class="form-control" v-model="form.curp" @input="toUpper('curp')">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-6">
            <label>E-mail</label>
            <input type="email" class="form-control" v-model="form.email">
          </div>
          <div class="form-group col-md-6">
            <label>Capturista</label>
            <input type="text" class="form-control" v-model="form.capturista" required @input="toUpper('capturista')">
          </div>
        </div>
        <div class="form-group mt-3">
          <button type="submit" class="btn btn-success mr-2">Aceptar</button>
          <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
        </div>
        <div v-if="formError" class="alert alert-danger">{{ formError }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropHologramasPage',
  data() {
    return {
      rows: [],
      selectedRow: null,
      showForm: false,
      isEdit: false,
      form: {
        idcontrib: null,
        nombre: '',
        domicilio: '',
        colonia: '',
        telefono: '',
        rfc: '',
        curp: '',
        email: '',
        capturista: ''
      },
      error: '',
      formError: ''
    };
  },
  created() {
    this.fetchRows();
  },
  methods: {
    async fetchRows() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.get_contribholog_list',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.rows = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar datos';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    onAdd() {
      this.showForm = true;
      this.isEdit = false;
      this.form = {
        idcontrib: null,
        nombre: '',
        domicilio: '',
        colonia: '',
        telefono: '',
        rfc: '',
        curp: '',
        email: '',
        capturista: ''
      };
      this.formError = '';
    },
    onEdit() {
      if (!this.selectedRow) return;
      this.showForm = true;
      this.isEdit = true;
      this.form = { ...this.selectedRow };
      this.formError = '';
    },
    async onDelete() {
      if (!this.selectedRow) return;
      if (confirm('¿Está seguro de borrar el registro?')) {
        try {
          const res = await this.$axios.post('/api/execute', {
            action: 'licencias2.delete_contribholog',
            payload: { idcontrib: this.selectedRow.idcontrib }
          });
          if (res.data.status === 'success') {
            this.fetchRows();
            this.selectedRow = null;
          } else {
            this.error = res.data.message || 'Error al borrar';
          }
        } catch (error) {
          this.error = 'Error de conexión con el servidor';
        }
      }
    },
    async onSubmit() {
      this.formError = '';
      const action = this.isEdit ? 'licencias2.update_contribholog' : 'licencias2.insert_contribholog';
      const payload = { ...this.form };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: action,
          payload: payload
        });
        if (res.data.status === 'success') {
          this.showForm = false;
          this.fetchRows();
          this.selectedRow = null;
        } else {
          this.formError = res.data.message || 'Error al guardar';
        }
      } catch (error) {
        this.formError = 'Error de conexión con el servidor';
      }
    },
    onCancel() {
      this.showForm = false;
      this.formError = '';
    },
    toUpper(field) {
      if (this.form[field]) {
        this.form[field] = this.form[field].toUpperCase();
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.table-active {
  background-color: #e9ecef;
}
</style>
