<template>
  <div class="container mt-4">
    <h2>Mantenimiento de Intereses</h2>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Intereses Mtto</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Listado de Intereses</div>
      <div class="card-body p-2">
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th>Año</th>
              <th>Mes</th>
              <th>Porcentaje</th>
              <th>Usuario</th>
              <th>Fecha Actualización</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in intereses" :key="row.axo + '-' + row.mes">
              <td>{{ row.axo }}</td>
              <td>{{ row.mes }}</td>
              <td>{{ row.porcentaje }}</td>
              <td>{{ row.id_usuario }}</td>
              <td>{{ row.fecha_actual }}</td>
              <td>
                <button class="btn btn-sm btn-primary" @click="editRow(row)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteRow(row)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="intereses.length === 0">
              <td colspan="6" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="card">
      <div class="card-header">{{ formMode === 'create' ? 'Agregar' : 'Editar' }} Interés</div>
      <div class="card-body">
        <form @submit.prevent="submitForm">
          <div class="row">
            <div class="col-md-3">
              <label>Año</label>
              <input type="number" class="form-control" v-model.number="form.axo" :readonly="formMode==='edit'" min="1995" max="2100" required />
            </div>
            <div class="col-md-3">
              <label>Mes</label>
              <input type="number" class="form-control" v-model.number="form.mes" :readonly="formMode==='edit'" min="1" max="12" required />
            </div>
            <div class="col-md-3">
              <label>Porcentaje</label>
              <input type="number" class="form-control" v-model.number="form.porcentaje" step="0.00000001" min="0.01" required />
            </div>
            <div class="col-md-3">
              <label>Usuario</label>
              <input type="number" class="form-control" v-model.number="form.id_usuario" required />
            </div>
          </div>
          <div class="mt-3">
            <button type="submit" class="btn btn-success">{{ formMode === 'create' ? 'Agregar' : 'Actualizar' }}</button>
            <button type="button" class="btn btn-secondary ml-2" @click="resetForm">Cancelar</button>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
        <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InteresesMttoPage',
  data() {
    return {
      intereses: [],
      form: {
        axo: '',
        mes: '',
        porcentaje: '',
        id_usuario: ''
      },
      formMode: 'create',
      error: '',
      success: ''
    };
  },
  mounted() {
    this.fetchIntereses();
  },
  methods: {
    async fetchIntereses() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'interesesmtto.list' })
        });
        const data = await res.json();
        if (data.success) {
          this.intereses = data.data;
        } else {
          this.error = data.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async submitForm() {
      this.error = '';
      this.success = '';
      let action = this.formMode === 'create' ? 'interesesmtto.create' : 'interesesmtto.update';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params: this.form })
        });
        const data = await res.json();
        if (data.success) {
          this.success = 'Operación exitosa';
          this.fetchIntereses();
          this.resetForm();
        } else {
          this.error = data.message || 'Error en la operación';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    editRow(row) {
      this.form = {
        axo: row.axo,
        mes: row.mes,
        porcentaje: row.porcentaje,
        id_usuario: row.id_usuario
      };
      this.formMode = 'edit';
      this.error = '';
      this.success = '';
    },
    async deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'interesesmtto.delete', params: { axo: row.axo, mes: row.mes } })
        });
        const data = await res.json();
        if (data.success) {
          this.success = 'Registro eliminado';
          this.fetchIntereses();
        } else {
          this.error = data.message || 'Error al eliminar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    resetForm() {
      this.form = { axo: '', mes: '', porcentaje: '', id_usuario: '' };
      this.formMode = 'create';
      this.error = '';
      this.success = '';
    }
  }
};
</script>

<style scoped>
.container { max-width: 900px; }
.card { margin-bottom: 1rem; }
</style>
