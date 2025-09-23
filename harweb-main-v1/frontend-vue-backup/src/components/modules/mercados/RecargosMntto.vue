<template>
  <div class="recargos-mntto-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Recargos Mantenimiento</li>
      </ol>
    </nav>
    <h1>Recargos de Mantenimiento</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="axo">Año</label>
          <input type="number" v-model.number="form.axo" min="1994" max="2999" class="form-control" id="axo" required />
        </div>
        <div class="form-group col-md-2">
          <label for="periodo">Periodo</label>
          <input type="number" v-model.number="form.periodo" min="1" max="12" class="form-control" id="periodo" required />
        </div>
        <div class="form-group col-md-3">
          <label for="porcentaje">Porcentaje</label>
          <input type="number" v-model.number="form.porcentaje" step="0.01" min="0.01" max="99" class="form-control" id="porcentaje" required />
        </div>
      </div>
      <div class="form-row mt-3">
        <button type="submit" class="btn btn-primary mr-2">{{ editMode ? 'Actualizar' : 'Agregar' }}</button>
        <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
      </div>
      <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
    </form>
    <hr />
    <h2>Listado de Recargos</h2>
    <table class="table table-striped table-bordered mt-2">
      <thead>
        <tr>
          <th>Año</th>
          <th>Periodo</th>
          <th>Porcentaje</th>
          <th>Fecha Alta</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="rec in recargos" :key="rec.axo + '-' + rec.periodo">
          <td>{{ rec.axo }}</td>
          <td>{{ rec.periodo }}</td>
          <td>{{ rec.porcentaje }}</td>
          <td>{{ rec.fecha_alta | formatDate }}</td>
          <td>{{ rec.usuario }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="editRecargo(rec)">Editar</button>
          </td>
        </tr>
        <tr v-if="recargos.length === 0">
          <td colspan="6" class="text-center">No hay recargos registrados.</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RecargosMnttoPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        periodo: 1,
        porcentaje: null
      },
      editMode: false,
      recargos: [],
      message: '',
      success: true,
      editingKey: null
    };
  },
  created() {
    this.fetchRecargos();
  },
  methods: {
    fetchRecargos() {
      axios.post('/api/execute', { action: 'list_recargos' })
        .then(res => {
          if (res.data.success) {
            this.recargos = res.data.data;
          } else {
            this.message = res.data.message;
            this.success = false;
          }
        });
    },
    onSubmit() {
      const action = this.editMode ? 'update_recargo' : 'insert_recargo';
      const params = { ...this.form, id_usuario: 1 };
      axios.post('/api/execute', { action, params })
        .then(res => {
          this.message = res.data.message;
          this.success = res.data.success;
          if (res.data.success) {
            this.fetchRecargos();
            this.resetForm();
          }
        });
    },
    editRecargo(rec) {
      this.form.axo = rec.axo;
      this.form.periodo = rec.periodo;
      this.form.porcentaje = rec.porcentaje;
      this.editMode = true;
      this.editingKey = rec.axo + '-' + rec.periodo;
    },
    resetForm() {
      this.form = {
        axo: new Date().getFullYear(),
        periodo: 1,
        porcentaje: null
      };
      this.editMode = false;
      this.editingKey = null;
      this.message = '';
    }
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.recargos-mntto-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
